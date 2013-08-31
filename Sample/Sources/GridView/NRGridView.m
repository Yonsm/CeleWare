//
//  NRGridView.m
//  Grid
//
//  Created by Louka Desroziers on 05/01/12.

/***********************************************************************************
 *
 * Copyright (c) 2012 Louka Desroziers
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 ***********************************************************************************
 *
 * Referencing this project in your AboutBox is appreciated.
 * Please tell me if you use this class so we can cross-reference our projects.
 *
 ***********************************************************************************/

#import "NRGridView.h"
#import "ObjC/Runtime.h"

@interface NRGridViewHeader : UIView
@property (nonatomic, readonly) UILabel *titleLabel;
@end
@implementation NRGridViewHeader
@synthesize titleLabel = _titleLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) [self setBackgroundColor:[UIColor clearColor]];
    return self;
}
- (UILabel*)titleLabel
{
    if(_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setTextAlignment:UITextAlignmentLeft];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:17.]];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setLineBreakMode:UILineBreakModeTailTruncation];
        [_titleLabel setShadowColor:[UIColor whiteColor]];
        [_titleLabel setShadowOffset:CGSizeMake(0, 1)];
        
        [self addSubview:_titleLabel];
    }
    
    return [[_titleLabel retain] autorelease];
}
static CGFloat const _kNRGridViewHeaderContentPadding = 10.;
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = [self bounds];
    CGRect titleLabelFrame = CGRectMake(_kNRGridViewHeaderContentPadding, 
                                        _kNRGridViewHeaderContentPadding, 
                                        CGRectGetWidth(bounds)-_kNRGridViewHeaderContentPadding*2, 
                                        CGRectGetHeight(bounds)-_kNRGridViewHeaderContentPadding*2);
    [[self titleLabel] setFrame:titleLabelFrame];
}

- (void)dealloc
{
    [_titleLabel release];
    [super dealloc];
}

@end
/** **/


/** **/
@interface NRGridViewSectionLayout : NSObject
@property (nonatomic, assign) NSInteger section, numberOfItems;
@property (nonatomic, assign) CGRect headerFrame, contentFrame, footerFrame;
@property (nonatomic, assign) NRGridViewLayoutStyle layoutStyle;
@property (nonatomic, retain) UIView *headerView, *footerView;
@property (nonatomic, readonly) CGRect sectionFrame;
@end
@implementation NRGridViewSectionLayout
@synthesize section,numberOfItems, headerFrame, contentFrame, footerFrame, layoutStyle;
@synthesize headerView = _headerView;
@synthesize footerView = _footerView;

@dynamic sectionFrame;
- (CGRect)sectionFrame
{
    return CGRectMake(CGRectGetMinX([self headerFrame]), 
                      CGRectGetMinY([self headerFrame]), 
                      (layoutStyle == NRGridViewLayoutStyleVertical
                       ? CGRectGetWidth([self contentFrame])
                       : CGRectGetWidth([self headerFrame])+CGRectGetWidth([self contentFrame])+CGRectGetWidth([self footerFrame])), 
                      (layoutStyle == NRGridViewLayoutStyleVertical
                       ? CGRectGetHeight([self headerFrame]) + CGRectGetHeight([self contentFrame])+CGRectGetHeight([self footerFrame])
                       : CGRectGetHeight([self contentFrame])));
}

- (void)setHeaderView:(UIView *)headerView
{
    if(_headerView != headerView)
    {
        [_headerView removeFromSuperview];
        [_headerView release];
        _headerView = [headerView retain];
    }
}

- (void)setFooterView:(UIView *)footerView
{
    if(_footerView != footerView)
    {
        [_footerView removeFromSuperview];
        [_footerView release];
        _footerView = [footerView retain];
    }
}


- (void)dealloc
{
    [self setHeaderView:nil];
    [self setFooterView:nil];

    [super dealloc];
}

@end
/** **/

static NSString* const _kNRGridViewCellIndexPathKey = @"_indexPath";
@interface NRGridViewCell (NRGridViewCellIndexPathExtension)
- (void)__setIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*)__indexPath;
@end
@implementation NRGridViewCell (NRGridViewCellIndexPathExtension)
- (void)__setIndexPath:(NSIndexPath*)indexPath
{
    objc_setAssociatedObject(self, 
                             &_kNRGridViewCellIndexPathKey, 
                             indexPath, 
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSIndexPath*)__indexPath
{
    return objc_getAssociatedObject(self, &_kNRGridViewCellIndexPathKey);
}
@end

/** **/
@implementation NSIndexPath (NRGridViewIndexPath)
@dynamic itemIndex;
+ (NSIndexPath*)indexPathForItemIndex:(NSInteger)itemIndex
                            inSection:(NSInteger)section
{
    return [NSIndexPath indexPathForRow:itemIndex 
                              inSection:section];
}
- (NSInteger)itemIndex
{
    return [self row];
}

@end
/** **/



static CGFloat const _kNRGridViewDefaultHeaderHeight = 50.; // layout style = vertical
static CGFloat const _kNRGridViewDefaultHeaderWidth = 30.; // layout style = horizontal


@interface NRGridView (/*Private*/) <UIGestureRecognizerDelegate>
- (void)__commonInit;
- (void)__reloadContentSize;

- (NSInteger)__numberOfCellsPerColumnUsingSize:(CGSize)cellSize
                                   layoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                         frame:(CGRect)frame;
- (NSInteger)__numberOfCellsPerLineUsingSize:(CGSize)cellSize
                                   layoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                       frame:(CGRect)frame;

- (BOOL)__hasHeaderInSection:(NSInteger)sectionIndex;
- (CGFloat)__widthForHeaderAtSectionIndex:(NSInteger)sectionIndex
                         usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                    frame:(CGRect)frame;
- (CGFloat)__heightForHeaderAtSectionIndex:(NSInteger)sectionIndex
                          usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                     frame:(CGRect)frame;

- (CGFloat)__widthForContentInSection:(NSInteger)section
                          forCellSize:(CGSize)cellSize
                     usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                frame:(CGRect)frame;
- (CGFloat)__heightForContentInSection:(NSInteger)section
                           forCellSize:(CGSize)cellSize
                      usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                 frame:(CGRect)frame;

- (BOOL)__hasFooterInSection:(NSInteger)sectionIndex;
- (CGFloat)__widthForFooterAtSectionIndex:(NSInteger)sectionIndex
                         usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                    frame:(CGRect)frame;
- (CGFloat)__heightForFooterAtSectionIndex:(NSInteger)sectionIndex
                          usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                     frame:(CGRect)frame;

- (NSArray*)__sectionsInRect:(CGRect)rect;
- (NRGridViewSectionLayout*)__sectionLayoutAtIndex:(NSInteger)section;

- (CGRect)__rectForHeaderInSection:(NSInteger)section
                  usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle;
- (UIView*)__visibleHeaderForSection:(NSInteger)section; // returns a visible header that has already been created.
- (UIView*)__headerForSection:(NSInteger)section; // returns a visible header that has already been created, or creates a new one if applicable.


- (UIView*)__footerForSection:(NSInteger)section;

- (CGRect)__rectForCellAtIndexPath:(NSIndexPath*)indexPath 
                  usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle;
- (void)__throwCellsInReusableQueue:(NSSet*)cellsSet;
- (void)__throwCellInReusableQueue:(NRGridViewCell*)cell;

- (void)__layoutCellsWithLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
       alreadyVisibleCellsIndexPaths:(NSArray*)alreadyVisibleCellsIndexPaths;


@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGestureRecognizer;

- (void)__handleTapGestureRecognition:(UIGestureRecognizer*)tapGestureRecognizer;
- (void)__handleLongPressGestureRecognizer:(UIGestureRecognizer*)tapGestureRecognizer;

@end

@implementation NRGridView
{
    BOOL __needsToReloadContentSize;
}
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize longPressGestureRecognizer = _longPressGestureRecognizer;

@dynamic delegate; // Dynamic because inherited from UIScrollView's delegate property.

@synthesize layoutStyle = _layoutStyle;
@synthesize dataSource = _dataSource;
@synthesize cellSize = _cellSize;
@synthesize longPressOptions = _longPressOptions;

@synthesize gridHeaderView = _gridHeaderView, gridFooterView = _gridFooterView;
@synthesize stickyGridHeaderView = _stickyGridHeaderView, stickyGridFooterView = _stickyGridFooterView;

@dynamic visibleCells, indexPathsForVisibleCells;
@dynamic selectedCellIndexPath/**Deprecated*/;
@synthesize allowsMultipleSelections   = _allowsMultipleSelections;

#pragma mark - Init

- (void)__commonInit
{
    _visibleCellsSet = [[NSMutableSet alloc] init];
    _reusableCellsSet = [[NSMutableSet alloc] init];
    
    [self setAutoresizesSubviews:NO];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setAlwaysBounceVertical:YES];
    [self setLayoutStyle:NRGridViewLayoutStyleVertical];
    [self setCellSize:kNRGridViewDefaultCellSize];
    [self setLongPressOptions:(NRGridViewLongPressUnhighlightUponScroll|NRGridViewLongPressUnhighlightUponAnotherTouch)];
    
    // Tap gesture recognizer
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                    action:@selector(__handleTapGestureRecognition:)];
    [_tapGestureRecognizer setNumberOfTapsRequired:1];
    [_tapGestureRecognizer setNumberOfTouchesRequired:1];
    [_tapGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:_tapGestureRecognizer];
    
    
    // Long press gesture recognizer
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(__handleLongPressGestureRecognizer:)];
    [_longPressGestureRecognizer setDelegate:self];
    [_longPressGestureRecognizer setNumberOfTapsRequired:0];
    [_longPressGestureRecognizer setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:_longPressGestureRecognizer];
}

- (id)initWithLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        [self __commonInit];
        [self setLayoutStyle:layoutStyle];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self __commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self __commonInit];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if(newSuperview)
        [self reloadData];
}

#pragma mark - Getters

- (NSArray*)visibleCells
{
    return [_visibleCellsSet allObjects];
}

- (NSArray*)indexPathsForVisibleCells
{
    return [[_visibleCellsSet allObjects] valueForKeyPath:@"@unionOfObjects.__indexPath"];
}

- (NRGridViewCell*)cellAtIndexPath:(NSIndexPath*)indexPath
{
    NRGridViewCell *cell = nil;
    
    if(indexPath!=nil)
        for(NRGridViewCell* aCell in [self visibleCells])
            if([[aCell __indexPath] isEqual:indexPath]){
                cell = [aCell retain];
                break;
            }
    
    return [cell autorelease];
}

- (NSIndexPath*)indexPathForLongPressuredCell
{
    return [_longPressuredCell __indexPath];
}

- (NSIndexPath*)selectedCellIndexPath { return [self indexPathForSelectedCell]; } /** Deprecated */

- (NSIndexPath*)indexPathForSelectedCell { return [_selectedCellsIndexPaths lastObject]; }
- (NSArray*)indexPathsForSelectedCells { return [NSArray arrayWithArray:_selectedCellsIndexPaths]; }

#pragma mark - Setters

- (void)setFrame:(CGRect)frame
{
    if(CGSizeEqualToSize(frame.size, [self frame].size) == NO && [self superview] != nil)
    {
        [self __reloadContentSizeUsingFrame:frame];
    }
    
    [super setFrame:frame];
}


- (void)setDelegate:(id<NRGridViewDelegate>)delegate
{
    [super setDelegate:delegate];
    
    _gridViewDelegateRespondsTo.willDisplayCell = [delegate respondsToSelector:@selector(gridView:willDisplayCell:atIndexPath:)];
    _gridViewDelegateRespondsTo.willSelectCell = [delegate respondsToSelector:@selector(gridView:willSelectCellAtIndexPath:)];
    _gridViewDelegateRespondsTo.didSelectCell = [delegate respondsToSelector:@selector(gridView:didSelectCellAtIndexPath:)];
    _gridViewDelegateRespondsTo.didLongPressCell = [delegate respondsToSelector:@selector(gridView:didLongPressCellAtIndexPath:)];
    
    _gridViewDelegateRespondsTo.didSelectHeader = [delegate respondsToSelector:@selector(gridView:didSelectHeaderForSection:)];

}

- (void)setDataSource:(id<NRGridViewDataSource>)dataSource
{
    if(_dataSource != dataSource)
    {
        [self willChangeValueForKey:@"dataSource"];
        _dataSource = dataSource;
        
        _gridViewDataSourceRespondsTo.numberOfSections = [dataSource respondsToSelector:@selector(numberOfSectionsInGridView:)];
        
        _gridViewDataSourceRespondsTo.titleForHeader = [dataSource respondsToSelector:@selector(gridView:titleForHeaderInSection:)];
        _gridViewDataSourceRespondsTo.viewForHeader = [dataSource respondsToSelector:@selector(gridView:viewForHeaderInSection:)];
        _gridViewDataSourceRespondsTo.heightForHeader = [dataSource respondsToSelector:@selector(gridView:heightForHeaderInSection:)];
        _gridViewDataSourceRespondsTo.widthForHeader = [dataSource respondsToSelector:@selector(gridView:heightForHeaderInSection:)];

        _gridViewDataSourceRespondsTo.titleForFooter = [dataSource respondsToSelector:@selector(gridView:titleForFooterInSection:)];
        _gridViewDataSourceRespondsTo.viewForFooter = [dataSource respondsToSelector:@selector(gridView:viewForFooterInSection:)];
        _gridViewDataSourceRespondsTo.heightForFooter = [dataSource respondsToSelector:@selector(gridView:heightForFooterInSection:)];
        _gridViewDataSourceRespondsTo.widthForFooter = [dataSource respondsToSelector:@selector(gridView:widthForFooterInSection:)];

        _gridViewDataSourceRespondsTo.hasTranslucentNavigationBar = ([[self dataSource] isKindOfClass:[UIViewController class]] 
                                                                     && [[(UIViewController*)[self dataSource] parentViewController] isKindOfClass:[UINavigationController class]]
                                                                     && [[(UINavigationController*)[(UIViewController*)[self dataSource] parentViewController] navigationBar] isTranslucent]);

        [self didChangeValueForKey:@"dataSource"];
    }
}

- (void)setCellSize:(CGSize)cellSize
{
    if(CGSizeEqualToSize(_cellSize, cellSize) == NO)
    {
        [self willChangeValueForKey:@"cellSize"];
        _cellSize = cellSize;
        
        [self __reloadContentSize];
        [self setNeedsLayout];
        [self didChangeValueForKey:@"cellSize"];
    }
}

- (void)setSelectedCellIndexPath:(NSIndexPath *)selectedCellIndexPath /** Deprecated */
{
    [self selectCellAtIndexPath:selectedCellIndexPath animated:NO];
}

- (void)setAllowsMultipleSelections:(BOOL)allowsMultipleSelections
{
    if(_allowsMultipleSelections != allowsMultipleSelections)
    {
        [self willChangeValueForKey:@"allowsMultipleSelections"];
        
        _allowsMultipleSelections = allowsMultipleSelections;
        
        if([_selectedCellsIndexPaths count]>0 && allowsMultipleSelections == NO)
            [self deselectCellsAtIndexPaths:[self indexPathsForSelectedCells] animated:YES];
        
        [self didChangeValueForKey:@"allowsMultipleSelections"];
    }
}

- (void)setLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    if(_layoutStyle != layoutStyle)
    {
        NSAssert((layoutStyle == NRGridViewLayoutStyleHorizontal || layoutStyle == NRGridViewLayoutStyleVertical),
                 @"%@: incorrect layout style", 
                 NSStringFromClass([self class]));
        
        [self willChangeValueForKey:@"layoutStyle"];
        _layoutStyle = layoutStyle;
        [self didChangeValueForKey:@"layoutStyle"];
        
        [self setAlwaysBounceVertical:(layoutStyle == NRGridViewLayoutStyleVertical)];
        [self setAlwaysBounceHorizontal:(layoutStyle == NRGridViewLayoutStyleHorizontal)];

        if([self dataSource])
        {
            [self __reloadContentSize];
            [self setNeedsLayout];
        }
    }
}


- (void)setGridHeaderView:(UIView *)gridHeaderView sticky:(BOOL)sticky
{
    BOOL needsRelayout = NO;
    
    if(gridHeaderView != _gridHeaderView)
    {
        [self willChangeValueForKey:@"gridHeaderView"];

        [_gridHeaderView removeObserver:self forKeyPath:@"frame"];
        [_gridHeaderView removeFromSuperview];
        [_gridHeaderView release];
        _gridHeaderView = [gridHeaderView retain];
        
        if(gridHeaderView)
        {
            [self addSubview:gridHeaderView];
            [gridHeaderView addObserver:self 
                             forKeyPath:@"frame" 
                                options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
                                context:nil];
        }
        
        if([self superview])
        {
            [self __reloadContentSize];
            needsRelayout = YES;
        }
        
        [self didChangeValueForKey:@"gridHeaderView"];
    }
    
    if(sticky != _stickyGridHeaderView)
    {
        [self willChangeValueForKey:@"stickyGridHeaderView"];
        _stickyGridHeaderView = sticky;
        needsRelayout = ([self superview]!=nil);
        [self didChangeValueForKey:@"stickyGridHeaderView"];
    }
    
    if(needsRelayout)
        [self setNeedsLayout];
}

- (void)setGridFooterView:(UIView *)gridFooterView sticky:(BOOL)sticky
{
    BOOL needsRelayout = NO;
    
    if(gridFooterView != _gridHeaderView)
    {
        [self willChangeValueForKey:@"gridFooterView"];
        
        [_gridFooterView removeObserver:self forKeyPath:@"frame"];
        [_gridFooterView removeFromSuperview];
        [_gridFooterView release];
        _gridFooterView = [gridFooterView retain];
        
        if(gridFooterView)
        {
            [self addSubview:gridFooterView];
            [gridFooterView addObserver:self 
                             forKeyPath:@"frame" 
                                options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
                                context:nil];
            
        }
        
        if([self superview])
        {
            [self __reloadContentSize];
            needsRelayout = YES;
        }
        
        [self didChangeValueForKey:@"gridFooterView"];
    }
    
    if(sticky != _stickyGridFooterView)
    {
        [self willChangeValueForKey:@"stickyGridFooterView"];
        _stickyGridFooterView = sticky;
        needsRelayout = ([self superview]!=nil);
        [self didChangeValueForKey:@"stickyGridFooterView"];
    }
    
    if(needsRelayout)
        [self setNeedsLayout];
}

- (void)setGridHeaderView:(UIView *)gridHeaderView
{
    [self setGridHeaderView:gridHeaderView 
                     sticky:[self isGridHeaderViewSticky]];
}

- (void)setGridFooterView:(UIView *)gridFooterView
{
    [self setGridFooterView:gridFooterView 
                     sticky:[self isGridFooterViewSticky]];
}

- (void)setStickyGridHeaderView:(BOOL)stickyGridHeaderView
{
    [self setGridHeaderView:[self gridHeaderView] 
                     sticky:stickyGridHeaderView];
}

- (void)setStickyGridFooterView:(BOOL)stickyGridFooterView
{
    [self setGridFooterView:[self gridFooterView] 
                     sticky:stickyGridFooterView];
}

#pragma mark - Private Methods

- (NSInteger)__numberOfCellsPerColumnUsingSize:(CGSize)cellSize
                                   layoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                         frame:(CGRect)frame
{
    if(CGRectIsEmpty(frame))
        return 1;
    return (layoutStyle == NRGridViewLayoutStyleHorizontal
            ? floor((CGRectGetHeight(frame) - [self contentInset].top - [self contentInset].bottom)/cellSize.height)
            : NSIntegerMax);
}

- (NSInteger)__numberOfCellsPerLineUsingSize:(CGSize)cellSize
                                 layoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                       frame:(CGRect)frame
{
    if(CGRectIsEmpty(frame))
       return 1;
    return (layoutStyle == NRGridViewLayoutStyleVertical
            ? floor((CGRectGetWidth(frame) - [self contentInset].left - [self contentInset].right)/cellSize.width)
            : NSIntegerMax);
}



- (BOOL)__hasHeaderInSection:(NSInteger)sectionIndex
{
    return ( (_gridViewDataSourceRespondsTo.titleForHeader && [[self dataSource] gridView:self 
                                                                  titleForHeaderInSection:sectionIndex] !=nil)
            || (_gridViewDataSourceRespondsTo.viewForHeader && [[self dataSource] gridView:self 
                                                                    viewForHeaderInSection:sectionIndex] !=nil) );
}


- (CGFloat)__widthForHeaderAtSectionIndex:(NSInteger)sectionIndex
                         usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                    frame:(CGRect)frame
{
    if([self __hasHeaderInSection:sectionIndex] == NO)
        return 0.;
    
    // If layout is horizontal, we set the headerWidth to the default value '_kNRGridViewDefaultHeaderWidth'
    // Otherwise, the headerWidth is set to the width of the grid view
    CGFloat headerWidth = (layoutStyle == NRGridViewLayoutStyleHorizontal 
                           ? _kNRGridViewDefaultHeaderWidth
                           : CGRectGetWidth(frame));
    
    if([self layoutStyle] == NRGridViewLayoutStyleHorizontal
       && _gridViewDataSourceRespondsTo.widthForHeader)
        headerWidth = [[self dataSource] gridView:self 
                          widthForHeaderInSection:sectionIndex];
    
    return headerWidth;
}

- (CGFloat)__heightForHeaderAtSectionIndex:(NSInteger)sectionIndex
                          usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                     frame:(CGRect)frame
{
    if([self __hasHeaderInSection:sectionIndex] == NO)
        return 0.;
    
    // If layout is vertical, we set the headerHeight to the default value '_kNRGridViewDefaultHeaderHeight'
    // Otherwise, the headerHeight is set to the height of the grid view
    CGFloat headerHeight = (layoutStyle == NRGridViewLayoutStyleVertical 
                            ? _kNRGridViewDefaultHeaderHeight
                            : CGRectGetHeight(frame));
    
    if([self layoutStyle] == NRGridViewLayoutStyleVertical
       && _gridViewDataSourceRespondsTo.heightForHeader)
        headerHeight = [[self dataSource] gridView:self 
                          heightForHeaderInSection:sectionIndex];
    
    return headerHeight;
}



- (CGFloat)__widthForContentInSection:(NSInteger)section
                          forCellSize:(CGSize)cellSize
                     usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                frame:(CGRect)frame
{
    return (layoutStyle == NRGridViewLayoutStyleHorizontal
            ? ceil((CGFloat)[[self dataSource] gridView:self 
                                 numberOfItemsInSection:section] / (CGFloat)[self __numberOfCellsPerColumnUsingSize:cellSize 
                                                                                                        layoutStyle:layoutStyle
                                                                                                              frame:frame]) * cellSize.width
            : CGRectGetWidth(frame));
}


- (CGFloat)__heightForContentInSection:(NSInteger)section
                           forCellSize:(CGSize)cellSize
                      usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                 frame:(CGRect)frame
{
    return (layoutStyle == NRGridViewLayoutStyleVertical
            ? ceil((CGFloat)[[self dataSource] gridView:self 
                                 numberOfItemsInSection:section] / (CGFloat)[self __numberOfCellsPerLineUsingSize:cellSize 
                                                                                                      layoutStyle:layoutStyle
                                                                                                            frame:frame]) * cellSize.height 
            : CGRectGetHeight(frame));
}


- (BOOL)__hasFooterInSection:(NSInteger)sectionIndex
{
    return ( (_gridViewDataSourceRespondsTo.titleForFooter && [[self dataSource] gridView:self 
                                                                  titleForFooterInSection:sectionIndex] !=nil)
            || (_gridViewDataSourceRespondsTo.viewForFooter && [[self dataSource] gridView:self 
                                                                    viewForFooterInSection:sectionIndex] !=nil) );
}

- (CGFloat)__widthForFooterAtSectionIndex:(NSInteger)sectionIndex
                         usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                    frame:(CGRect)frame
{
    if([self __hasFooterInSection:sectionIndex] == NO)
        return 0.;
    
    // If layout is horizontal, we set the headerWidth to the default value '_kNRGridViewDefaultHeaderWidth'
    // Otherwise, the headerWidth is set to the width of the grid view
    CGFloat footerWidth = (layoutStyle == NRGridViewLayoutStyleHorizontal 
                           ? _kNRGridViewDefaultHeaderWidth
                           : CGRectGetWidth(frame));
    
    if([self layoutStyle] == NRGridViewLayoutStyleHorizontal
       && _gridViewDataSourceRespondsTo.widthForFooter)
        footerWidth = [[self dataSource] gridView:self 
                          widthForFooterInSection:sectionIndex];
    
    return footerWidth;
}

- (CGFloat)__heightForFooterAtSectionIndex:(NSInteger)sectionIndex
                          usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
                                     frame:(CGRect)frame
{
    if([self __hasFooterInSection:sectionIndex] == NO)
        return 0.;
    
    // If layout is vertical, we set the headerHeight to the default value '_kNRGridViewDefaultHeaderHeight'
    // Otherwise, the headerHeight is set to the height of the grid view
    CGFloat footerHeight = (layoutStyle == NRGridViewLayoutStyleVertical 
                            ? _kNRGridViewDefaultHeaderHeight
                            : CGRectGetHeight(frame));
    
    if([self layoutStyle] == NRGridViewLayoutStyleVertical
       && _gridViewDataSourceRespondsTo.heightForFooter)
        footerHeight = [[self dataSource] gridView:self 
                          heightForFooterInSection:sectionIndex];
    
    return footerHeight;
}


#pragma mark - Visible Sections

- (CGRect)rectForSection:(NSInteger)section
{
    NRGridViewSectionLayout *sectionLayout = [self __sectionLayoutAtIndex:section];
    return [sectionLayout sectionFrame];
}

- (NSArray*)__sectionsInRect:(CGRect)rect
{
    NSMutableArray* sectionsInRect = [[NSMutableArray alloc] init];
    for(NRGridViewSectionLayout *sectionLayout in _sectionLayouts)
    {
        if(CGRectIntersectsRect([sectionLayout sectionFrame], rect))
            [sectionsInRect addObject:sectionLayout];
    }
    return [sectionsInRect autorelease];
}

- (NRGridViewSectionLayout*)__sectionLayoutAtIndex:(NSInteger)section
{
    return (NRGridViewSectionLayout*)[_sectionLayouts objectAtIndex:section];
}


#pragma mark - Section Headers

- (CGRect)rectForHeaderInSection:(NSInteger)section
{
    return [self __rectForHeaderInSection:section 
                         usingLayoutStyle:[self layoutStyle]];;
}

- (CGRect)__rectForHeaderInSection:(NSInteger)section
                  usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    NRGridViewSectionLayout *sectionLayout = [self __sectionLayoutAtIndex:section];
    CGRect sectionHeaderFrame =  [sectionLayout headerFrame];
    
    CGPoint headerOffset = CGPointZero;
    
    if(_gridViewDataSourceRespondsTo.hasTranslucentNavigationBar)
        headerOffset.y += CGRectGetHeight([[(UINavigationController*)[(UIViewController*)[self dataSource] parentViewController] navigationBar] frame]);
    
    
    
    if([self gridHeaderView] != nil && [self isGridHeaderViewSticky] ){
        if(layoutStyle == NRGridViewLayoutStyleVertical){
            headerOffset.y += CGRectGetHeight([[self gridHeaderView] frame]); 
        }
        else if(layoutStyle == NRGridViewLayoutStyleHorizontal){
            headerOffset.x += CGRectGetWidth([[self gridHeaderView] frame]); 
        }
    }
    
    if(layoutStyle == NRGridViewLayoutStyleVertical){
        if(CGRectGetMinY(sectionHeaderFrame) < ([self contentOffset].y + headerOffset.y))
            sectionHeaderFrame.origin.y = ([self contentOffset].y + headerOffset.y);
        if(CGRectGetMaxY(sectionHeaderFrame) > CGRectGetMaxY([sectionLayout contentFrame]))
            sectionHeaderFrame.origin.y = CGRectGetMaxY([sectionLayout contentFrame]) - CGRectGetHeight(sectionHeaderFrame) ;
        
    }else if(layoutStyle == NRGridViewLayoutStyleHorizontal){
        if(CGRectGetMinX(sectionHeaderFrame) < [self contentOffset].x)
            sectionHeaderFrame.origin.x = [self contentOffset].x;
        if(CGRectGetMaxX(sectionHeaderFrame) > CGRectGetMaxX([sectionLayout contentFrame]))
            sectionHeaderFrame.origin.x = CGRectGetMaxX([sectionLayout contentFrame]) - CGRectGetWidth(sectionHeaderFrame) ;
        
    }
    
    return sectionHeaderFrame; 
}

- (UIView*)__visibleHeaderForSection:(NSInteger)section
{
    if([self __hasHeaderInSection:section] == NO)
        return nil;

    UIView *visibleHeader = nil;
    for(NRGridViewSectionLayout *sectionLayout in _sectionLayouts)
    {
        if([sectionLayout section] == section)
        {
            visibleHeader = [[sectionLayout headerView] retain];
            break;
        }
    }
    return [visibleHeader autorelease];
}

- (UIView*)__headerForSection:(NSInteger)section
{
    if([self __hasHeaderInSection:section] == NO)
        return nil;
    
    NRGridViewSectionLayout* sectionLayout = [self __sectionLayoutAtIndex:section];
    UIView *header = [[sectionLayout headerView] retain];
    
    if(header == nil){
        // header needs to be created...
        if(_gridViewDataSourceRespondsTo.viewForHeader)
        {
            header = [[[self dataSource] gridView:self 
                           viewForHeaderInSection:section] retain];
        }
        else if(_gridViewDataSourceRespondsTo.titleForHeader)
        {
            header = [[NRGridViewHeader alloc] initWithFrame:CGRectZero];
            [[(NRGridViewHeader*)header titleLabel] setText:[[self dataSource] gridView:self
                                                                titleForHeaderInSection:section]];
        }
        
        [sectionLayout setHeaderView:header];                    
    }
    
    return [header autorelease];
}



#pragma mark - Section Footers

- (CGRect)rectForFooterInSection:(NSInteger)section
{
    NRGridViewSectionLayout *sectionLayout = [self __sectionLayoutAtIndex:section];        
    return [sectionLayout footerFrame]; 
}


- (UIView*)__visibleFooterForSection:(NSInteger)section
{
    if([self __hasFooterInSection:section] == NO)
        return nil;
    
    UIView *visibleFooter = nil;
    for(NRGridViewSectionLayout *sectionLayout in _sectionLayouts)
    {
        if([sectionLayout section] == section)
        {
            visibleFooter = [[sectionLayout footerView] retain];
            break;
        }
    }
    return [visibleFooter autorelease];
}

- (UIView*)__footerForSection:(NSInteger)section
{
    if([self __hasFooterInSection:section] == NO)
        return nil;
    
    NRGridViewSectionLayout* sectionLayout = [self __sectionLayoutAtIndex:section];
    UIView *footer = [[sectionLayout footerView] retain];
    
    if(footer == nil){
        // header needs to be created...
        if(_gridViewDataSourceRespondsTo.viewForFooter)
        {
            footer = [[[self dataSource] gridView:self 
                           viewForFooterInSection:section] retain];
        }
        else if(_gridViewDataSourceRespondsTo.titleForFooter)
        {
            footer = [[NRGridViewHeader alloc] initWithFrame:CGRectZero];
            [[(NRGridViewHeader*)footer titleLabel] setText:[[self dataSource] gridView:self
                                                                titleForFooterInSection:section]];
        }
        
        [sectionLayout setFooterView:footer];                    
    }
    
    return [footer autorelease];
}


#pragma mark - Cells Stuff

- (CGRect)rectForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return [self __rectForCellAtIndexPath:indexPath
                         usingLayoutStyle:[self layoutStyle]];
}

- (CGRect)__rectForCellAtIndexPath:(NSIndexPath*)indexPath 
                  usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    CGRect cellFrame = CGRectZero;
    cellFrame.size = [self cellSize];

    NRGridViewSectionLayout *sectionLayout = [self __sectionLayoutAtIndex:indexPath.section];
    
    if(layoutStyle == NRGridViewLayoutStyleVertical){
        NSInteger numberOfCellsPerLine = [self __numberOfCellsPerLineUsingSize:[self cellSize]
                                                                   layoutStyle:layoutStyle
                                                                         frame:[self bounds]];
        
        if(numberOfCellsPerLine > 0)
        {
            CGFloat lineWidth = numberOfCellsPerLine*[self cellSize].width;
            
            NSInteger currentLine = (NSInteger)floor(indexPath.itemIndex/numberOfCellsPerLine);
            NSInteger currentColumn = (NSInteger)(indexPath.itemIndex - numberOfCellsPerLine*currentLine);
            
            cellFrame.origin.y = CGRectGetMinY([sectionLayout contentFrame]) + floor([self cellSize].height * currentLine);
            cellFrame.origin.x = floor([self cellSize].width * currentColumn) + floor((CGRectGetWidth([self bounds]) - ([self contentInset].left + [self contentInset].right))/2. - lineWidth/2.);
        }
        
    }else if(layoutStyle == NRGridViewLayoutStyleHorizontal)
    {
        NSInteger numberOfCellsPerColumn = [self __numberOfCellsPerColumnUsingSize:[self cellSize]
                                                                       layoutStyle:layoutStyle
                                                                             frame:[self bounds]];
        
        if(numberOfCellsPerColumn > 0)
        {
            CGFloat columnHeight = numberOfCellsPerColumn*[self cellSize].height;
            
            NSInteger currentColumn = (NSInteger)floor(indexPath.itemIndex/numberOfCellsPerColumn);
            NSInteger currentLine = (NSInteger)(indexPath.itemIndex - numberOfCellsPerColumn*currentColumn);
            
            cellFrame.origin.x = CGRectGetMinX([sectionLayout contentFrame]) + floor([self cellSize].width * currentColumn);
            cellFrame.origin.y = floor([self cellSize].height * currentLine) + floor((CGRectGetHeight([self bounds]) - ([self contentInset].top + [self contentInset].bottom))/2. - columnHeight/2.);
        }
        
    }
    
    return cellFrame;
}


- (void)__throwCellsInReusableQueue:(NSSet*)cellsSet
{
    [cellsSet makeObjectsPerformSelector:@selector(__setIndexPath:) withObject:nil];
    [cellsSet makeObjectsPerformSelector:@selector(removeFromSuperview)];

    [_reusableCellsSet unionSet:cellsSet];
    [_visibleCellsSet minusSet:cellsSet];
}
- (void)__throwCellInReusableQueue:(NRGridViewCell*)cell
{
    [cell __setIndexPath:nil];
    [cell setAlpha:0.];
    [_reusableCellsSet addObject:cell];
    [_visibleCellsSet removeObject:cell];
}


- (NRGridViewCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier
{
    NRGridViewCell* dequeuedCell = nil;
    
    if(identifier != nil){
        NSArray *dequeuableCells = [_reusableCellsSet allObjects];
        NSArray *dequeuableIdentifiers = [dequeuableCells valueForKeyPath:@"@unionOfObjects.reuseIdentifier"];
        NSInteger indexOfIdentifier = [dequeuableIdentifiers indexOfObject:identifier];
        
        if(indexOfIdentifier != NSNotFound)
        {
            dequeuedCell = [[dequeuableCells objectAtIndex:indexOfIdentifier] retain];
            [dequeuedCell setAlpha:1.];
            [dequeuedCell prepareForReuse];
            [_reusableCellsSet removeObject:dequeuedCell];
        }
        
        /** I have commented the follow shorter way to find out a reusable cell because predicates are OVERSLOW.
         *
        NSPredicate *dequeueablePredicate = [NSPredicate predicateWithFormat:@"reuseIdentifier isEqualToString: %@",identifier];
        NSSet *dequeuableSet = [_reusableCellsSet filteredSetUsingPredicate:dequeueablePredicate];
        
        dequeuedCell = [[dequeuableSet anyObject] retain];
        if(dequeuedCell != nil){
            [_reusableCellsSet removeObject:dequeuedCell];
            [dequeuedCell prepareForReuse];
        }
         */
    }
        
    return [dequeuedCell autorelease];
}

#pragma mark - Scrolling

- (void)scrollRectToSection:(NSInteger)section 
                   animated:(BOOL)animated
             scrollPosition:(NRGridViewScrollPosition)scrollPosition
{
    CGRect sectionRect = [self rectForSection:section];
    CGPoint contentOffsetForSection = CGPointZero;
    
    if(scrollPosition == NRGridViewScrollPositionNone 
       && CGRectContainsRect([self bounds], sectionRect))
            return; // no scroll, as specified in NRGridViewScrollPositionNone's description.
    
    if([self layoutStyle] == NRGridViewLayoutStyleVertical)
    {
        if(scrollPosition == NRGridViewScrollPositionNone){
            if(CGRectGetMaxY(sectionRect) > CGRectGetMaxY([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtBottom;
            else if(CGRectGetMinY(sectionRect) < CGRectGetMinY([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtTop;
        }
        
        
        switch (scrollPosition) {
            case NRGridViewScrollPositionAtTop:
                contentOffsetForSection.y = CGRectGetMinY(sectionRect);
                break;
            case NRGridViewScrollPositionAtMiddle:
                contentOffsetForSection.y = floor(CGRectGetMidY(sectionRect) - CGRectGetHeight([self bounds])/2.);
                break;
            case NRGridViewScrollPositionAtBottom:
                contentOffsetForSection.y = CGRectGetMaxY(sectionRect) - CGRectGetHeight([self bounds]);
                break;
            default:
                break;
        }
        
        
        if(contentOffsetForSection.y<0)
            contentOffsetForSection.y = 0;
        else if(contentOffsetForSection.y> [self contentSize].height-CGRectGetHeight([self bounds]))
            contentOffsetForSection.y = [self contentSize].height - CGRectGetHeight([self bounds]);
        
    }else if([self layoutStyle] == NRGridViewLayoutStyleHorizontal)
    {
        if(scrollPosition == NRGridViewScrollPositionNone){
            if(CGRectGetMaxX(sectionRect) > CGRectGetMaxX([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtRight;
            else if(CGRectGetMinX(sectionRect) < CGRectGetMinX([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtLeft;
        }
        
        
        switch (scrollPosition) {
            case NRGridViewScrollPositionAtLeft:
                contentOffsetForSection.x = CGRectGetMinX(sectionRect);
                break;
            case NRGridViewScrollPositionAtMiddle:
                contentOffsetForSection.x = floor(CGRectGetMidX(sectionRect) - CGRectGetWidth([self bounds])/2.);
                break;
            case NRGridViewScrollPositionAtRight:
                contentOffsetForSection.x = CGRectGetMaxX(sectionRect) - CGRectGetWidth([self bounds]);
                break;
            default:
                break;
        }
        
        if(contentOffsetForSection.x<0)
            contentOffsetForSection.x = 0;
        else if(contentOffsetForSection.x > [self contentSize].width - CGRectGetWidth([self bounds]))
            contentOffsetForSection.x = [self contentSize].width - CGRectGetWidth([self bounds]);
    }
      
    [self setContentOffset:contentOffsetForSection animated:animated];
}

- (void)scrollRectToItemAtIndexPath:(NSIndexPath*)indexPath 
                           animated:(BOOL)animated
                     scrollPosition:(NRGridViewScrollPosition)scrollPosition
{
    CGRect itemRect = [self rectForItemAtIndexPath:indexPath];
    CGPoint contentOffsetForItem = CGPointZero;
    
    if(scrollPosition == NRGridViewScrollPositionNone 
       && CGRectContainsRect([self bounds], itemRect))
        return; // no scroll, as specified in NRGridViewScrollPositionNone's description.
    
    if([self layoutStyle] == NRGridViewLayoutStyleVertical)
    {
        contentOffsetForItem.x = [self contentOffset].x;
        
        if(scrollPosition == NRGridViewScrollPositionNone){
            if(CGRectGetMaxY(itemRect) > CGRectGetMaxY([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtBottom;
            else if(CGRectGetMinY(itemRect) < CGRectGetMinY([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtTop;
        }
        
        
        switch (scrollPosition) {
            case NRGridViewScrollPositionAtTop:
                contentOffsetForItem.y = CGRectGetMinY(itemRect);
                break;
            case NRGridViewScrollPositionAtMiddle:
                contentOffsetForItem.y = floor(CGRectGetMidY(itemRect) - CGRectGetHeight([self bounds])/2.);
                break;
            case NRGridViewScrollPositionAtBottom:
                contentOffsetForItem.y = CGRectGetMinY(itemRect) - (CGRectGetHeight([self bounds]) - CGRectGetHeight(itemRect));
                break;
            default:
                break;
        }
        
        
        if(contentOffsetForItem.y<0)
            contentOffsetForItem.y = 0;
        else if(contentOffsetForItem.y > [self contentSize].height - CGRectGetHeight([self bounds]))
            contentOffsetForItem.y = [self contentSize].height - CGRectGetHeight([self bounds]);
        
    }else if([self layoutStyle] == NRGridViewLayoutStyleHorizontal)
    {
        contentOffsetForItem.y = [self contentOffset].y;

        if(scrollPosition == NRGridViewScrollPositionNone){
            if(CGRectGetMaxX(itemRect) > CGRectGetMaxX([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtRight;
            else if(CGRectGetMinX(itemRect) < CGRectGetMinX([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtLeft;
        }
        
        
        switch (scrollPosition) {
            case NRGridViewScrollPositionAtLeft:
                contentOffsetForItem.x = CGRectGetMinX(itemRect);
                break;
            case NRGridViewScrollPositionAtMiddle:
                contentOffsetForItem.x = floor(CGRectGetMidX(itemRect) - CGRectGetWidth([self bounds])/2.);
                break;
            case NRGridViewScrollPositionAtRight:
                contentOffsetForItem.x = CGRectGetMinX(itemRect) - (CGRectGetWidth([self bounds]) - CGRectGetWidth(itemRect));
                break;
            default:
                break;
        }
        
        if(contentOffsetForItem.x<0)
            contentOffsetForItem.x = 0;
        else if(contentOffsetForItem.x > [self contentSize].width - CGRectGetWidth([self bounds]))
            contentOffsetForItem.x = [self contentSize].width - CGRectGetWidth([self bounds]);
    }
    
    [self setContentOffset:contentOffsetForItem animated:animated];
}


#pragma mark - Reloading Content

- (void)__reloadContentSizeUsingFrame:(CGRect)frame
{        
    [_sectionLayouts release], _sectionLayouts=nil;
    _sectionLayouts = [[NSMutableArray alloc] init];
    
    CGSize contentSize = CGSizeZero;
    
    if([self gridHeaderView] != nil){
        if([self layoutStyle] == NRGridViewLayoutStyleVertical){
            contentSize.height += CGRectGetHeight([[self gridHeaderView] frame]);
        }
        else if([self layoutStyle] == NRGridViewLayoutStyleHorizontal){
            contentSize.width += CGRectGetWidth([[self gridHeaderView] frame]);
        }
    }    
    
    NSInteger numberOfSections  = (_gridViewDataSourceRespondsTo.numberOfSections
                                   ? [[self dataSource] numberOfSectionsInGridView:self]
                                   : 1);
    
    for(NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++)
    {        
        NSInteger numberOfCellsInSection = [[self dataSource] gridView:self 
                                                numberOfItemsInSection:sectionIndex];

        NRGridViewSectionLayout *sectionLayout = [[NRGridViewSectionLayout alloc] init];
        [sectionLayout setLayoutStyle:[self layoutStyle]];
        [sectionLayout setSection:sectionIndex];
        [sectionLayout setNumberOfItems:numberOfCellsInSection];
        
        
        CGSize sectionHeaderSize = CGSizeMake([self __widthForHeaderAtSectionIndex:sectionIndex 
                                                                  usingLayoutStyle:[self layoutStyle]
                                                                             frame:frame], 
                                              [self __heightForHeaderAtSectionIndex:sectionIndex
                                                                   usingLayoutStyle:[self layoutStyle]
                                                                              frame:frame]);
        CGSize sectionFooterSize = CGSizeMake([self __widthForFooterAtSectionIndex:sectionIndex 
                                                                  usingLayoutStyle:[self layoutStyle]
                                                                             frame:frame], 
                                              [self __heightForFooterAtSectionIndex:sectionIndex
                                                                   usingLayoutStyle:[self layoutStyle]
                                                                              frame:frame]);
        
        if([self layoutStyle] == NRGridViewLayoutStyleVertical)
        {
            CGFloat contentHeightInSection = [self __heightForContentInSection:sectionIndex 
                                                                   forCellSize:[self cellSize] 
                                                              usingLayoutStyle:[self layoutStyle]
                                                                         frame:frame];
                        
            [sectionLayout setHeaderFrame:CGRectMake(0, 
                                                     contentSize.height, 
                                                     sectionHeaderSize.width, 
                                                     sectionHeaderSize.height)];
            [sectionLayout setContentFrame:CGRectMake(0, 
                                                      CGRectGetMaxY([sectionLayout headerFrame]), 
                                                      CGRectGetWidth(frame), 
                                                      contentHeightInSection)];
            [sectionLayout setFooterFrame:CGRectMake(0, 
                                                     CGRectGetMaxY([sectionLayout contentFrame]), 
                                                     sectionFooterSize.width, 
                                                     sectionFooterSize.height)];

            
            contentSize.height += CGRectGetHeight([sectionLayout sectionFrame]);
            
        }else if([self layoutStyle] == NRGridViewLayoutStyleHorizontal)
        {
            CGFloat contentWidthInSection = [self __widthForContentInSection:sectionIndex 
                                                                 forCellSize:[self cellSize] 
                                                            usingLayoutStyle:[self layoutStyle]
                                                                       frame:frame];
            
            [sectionLayout setHeaderFrame:CGRectMake(contentSize.width, 
                                                     0, 
                                                     sectionHeaderSize.width, 
                                                     sectionHeaderSize.height)];
            [sectionLayout setContentFrame:CGRectMake(CGRectGetMaxX([sectionLayout headerFrame]), 
                                                      0, 
                                                      contentWidthInSection, 
                                                      CGRectGetHeight(frame))];
            [sectionLayout setFooterFrame:CGRectMake(CGRectGetMaxX([sectionLayout contentFrame]), 
                                                     0, 
                                                     sectionFooterSize.width, 
                                                     sectionFooterSize.height)];
            
            contentSize.width += CGRectGetWidth([sectionLayout sectionFrame]);
        }
        
        [_sectionLayouts addObject:sectionLayout];
        [sectionLayout release];
    }
    
    if([self gridFooterView] != nil){
        if([self layoutStyle] == NRGridViewLayoutStyleVertical){
            contentSize.height += CGRectGetHeight([[self gridFooterView] frame]);
        }
        else if([self layoutStyle] == NRGridViewLayoutStyleHorizontal){
            contentSize.width += CGRectGetWidth([[self gridFooterView] frame]);
        }
    }

    
    [self setContentSize:contentSize];
}

- (void)__reloadContentSize
{
    [self __reloadContentSizeUsingFrame:[self bounds]];
}

- (void)reloadData
{
    _gridViewDataSourceRespondsTo.hasTranslucentNavigationBar = ([[self dataSource] isKindOfClass:[UIViewController class]] 
                                                                 && [[(UIViewController*)[self dataSource] parentViewController] isKindOfClass:[UINavigationController class]]
                                                                 && [[(UINavigationController*)[(UIViewController*)[self dataSource] parentViewController] navigationBar] isTranslucent]);
    

    
    [self __reloadContentSize];
    
    [self __throwCellsInReusableQueue:_visibleCellsSet];
    [_selectedCellsIndexPaths release], _selectedCellsIndexPaths = [[NSMutableArray alloc] init];
    
    [[self longPressGestureRecognizer] setEnabled:_gridViewDelegateRespondsTo.didLongPressCell];
    
    [self setNeedsLayout];
}

#pragma mark - Layouting

- (void)setContentOffset:(CGPoint)offset
{
    [super setContentOffset:offset];
    if([self longPressOptions] & NRGridViewLongPressUnhighlightUponScroll)
    {
        [self unhighlightPressuredCellAnimated:YES];
    }
}

- (void)__layoutCellsWithLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
       alreadyVisibleCellsIndexPaths:(NSArray*)alreadyVisibleCellsIndexPaths
{
    UIImageView *verticalScrollIndicator = nil, *horizontalScrollIndicator = nil;
    object_getInstanceVariable(self, "_verticalScrollIndicator", (void*)&verticalScrollIndicator);
    object_getInstanceVariable(self, "_horizontalScrollIndicator", (void*)&horizontalScrollIndicator);

    
    NSArray *visibleSections = [self __sectionsInRect:[self bounds]];
    
    // sections layout that won't be visible
    NSMutableSet *sectionLayoutsOffScreen = [[NSMutableSet alloc] initWithArray:_sectionLayouts];
    [sectionLayoutsOffScreen minusSet:[NSSet setWithArray:visibleSections]];
    [sectionLayoutsOffScreen makeObjectsPerformSelector:@selector(setHeaderView:) withObject:nil];
    [sectionLayoutsOffScreen release];
    /**/
    
    for(NRGridViewSectionLayout *sectionLayout in visibleSections)
    {
        NSInteger sectionIndex = [sectionLayout section];
        CGRect sectionContentFrame = [sectionLayout contentFrame];
        
        UIView *sectionHeaderView = [self __headerForSection:sectionIndex];
        [sectionHeaderView setFrame:[self __rectForHeaderInSection:sectionIndex 
                                                  usingLayoutStyle:layoutStyle]];
        if([sectionHeaderView superview] == nil)
            [self addSubview:sectionHeaderView];
        
        UIView *sectionFooterView = [self __footerForSection:sectionIndex];
        [sectionFooterView setFrame:[self rectForFooterInSection:sectionIndex]];
        if([sectionFooterView superview] == nil)
            [self addSubview:sectionFooterView];
        
        
        
        NSInteger numberOfCellsInSection = [[self dataSource] gridView:self 
                                                numberOfItemsInSection:sectionIndex];
        NSInteger firstVisibleCellIndex=0;
        NSInteger cellIndexesRange=0;
        
        if(layoutStyle == NRGridViewLayoutStyleVertical){
            NSInteger numberOfCellsPerLine = [self __numberOfCellsPerLineUsingSize:[self cellSize]
                                                                       layoutStyle:layoutStyle
                                                                             frame:[self bounds]];
            
            NSInteger firstVisibleLineIndex = floor((CGRectGetMinY([self bounds])-CGRectGetMinY(sectionContentFrame)) / [self cellSize].height);
            if(firstVisibleLineIndex<0)
                firstVisibleLineIndex = 0;
            
            NSInteger lastVisibleLineIndex = floor((CGRectGetMaxY([self bounds])-CGRectGetMinY(sectionContentFrame)) / [self cellSize].height);
            
            firstVisibleCellIndex = firstVisibleLineIndex * numberOfCellsPerLine;
            cellIndexesRange = ((lastVisibleLineIndex+1) * numberOfCellsPerLine) - firstVisibleCellIndex;
            
        }else if(layoutStyle == NRGridViewLayoutStyleHorizontal)
        {
            NSInteger numberOfCellsPerColumn = [self __numberOfCellsPerColumnUsingSize:[self cellSize]
                                                                           layoutStyle:layoutStyle
                                                                                 frame:[self bounds]];
            
            NSInteger firstVisibleColumnIndex = floor((CGRectGetMinX([self bounds])-CGRectGetMinX(sectionContentFrame)) / [self cellSize].width);
            if(firstVisibleColumnIndex<0)
                firstVisibleColumnIndex = 0;
            
            NSInteger lastVisibleColumnIndex = floor((CGRectGetMaxX([self bounds])-CGRectGetMinX(sectionContentFrame)) / [self cellSize].width);
            
            firstVisibleCellIndex = firstVisibleColumnIndex * numberOfCellsPerColumn;
            cellIndexesRange = ((lastVisibleColumnIndex+1) * numberOfCellsPerColumn) - firstVisibleCellIndex;
        }
        
        if(firstVisibleCellIndex + cellIndexesRange > numberOfCellsInSection)
            cellIndexesRange = numberOfCellsInSection - firstVisibleCellIndex;
        if(cellIndexesRange <0)
            cellIndexesRange=0;            
        
        
        NSMutableIndexSet *sectionVisibleContentIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(firstVisibleCellIndex, cellIndexesRange)];
        
        
        [sectionVisibleContentIndexes enumerateIndexesUsingBlock:^(NSUInteger cellIndexInSection, BOOL *stop)
         {
             NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItemIndex:cellIndexInSection 
                                                                   inSection:sectionIndex];    
             
             if([alreadyVisibleCellsIndexPaths containsObject:cellIndexPath] == NO)
             {
                 // insert cell.
                 NRGridViewCell *cell = [[self dataSource] gridView:self 
                                             cellForItemAtIndexPath:cellIndexPath];
                 [cell __setIndexPath:cellIndexPath];
                 [cell setFrame:[self __rectForCellAtIndexPath:cellIndexPath 
                                              usingLayoutStyle:layoutStyle]];                         
                 [cell setSelected:[_selectedCellsIndexPaths containsObject:cellIndexPath]];
                 
                 if(_gridViewDelegateRespondsTo.willDisplayCell)
                     [[self delegate] gridView:self 
                               willDisplayCell:cell 
                                   atIndexPath:cellIndexPath];
                 
                 [self insertSubview:cell atIndex:0];
                 [_visibleCellsSet addObject:cell];
                 
             }
         }];
        
        
    }
    
    [self bringSubviewToFront:verticalScrollIndicator];
    [self bringSubviewToFront:horizontalScrollIndicator];
}   

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(CGRectIsEmpty([self bounds]))
        return;
    
    /** Layout Grid Header View */
    if([self gridHeaderView] != nil)
    {
        CGRect gridHeaderViewFrame = [[self gridHeaderView] frame];
        CGPoint gridHeaderOrigin = CGPointZero;
        
        if([self isGridHeaderViewSticky]){
            gridHeaderOrigin = CGPointMake(([self layoutStyle] == NRGridViewLayoutStyleHorizontal
                                            ? [self contentOffset].x
                                            : 0.),
                                           ([self layoutStyle] == NRGridViewLayoutStyleVertical
                                            ? [self contentOffset].y
                                            : 0.));
        }
        
        if([self layoutStyle] == NRGridViewLayoutStyleVertical){
            gridHeaderViewFrame.size.width = CGRectGetWidth([self bounds]) - ([self contentInset].left + [self contentInset].right);
        }
        else if([self layoutStyle] == NRGridViewLayoutStyleHorizontal){
            gridHeaderViewFrame.size.height = CGRectGetHeight([self bounds]) - ([self contentInset].top + [self contentInset].bottom);
        }
        
        gridHeaderViewFrame.origin = gridHeaderOrigin;
        [[self gridHeaderView] setFrame:gridHeaderViewFrame];
        [self bringSubviewToFront:[self gridHeaderView]];
    }
    
    /** Layout Grid Footer View */
    if([self gridFooterView] != nil)
    {
        CGRect gridFooterViewFrame = [[self gridFooterView] frame];
        CGPoint gridFooterOrigin = CGPointZero;
        
        if([self isGridFooterViewSticky]){
            gridFooterOrigin = CGPointMake(([self layoutStyle] == NRGridViewLayoutStyleHorizontal
                                            ? ([self contentOffset].x + CGRectGetWidth([self bounds]) - CGRectGetWidth(gridFooterViewFrame))
                                            : 0.),
                                           ([self layoutStyle] == NRGridViewLayoutStyleVertical
                                            ? ([self contentOffset].y + CGRectGetHeight([self bounds]) - CGRectGetHeight(gridFooterViewFrame))
                                            : 0.));
        }
        else {
            gridFooterOrigin = CGPointMake(([self layoutStyle] == NRGridViewLayoutStyleHorizontal
                                            ? ([self contentSize].width - CGRectGetWidth(gridFooterViewFrame))
                                            : 0.),
                                           ([self layoutStyle] == NRGridViewLayoutStyleVertical
                                            ? ([self contentSize].height - CGRectGetHeight(gridFooterViewFrame))
                                            : 0.));
        }
        
        if([self layoutStyle] == NRGridViewLayoutStyleVertical){
            gridFooterViewFrame.size.width = CGRectGetWidth([self bounds]) - ([self contentInset].left + [self contentInset].right);        }
        else if([self layoutStyle] == NRGridViewLayoutStyleHorizontal){
            gridFooterViewFrame.size.height = CGRectGetHeight([self bounds]) - ([self contentInset].top + [self contentInset].bottom);
        }
        
        gridFooterViewFrame.origin = gridFooterOrigin;
        [[self gridFooterView] setFrame:gridFooterViewFrame];
        [self bringSubviewToFront:[self gridFooterView]];
    }
    
    
    /** Send non-visible cells to recycle bin */
    [_highlightedCell setHighlighted:NO animated:NO];
    [_highlightedCell release], _highlightedCell=nil;

    NSMutableArray *visibleCellsIndexPaths = [[NSMutableArray alloc] init];
    NSSet *visibleCellsSetCopy = [_visibleCellsSet copy];
    
    for(NRGridViewCell* visibleCell in visibleCellsSetCopy)
    {
        [visibleCell setFrame:[self __rectForCellAtIndexPath:[visibleCell __indexPath] 
                                            usingLayoutStyle:[self layoutStyle]]];
        
        if(CGRectIntersectsRect([visibleCell frame], [self bounds]) == NO)
        {
            [self __throwCellInReusableQueue:visibleCell];
        }else{
            [visibleCellsIndexPaths addObject:[visibleCell __indexPath]]; // gather the index path of the enumerated cell if it's still visible on screen.
        }
    }
    
    [visibleCellsSetCopy release];
    
    
    [self __layoutCellsWithLayoutStyle:[self layoutStyle]
         alreadyVisibleCellsIndexPaths:visibleCellsIndexPaths];
    
    [visibleCellsIndexPaths release];
}


#pragma mark - Handling Highlight/(De)Selection

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    [self selectCellAtIndexPath:indexPath autoScroll:NO scrollPosition:NRGridViewScrollPositionNone animated:animated];
}


- (void)selectCellAtIndexPath:(NSIndexPath*)indexPath 
                   autoScroll:(BOOL)autoScroll 
               scrollPosition:(NRGridViewScrollPosition)scrollPosition
                     animated:(BOOL)animated
{
    if([_selectedCellsIndexPaths containsObject:indexPath] == NO && indexPath)
    {
        
        if([self allowsMultipleSelections] == NO)
            [self deselectCellAtIndexPath:[self indexPathForSelectedCell] 
                                 animated:animated];

        
        [_selectedCellsIndexPaths addObject:indexPath];
        [[self cellAtIndexPath:indexPath] setSelected:YES animated:animated];
    }
    
    
    if(autoScroll && indexPath)
    {
        [self scrollRectToItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    }
}





- (void)deselectCellAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated
{
    if(indexPath != nil)
        [self deselectCellsAtIndexPaths:[NSArray arrayWithObject:indexPath] animated:animated];
}

- (void)deselectCellsAtIndexPaths:(NSArray*)indexPaths 
                         animated:(BOOL)animated
{
    if([indexPaths count] == 0) return;
    
    for(NRGridViewCell *visibleCell in [self visibleCells])
    {
        if([visibleCell isSelected] 
           && [indexPaths containsObject:[visibleCell __indexPath]])
        {
            [visibleCell setSelected:NO animated:animated];
        }
    }
    
    [_selectedCellsIndexPaths removeObjectsInArray:indexPaths];
}

- (void)unhighlightPressuredCellAnimated:(BOOL)animated
{
    [_longPressuredCell setHighlighted:NO animated:animated];
    [_longPressuredCell release], _longPressuredCell=nil;
}

#pragma mark -

- (void)__handleTapGestureRecognition:(UIGestureRecognizer*)tapGestureRecognizer
{
    if(tapGestureRecognizer == _tapGestureRecognizer)
    {
        
        CGPoint touchLocation = [tapGestureRecognizer locationInView:self];
        
        if(_gridViewDelegateRespondsTo.didSelectHeader){
            for(NRGridViewSectionLayout* aSectionLayout in _sectionLayouts)
            {
                if([aSectionLayout headerView] 
                   && CGRectContainsPoint([[aSectionLayout headerView] frame], touchLocation))
                {
                    [[self delegate] gridView:self didSelectHeaderForSection:[aSectionLayout section]];
                    return;
                }
            }
        }
        
        
        for(NRGridViewCell *aCell in _visibleCellsSet)
        {
            if(CGRectContainsPoint([aCell frame], 
                                   touchLocation))
            {
                if([self allowsMultipleSelections] == NO)
                    [self deselectCellsAtIndexPaths:[self indexPathsForSelectedCells] animated:YES];

                
                if(_gridViewDelegateRespondsTo.willSelectCell)
                    [[self delegate] gridView:self willSelectCellAtIndexPath:[aCell __indexPath]];

                [self selectCellAtIndexPath:[aCell __indexPath] animated:YES];
                
                if(_gridViewDelegateRespondsTo.didSelectCell)
                    [[self delegate] gridView:self didSelectCellAtIndexPath:[aCell __indexPath]];
                
                break;
            }
        }
    }
}

- (void)__handleLongPressGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
    if(gestureRecognizer == _longPressGestureRecognizer)
    {
        if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
        {
            CGPoint touchLocation = [gestureRecognizer locationInView:self];
            
            for(NRGridViewCell *aCell in _visibleCellsSet)
            {
                if(CGRectContainsPoint([aCell frame], 
                                       touchLocation))
                {
                    if(_longPressuredCell != aCell)
                    {
                        [self unhighlightPressuredCellAnimated:YES];
                        
                        _longPressuredCell = [aCell retain];
                        [_longPressuredCell setHighlighted:YES animated:YES];
                    }

                    [[self delegate] gridView:self didLongPressCellAtIndexPath:[aCell __indexPath]];
                    
                    break;
                }
            }
        }
        else if(([gestureRecognizer state] == UIGestureRecognizerStateEnded 
                 && ([self longPressOptions] & NRGridViewLongPressUnhighlightUponPressGestureEnds))
                || [gestureRecognizer state] == UIGestureRecognizerStateCancelled)
        {
            [self unhighlightPressuredCellAnimated:YES];
        }

    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if([touches count] == 1
       && [self gestureRecognizer:_tapGestureRecognizer
               shouldReceiveTouch:[touches anyObject]])
    {
        UITouch* touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        
        [_highlightedCell setHighlighted:NO animated:YES];
        [_highlightedCell release], _highlightedCell=nil;
        
        if([self longPressOptions] & NRGridViewLongPressUnhighlightUponAnotherTouch)
        {
            [self unhighlightPressuredCellAnimated:YES];
        }
        
        for(NRGridViewCell *aCell in _visibleCellsSet)
        {
            if(CGRectContainsPoint([aCell frame], 
                                   touchLocation))
            {
                [aCell setHighlighted:YES animated:YES];
                _highlightedCell = [aCell retain];                
                break;
            }
        }
    }
     
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_highlightedCell setHighlighted:(_longPressuredCell==_highlightedCell) animated:YES];
    [_highlightedCell release], _highlightedCell=nil;
    [super touchesCancelled:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_highlightedCell setHighlighted:(_longPressuredCell==_highlightedCell) animated:YES];
    [_highlightedCell release], _highlightedCell=nil;
    [super touchesEnded:touches withEvent:event];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if( (gestureRecognizer == _longPressGestureRecognizer || gestureRecognizer == _tapGestureRecognizer)
       && (([[touch view] isKindOfClass:[UIControl class]] && [[touch view] isUserInteractionEnabled])
           || [touch view] == [self gridHeaderView] || [touch view] == [self gridFooterView]))
        return NO;
    else if(gestureRecognizer == _longPressGestureRecognizer)
        return _gridViewDelegateRespondsTo.didLongPressCell;
    
    return YES;
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( (object == [self gridHeaderView] || object == [self gridFooterView])
       && [keyPath isEqualToString:@"frame"] 
       && [self superview] != nil)
    {
        NSValue *oldFrameValue, *newFrameValue;
        oldFrameValue = [change objectForKey:NSKeyValueChangeOldKey];
        newFrameValue = [change objectForKey:NSKeyValueChangeNewKey];
        BOOL sizeHasChanged = YES;
        
        if(oldFrameValue != (id)[NSNull null] && newFrameValue != (id)[NSNull null]) // cast type id to avoid useless warnings. 
        {
            CGSize oldSize = [oldFrameValue CGRectValue].size;
            CGSize newSize = [newFrameValue CGRectValue].size;
            
            if([self layoutStyle] == NRGridViewLayoutStyleVertical){
                sizeHasChanged = (oldSize.height != newSize.height);
            }
            else if([self layoutStyle] == NRGridViewLayoutStyleHorizontal){
                sizeHasChanged = (oldSize.width != newSize.width);
            }
        }
        
        if(sizeHasChanged)
        {
            [self __reloadContentSize];
            [self setNeedsLayout];
        }
    }
}


#pragma mark - Memory

- (void)dealloc
{   
    [_gridHeaderView removeObserver:self forKeyPath:@"frame"];
    [_gridFooterView removeObserver:self forKeyPath:@"frame"];

    [_gridHeaderView release];
    [_gridFooterView release];
    
    [_longPressuredCell release];
    [_longPressGestureRecognizer release];
    [_sectionLayouts release];
    [_highlightedCell release];
    [_tapGestureRecognizer release];
    [_reusableCellsSet release];
    [_visibleCellsSet release];
    [_selectedCellsIndexPaths release];
    [super dealloc];
}

@end
