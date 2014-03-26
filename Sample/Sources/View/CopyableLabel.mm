
#import "CopyableLabel.h"

@implementation CopyableLabel

//
+ (id)copyableLabelAtPoint:(CGPoint)point
					 width:(float)width
					  text:(NSString *)text
					 color:(UIColor *)color
					  font:(UIFont*)font
				 alignment:(NSTextAlignment)alignment
{
	CGSize size = [text sizeWithFont:font
				   constrainedToSize:CGSizeMake(width, 1000)];
	
	CGRect frame = CGRectMake(point.x, point.y, width, ceil(size.height));
	
	UILabel *label = [CopyableLabel copyableLabelWithFrame:frame text:text color:color font:font alignment:alignment];
	label.numberOfLines = 0;
	return label;
}

//
+ (id)copyableLabelWithFrame:(CGRect)frame
						text:(NSString *)text
					   color:(UIColor *)color
						font:(UIFont *)font
				   alignment:(NSTextAlignment)alignment
{
	UILabel *label = [[CopyableLabel alloc] initWithFrame:frame];
	label.userInteractionEnabled = YES;
	label.textColor = color;
	label.backgroundColor = [UIColor clearColor];
	label.font = font;
	label.text = text;
	label.textAlignment = alignment;
	
	return label;
}

//
- (void)killTimer
{
	if (_holdTimer)
	{
		[_holdTimer invalidate];
		_holdTimer = nil;
	}
}

//
- (void)dealloc
{
	[self killTimer];
}

//
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
	if (self.text.length && (action == @selector(copy:)))
	{
		return YES;
	}
	return NO;
}

//
- (void)copy:(id)sender
{
	[UIPasteboard generalPasteboard].string = self.text;
	[self resignFirstResponder];
}

//
- (BOOL)canBecomeFirstResponder
{
	return YES;
}

//
- (void)onHold:(NSTimer *)sender
{
	NSValue *location = sender.userInfo;
	
	[self killTimer];
	self.alpha = 1;

	if ([self isFirstResponder])
	{
		UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setMenuVisible:NO animated:YES];
		[menu update];
		[self resignFirstResponder];
	}
	else if ([self becomeFirstResponder])
	{
		if (self.text.length == 0) return;
		
		CGPoint point = location.CGPointValue;

		UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setTargetRect:CGRectMake(point.x, /*point.y*/0, 0, 0) inView:self];
		[menu setMenuVisible:YES animated:YES];
	}
}

//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.alpha = 0.75;
	[self killTimer];
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	_holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(onHold:) userInfo:[NSValue valueWithCGPoint:location] repeats:NO];

	[super touchesBegan:touches withEvent:event];
}

//
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self killTimer];
	self.alpha = 1;
	[super touchesEnded:touches withEvent:event];
}

//
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self killTimer];
	self.alpha = 1;
	[super touchesCancelled:touches withEvent:event];
}

@end
