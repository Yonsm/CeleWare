
#import "IconPane.h"

static const struct {NSString *name; NSString *icon; NSString *url;} c_apps[] =
{
	{@"Auto Map"	/*NSLocalizedString(@"Auto Maps", @"高德地图")*/,		@"com_autonavi_amap",		@"iosamap://"},
	{@"Ovital Maps"	/*NSLocalizedString(@"Ovital Maps", @"奥维地图")*/,	@"com_ovital_omapTool",		@"gpsov://"},
	{@"Baidu Maps"	/*NSLocalizedString(@"Baidu Maps", @"百度地图")*/,	@"com_baidu_map",			@"baidumap://"},
	{@"Navi One"	/*NSLocalizedString(@"Navi One", @"凯立德导航")*/,	@"linfengkun_NaviOne",		@"NaviOne://"},
	{@"Google Maps"	/*NSLocalizedString(@"Google Maps", @"谷歌地图")*/,	@"com_google_Maps",			@"googlemaps://"},
	{@"Tencent Maps"/*NSLocalizedString(@"Tencent Maps", @"腾讯地图")*/,	@"com_tencent_sosomap",		@"sosomap://"},
	{@"Sogou Maps"	/*NSLocalizedString(@"Sogou Maps", @"搜狗地图")*/,	@"com_sogou_map_app_Map",	@"sgmap://"},
};

@implementation IconPane

// Constructor
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	self.backgroundColor = UIUtil::Color(67,186,231);

	CGFloat gap = (frame.size.width - 60 * 4) / 5;
	frame.origin.x = gap;
	frame.origin.y = 14;
	frame.size.width = frame.size.height = 60;
	_apps = [NSMutableArray arrayWithCapacity:_NumOf(c_apps)];
	for (int i = 0; i < _NumOf(c_apps); i++)
	{
#if !TARGET_IPHONE_SIMULATOR
		if (UIUtil::CanOpenUrl(c_apps[i].url))
#endif
		{
			[_apps addObject:@{@"icon":c_apps[i].icon, @"url":c_apps[i].url}];
			
			UIButton *button = [[UIButton alloc] initWithFrame:frame];
			button.layer.cornerRadius = 8;
			button.clipsToBounds = YES;
			UIImage *icon = UIUtil::Image(c_apps[i].icon);
			[button setImage:icon forState:UIControlStateNormal];
			[self addSubview:button];
			
			button.tag = i;
			[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		}
	}
	
	return self;
}

//
- (void)buttonClicked:(UIButton *)sender
{
	UIUtil::OpenUrl(c_apps[sender.tag].url);
}

@end
