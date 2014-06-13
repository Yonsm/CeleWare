
#import "PredictScrollView.h"


@implementation PredictScrollView

#pragma mark Generic methods

// Constructor
- (id)initWithFrame:(CGRect)frame
{
	_gap = 5;
	frame.origin.x -= _gap;
	frame.size.width += _gap * 2;
	
	self = [super initWithFrame:frame];
	self.pagingEnabled = YES;
	self.delegate = self;
	self.scrollsToTop = NO;
	self.showsHorizontalScrollIndicator = NO;
	
	//self.backgroundColor = [UIColor blackColor];
	
	return self;
}

// Destructor
- (void)dealloc
{
	if (_pages) free(_pages);
}

//
- (void)setGap:(CGFloat)gap
{
	CGRect frame = self.frame;
	frame.origin.x += _gap;
	frame.size.width -= _gap * 2;
	
	frame.origin.x -= gap;
	frame.size.width += gap * 2;
	self.frame = frame;
	_gap = gap;
}

//
- (void)removeFromSuperview
{
	_delegate2 = nil;
	[super removeFromSuperview];
}

// Remove cached pages
- (void)freePages:(BOOL)force
{
	NSUInteger count = _numberOfPages;
	for (NSUInteger i = 0; i < count; ++i)
	{
		if (_pages[i])
		{
			if ((i != _currentPage) && (force || ((i != _currentPage - 1) && (i != _currentPage + 1))))
			{
				[_pages[i] removeFromSuperview];
				_pages[i] = nil;
			}
		}
	}
}

//
- (void)loadPage:(NSUInteger)index
{
	if (index >= _numberOfPages) return;
	if (_pages[index]) return;
	
	CGRect frame = self.frame;
	frame.origin.y = 0;
	frame.origin.x = frame.size.width * index + _gap;
	frame.size.width -= _gap * 2;
	
	_pages[index] = [_delegate2 scrollView:self viewForPage:index inFrame:frame];
	(_pages[index]).autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[self addSubview:_pages[index]];
}

//
- (void)loadNearby
{
	@autoreleasepool
	{
		[self loadPage:_currentPage - 1];
		[self loadPage:_currentPage + 1];
	}
}

//
- (void)scheduledNearby
{
	@autoreleasepool
	{
		[self performSelectorOnMainThread:@selector(loadNearby) withObject:nil waitUntilDone:YES];
	}
}

//
- (void)loadPages
{
	[self freePages:NO];
	[self loadPage:_currentPage];
	[_delegate2 scrollView:self scrollToPage:_currentPage];
	
	if (!_noPredict)
	{
		[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(scheduledNearby) userInfo:nil repeats:NO];
	}
}

//
- (void)setCurrentPage:(NSUInteger)currentPage animated:(BOOL)animated
{
	if (currentPage >= _numberOfPages)
	{
		currentPage = 0;
	}
	if (_currentPage != currentPage)
	{
		[self setContentOffset:CGPointMake(self.frame.size.width * currentPage, 0) animated:animated];
	}
	else
	{
		[self loadPages];
	}
}

//
- (void)setCurrentPage:(NSUInteger)currentPage
{
	[self setCurrentPage:currentPage animated:NO];
}

//
- (void)setNumberOfPages:(NSUInteger)numberOfPages
{
	if (_numberOfPages) UIUtil::RemoveSubviews(self);
	_numberOfPages = numberOfPages;
	
	NSUInteger size = numberOfPages * sizeof(UIView *);
	_pages = (__weak UIView **)realloc(_pages, size);
	memset(_pages, 0, size);
}


#pragma mark View methods

// Layout subviews.
- (void)layoutSubviews
{
	_bIgnore = YES;
	[super layoutSubviews];
	self.contentSize = CGSizeMake(self.frame.size.width * _numberOfPages, self.frame.size.height);
	_bIgnore = NO;
}

// Set view frame.
- (void)setFrame:(CGRect)frame
{
	_bIgnore = YES;
	[super setFrame:frame];
	self.contentOffset = CGPointMake(frame.size.width * _currentPage, 0);
	_bIgnore = NO;
}


#pragma mark Scroll view methods

//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (_bIgnore) return;
	
	CGFloat width = scrollView.frame.size.width;
	NSUInteger currentPage = floor((scrollView.contentOffset.x - width / 2) / width) + 1;
	if ((_currentPage != currentPage) && (currentPage < _numberOfPages))
	{
		_currentPage = currentPage;
		[self loadPages];
	}
}

@end


//
@implementation PageControlScrollView

//
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	frame.origin.y = frame.size.height - 10;
	frame.size.height = 10;
	_pageCtrl = [[UIPageControl alloc] initWithFrame:frame];
	//_pageCtrl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_pageCtrl.numberOfPages = 0;
	_pageCtrl.currentPage = 0;
	_pageCtrl.hidesForSinglePage = YES;
	[_pageCtrl addTarget:self action:@selector(pageCtrlChanged:) forControlEvents:UIControlEventValueChanged];
	
	return self;
}

//

//
- (void)willMoveToSuperview:(UIView *)newSuperview
{
	if (_hasParent)
	{
		[_pageCtrl removeFromSuperview];
		_hasParent = NO;
	}
}

//
- (void)didMoveToSuperview
{
	if (self.superview)
	{
		_hasParent = YES;
		[self.superview addSubview:_pageCtrl];
	}
}

//
- (void)setNumberOfPages:(NSUInteger)count
{
	[super setNumberOfPages:count];
	_pageCtrl.numberOfPages = count;
}

//
- (void)loadPages
{
	_pageCtrl.currentPage = self.currentPage;
	[super loadPages];
}

//
- (void)pageCtrlChanged:(UIPageControl *)sender
{
	self.currentPage = _pageCtrl.currentPage;
}

@end

