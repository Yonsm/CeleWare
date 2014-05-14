
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
	return [[CopyableLabel alloc] initAtPoint:point width:width text:text color:color font:font alignment:alignment];
}

//
+ (id)copyableLabelWithFrame:(CGRect)frame
						text:(NSString *)text
					   color:(UIColor *)color
						font:(UIFont *)font
				   alignment:(NSTextAlignment)alignment
{
	return [[CopyableLabel alloc] initWithFrame:frame text:text color:color font:font alignment:alignment];
}

//
- (id)initAtPoint:(CGPoint)point
			width:(float)width
			 text:(NSString *)text
			color:(UIColor *)color
			 font:(UIFont *)font
		alignment:(NSTextAlignment)alignment
{
	CGSize size = [text sizeWithFont:font
				   constrainedToSize:CGSizeMake(width, 1000)];
	if (alignment == NSTextAlignmentCenterOrLeft)
	{
		alignment = (size.height > font.lineHeight + 1) ? NSTextAlignmentLeft : NSTextAlignmentCenter;
	}
	CGRect frame = CGRectMake(point.x, point.y, width, ceil(size.height));
	
	self = [self initWithFrame:frame text:text color:color font:font alignment:alignment];
	self.numberOfLines = 0;
	return self;
}

//
- (id)initWithFrame:(CGRect)frame
			   text:(NSString *)text
			  color:(UIColor *)color
			   font:(UIFont *)font
		  alignment:(NSTextAlignment)alignment
{
	self = [super initWithFrame:frame];
	self.userInteractionEnabled = YES;
	self.textColor = color;
	self.backgroundColor = [UIColor clearColor];
	self.font = font;
	self.text = text;
	self.textAlignment = alignment;
	
	UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onHold:)];
	[self addGestureRecognizer:gesture];
	return self;
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
- (void)onHold:(UILongPressGestureRecognizer *)sender
{
	if (sender.state != UIGestureRecognizerStateBegan) return;
	
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
		
		CGPoint point = [sender locationInView:self];
		UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setTargetRect:CGRectMake(point.x, /*point.y*/0, 0, 0) inView:self];
		[menu setMenuVisible:YES animated:YES];
	}
}

//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.alpha = 0.75;
	[super touchesBegan:touches withEvent:event];
}

//
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.alpha = 1;
	[super touchesEnded:touches withEvent:event];
}

//
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.alpha = 1;
	[super touchesCancelled:touches withEvent:event];
}

@end
