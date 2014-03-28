
//
#ifdef _ExViewController
@interface UIViewController (ExViewController)
- (void)dismissModalViewController;
- (UINavigationController *)presentNavigationController:(UIViewController *)controller animated:(BOOL)animated;
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated;
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated dismissButtonTitle:(NSString *)dismissButtonTitle;
@end
#endif

//
#ifdef _ExBarButtonItem
@interface UIBarButtonItem (ExBarButtonItem)
+ (id)buttonItemWithImage:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)action;
+ (id)buttonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (id)buttonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
@end
#endif
