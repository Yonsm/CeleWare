
#define kScrollViewBottomPad 30

#import "DataLoader.h"

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

