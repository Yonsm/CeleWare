
#import "SettingController.h"

@implementation SettingController

#pragma mark Generic methods

// Constructor
- (id)init
{
	self = [super init];
	self.title = NSLocalizedString(@"Settings", @"设置");
	return self;
}

#pragma mark View methods

// Creates the view that the controller manages.
//- (void)loadView
//{
//	[super loadView];
//}

// Do additional setup after loading the view.
//- (void)viewDidLoad
//{
//	[super viewDidLoad];
//}

//
- (void)loadPage
{
	BOOL iPhone5 = UIUtil::IsPhone5();
	UIImage *image = UIUtil::Image(@"Icon");
	_logoButton = [UIButton buttonWithImage:image];
	[_logoButton addTarget:self action:@selector(logoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	_logoButton.center = CGPointMake(160, (iPhone5 ? 20 : 6) + image.size.height / 2);
	[self addView:_logoButton];
	
	UILabel *label = [UILabel labelWithFrame:CGRectMake(10, _contentHeight + 4, 300, iPhone5 ? 40 : 20)
										text:[NSString stringWithFormat:@"版本 %@ %@© CeleWare", NSUtil::BundleVersion(), (iPhone5 ? @"\n" : @" ")]
									   color:[UIColor darkGrayColor]
										font:[UIFont systemFontOfSize:15]
								   alignment:NSTextAlignmentCenter];
	[self addView:label];
	if (iPhone5)
	{
		label.numberOfLines = 2;
		[self spaceWithHeight:24];
	}
	else
	{
		[self spaceWithHeight:14];
	}
	
	{
//		if (DataLoader.isLogon)
//		{
//			BOOL enabled = [Settings::Get(kDeviceBinded) boolValue];
//			[self cellButtonWithName:@"推送状态"
//							  detail:enabled ? nil : @"请在系统通知中心开启"
//							   title:enabled ? @"已开启" : @"已关闭"
//							  action:nil//@selector(pushButtonClicked:)
//							   width:56].enabled = NO;
//		}
		
		[self cellButtonWithName:@"网络缓存"
						  detail:[NSString stringWithFormat:@"%.2f MB", float(NSUtil::CacheSize() / 1024.0 / 1024.0)]
						   title:@"清除"
						  action:@selector(clearButtonClicked:)
						   width:56];
	}
	
	if (DataLoader.isLogon)
	{
		//self.navigationItem.rightBarButtonItem = [UIBarButtonItem _buttonItemWithTitle: target:self action:@selector(logoutButtonClicked:)];
		[self majorButtonWithTitle:@"安全退出" action:@selector(logoutButtonClicked:)];

		if (!iPhone5) [self spaceWithHeight:-3];
	}

	[self spaceWithHeight:kDefaultHeaderHeight];
	{
		[self cellWithName:@"给个好评" detail:nil action:@selector(starButtonClicked:)];
		[self cellWithName:@"关于" detail:nil action:@selector(logoButtonClicked:)];
	}

	if (!iPhone5) [self spaceWithHeight:-10];
}

#pragma mark Event methods

//
#define kClearCacheAlertViewTag 12517
- (void)clearButtonClicked:(UIButton *)sender
{
	_cacheCell = (WizardCell *)sender.superview;
	UIAlertView *alertView = [UIAlertView alertWithTitle:@"清除缓存" message:@"你确定要清除网络缓存吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"清除"];
	alertView.tag = kClearCacheAlertViewTag;
}

//
- (void)starButtonClicked:(WizardCell *)sender
{
	UIUtil::OpenURL(kAppStoreUrl);
}

//
- (void)logoutButtonClicked:(id)sender
{
	[UIAlertView alertWithTitle:@"注销" message:@"你要退出当前账户吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"确定"];
}

//
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == alertView.cancelButtonIndex) return;
	
	if (alertView.tag == kClearCacheAlertViewTag)
	{
		NSUtil::ClearCache();
		_cacheCell.detail = nil;
		UIButton *button = (UIButton *)_cacheCell.accessoryView;
		[button setTitle:@"已清除" forState:UIControlStateNormal];
		button.enabled = NO;
		return;
	}
	
	[DataLoader logout];
	[self.navigationController popViewControllerAnimated:YES];
}

//
#define kSloganFromViewTag 12821
- (void)logoButtonClicked:(UIView *)sender
{
	UIUtil::ShowStatusBar(NO, UIStatusBarAnimationSlide);
	
	UIImage *image = [UIImage imageNamed:UIUtil::IsPhone5() ? @"Default-568h" : @"Default"];
	UIButton *button = [UIButton buttonWithImage:image];
	[button setImage:image forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(sloganButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	button.tag = sender.tag = kSloganFromViewTag;
	[self.view.window addSubview:button];
	
	CGRect frame = button.frame;
	button.frame = [self.navigationController.view convertRect:sender.frame fromView:self.view];
	button.alpha = 0;
	[UIView animateWithDuration:0.4 animations:^()
	 {
		 button.alpha = 1;
		 button.frame = frame;
	 }];
}

//
- (void)sloganButtonClicked:(UIButton *)sender
{
	UIUtil::ShowStatusBar(YES, UIStatusBarAnimationSlide);
	[UIView animateWithDuration:0.4 animations:^()
	 {
		 sender.alpha = 0;
		 sender.frame = [self.navigationController.view convertRect:[_contentView viewWithTag:kSloganFromViewTag].frame fromView:self.view];;
	 } completion:^(BOOL finished)
	 {
		 [sender removeFromSuperview];
	 }];
}

@end
