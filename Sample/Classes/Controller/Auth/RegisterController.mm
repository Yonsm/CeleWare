
#import "RegisterController.h"
//#import "BasicProfileController.h"

@implementation RegisterController

#pragma mark Generic methods

// Constructor
- (id)init
{
	self = [super init];
	self.forgot = NO;
	return self;
}

//
- (void)setForgot:(BOOL)forgot
{
	_forgot = forgot;
	self.title = forgot? @"重置密码" : @"注册帐号";
}

#pragma mark View methods

// Creates the view that the controller manages.
//- (void)loadView
//{
//	[super loadView];
//}

// Do additional setup after loading the view.
//- (void)viewDidLoad
//{
//	[super viewDidLoad];
//}

// 
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[_usernameField becomeFirstResponder];
}

// Called after the view was dismissed, covered or otherwise hidden.
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//}

#pragma mark Data methods

//
- (void)loadPage
{
	_usernameField = [self cellNumberWithName:@"手机号"
										 text:nil
								  placeholder:@"请输入手机号码"
									  changed:@selector(phoneFieldChanged:)];
	
	{
		_usernameField.adjustsFontSizeToFitWidth = YES;
		CGRect frame  = _usernameField.frame;
		frame.size.width -= 85;
		_usernameField.frame = frame;
		
		// NEXT: 重整 WizardCell，支持Icon Name Value Accessory，所有均可为 UIView，Icon Name 支持居中或上对齐，Value支持底部对齐或者顶部对齐，Accessory 右上或者右中
		UIFont *font = [UIFont systemFontOfSize:14];
		_authButton = [[UIButton alloc] initWithFrame:CGRectMake(310 - 80, 6, 84, 30)];
		_authButton.titleLabel.font = font;
		[_authButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
		[_authButton setBackgroundImage:UIUtil::ImageWithColor(0x007aff) forState:UIControlStateNormal];
		[_authButton setBackgroundImage:UIUtil::ImageWithColor(0x209aff) forState:UIControlStateHighlighted];
		[_authButton setTitle:@"获取验证码" forState:UIControlStateNormal];
		[_usernameField.superview addSubview:_authButton];
		[_authButton addTarget:self action:@selector(authButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		_authButton.enabled = NO;
	}
	
	_authCodeField = [self cellNumberWithName:@"验证码"
										 text:nil
								  placeholder:@"请输入手机短信收到的验证码"
									  changed:@selector(updateDoneButton)];
	_authCodeField.enabled = NO;
	
	_passwordField = [self cellTextWithName:@"密　码"
									   text:nil
								placeholder:@"请输入要设定的密码"
									changed:@selector(updateDoneButton)];
	_passwordField.secureTextEntry = YES;
	
	if (!_forgot)
	{
		[self spaceWithHeight:10];
		UILabel *tips = [self tipsWithTitle:@"点击 注册 即表示同意"];
		CGRect frame = tips.frame;
		frame.origin.x += [tips.text sizeWithFont:tips.font].width;
		frame.size.width = 80;
		UIButton *button = [UIButton linkButtonWithTitle:@"《用户协议》" frame:frame];
		button.titleLabel.font = tips.font;
		[button addTarget:self action:@selector(agreementButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[_contentView addSubview:button];
		[self spaceWithHeight:-10];
	}
	
	[self majorButtonWithTitle:_forgot ? @"重置" : @"注册" action:@selector(doneButtonClicked:)].enabled = NO;
}

#pragma mark Event methods

//
- (void)agreementButtonClicked:(id)sender
{
	[_contentView.findFirstResponder resignFirstResponder];

	UIViewController *controller = [[WebController alloc] initWithURL:[NSURL fileURLWithPath:NSUtil::AssetPath(@"user_agreement.txt")]];
	controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
	controller.modalPresentationStyle = UIModalPresentationFormSheet;
	[self.navigationController presentModalNavigationController:controller animated:YES];
}

//
- (void)phoneFieldChanged:(UITextField *)sender
{
	_authButton.enabled = (sender.text.length == 11);
	[self updateDoneButton];
}

//
- (void)authButtonClicked:(UIButton *)sender
{
	sender.enabled = NO;
	[DataLoader loadWithService:@"/api/passport/phone/getAuthCode.json"
						 params:@{
								  @"phone":_usernameField.text,
								  @"source":kAuthConsumerKey,
								  @"authCodeType":_forgot ? @"resetPassword" : @"register",
								  }
					 completion:^(DataLoader *loader)
	 {
		 if (loader.error == DataLoaderNoError)
		 {
			 [self authTimerFired:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(authTimerFired:) userInfo:nil repeats:YES]];
			 [ToastView toastWithSuccess:@"验证码已发送"];
			 _authCodeField.enabled = YES;
			 [_authCodeField becomeFirstResponder];
		 }
		 else
		 {
			 sender.enabled = YES;
		 }
	 }];
}

//
- (void)authTimerFired:(NSTimer *)sender
{
	if (_authTimeout == 60)
	{
		_authTimeout = 0;
		[sender invalidate];
		_authButton.enabled = YES;
		[_authButton setTitle:@"重新获取" forState:UIControlStateNormal];
	}
	else
	{
		[_authButton setTitle:[NSString stringWithFormat:@"重新获取(%d)", 60 - ++_authTimeout] forState:UIControlStateNormal];
	}
}

//
- (void)updateDoneButton
{
	_lastButton.enabled =
	(_usernameField.text.length == 11) &&
	(_authCodeField.text.length == 6) &&
	(_passwordField.text.length >= 6);
}

//
- (void)doneAction
{
}
@end
