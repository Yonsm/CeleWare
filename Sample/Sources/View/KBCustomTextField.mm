
#import "UIUtil.h"
#import "KBCustomTextField.h"


//
@interface KBCustomButton : UIButton
{
}
@end

@implementation KBCustomButton

- (id)key
{
	return nil;
}

//
+ (id)customButtonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action
{
	UIButton *button = [[[KBCustomButton alloc] initWithFrame:frame] autorelease];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:UIUtil::IsOS7() ? [UIColor whiteColor] : [UIColor darkGrayColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	return button;
}

@end


@implementation KBCustomTextField

//
- (void)dealloc
{
	[_kbDelegate keyboardHide:self];
	[super dealloc];
}

//
- (BOOL)becomeFirstResponder
{
	BOOL ret = [super becomeFirstResponder];
	[_kbDelegate keyboardShow:self];
	return ret;
}

//
- (BOOL)resignFirstResponder
{
	BOOL ret = [super resignFirstResponder];
	[_kbDelegate keyboardHide:self];
	return ret;
}

//
//#define _LOG_KEY_VIEW
#ifdef _LOG_KEY_VIEW
+ (void)logKeyView:(UIKBKeyView *)view
{
	_Log(@"\tname=%@"
		 @"\trepresentedString=%@"
		 @"\tdisplayString=%@"
		 @"\tdisplayType=%@"
		 @"\tinteractionType=%@"
		 //@"\tvariantType=%@"
		 //@"\tvisible=%u"
		 //@"\tdisplayTypeHint=%d"
		 @"\tdisplayRowHint=%@"
		 //@"\toverrideDisplayString=%@"
		 //@"\tdisabled=%d"
		 //@"\thidden=%d\n"
		 
		 ,view.key.name
		 ,view.key.representedString
		 ,view.key.displayString
		 ,view.key.displayType
		 ,view.key.interactionType
		 //,view.key.variantType
		 //,view.key.visible
		 //,view.key.displayTypeHint
		 ,view.key.displayRowHint
		 //,view.key.overrideDisplayString
		 //,view.key.disabled
		 //,view.key.hidden
		 );
}
#endif

//
+ (UIKBKeyView *)findKeyView:(NSString *)name inView:(UIView *)view
{
	for (UIKBKeyView *subview in view.subviews)
	{
		NSString *className = NSStringFromClass([subview class]);
		
#ifdef _LOG_KEY_VIEW
		_Log(@"Found View: %@\n", className);
		if ([className isEqualToString:@"UIKBKeyView"])
		{
			[self logKeyView:subview];
		}
#else
		if ([className isEqualToString:@"UIKBKeyView"])
		{
			if ((name == nil) || [subview.key.name isEqualToString:name])
			{
				return subview;
			}
		}
#endif
		else if (UIKBKeyView *subview2 = [self findKeyView:name inView:subview])
		{
			return subview2;
		}
	}
	return nil;
}

//
+ (UIKBKeyView *)findKeyView:(NSString *)name
{
	NSArray *windows = [[UIApplication sharedApplication] windows];
	if (windows.count < 2) return nil;
	return [self findKeyView:name inView:[windows objectAtIndex:1]];
}

//
+ (UIKBKeyView *)modifyKeyView:(NSString *)name display:(NSString *)display represent:(NSString *)represent interaction:(NSString *)type
{
	UIKBKeyView *view = [self findKeyView:name];
	if (view)
	{
		if ([view.key respondsToSelector:@selector(setRepresentedString:)])
			view.key.representedString = represent;
		if ([view.key respondsToSelector:@selector(setDisplayString:)])
			view.key.displayString = display;
		if ([view.key respondsToSelector:@selector(setInteractionType:)])
			view.key.interactionType = type;
		[view setNeedsDisplay];
	}
	return view;
}

//
+ (UIButton *)addCustomButton:(NSString *)name title:(NSString *)title target:(id)target action:(SEL)action
{
	UIKBKeyView *view = [self findKeyView:name];
	if (view)
	{
		KBCustomButton *button = [KBCustomButton customButtonWithFrame:view.frame title:title target:target action:action];
		[view.superview addSubview:button];
		view.superview.userInteractionEnabled = YES;
		return button;
	}
	return nil;
}

@end


//
@implementation ActionNumberField

//
- (id)initWithFrame:(CGRect)frame actionButtonTitle:(NSString *)actionButtonTitle
{
	self = [super initWithFrame:frame];
	self.keyboardType = UIKeyboardTypeNumberPad;
	if (UIUtil::IsPad() == NO)
	{
		self.kbDelegate = self;
		
		_actionButton = [[KBCustomButton customButtonWithFrame:CGRectZero
														 title:actionButtonTitle
														target:self
														action:@selector(actionButtonClicked:)] retain];
	}
	return self;
}

//
- (void)dealloc
{
	[_actionButton release];
	[super dealloc];
}

// Handle keyboard show
- (void)keyboardShow:(KBCustomTextField *)sender
{
	UIKBKeyView *view = [KBCustomTextField findKeyView:@"NumberPad-Empty"];
	_actionButton.frame = view.frame;
	[_actionButton removeFromSuperview];
	[view.superview addSubview:_actionButton];
	view.superview.userInteractionEnabled = YES;
}

// Handle keyboard hide
- (void)keyboardHide:(KBCustomTextField *)sender
{
	[_actionButton removeFromSuperview];
}

//
- (void)actionButtonClicked:(id)sender
{
	[self sendActionsForControlEvents:UIControlEventEditingDidEndOnExit];
}

@end
