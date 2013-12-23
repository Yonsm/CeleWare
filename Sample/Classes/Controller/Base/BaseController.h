
#define kScrollViewBottomPad 30

//
@protocol WizardControllerDelegate
- (id)init;
- (id)initWithParam:(id)param;	// 请注意：param 参数为 nil 时将调用 init 而不是 initWithParam
@end

//
@interface BaseController : UIViewController
{
	BOOL _needLogin;
}
- (void)backButtonClicked:(UIButton *)sender;
@end

