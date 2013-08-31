
#import "NavigationController.h"

//
@implementation NavigationController

#pragma mark Generic methods

// Destructor
- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	self = [super initWithRootViewController:rootViewController];
	
	self.delegate = self;
	UIImage *image = UIUtil::Image(@"NaviBar.png");
#ifdef kNavigationBarTintColor
	self.toolbar.tintColor = self.navigationBar.tintColor = kNavigationBarTintColor;
#endif
	[self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
	
	return self;
}

#pragma mark NavagationBar delegate

//
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	UIBarButtonItem *leftItem = viewController.navigationItem.leftBarButtonItem;
	if (leftItem && leftItem.title)
	{
		viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImage:UIUtil::ImageNamed(@"NaviLeft.png") title:leftItem.title target:leftItem.target action:leftItem.action];
	}
	else if (!leftItem && (navigationController.viewControllers.count > 1))
	{
		viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImage:UIUtil::ImageNamed(@"NaviLeft.png") title:@"返回" target:self action:@selector(backButtonClicked:)];
	}
	
	UIBarButtonItem *rightItem = viewController.navigationItem.rightBarButtonItem;
	if (rightItem && rightItem.title)
	{
		viewController.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithImage:UIUtil::ImageNamed(@"NaviRight.png") title:rightItem.title target:rightItem.target action:rightItem.action];
	}
}

//
- (void)backButtonClicked:(UIButton *)sender
{
	[self popViewControllerAnimated:YES];
}

@end
