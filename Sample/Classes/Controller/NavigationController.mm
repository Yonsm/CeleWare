
#import "NavigationController.h"

//
@implementation NavigationController

#pragma mark Generic methods

//
- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	self = [super initWithRootViewController:rootViewController];
	
	self.delegate = self;
#ifdef _NavigationBarTintColor
	self.toolbar.tintColor = self.navigationBar.tintColor = _NavigationBarTintColor;
#endif
	
#ifdef _NavigationBarImage
	[self.navigationBar setBackgroundImage:_NavigationBarImage forBarMetrics:UIBarMetricsDefault];
#endif
	
	return self;
}

#pragma mark NavagationBar delegate

#ifndef _NaviBackItem
#define _NaviBackItem(t, o, a) [UIBarButtonItem buttonItemWithImage:UIUtil::ImageNamed(@"NaviLeft.png") title:t target:o action:a];
#endif
#ifndef _NaviLeftItem
#define _NaviLeftItem(t, o, a) [UIBarButtonItem buttonItemWithImage:UIUtil::ImageNamed(@"NaviLeft.png") title:t target:o action:a];
#endif
#ifndef _NaviRightButton
#define _NaviRightButton(t, o, a) [UIBarButtonItem buttonItemWithImage:UIUtil::ImageNamed(@"NaviRight.png") title:t target:o action:a];
#endif

//
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	UIBarButtonItem *leftItem = viewController.navigationItem.leftBarButtonItem;
	if (leftItem && leftItem.title)
	{
		viewController.navigationItem.leftBarButtonItem = _NaviLeftItem(leftItem.title, leftItem.target, leftItem.action);
	}
	else if (!viewController.navigationItem.hidesBackButton && !leftItem && (navigationController.viewControllers.count > 1))
	{
		viewController.navigationItem.leftBarButtonItem = _NaviBackItem(@"返回", self, @selector(backButtonClicked:));
	}
	
	UIBarButtonItem *rightItem = viewController.navigationItem.rightBarButtonItem;
	if (rightItem && rightItem.title)
	{
		viewController.navigationItem.rightBarButtonItem = _NaviRightButton(rightItem.title, rightItem.target, rightItem.action);
	}
}

//
- (void)backButtonClicked:(UIButton *)sender
{
	[self popViewControllerAnimated:YES];
}

@end
