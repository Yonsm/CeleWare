//
//  NRGridViewController.m
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

#import "NRGridViewController.h"

@interface NRGridViewController()
@end

@implementation NRGridViewController
@synthesize gridLayoutStyle = _gridLayoutStyle;
@synthesize gridView = _gridView;

- (id)initWithGridLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        _gridLayoutStyle = layoutStyle;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _gridLayoutStyle = NRGridViewLayoutStyleVertical;
    }
    return self;
}

#pragma mark - Getters

- (NRGridViewLayoutStyle)gridLayoutStyle
{
    if([self isViewLoaded])
        return [[self gridView] layoutStyle];
    return _gridLayoutStyle;
}

#pragma mark - Setters

// Re-write the -setView: in order to make sure that 'view' is conform
- (void)setView:(UIView *)view
{
    // Raise an exception if 'view' is not an instance of NRGridView.
    NSAssert([view isKindOfClass:[NRGridView class]] || view == nil, @"NRGridViewController -setView: method only supports view which class is NRGridView");
    [super setView:view];
    
    if([self gridView] != view)
        [self setGridView:(NRGridView*)view]; 
}

- (void)setGridView:(NRGridView *)gridView
{
    if(_gridView != gridView)
    {
        [_gridView release];
        _gridView = [gridView retain];

        [self setView:gridView];
    }
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    if([self nibName] != nil)
        [super loadView];
    else{
        // Create the gridView manually
        NRGridView *tempGridView = [[NRGridView alloc] initWithLayoutStyle:[self gridLayoutStyle]];
        [tempGridView setCellSize:CGSizeMake(160, 120)];
        [tempGridView setDelegate:self];
        [tempGridView setDataSource:self];
        
        [self setGridView:tempGridView];
        [tempGridView release];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.gridView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([[self gridView] allowsMultipleSelections] == NO)
        [[self gridView] deselectCellAtIndexPath:[[self gridView] indexPathForSelectedCell] 
                                        animated:animated];
}

#pragma mark - GridView DataSource


- (NSInteger)gridView:(NRGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (NRGridViewCell*)gridView:(NRGridView *)gridView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* NRGridViewCellIdentifier = @"NRGridViewCellIdentifier";
    NRGridViewCell* cell = [gridView dequeueReusableCellWithIdentifier:NRGridViewCellIdentifier];
    
    if(cell == nil)
        cell = [[[NRGridViewCell alloc] initWithReuseIdentifier:NRGridViewCellIdentifier] autorelease];

    return cell;
}


#pragma mark - Memory Management


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [_gridView release];
    [super dealloc];
}

@end
