
#import "PullDataLoader.h"
#import "RegisterController.h"

@implementation PullDataLoader

#pragma mark Generic methods

//
//- (id)init
//{
//	self = [super init];
//	return self;
//}

//
- (void)dealloc
{
	[_scrollView release];
	[_emptyView release];
	[_authView release];
	[super dealloc];
}

//
- (void)setScrollView:(UIScrollView *)scrollView
{
	if (_scrollView != scrollView)
	{
		[_scrollView release];
		_scrollView = scrollView.retain;
		
		_refreshControl = [[[ODRefreshControl alloc] initInScrollView:scrollView] autorelease];
		[_refreshControl addTarget:self action:@selector(loadRefresh) forControlEvents:UIControlEventValueChanged];
	}
}

//
- (BOOL)needLogin
{
	return _needAuth && (!Settings::Get(kUsername) || !Settings::Get(kPassword));
}

//
//- (void)loadFirst
//{
//	_disableLoadOnResumeOnce = YES;
//	self.checkError = YES;
//	self.checkChange = NO;
//	[self loadBegin];
//}

//
- (void)loadRefresh
{
	self.checkError = YES;
	if (![self loadExpire])
	{
		[_refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.5];
	}
}

//
- (void)loadResume
{
	//	if (_disableLoadOnResumeOnce)
	//	{
	//		_disableLoadOnResumeOnce = NO;
	//		return;
	//	}
	
	if (self.needLogin)
	{
		[self clearData];
	}
	
	self.checkError = (self.dict == nil);
	[self loadExpire];
}

//
- (void)loadPause
{
	self.checkError = NO;
	_disableShowLoginOnce = YES;	// 禁止隐藏页面后再次显示时弹出自动登录，场景：处于在子页面的时候如果被踢出或注销，返回到父页面时不再弹出登录
}

//
- (BOOL)loadExpire
{
	if ((self.error == DataLoaderNoError || self.error == DataLoaderNoChange))
	{
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceReferenceDate] - self.date.timeIntervalSinceReferenceDate;
		if (interval < 60)
		{
			return NO;
		}
	}
	[self loadBegin];
	return YES;
}

#pragma mark -
#pragma mark Data loader methods

//
- (void)loadBegin
{
	if (self.needLogin)
	{
		[_refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.5];
		if (_authView == nil)
		{
			_authView = self.authView.retain;
			[_scrollView addSubview:_authView];
			
			if (_disableShowLoginOnce)
			{
				_disableShowLoginOnce = NO;
			}
			else
			{
				[DataLoader login];
			}
		}
		return;
	}
	else if (_authView)
	{
		[_authView removeFromSuperview];
		[_authView release];
		_authView = nil;
	}
	
	[super loadBegin];
	//[_refreshControl beginRefreshing];
}

//
- (void)loadStop:(NSDictionary *)dict
{
	self.checkChange = YES;
	
	//sscrollView.pullView.stampLabel.text = self.stamp;
	[_refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.5];
	
	if (self.error == DataLoaderNotLogin)
	{
		_needAuth = YES;
		_disableShowLoginOnce = YES;
		[self clearData];
	}
	
	[super loadStop:dict];
}

//
- (void)setEmpty:(BOOL)empty
{
	if (empty)
	{
		if (_emptyView == nil)
		{
			_emptyView = self.emptyView.retain;
			[_scrollView addSubview:_emptyView];
		}
	}
	else if (_emptyView)
	{
		[_emptyView removeFromSuperview];
		[_emptyView release];
		_emptyView = nil;
	}
}

//
- (void)setRefreshEnabled:(BOOL)enabled
{
	_refreshControl.hidden = !enabled;
	_refreshControl.enabled = enabled;
}

//
- (void)registerButtonClicked:(id)sender
{
	UIViewController *controller = [[[RegisterController alloc] init] autorelease];
	[UIUtil::RootViewController() presentModalNavigationController:controller animated:YES];
}

// TODO: 优化重构
- (UIView *)emptyView
{
	CGRect frame = _scrollView.bounds;
	UIView *view = [[[UIView alloc] initWithFrame:frame] autorelease];
	view.backgroundColor = _scrollView.backgroundColor;
	
	UIImageView *icon = [[[UIImageView alloc] initWithImage:UIUtil::Image(@"EmptyIcon")] autorelease];
	icon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	icon.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 - 30);
	[view addSubview:icon];
	
	frame.origin.y = CGRectGetMaxY(icon.frame) + 2;
	frame.size.height = 30;
	UILabel *label = [UILabel labelWithFrame:frame
										text:@"暂时是空的"
									   color:[UIColor darkGrayColor]
										font:[UIFont systemFontOfSize:14]
								   alignment:NSTextAlignmentCenter];
	label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[view addSubview:label];
	
	return view;
}

//
- (UIView *)authView
{
	UIView *view = self.emptyView;
	
	UIImageView *icon = (UIImageView *)view.subviews[0];
	UILabel *label = (UILabel *)view.subviews[1];
	
	icon.center = CGPointMake(icon.center.x, icon.center.y - 22);
	label.center = CGPointMake(label.center.x, label.center.y - 22);
	label.text = @"没有登录";
	
	CGFloat y = CGRectGetMaxY(label.frame) + 4;
	UIButton *loginButton = [UIButton linkButtonWithTitle:@"登录" frame:CGRectMake(view.frame.size.width / 2 - 8 - 40, y, 40, 0)];
	[loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	loginButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[view addSubview:loginButton];
	
	UIButton *registerButton = [UIButton linkButtonWithTitle:@"注册" frame:CGRectMake(view.frame.size.width / 2 + 8, y, 40, 0)];
	registerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[registerButton addTarget:self action:@selector(registerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:registerButton];
	
	return view;
}

@end


@implementation AutoPullDataLoader

//
- (void)dealloc
{
	[_abortTimer invalidate];
	[_abortTimer release];
	[_autoTimer invalidate];
	[_autoTimer release];
	[super dealloc];
}

//
- (void)loadPause
{
	[super loadPause];
	
	// 隐藏就取消自动刷新？
	[_abortTimer invalidate];
	[_abortTimer release];
	_abortTimer = nil;
	[_autoTimer invalidate];
	[_autoTimer release];
	_autoTimer = nil;
}

//
- (void)loadSlient
{
	self.checkError = NO;
	[self loadBegin];
}

//
- (void)loadAuto
{
	_autoReload = YES;	// 60 秒钟后，自动重新刷新
	[self loadSlient];
	//[self performSelector:@selector(loadAbort) withObject:nil afterDelay:60 * 5];	// 5 分钟后，取消自动刷新机制
	
	[_abortTimer invalidate];
	[_abortTimer release];
	_abortTimer = [NSTimer timerWithTimeInterval:60 * 5 target:self selector:@selector(loadAbort) userInfo:nil repeats:NO].retain;
}

//
- (void)loadAbort
{
	_autoReload = NO;
}

//
- (void)loadStop:(NSDictionary *)dict
{
	if (self.error == DataLoaderNoError)
	{
		[self loadAbort];
	}
	
	if (_autoReload)
	{
		[_autoTimer invalidate];
		[_autoTimer release];
		_autoTimer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(loadSlient) userInfo:nil repeats:NO].retain;
		//[self performSelector:@selector(loadSlient) withObject:nil afterDelay:60];	// 60 秒钟后，自动重新刷新
	}
	
	[super loadStop:dict];
}

@end