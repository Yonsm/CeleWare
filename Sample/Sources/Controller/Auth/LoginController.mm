
#import "LoginController.h"
#import "RegisterController.h"

@implementation LoginController

#pragma mark Generic methods

// Constructor
- (id)init
{
	self = [super initWithAutoHide:YES autoNext:NO autoScroll:NO];
	self.title = @"我的账户";
	
	return self;
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

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[_usernameField.text.length ? _passwordField : _usernameField becomeFirstResponder];
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
	NSString *username = Settings::Get(kUsername);
	_usernameField = [self cellNumberWithName:@"手机号"
										 text:username
								  placeholder:@"请输入11位手机号码"
									  changed:@selector(updateDoneButton)];
	
	_passwordField = [self cellTextWithName:@"密　码"
									   text:nil
								placeholder:@"请输入密码"
									changed:@selector(updateDoneButton)];
	_passwordField.secureTextEntry = YES;
	
	//DataLoaderPasswordError
	
	[super buttonsWithTitles:@[@"注册", @"登录"] action:@selector(buttonClicked:)];
	_lastButton.enabled = NO;
	
	//
	_contentHeight += 12;
	CGRect frame = {kLeftGap, _contentHeight, 0, 0};
	UIButton *forgotButton = [UIButton linkButtonWithTitle:@"忘记密码？" frame:frame];
	forgotButton.tag = 2;
	[forgotButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[_contentView addSubview:forgotButton];
	_contentHeight += frame.size.height;
}

#pragma mark Event methods

//
- (void)buttonClicked:(UIButton *)sender
{
	if (sender.tag == 1)
	{
		[self doneButtonClicked:sender];
		return;
	}
	
	RegisterController *controller = [[RegisterController alloc] init];
	controller.forgot = (sender.tag == 2);
	[self.navigationController pushViewController:controller animated:YES];
}

//
- (void)updateDoneButton
{
	_lastButton.enabled = (_usernameField.text.length == 11) && (_passwordField.text.length >= 6);
}

//
- (void)doneAction
{
	Settings::Set(kUsername, _usernameField.text);
	Settings::EncryptSet(kPassword, _passwordField.text);
	
	_lastButton.enabled = NO;
	[DataLoader loadWithService:nil params:nil completion:^(DataLoader *loader)
	 {
		 if (loader.error != DataLoaderNoError)
		 {
			 Settings::Save(kPassword);
			 if (loader.error == DataLoaderPasswordError)
			 {
				 _passwordField.text = nil;
				 [self updateDoneButton];
				 [_passwordField becomeFirstResponder];
			 }
			 else
			 {
				 _lastButton.enabled = YES;
			 }
			 return;
		 }
		 
		 Settings::Save();
		 [self.navigationController dismissModalViewController];
	 }];
}

@end
