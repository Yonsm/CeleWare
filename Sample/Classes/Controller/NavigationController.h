
//
@interface UIBarButtonItem (Ex)
+ (id)_backItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (id)_buttonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (id)buttonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
@end

//
@interface NavigationController : UINavigationController <UINavigationControllerDelegate>
{
}

@end

