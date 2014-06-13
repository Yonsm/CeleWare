
#import "PullDataLoader.h"
#import "RegisterController.h"

@implementation PullDataLoader

#pragma mark Generic methods

//
- (id)init
{
	self = [super init];
	_checkExpire = YES;
	return self;
}

//
- (void)setScrollView:(UIScrollView *)scrollView
{
	if (_scrollView != scrollView)
	{
		_scrollView = scrollView;
		
		_refreshControl = [[ODRefreshControl alloc] initInScrollView:scrollView];
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
	//[self loadExpire];
	[self loadBegin];
	if (!self.loading)
	{
		[_refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.5];
	}
	else
	{
		_refreshing = YES;
	}
}

//
- (void)loadResume
{
	if (_disableLoadOnResumeOnce)
	{
		_disableLoadOnResumeOnce = NO;
		return;
	}
	
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
	if (_checkExpire)
	{
		if ((self.error == DataLoaderNoError || self.error == DataLoaderNoChange))
		{
			NSTimeInterval interval = [[NSDate date] timeIntervalSinceReferenceDate] - self.date.timeIntervalSinceReferenceDate;
			if (interval < 600)
			{
				return NO;
			}
		}
	}
	return [self loadBegin];
}

#pragma mark -
#pragma mark Data loader methods

//
- (BOOL)loadBegin
{
	if (self.needLogin)
	{
		[_refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.5];
		if (_authView == nil)
		{
			_authView = self.authView;
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
		return NO;
	}
	else if (_authView)
	{
		[_authView removeFromSuperview];
		_authView = nil;
	}
	
	//[_refreshControl beginRefreshing];
	return [super loadBegin];
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
- (void)loadEnded:(NSDictionary *)dict
{
	[super loadEnded:dict];

	_refreshing = NO;
}

//
- (void)setEmpty:(BOOL)empty
{
	if (empty)
	{
		if (_emptyView == nil)
		{
			_emptyView = self.emptyView;
			[_scrollView addSubview:_emptyView];
		}
	}
	else if (_emptyView)
	{
		[_emptyView removeFromSuperview];
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
	UIViewController *controller = [[RegisterController alloc] init];
	UIUtil::PresentModalNavigationController(UIUtil::RootViewController(), controller);
}

// NEXT: 优化重构
- (UIView *)emptyView
{
	CGRect frame = _scrollView.frame;
	frame.origin.x = frame.origin.y = 0;
	if ([_scrollView isKindOfClass:UITableView.class])
	{
		frame.origin.y = ((UITableView *)_scrollView).tableHeaderView.frame.size.height;
		frame.size.height -= frame.origin.y;
	}
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.backgroundColor = _scrollView.backgroundColor;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	UIImageView *icon = [[UIImageView alloc] initWithImage:UIUtil::Image(@"EmptyIcon")];
	icon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	icon.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 - 30);
	[view addSubview:icon];
	
	frame.origin.y = CGRectGetMaxY(icon.frame) + 12;
	frame.size.height = 16;
	UILabel *label = UIUtil::LabelWithFrame(frame, @"没有内容", [UIFont systemFontOfSize:14], UIUtil::Color(0x807e7a), NSTextAlignmentCenter);
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
	
//	CGFloat y = CGRectGetMaxY(label.frame) + 4;
//	UIButton *loginButton = [UIButton linkButtonWithTitle:@"登录" frame:CGRectMake(view.frame.size.width / 2 - 8 - 40, y, 40, 0)];
//	[loginButton addTarget:DataLoader.class action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
//	loginButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
//	[view addSubview:loginButton];
//	
//	UIButton *registerButton = [UIButton linkButtonWithTitle:@"注册" frame:CGRectMake(view.frame.size.width / 2 + 8, y, 40, 0)];
//	registerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
//	[registerButton addTarget:self action:@selector(registerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//	[view addSubview:registerButton];
	
	return view;
}

@end
