
#import "AutoWizardController.h"


@implementation AutoWizardController

//
- (id)initWithAutoHide:(BOOL)autoHide autoNext:(BOOL)autoNext autoScroll:(BOOL)autoScroll
{
	self = [super init];
	_noAutoHide = !autoHide;
	_noAutoNext = !autoNext;
	_noAutoScroll = !autoScroll;
	return self;
}

//

//
- (void)lookupTextFieldsInView:(UIView *)view
{
	for (UITextField *subview in view.subviews)
	{
		if ([subview isKindOfClass:[UITextField class]])
		{
			[self pushTextField:(UITextField *)subview];
		}
		else
		{
			[self lookupTextFieldsInView:subview];
		}
	}
}

//
- (void)pushTextField:(UITextField *)textField
{
	if (!_noAutoNext)
	{
		if (_textFields == nil)
		{
			_textFields = [[NSMutableArray alloc] init];
		}
		else if ([_textFields containsObject:textField])
		{
			return;
		}
		else
		{
			UITextField *previous = [_textFields lastObject];
			previous.returnKeyType = UIReturnKeyNext;
		}
		[_textFields addObject:textField];
		
		if (!(textField.allControlEvents & UIControlEventEditingDidEndOnExit))
		{
			textField.returnKeyType = UIReturnKeyDone;
			[textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
		}
	}
	
	if (!_noAutoScroll)
	{
		[textField addTarget:self action:@selector(textFieldBegin:) forControlEvents:UIControlEventEditingDidBegin];
	}
}

#pragma mark View methods

//
- (void)viewDidLoad
{
	[super viewDidLoad];
	if (!_noAutoHide)
	{
		[self.view addTapGestureRecognizerWithTarget:_contentView action:@selector(hideKeyboard)];
	}
}

//
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!_noAutoScroll)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
	}
}

//
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	if (!_noAutoScroll)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	}
}

#pragma mark Keyboard methods

//
- (void)centerView:(UIView *)view
{
	CGPoint center = view.center;
	if (view.superview != _scrollView)
	{
		center = [_scrollView convertPoint:center fromView:view.superview];
	}
	//center.y += self.centerOffset;	// Allow subclass to ajust center offset
	
	CGRect frame = _scrollView.frame;
	CGFloat max = _scrollView.contentSize.height - frame.size.height;
	CGFloat min = center.y - (view.frame.size.height / 2);
	CGFloat y = (max < min) ? (max - 5) : (center.y - (frame.size.height / 2));
	
	if (y < 0) y = 0;
	else if (y > max) y = max;
	_scrollView.contentOffset = CGPointMake(0, y);
}

//
- (void)textFieldBegin:(UITextField *)sender
{
	if (_keyboardShown)
	{
		//_Log(@"editingDidBegin, _keyboardShown: %d", _keyboardShown);
		[UIView animateWithDuration:0.3 animations:^()
		 {
			 [self centerView:sender];
		 }];
	}
}

//
- (void)textFieldDone:(UITextField *)sender
{
	NSInteger index = [_textFields indexOfObject:sender];
	if (index < _textFields.count - 1)
	{
		[_textFields[index + 1] becomeFirstResponder];
	}
	else
	{
		[sender resignFirstResponder];
	}
}

//
- (void)keyboardWillShow:(NSNotification *)notification
{
	UIView *view = [_scrollView findFirstResponder];
	if (view/* && !_keyboardShown*/)
	{
		//_Log(@"keyboardWillShow, _keyboardShown: %d, view: %@", _keyboardShown, NSStringFromClass(view.class));
		
		CGRect rect;
		NSValue *value = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
		[value getValue:&rect];
		
		CGRect frame = _scrollView.frame;
		frame.size.height = _scrollView.superview.frame.size.height - frame.origin.y - rect.size.height;
		
		if (_keyboardShown)
		{
			_scrollView.frame = frame;
			//[self centerView:view animated:NO];
		}
		else
		{
			_keyboardShown = YES;
			[UIView animateWithDuration:0.3 animations:^()
			 {
				 _scrollView.frame = frame;
			 }];
			[self centerView:view];
		}
	}
}

//
- (void)keyboardWillHide:(NSNotification *)notification
{
	UIView *view = [self.view findFirstResponder];
	if (view/* && _keyboardShown*/)
	{
		_Log(@"keyboardWillHide, _keyboardShown: %d, view: %@", _keyboardShown, NSStringFromClass(view.class));
		_keyboardShown = NO;
		
		CGRect rect;
		NSValue *value = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
		[value getValue:&rect];
		
		CGPoint offset = _scrollView.contentOffset;
		
		CGRect frame = _scrollView.frame;
		frame.size.height = _scrollView.superview.frame.size.height - frame.origin.y;
		_scrollView.frame = frame;
		_scrollView.contentOffset = offset;
		
		offset.y -= rect.size.height;
		if (offset.y < 0) offset.y = 0;
		[UIView animateWithDuration:0.3 animations:^()
		 {
			 [_scrollView setContentOffset:offset animated:YES];
		 }];
	}
}

#pragma mark -
#pragma mark Data methods

//
- (void)reloadPage
{
	[super reloadPage];
	
	if (!_noAutoNext || !_noAutoScroll)
	{
		[self lookupTextFieldsInView:_contentView];
	}
}

@end
