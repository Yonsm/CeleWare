
#import "UIAddition.h"
#import "UIUtil.h"


#pragma mark UIViewController methods
#ifdef _ExViewController
@implementation UIViewController (ExViewController)

//
#ifndef _NavigationController
#define _NavigationController UINavigationController
#endif
- (UINavigationController *)presentNavigationController:(UIViewController *)controller animated:(BOOL)animated
{
	UINavigationController *navigator = [[_NavigationController alloc] initWithRootViewController:controller];
	navigator.modalTransitionStyle = controller.modalTransitionStyle;
	navigator.modalPresentationStyle = controller.modalPresentationStyle;
	
#ifdef _NavigationBarTintColor
	navigator.toolbar.tintColor = navigator.navigationBar.tintColor = _NavigationBarTintColor;
#endif
	
	if (animated)
	{
		// MAGIC: Fix Alipay Cell's Bug
		[self performSelector:@selector(presentViewController:) withObject:navigator afterDelay:0.01];
		return navigator;
	}
	
	[self presentViewController:navigator animated:animated completion:nil];
	return navigator;
}

//
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated dismissButtonTitle:(NSString *)dismissButtonTitle
{
#ifndef _BarButtonItem
#define _BarButtonItem UIBarButtonItem
#endif
#ifndef _buttonItemWithTitle
#define _buttonItemWithTitle buttonItemWithTitle
#endif
	controller.navigationItem.leftBarButtonItem = [_BarButtonItem _buttonItemWithTitle:dismissButtonTitle
																				target:self.navigationController
																				action:@selector(dismissModalViewController)];
	return [self presentNavigationController:controller animated:animated];
}

//
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated
{
	return [self presentModalNavigationController:controller animated:animated dismissButtonTitle:NSLocalizedString(@"Back", @"返回")];
}

//
- (void)presentViewController:(UIViewController *)controller
{
	[self presentViewController:controller animated:YES completion:nil];
}

//
- (void)dismissModalViewController
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
#endif

#pragma mark Bar button item methods
#ifdef _ExBarButtonItem
@implementation UIBarButtonItem (ExBarButtonItem)

//
+ (id)buttonItemWithImage:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)action
{
	UIFont *font = title ? [UIFont boldSystemFontOfSize:13] : nil;
	CGRect frame = {0, 0, [title sizeWithFont:font].width + image.size.width, image.size.height};
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	
	if (title)
	{
		button.titleLabel.font = font;
		[button setTitle:title forState:UIControlStateNormal];
		[button setBackgroundImage:UIUtil::StretchableImage(image) forState:UIControlStateNormal];
	}
	else
	{
		button.showsTouchWhenHighlighted = YES;
		[button setImage:image forState:UIControlStateNormal];
	}
	
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	return [[UIBarButtonItem alloc] initWithCustomView:button];
}

//
+ (id)buttonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
	return [self buttonItemWithImage:image title:nil target:target action:action];
}

//
+ (id)buttonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
	return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:target action:action];
}

@end
#endif
