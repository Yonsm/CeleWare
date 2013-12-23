
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

// Destructor
//- (void)dealloc
//{
//	[super dealloc];
//}

#pragma mark View methods

// Creates the view that the controller manages.
//- (void)loadView
//{
//	[super loadView];
//}

// Do additional setup after loading the view.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//
	BOOL iPhone5 = YES;//UIUtil::IsPhone5();
	UIImage *image = /*UIUtil::Image(@"guanyu");*/[UIImage imageNamed:@"Icon"];
	_logoButton = [UIButton buttonWithImage:image];
	[_logoButton addTarget:self action:@selector(logoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	_logoButton.center = CGPointMake(160, (iPhone5 ? 20 : 6) + image.size.height / 2);
	
	UILabel *label = [UILabel labelWithFrame:CGRectMake(10, CGRectGetMaxY(_logoButton.frame) + 4, 300, iPhone5 ? 40 : 20)
										text:[NSString stringWithFormat:@"版本 %@ %@© Gozap", NSUtil::BundleVersion(), (iPhone5 ? @"\n" : @" ")]
									   color:[UIColor darkGrayColor]
										font:[UIFont systemFontOfSize:15]
								   alignment:NSTextAlignmentCenter];
	
	if (iPhone5) label.numberOfLines = 2;
	
	UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 15 + image.size.height + (iPhone5 ? 60 : 20))] autorelease];
	[header addSubview:_logoButton];
	[header addSubview:label];
	
	self.tableView.tableHeaderView = header;
	
}

// Called after the view controller's view is released and set to nil.
- (void)viewDidUnload
{
	[super viewDidUnload];
	_logoButton = nil;
}

// Called when the view is about to made visible.
//- (void)viewWillAppear:(BOOL)animated
//{
//	[super viewWillAppear:animated];
//}
//
//// Called after the view was dismissed, covered or otherwise hidden.
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//}

#pragma mark Table view delegate

//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

//
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		default: /*return NSLocalizedString(@"Application Information", @"软件信息");
				  case 1: */return NSLocalizedString(@"Feedback & Share", @"一般设置");
			//		case 2: return NSLocalizedString(@"Online Information", @"在线内容");
	}
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
	{
		default: /*return 2;
				  case 1: */return 5;
			//case 2: return 5;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	NSString *reuse = [NSString stringWithFormat:@"Cell%d.%d", section, row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		//		if (section == 0)
		//		{
		//			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		//			switch (row)
		//			{
		//				case 0:
		//				{
		//					cell.textLabel.text = NSUtil::BundleDisplayName();
		//					cell.detailTextLabel.text = NSUtil::BundleInfo(@"CFBundleVersion");
		//					break;
		//				}
		//				case 1:
		//				{
		//					cell.textLabel.text = NSLocalizedString(@"Copyright©", @"版权所有©");
		//					cell.detailTextLabel.text = NSLocalizedString(@"QingChiFan.com", @"QingChiFan.com");
		//					break;
		//				}
		//			}
		//		}
		//		else if (section == 1)
		{
			switch (row)
			{
				case 0:
				{
					cell.textLabel.text = NSLocalizedString(@"Push Notification", @"推送设置");
					break;
				}
				case 1:
				{
					cell.textLabel.text = NSLocalizedString(@"Clear Cache", @"清除缓存");
					break;
				}
				case 2:
				{
					cell.textLabel.text = NSLocalizedString(@"Feedback", @"意见反馈");
					break;
				}
				case 3:
				{
					cell.textLabel.text = NSLocalizedString(@"Rated QingChiFan", @"给个好评");
					break;
				}
				case 4:
				{
					cell.textLabel.text = NSLocalizedString(@"About QingChiFan", @"关于请吃饭");
					break;
				}
			}
		}
		//		else if (section == 2)
		//		{
		//			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		//			switch (row)
		//			{
		//				case 0:
		//				{
		//					cell.textLabel.text = NSLocalizedString(@"Weibo", @"官方微博");
		//					cell.detailTextLabel.text = nil;
		//					break;
		//				}
		//				case 1:
		//				{
		//					cell.textLabel.text = NSLocalizedString(@"Introduce", @"功能介绍");
		//					cell.detailTextLabel.text = nil;
		//					break;
		//				}
		//				case 2:
		//				{
		//					cell.textLabel.text = NSLocalizedString(@"Terms of Service", @"服务条款");
		//					cell.detailTextLabel.text = nil;
		//					break;
		//				}
		//				case 3:
		//				{
		//					cell.textLabel.text = NSLocalizedString(@"Privay Policy", @"隐私政策");
		//					cell.detailTextLabel.text = nil;
		//					break;
		//				}
		//				case 4:
		//				{
		//					cell.textLabel.text = NSLocalizedString(@"Special Thanks", @"致谢声明");
		//					cell.detailTextLabel.text = nil;
		//					break;
		//				}
		//			}
		//		}
	}
	return cell;
}

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	//	NSInteger section = [indexPath section];
	//	NSInteger row = [indexPath row];
	//	if (section == 0)
	//	{
	//		if (row == 0)
	//		{
	//			UIUtil::OpenURL(@"http://itunes.apple.com/cn/app/id434119998");
	//		}
	//		else
	//		{
	//			row = 0;
	//			goto __OpenWebBrowser;
	//		}
	//	}
	//	else if (section == 1)
	//	{
	//		switch (row)
	//		{
	//			case 0:
	//			{
	//				UIUtil::OpenURL(@"https://userpub.itunes.apple.com/WebObjects/MZUserPublishing.woa/wa/addUserReview?id=434119998&type=Purple+Software");
	//				break;
	//			}
	//			case 1:
	//			{
	//				[self composeMail:NSLocalizedString(@"Hello, \n\n  ...", @"你好，\n\n  ⋯")
	//						  subject:NSLocalizedString(@"CeleDial for iPhone Feedback", @"CeleDial for iPhone 问题反馈")
	//							   to:[NSArray arrayWithObject:@"support@celedial.com"]];
	//				break;
	//			}
	//			case 2:
	//			{
	//				[self composeMail:NSLocalizedString(@"<P>Hello,<br><br>I'm using CeleDial for iPhone, that is a powerful yet easy to use smart dialing utility.<br><br>...<br><br>You can download it from <a href='http://www.celedial.com/appstore'>http://www.celedial.com/appstore</a><br></P>", @"<P>您好，<br><br>我正在使用 CeleDial for iPhone，一个非常强大且非常容易使用的智能拨号和号码归属查询工具。⋯<br><br>您可以从 <a href='http://www.celedial.com/appstore'>http://www.celedial.com/appstore</a> 下载它。<br></P>")
	//						  subject:NSLocalizedString(@"Share a smart dialing utility, CeleDial for iPhone.", @"推荐一个好用的 CeleDial 智能拨号工具")
	//							   to:nil];
	//				break;
	//			}
	//			case 3:
	//			{
	//				[self composeSMS:NSLocalizedString(@"Share a smart dialing utility, CeleDial for iPhone. You can download it from http://www.celedial.com/appstore", @"推荐一个好用的 CeleDial 智能拨号和号码归属查询工具，您可以从 http://www.celedial.com/appstore 下载它。")
	//							  to:nil];
	//				break;
	//			}
	//		}
	//	}
	//	else if (section == 2)
	//	{
	//		UIViewController *controller;
	//		if (row == 0)
	//		{
	//			controller = [WeiboComposer composerWithBody:NSLocalizedString(@"I'm using CeleDial for iPhone, that is a powerful yet easy to use smart dialing utility. You can download it from http://www.celedial.com/appstore.", @"我正在使用 @CeleDial智能拨号，一个非常强大且非常容易使用的智能拨号和号码归属查询工具。您可以从 http://www.celedial.com/appstore 下载它。")];
	//		}
	//		else
	//		{
	//		__OpenWebBrowser:
	//			//
	//			const static NSString *c_urls[] =
	//			{
	//				@"http://www.celedial.com/",
	//				@"http://www.celedial.com/feature",
	//				@"http://www.celedial.com/contract",
	//				@"http://www.celedial.com/privacy",
	//				@"http://www.celedial.com/thanks",
	//			};
	//			controller = [[[WebBrowser alloc] initWithUrl:(NSString *)c_urls[row]] autorelease];
	//		}
	//		[self.navigationController pushViewController:controller animated:YES];
	//	}
	//	else //if (section == 3)
	//	{
	//		if (row == 0)
	//		{
	//			UIUtil::OpenURL(@"http://itunes.apple.com/cn/app/id478797719");
	//		}
	//	}
}

#pragma mark Event methods

//
- (void)logoutButtonClicked:(id)sender
{
	[UIAlertView alertWithTitle:@"注销" message:@"您要退出当前账户吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"确定"];
}

//
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		//[DataLoader logout];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

//
- (void)logoButtonClicked:(UIButton *)sender
{
	UIUtil::ShowStatusBar(NO, UIStatusBarAnimationSlide);
	
	UIImage *image = [UIImage imageNamed:UIUtil::IsPhone5() ? @"Default-568h" : @"Default"];
	UIButton *button = [UIButton buttonWithImage:image];
	[button setImage:image forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(sloganButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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
		 sender.frame = [self.navigationController.view convertRect:_logoButton.frame fromView:self.view];;
	 } completion:^(BOOL finished)
	 {
		 [sender removeFromSuperview];
	 }];
}

@end
