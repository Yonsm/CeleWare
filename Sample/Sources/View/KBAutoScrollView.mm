

#import "KBAutoScrollView.h"


@implementation KBAutoScrollView

//
- (void)resetContentSize
{
	CGSize size = {self.frame.size.width, 0};
	for (UIView *view in self.subviews)
	{
		CGRect frame = view.frame;
		BOOL isImageView = [view isKindOfClass:UIImageView.class];
		if (((frame.size.width >= 10) && (frame.size.height >= 10)) || !isImageView)
		{
			CGFloat y = frame.origin.y + frame.size.height;
			if (!isImageView) y += 15;	// MAGIC
			if (size.height < y)
			{
				size.height = y;
			}
		}
	}
	self.contentSize = size;
}

#pragma mark View methods

//
- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	
	if (self.superview)
	{
		//
		if (self.contentSize.height == 0)
		{
			[self resetContentSize];
		}
		
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
- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	if (newSuperview == nil)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
}

#pragma mark Keyboard methods

//
- (void)keyboardWillShow:(NSNotification *)notification
{
	UIView *view = [self findFirstResponder];
	if (view)
	{
		CGRect rect;
		NSValue *value = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
		[value getValue:&rect];
		
		CGRect frame = self.frame;
		frame.size.height = self.superview.frame.size.height - frame.origin.y - rect.size.height;
		
		[UIView animateWithDuration:0.3 animations:^()
		 {
			 self.frame = frame;
		 }];
		
		CGPoint offset = {0, view.center.y - (frame.size.height / 2)};
		CGFloat max = self.contentSize.height - frame.size.height;
		if (offset.y > max) offset.y = max;
		if (offset.y < 0) offset.y = 0;
		[self setContentOffset:offset animated:NO];
	}
}

//
- (void)keyboardWillHide:(NSNotification *)notification
{
	UIView *view = [self findFirstResponder];
	if (view)
	{
		CGRect rect;
		NSValue *value = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
		[value getValue:&rect];
		
		CGPoint offset = self.contentOffset;
		
		CGRect frame = self.frame;
		frame.size.height = self.superview.frame.size.height - frame.origin.y;
		self.frame = frame;
		self.contentOffset = offset;
		
		offset.y -= rect.size.height;
		if (offset.y < 0) offset.y = 0;
		 [self setContentOffset:offset animated:YES];
	}
}

//
#pragma mark Touch methods

//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	[self.findFirstResponder resignFirstResponder];
}

@end
