
#import "LoginController.h"
#import "RootController.h"
#import "EXButton.h"

@implementation LoginController

#pragma mark Generic methods

// Constructor
//- (id)init
//{
//	self = [super init];
//	return self;
//}

#pragma mark View methods

// Creates the view that the controller manages.
- (void)loadView
{
	UIImageView *view = [[UIImageView alloc] initWithImage:UIUtil::Image(@"Background")];
	view.userInteractionEnabled = YES;
	self.view = view;
}

// Do additional setup after loading the view.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	CGRect bounds = self.view.bounds;
	
	{
		_logoView = [[UIImageView alloc] initWithImage:UIUtil::Image(@"LoginLogo")];
		_logoView.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
		_logoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self.view addSubview:_logoView];
	}
	{
		_footView = [[UIImageView alloc] initWithImage:UIUtil::Image(@"LoginFooter")];
		_footView.center = CGPointMake(bounds.size.width / 2, bounds.size.height - _footView.frame.size.height / 2);
		_footView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
		[self.view addSubview:_footView];
	}
	{
		_loginPane = [[UIImageView alloc] initWithImage:UIUtil::Image(@"LoginPane")];
		_loginPane.center = CGPointMake(bounds.size.width / 2, 60 + bounds.size.height / 2);
		_loginPane.userInteractionEnabled = YES;
		_loginPane.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self.view addSubview:_loginPane];
		
		{
			UILabel *label = UIUtil::LabelWithFrame(CGRectMake(0, 40, _loginPane.frame.size.width, 30),
													NSLocalizedString(@"Sales Login", @"促销员登录"),
													[UIFont systemFontOfSize:20],
													UIUtil::Color(0x393939),
													NSTextAlignmentCenter);
			[_loginPane addSubview:label];
		}
		
		UIImage *fieldBg = UIUtil::Image(@"InputBox");
		CGRect frame = {(_loginPane.frame.size.width - fieldBg.size.width) / 2, 96, fieldBg.size.width, fieldBg.size.height};
		{
			_usernameField = [[UITextField alloc] initWithFrame:frame];
			_usernameField.background = fieldBg;
			_usernameField.leftView = [[UIImageView alloc] initWithImage:UIUtil::Image(@"UserIcon")];
			_usernameField.leftViewMode = UITextFieldViewModeAlways;
			[_usernameField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
			[_usernameField addTarget:self action:@selector(textFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
			[_usernameField addTarget:self action:@selector(textFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
			[_loginPane addSubview:_usernameField];
		}
		frame.origin.y = 160;
		{
			_passwordField = [[UITextField alloc] initWithFrame:frame];
			_passwordField.background = fieldBg;
			_passwordField.leftView = [[UIImageView alloc] initWithImage:UIUtil::Image(@"PassIcon")];
			_passwordField.leftViewMode = UITextFieldViewModeAlways;
			[_passwordField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
			[_passwordField addTarget:self action:@selector(textFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
			[_passwordField addTarget:self action:@selector(textFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
			[_loginPane addSubview:_passwordField];
		}
		frame.origin.x -= 5;
		frame.origin.y = 220;
		{
			_rememberButton = [UIButton checkButtonWithTitle:NSLocalizedString(@"Remember Me", @"记住我") frame:frame];
			[_loginPane addSubview:_rememberButton];
		}
		{
			_doneButton = [UIButton buttonWithTitle:NSLocalizedString(@"Login", @"登录") name:@"Push" width:85];
			_doneButton.enabled = NO;
			_doneButton.center = CGPointMake(CGRectGetMaxX(_passwordField.frame) - 85/2, _rememberButton.center.y);
			[_doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[_loginPane addSubview:_doneButton];
		}
		
		UIUtil::AddTapGesture(self.view, _loginPane, @selector(endEditing:));
	}
	_footView.alpha = 0;
	_loginPane.alpha = 0;
}

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES];
}

//
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
	
	[UIView animateWithDuration:0.5 animations:^()
	 {
		 _logoView.center = CGPointMake(self.view.bounds.size.width / 2, _logoView.frame.size.height / 2);
		 _loginPane.alpha = 1;
		 _footView.alpha = 1;
	 } completion:^(BOOL finished)
	 {
		 //[_usernameField.text.length ? _passwordField : _usernameField becomeFirstResponder];
	 }];
}

//
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark Keyboard methods

//
- (void)keyboardWillShow:(NSNotification *)notification
{
	CGRect rect;
	NSValue *value = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	[value getValue:&rect];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	[UIView setAnimationCurve:(UIViewAnimationCurve)[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
	_loginPane.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height - rect.size.width) / 2);
	//	_logoView.center = CGPointMake(self.view.bounds.size.width / 2, -_logoView.frame.size.height / 2);
	//	_footView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height + _footView.frame.size.height / 2);
	_logoView.alpha = 0;
	_footView.alpha = 0;
	[UIView commitAnimations];
}

//
- (void)keyboardWillHide:(NSNotification *)notification
{
	CGRect rect;
	NSValue *value = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	[value getValue:&rect];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	[UIView setAnimationCurve:(UIViewAnimationCurve)[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
	_loginPane.center = CGPointMake(self.view.bounds.size.width / 2, 60 + (self.view.bounds.size.height) / 2);
	//_logoView.center = CGPointMake(self.view.bounds.size.width / 2, _logoView.frame.size.height / 2);
	//_footView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - _footView.frame.size.height / 2);
	_logoView.alpha = 1;
	_footView.alpha = 1;
	[UIView commitAnimations];
}

#pragma mark Data methods

//
- (void)loadPage
{
	
}

#pragma mark Event methods

//
- (void)textFieldEditingDidBegin:(UITextField *)sender
{
	sender.background = UIUtil::Image(@"InputBox_");
}

//
- (void)textFieldEditingDidEnd:(UITextField *)sender
{
	sender.background = UIUtil::Image(@"InputBox");
}

//
- (void)textFieldChanged:(UITextField *)sender
{
	[self updateDoneButton];
}

//
- (void)updateDoneButton
{
	_doneButton.enabled = (_usernameField.text.length != 0) && (_passwordField.text.length != 0);
}

//
- (void)doneButtonClicked:(id)sender
{
	UIView *focusView = UIUtil::FindFirstResponder(self.view);
	if (focusView)
	{
		[focusView resignFirstResponder];
		[self performSelector:@selector(doneAction) withObject:nil afterDelay:0.3];
	}
	else
	{
		[self doneAction];
	}
}

//
- (void)doneAction
{
	Settings::Set(kUsername, _usernameField.text);
	Settings::EncryptSet(kPassword, _passwordField.text);
	
	//_lastButton.enabled = NO;
	//	[DataLoader loadWithService:nil params:nil completion:^(DataLoader *loader)
	//	 {
	//		 if (loader.error != DataLoaderNoError)
	//		 {
	//			 Settings::Save(kPassword);
	//			 if (loader.error == DataLoaderPasswordError)
	//			 {
	//				 _passwordField.text = nil;
	//				 [self updateDoneButton];
	//				 [_passwordField becomeFirstResponder];
	//			 }
	//			 else
	//			 {
	//				 _lastButton.enabled = YES;
	//			 }
	//			 return;
	//		 }
	
	Settings::Save();
	UIViewController *controller = [[RootController alloc] init];
	[self.navigationController setViewControllers:@[controller] animated:YES];
	//	 }];
}

@end
