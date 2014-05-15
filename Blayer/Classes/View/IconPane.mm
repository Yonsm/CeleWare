
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
	CGRect rect = {gap, 14, 60, 60};
	_apps = [NSMutableArray arrayWithCapacity:_NumOf(c_apps)];
	for (int i = 0; i < _NumOf(c_apps); i++)
	{
#if !TARGET_IPHONE_SIMULATOR
		if (UIUtil::CanOpenUrl(c_apps[i].url))
#endif
		{
			[_apps addObject:@{@"icon":c_apps[i].icon, @"url":c_apps[i].url}];
			
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
	self.contentSize = CGSizeMake(rect.origin.x, frame.size.height);
	
	return self;
}

//
- (void)buttonClicked:(UIButton *)sender
{
	UIUtil::OpenUrl(c_apps[sender.tag].url);
}

@end
