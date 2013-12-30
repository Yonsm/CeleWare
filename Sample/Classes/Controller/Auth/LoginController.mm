
#import "LoginController.h"
#import "RegisterController.h"

@implementation LoginController

#pragma mark Generic methods

// Constructor
- (id)init
{
	self = [super initWithAutoHide:YES autoNext:NO autoScroll:NO];
	//self.title = @"登录";
	
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem buttonItemWithTitle:@"登录" target:self action:@selector(doneButtonClicked:)];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
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
//- (void)viewWillAppear:(BOOL)animated
//{
//	[super viewWillAppear:animated];
//}

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
										 text:Settings::Get(kUsername)
								  placeholder:@"请输入11位手机号码"
									  changed:@selector(updateDoneButton)];
	[_usernameField becomeFirstResponder];
	
	_passwordField = [self cellTextWithName:@"密　码"
									   text:nil
								placeholder:@"请输入密码"
									changed:@selector(updateDoneButton)];
	_passwordField.secureTextEntry = YES;
	
	//DataLoaderPasswordError
	
	[super buttonsWithTitles:@[@"忘记密码", @"注册帐号"] action:@selector(buttonClicked:)];
	
#ifdef TEST
	[super buttonsWithTitles:@[@"好男人", @"masterB"] action:@selector(testButtonClicked:)];
#endif
}

#pragma mark Event methods

//
- (void)buttonClicked:(UIButton *)sender
{
	RegisterController *controller = [[RegisterController alloc] init];
	controller.forgot = !sender.tag;
	[self.navigationController pushViewController:controller animated:YES];
}

//
#ifdef TEST
- (void)testButtonClicked:(UIButton *)sender
{
	_usernameField.text = sender.tag ? @"18610103505" : @"18901398225";
	_passwordField.text = sender.tag ? @"justdoit" : @"123456";
	[self updateDoneButton];
}
#endif

//
- (void)updateDoneButton
{
	self.navigationItem.rightBarButtonItem.enabled = (_usernameField.text.length == 11) && (_passwordField.text.length != 0);
}

//
- (void)doneAction
{
	Settings::Set(kUsername, _usernameField.text);
	Settings::EncryptSet(kPassword, _passwordField.text);
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
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
			 self.navigationItem.rightBarButtonItem.enabled = YES;
			 return;
		 }
		 Settings::Save();
		 [self.navigationController dismissModalViewController];
	 }];
}

@end
