
#import "LoginController.h"
//#import "ForgotController.h"
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

// Destructor
//- (void)dealloc
//{
//	[super dealloc];
//}

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

// Called after the view controller's view is released and set to nil.
//- (void)viewDidUnload
//{
//	[super viewDidUnload];
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
	{
		[[self cellNumberWithName:@"手机号"
							 text:nil
					  placeholder:@"请输入11位手机号码"
						  changed:@selector(updateDoneButton)]
		 becomeFirstResponder];
		
		[self cellTextWithName:@"密　码"
						  text:nil
				   placeholder:@"请输入密码"
					   changed:@selector(updateDoneButton)]
		.secureTextEntry = YES;
	}
	
	{
		[super buttonsWithTitles:@[@"忘记密码", @"注册帐号"] action:@selector(buttonClicked:)];
		
#ifdef TEST
		[self buttonWithTitle:@"测试帐号" action:@selector(testButtonClicked:)];
#endif
	}
}

#pragma mark Event methods

//
- (void)buttonClicked:(UIButton *)sender
{
	if (sender.tag == 1)
	{
		UIViewController *controller = [[[RegisterController alloc] init] autorelease];
		[self.navigationController pushViewController:controller animated:YES];
	}
	else
	{
	}
}

//
#ifdef TEST
- (void)testButtonClicked:(id)sender
{
	UITextField *usernameField = (UITextField *)[_cells[0] accessoryView];
	UITextField *passwordField = (UITextField *)[_cells[1] accessoryView];
	usernameField.text = @"18901398225";
	passwordField.text = @"123456";
	[self updateDoneButton];
}
#endif

//
- (void)updateDoneButton
{
	UITextField *usernameField = (UITextField *)[_cells[0] accessoryView];
	UITextField *passwordField = (UITextField *)[_cells[1] accessoryView];
	self.navigationItem.rightBarButtonItem.enabled = (usernameField.text.length == 11) && (passwordField.text.length != 0);
}

//
- (void)doneAction
{
//	UITextField *usernameField = (UITextField *)[_cells[0] accessoryView];
//	UITextField *passwordField = (UITextField *)[_cells[1] accessoryView];
	
//	Settings::Set(kUsername, usernameField.text);
//	Settings::EncryptSet(kPassword, passwordField.text);
//	
//	[DataLoader loaderWithService:nil params:nil success:^(DataLoader *loader)
//	 {
//		 Settings::Save();
//		 [self.navigationController dismissModalViewController];
//	 }];
}

@end
