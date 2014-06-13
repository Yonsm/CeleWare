
//
typedef NS_ENUM(NSInteger, ToastViewType)
{
	ToastViewDefault,
	ToastViewInfo = ToastViewDefault,
	ToastViewError,
	ToastViewCancel = ToastViewError,
	ToastViewSuccess,
	ToastViewLoading,
};

//
@interface ToastView : UIView
{
}
- (id)initWithTitle:(NSString *)title type:(ToastViewType)type;

+ (ToastView *)toastWithTitle:(NSString *)title type:(ToastViewType)type;
+ (ToastView *)toastWithTitle:(NSString *)title;
+ (ToastView *)toastWithInfo:(NSString *)info;
+ (ToastView *)toastWithError:(NSString *)error;
+ (ToastView *)toastWithCancel:(NSString *)cancel;
+ (ToastView *)toastWithSuccess:(NSString *)success;
+ (ToastView *)toastWithLoading:(NSString *)loading;
+ (ToastView *)toastWithLoading;
+ (void)dismissToast;
@end

//
@interface UIView (ToastView)

- (ToastView *)toastWithTitle:(NSString *)title type:(ToastViewType)type;
- (ToastView *)toastWithTitle:(NSString *)title;
- (ToastView *)toastWithInfo:(NSString *)info;
- (ToastView *)toastWithError:(NSString *)error;
- (ToastView *)toastWithCancel:(NSString *)cancel;
- (ToastView *)toastWithSuccess:(NSString *)success;
- (ToastView *)toastWithLoading:(NSString *)loading;
- (ToastView *)toastWithLoading;
- (void)dismissToast;
@end
