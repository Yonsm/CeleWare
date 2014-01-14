
#import "NavigationController.h"

@implementation UIBarButtonItem (Ex)

+ (id)_buttonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
	UIFont *font = [UIFont systemFontOfSize:17];
	CGRect frame;
	frame.origin.x = frame.origin.y = 0;
	frame.size = [title sizeWithFont:font];
	frame.size.width += 2;
	if (frame.size.height < 22) frame.size.height = 22;
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	[button setTitleColor:UIUtil::Color(0x4d4b47) forState:UIControlStateNormal];
	[button setTitleColor:UIUtil::Color(0x807e7a) forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	[button setTitle:title forState:UIControlStateNormal];
	button.titleLabel.font = font;
	
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	return [[UIBarButtonItem alloc] initWithCustomView:button];
}

//
+ (id)_buttonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action imageNamed:(NSString *)imageNamed
{
	UIBarButtonItem *item = [self _buttonItemWithTitle:title target:target action:action];
	
	UIButton *button = (UIButton *)item.customView;
	[button setImage:UIUtil::Image(imageNamed) forState:UIControlStateNormal];
	[button setImage:UIUtil::Image([imageNamed stringByAppendingString:@"_"]) forState:UIControlStateHighlighted];
	[button sizeToFit];
	
	return item;
}

//
+ (id)_backItemWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
	return [self _buttonItemWithTitle:title target:target action:action imageNamed:@"NaviBack"];
}

@end

//
@implementation NavigationController

#pragma mark Generic methods

//
- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	self = [super initWithRootViewController:rootViewController];
	self.navigationBar.translucent = NO;
	[self.navigationBar setBackgroundImage:[UIImage imageWithColor:UIUtil::Color(0xf8f8f8)] forBarMetrics:UIBarMetricsDefault];

	if (!UIUtil::IsOS7())
	{
		self.navigationBar.shadowImage = UIUtil::Image(@"NaviBar_");
		self.navigationBar.titleTextAttributes = @
		{
		UITextAttributeFont: [UIFont systemFontOfSize:18],
		UITextAttributeTextColor: UIUtil::Color(49, 49, 49),
		UITextAttributeTextShadowColor: [UIColor clearColor],
		UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeZero],
		};
		
#ifdef _AllNaviButton
		self.delegate = self;
#endif
	}
	
	return self;
}

#pragma mark NavagationBar delegate

//
#if _AllNaviButton
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	UIBarButtonItem *leftItem = viewController.navigationItem.leftBarButtonItem;
	if (leftItem && leftItem.title)
	{
		viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem _buttonItemWithTitle:leftItem.title target:leftItem.target action:leftItem.action];
	}
	else if (!viewController.navigationItem.hidesBackButton && !leftItem && (navigationController.viewControllers.count > 1))
	{
		viewController.navigationItem.leftBarButtonItem =[UIBarButtonItem _backItemWithTitle:@"返回" target:self action:@selector(backButtonClicked:)];
	}
	
	UIBarButtonItem *rightItem = viewController.navigationItem.rightBarButtonItem;
	if (rightItem && rightItem.title)
	{
		viewController.navigationItem.rightBarButtonItem = [UIBarButtonItem _buttonItemWithTitle:rightItem.title target:rightItem.target action:rightItem.action];
	}
}

//
- (void)backButtonClicked:(UIButton *)sender
{
	[self popViewControllerAnimated:YES];
}
#endif

@end
