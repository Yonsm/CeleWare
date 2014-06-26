
#import "LoginController.h"
#import "RootController.h"

@implementation LoginController

#pragma mark Generic methods

// Constructor
//- (id)init
//{
//	self = [super init];
//	return self;
//}

//
- (void)createSubviews
{
	
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
		
		CGRect frame = {(_loginPane.frame.size.width - 273) / 2, 96, 273, 38};
		{
			_usernameField = [[InputBox alloc] initWithFrame:frame iconName:@"UserIcon"];
			[_usernameField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
			[_loginPane addSubview:_usernameField];
		}
		frame.origin.y = 160;
		{
			_passwordField = [[InputBox alloc] initWithFrame:frame iconName:@"PassIcon"];
			[_passwordField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
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
		
		[_usernameField addTarget:_passwordField action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
		[_passwordField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
		
		UIUtil::AddTapGesture(self.view, _loginPane, @selector(endEditing:));
	}
	_footView.alpha = 0;
	_loginPane.alpha = 0;
}

//
- (void)showSubviews
{
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
	[self createSubviews];
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
#define _HAS_PENDING_OPERATION
#ifdef _HAS_PENDING_OPERATION
	[self.view toastWithLoading].center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height * 3 / 4);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
				   {
					   // TODO: 如果有网络请求
					   [NSThread sleepForTimeInterval:2];
					   
					   dispatch_async(dispatch_get_main_queue(), ^()
									  {
										  [self.view dismissToast];
										  [self showSubviews];
									  });
				   });
#else
	[self showSubviews];
#endif
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

#pragma mark Event methods

//
- (void)textFieldChanged:(UITextField *)sender
{
	[self updateDoneButton];
}

//
- (void)textFieldDone:(UITextField *)sender
{
	if (_doneButton.enabled)
	{
		[self doneButtonClicked:nil];
	}
	else
	{
		[_usernameField becomeFirstResponder];
	}
}

//
- (void)updateDoneButton
{
	_doneButton.enabled = (_usernameField.text.length != 0) && (_passwordField.text.length != 0);
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
