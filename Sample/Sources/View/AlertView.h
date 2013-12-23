
//
@interface AlertView : UIImageView
{
	id<UIAlertViewDelegate> _delegate;
	SEL _clickAction;
	id _clickParam;

	UILabel *_titleLabel;
	UILabel *_messageLabel;
	UIButton *_cancelButton;
	UIButton *_otherButton;
	
	BOOL _fitKeyboard;
	
	UITextField *_textField;
}

@property(nonatomic,readonly) UILabel *titleLabel;
@property(nonatomic,readonly) UILabel *messageLabel;
@property(nonatomic,readonly) UIActivityIndicatorView *activityIndicator;
@property(nonatomic,readonly) UITextField *textField;
@property(nonatomic,assign) id/*<UIAlertViewDelegate>*/ delegate;
@property(nonatomic,assign) SEL clickAction;
@property(nonatomic,assign) id clickParam;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id/*<UIUIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle accessoryView:(UIView *)accesoryView;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id/*<UIUIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;

- (void)show;
- (void)showInView:(UIView *)parent;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;
- (void)dismissOnMainThread;
- (void)dismiss;

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle accessoryView:(UIView *)accessoryView;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (id)alertWithTitle:(NSString *)title;
+ (id)alertWithTask:(id/*<AlertViewExDelegate>*/)delegate title:(NSString *)title;

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle target:(id)target action:(SEL)action param:(id)param;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle target:(id)target action:(SEL)action;

@end
