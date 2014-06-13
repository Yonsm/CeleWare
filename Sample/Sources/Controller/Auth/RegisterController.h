
#import "AutoWizardController.h"

//
@interface RegisterController : AutoWizardController
{
	int _authTimeout;
	UIButton *_authButton;
	UITextField *_usernameField;
	UITextField *_authCodeField;
	UITextField *_passwordField;
}
@property(nonatomic,assign) BOOL forgot;
@end
