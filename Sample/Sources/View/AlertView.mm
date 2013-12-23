
#import "AlertView.h"

//
@implementation AlertView

#pragma mark Simulate UIAlertView

//
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIUIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle
{
	return [self initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitle:otherButtonTitle accessoryView:nil];
}

//
#ifndef kAlertBoxLeftPad
#define kAlertBoxLeftPad 30
#endif

#ifndef kAlertBoxRightPad
#define kAlertBoxRightPad	30
#endif

#ifndef kAlertBoxTopPad
#define kAlertBoxTopPad 35
#endif
#ifndef kAlertBoxBottomPad
#define kAlertBoxBottomPad 20
#endif
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIUIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle accessoryView:(UIView *)accessoryView
{
	//
	UIImage *image = UIUtil::ImageNamed(@"AlertBox.png");
	
	//
	CGRect frame = {0, 0, image.size.width, kAlertBoxTopPad};
	self = [super initWithFrame:frame];
	
	self.userInteractionEnabled = YES;
	self.image = image.stretchableImage;
	self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	_delegate = delegate;
	
	if (accessoryView)
	{
		[self addSubview:accessoryView];
		
		accessoryView.center = CGPointMake(image.size.width / 2, frame.size.height + accessoryView.frame.size.height / 2);
		frame.size.height += accessoryView.frame.size.height + 20;
	}
	
	if (title)
	{
		UIFont *font = [UIFont boldSystemFontOfSize:17];
		CGSize size = [title sizeWithFont:font constrainedToSize:CGSizeMake(image.size.width - (kAlertBoxLeftPad + kAlertBoxRightPad), 1000)];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAlertBoxLeftPad, frame.size.height, image.size.width - (kAlertBoxLeftPad + kAlertBoxRightPad), size.height)];
		_titleLabel.text = title;
		_titleLabel.backgroundColor = UIColor.clearColor;
		_titleLabel.textColor = [UIColor colorWithRed:98.0 / 255 green:113.0 / 255 blue:147.0 / 255 alpha:1.0];
		_titleLabel.numberOfLines = 0;
		_titleLabel.font = font;
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_titleLabel];
		
		frame.size.height = CGRectGetMaxY(_titleLabel.frame) + 12;
	}
	
	//
	if (message)
	{
		UIFont *font = [UIFont systemFontOfSize:16];
		CGSize size = [message sizeWithFont:font constrainedToSize:CGSizeMake(image.size.width - (kAlertBoxLeftPad + kAlertBoxRightPad), 1000)];
		
		_messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAlertBoxLeftPad, frame.size.height, image.size.width - (kAlertBoxLeftPad + kAlertBoxRightPad), size.height)];
		_messageLabel.text = message;
		_messageLabel.backgroundColor = UIColor.clearColor;
		_messageLabel.textColor = [UIColor colorWithRed:98.0 / 255 green:113.0 / 255 blue:147.0 / 255 alpha:1.0];
		_messageLabel.numberOfLines = 0;
		_messageLabel.font = font;
		[self addSubview:_messageLabel];
		
		frame.size.height = CGRectGetMaxY(_messageLabel.frame) + 12;
	}
	
	//
	if (cancelButtonTitle)
	{
		_cancelButton = otherButtonTitle ? [UIButton minorButtonWithTitle:cancelButtonTitle width:-1] : [UIButton buttonWithTitle:cancelButtonTitle width:-1];
		[_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cancelButton];
	}
	
	//
	if (otherButtonTitle)
	{
		_otherButton = [UIButton buttonWithTitle:otherButtonTitle width:-1];
		[_otherButton addTarget:self action:@selector(otherButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_otherButton];
	}
	
	frame.size.height += 3;
	if (_cancelButton)
	{
		if (_otherButton)
		{
			_cancelButton.center = CGPointMake((image.size.width - _cancelButton.frame.size.width) / 2 - 6, frame.size.height + _cancelButton.frame.size.height / 2);
			_otherButton.center = CGPointMake((image.size.width + _otherButton.frame.size.width) / 2 + 6, frame.size.height + _otherButton.frame.size.height / 2);
		}
		else
		{
			_cancelButton.center = CGPointMake((image.size.width / 2), frame.size.height + _cancelButton.frame.size.height / 2);
		}
		frame.size.height = CGRectGetMaxY(_cancelButton.frame) + 10;
	}
	else if (_otherButton)
	{
		_otherButton.center = CGPointMake((image.size.width / 2), frame.size.height + _otherButton.frame.size.height / 2);
		frame.size.height = CGRectGetMaxY(_otherButton.frame) + 10;
	}
	else
	{
		frame.size.height += 15;
	}
	
	frame.size.height += kAlertBoxBottomPad;
	self.frame = frame;
	
	return self;
}

//
- (void)cancelButtonClicked
{
	[self dismissWithClickedButtonIndex:0 animated:YES];
}

//
- (void)otherButtonClicked
{
	[self dismissWithClickedButtonIndex:1 animated:YES];
}

//
#define kAlertWindowTag 92304
- (UIWindow *)paneWindow
{
	UIWindow *window = (UIWindow *)self.superview;
	return ([window isKindOfClass:[UIWindow class]] && window.tag == kAlertWindowTag) ? window : nil;
}

//
- (UIView *)pane
{
	UIWindow *window = self.paneWindow;
	return window ? window : self;
}

//
- (void)show
{
	UIWindow *window = [[UIWindow alloc] initWithFrame:UIUtil::ScreenBounds()];
	window.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
	window.windowLevel = UIWindowLevelAlert;
	window.tag = kAlertWindowTag;
	[window makeKeyAndVisible];
	[self showInView:window];
}


//
- (void)showInView:(UIView *)parent
{
	CGRect bounds = parent.bounds;
	if ([parent isKindOfClass:[UIWindow class]] && UIUtil::IsKeyboardInDisplay())
	{
		_fitKeyboard = YES;
		bounds.size.height -= 216;
	}
	self.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
	[parent addSubview:self];
	
	self.pane.alpha = 0;
	
	if ([_delegate respondsToSelector:@selector(willPresentAlertView:)])
	{
		[_delegate willPresentAlertView:(UIAlertView *)self];
	}
	
	[UIView animateWithDuration:0.3 animations:^()
	 {
		 self.pane.alpha = 1;
	 } completion:^(BOOL finished)
	 {
		 if ([_delegate respondsToSelector:@selector(didPresentAlertView:)])
		 {
			 [_delegate didPresentAlertView:(UIAlertView *)self];
		 }
	 }];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
	
	[_textField becomeFirstResponder];
}

//
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex
{
	if ([_delegate respondsToSelector:@selector(alertView: didDismissWithButtonIndex:)])
	{
		[_delegate alertView:(UIAlertView *)self didDismissWithButtonIndex:buttonIndex];
	}
	
	[self removeFromSuperview];
	
	if (_clickAction && [_delegate respondsToSelector:_clickAction])
	{
		_SuppressPerformSelectorLeakWarning([_delegate performSelector:_clickAction withObject:_clickParam]);
	}
	else if ([_delegate respondsToSelector:@selector(alertView: clickedButtonAtIndex:)])
	{
		[_delegate alertView:(UIAlertView *)self clickedButtonAtIndex:buttonIndex];
	}
}

//
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
	if ([_delegate respondsToSelector:@selector(alertView: willDismissWithButtonIndex:)])
	{
		[_delegate alertView:(UIAlertView *)self willDismissWithButtonIndex:buttonIndex];
	}
	
	if (animated)
	{
		[UIView animateWithDuration:0.3 animations:^()
		 {
			 self.pane.alpha = 0;
		 } completion:^(BOOL finished)
		 {
			 [self dismissWithClickedButtonIndex:buttonIndex];
		 }];
	}
	else
	{
		[self dismissWithClickedButtonIndex:buttonIndex];
	}
}


#pragma mark Keyboard handler

//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	[[self findFirstResponder] resignFirstResponder];
//	[super touchesBegan:touches withEvent:event];
//}

//
- (void)removeFromSuperview
{
	UIWindow *window = self.paneWindow;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super removeFromSuperview];
	
	[window resignKeyWindow];
}

//
- (void)keyboardWillShow:(NSNotification *)notification
{
	if (_fitKeyboard) return;
	_fitKeyboard = YES;
	
	CGRect rect;
	NSValue *value = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	[value getValue:&rect];
	
	[UIView animateWithDuration:0.3 animations:^()
	 {
		 CGPoint center = self.center;
		 center.y -= rect.size.height / 2;
		 self.center = center;
	 }];
}

//
- (void)keyboardWillHide:(NSNotification *)notification
{
	if (!_fitKeyboard) return;
	_fitKeyboard = NO;
	
	CGRect rect;
	NSValue *value = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	[value getValue:&rect];
	
	[UIView animateWithDuration:0.3 animations:^()
	 {
		 CGPoint center = self.center;
		 center.y += rect.size.height / 2;
		 self.center = center;
	 }];
}


#pragma mark Simulate UIAlertView (AlertViewEx)

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle accessoryView:(UIView *)accessoryView
{
	AlertView *alertView = [[AlertView alloc] initWithTitle:title
													 message:message
													delegate:delegate
										   cancelButtonTitle:cancelButtonTitle
											otherButtonTitle:otherButtonTitle
											   accessoryView:accessoryView
							 ];
	[alertView show];
	return alertView;
}

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle
{
	return [self alertWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitle:otherButtonTitle accessoryView:nil];
}

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle{
	return [self alertWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitle:nil];
}
//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate
{
	return [self alertWithTitle:title message:message delegate:delegate cancelButtonTitle:NSLocalizedString(@"Dismiss", @"关闭")];
}

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message
{
	return [self alertWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"关闭") otherButtonTitle:nil];
}

//
+ (id)alertWithTitle:(NSString *)title
{
	return [self alertWithTitle:title message:nil];
}

//
+ (id)alertWithTask:(id/*<AlertViewExDelegate>*/)delegate title:(NSString *)title
{
	AlertView *alertView = [self alertWithTitle:title message:@" \n " delegate:nil cancelButtonTitle:nil otherButtonTitle:nil];
	[alertView.activityIndicator startAnimating];
	[delegate performSelectorInBackground:@selector(taskForAlertView:) withObject:alertView];
	return alertView;
}

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle target:(id)target action:(SEL)action param:(id)param
{
	AlertView *alertView = [AlertView alertWithTitle:title message:message delegate:target cancelButtonTitle:buttonTitle otherButtonTitle:nil];
	alertView.clickAction = action;
	alertView.clickParam = param;
	return alertView;
}

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle target:(id)target action:(SEL)action
{
	AlertView *alertView = [AlertView alertWithTitle:title message:message buttonTitle:buttonTitle target:target action:action param:nil];
	alertView.clickParam = alertView;
	return alertView;
}

//
- (UITextField *)textField
{
	if (_textField == nil)
	{
		CGRect frame = _messageLabel.frame;
		_textField = [[UITextField alloc] initWithFrame:CGRectInset(_messageLabel.frame, 0, (frame.size.height - 32) / 2)];
		_textField.borderStyle = UITextBorderStyleRoundedRect;
		//_textField.background = UIUtil::ImageNamed(@"AlertEdit.png");
		//_textField.textAlignment = NSTextAlignmentCenter;
		_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		
		[self addSubview:_textField];
		//[textField becomeFirstResponder];
		
		//
		UIControl *touch = [[UIControl alloc] initWithFrame:self.superview.bounds];
		[touch addTarget:_textField action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchDown];
		[self.superview insertSubview:touch belowSubview:self];
	}
	return _textField;
}

//
#define kActivityIndicatorTag 1924
- (UIActivityIndicatorView *)activityIndicator
{
	UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self viewWithTag:kActivityIndicatorTag];
	if (activityIndicator == nil)
	{
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicator.center = _messageLabel.center;
		activityIndicator.tag = kActivityIndicatorTag;
		activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:activityIndicator];
	}
	return activityIndicator;
}

//
- (void)dismissOnMainThread
{
	[self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
}

//
- (void)dismiss
{
	[self dismissWithClickedButtonIndex:0 animated:YES];
}

@end
