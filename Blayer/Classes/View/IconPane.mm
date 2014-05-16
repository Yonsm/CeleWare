
#import "IconPane.h"

static const struct {NSString *name; NSString *icon; NSString *url;} c_apps[] =
{
	{@"Maps"		/*NSLocalizedString(@"Maps", @"地图")*/,				@"com_apple_Maps",			@"maps://"},
	{@"Navi One"	/*NSLocalizedString(@"Navi One", @"凯立德导航")*/,	@"linfengkun_NaviOne",		@"NaviOne://"},
	{@"Auto Maps"	/*NSLocalizedString(@"Auto Maps", @"高德地图")*/,		@"com_autonavi_amap",		@"iosamap://"},
	{@"Baidu Maps"	/*NSLocalizedString(@"Baidu Maps", @"百度地图")*/,	@"com_baidu_map",			@"baidumap://"},
	{@"Sogou Maps"	/*NSLocalizedString(@"Sogou Maps", @"搜狗地图")*/,	@"com_sogou_map_app_Map",	@"wx7818130b73551513://"},
	{@"Tencent Maps"/*NSLocalizedString(@"Tencent Maps", @"腾讯地图")*/,	@"com_tencent_sosomap",		@"sosomap://"},
	{@"Google Maps"	/*NSLocalizedString(@"Google Maps", @"谷歌地图")*/,	@"com_google_Maps",			@"googlemaps://"},
	{@"Ovital Maps"	/*NSLocalizedString(@"Ovital Maps", @"奥维地图")*/,	@"com_ovital_omapTool",		@"gpsov://"},
};

@implementation IconPane

// Constructor
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	self.backgroundColor = UIUtil::Color(67,186,231);

	CGFloat gap = (frame.size.width - 60 * 4) / 5;
	CGRect rect = {0, 14, 60, 60};
	//_apps = [NSMutableArray arrayWithCapacity:_NumOf(c_apps)];
	for (int i = 0; i < _NumOf(c_apps); i++)
	{
#if !TARGET_IPHONE_SIMULATOR
		if (UIUtil::CanOpenUrl(c_apps[i].url))
#endif
		{
			//[_apps addObject:@{@"icon":c_apps[i].icon, @"url":c_apps[i].url}];
			if ((i % 4) == 0) rect.origin.x += gap;
			
			UIButton *button = [[UIButton alloc] initWithFrame:rect];
			button.layer.cornerRadius = 10;
			button.clipsToBounds = YES;
			UIImage *icon = UIUtil::Image(c_apps[i].icon);
			[button setImage:icon forState:UIControlStateNormal];
			button.tag = i;
			[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];
			
			UILabel *label = UIUtil::LabelWithFrame(CGRectMake(rect.origin.x - gap + 2, rect.origin.y + rect.size.height, rect.size.width + gap * 2 - 4, frame.size.height - rect.origin.y - rect.size.height),
													NSLocalizedString(c_apps[i].name, c_apps[i].name),
													[UIFont systemFontOfSize:12],
													[UIColor whiteColor],
													NSTextAlignmentCenter);
			[self addSubview:label];
			
			rect.origin.x += rect.size.width + gap;
		}
	}
	
	self.pagingEnabled = YES;
	self.showsHorizontalScrollIndicator = NO;
	NSUInteger numberOfPages = ceil(rect.origin.x / frame.size.width);
	self.contentSize = CGSizeMake(frame.size.width * numberOfPages, frame.size.height);
	
	//
	frame.origin.y += 0;
	frame.size.height = 12;
	_pageCtrl = [[UIPageControl alloc] initWithFrame:frame];
	_pageCtrl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_pageCtrl.numberOfPages = numberOfPages;
	_pageCtrl.currentPage = 0;
	_pageCtrl.hidesForSinglePage = YES;
	[_pageCtrl addTarget:self action:@selector(pageCtrlChanged:) forControlEvents:UIControlEventValueChanged];
	self.delegate = self;
	
	return self;
}

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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat width = scrollView.frame.size.width;
	NSUInteger currentPage = floor((scrollView.contentOffset.x - width / 2) / width) + 1;
	if ((_pageCtrl.currentPage != currentPage) && (currentPage < _pageCtrl.numberOfPages))
	{
		_pageCtrl.currentPage = currentPage;
	}
}

//
- (void)pageCtrlChanged:(UIPageControl *)sender
{
	CGSize size = self.bounds.size;
	[self setContentOffset:CGPointMake(size.width * _pageCtrl.currentPage, size.height) animated:YES];
}

//
- (void)buttonClicked:(UIButton *)sender
{
	UIUtil::OpenUrl(c_apps[sender.tag].url);
}

@end
