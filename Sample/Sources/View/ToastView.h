

@interface ToastView : UIView
{
}
- (id)initWithTitle:(NSString *)title loading:(BOOL)loading;
@end

//
@interface UIView (ToastView)

- (ToastView *)showToast:(NSString *)title loading:(BOOL)loading;
- (ToastView *)showToast:(NSString *)title;
- (void)showLoading;
- (void)hideLoading;

+ (ToastView *)showToast:(NSString *)title loading:(BOOL)loading;
+ (ToastView *)showToast:(NSString *)title;

+ (void)showLoading;
+ (void)hideLoading;
@end
