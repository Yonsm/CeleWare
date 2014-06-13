
//
@protocol TouchViewDelegate <NSObject>
@optional
- (BOOL)touchView:(UIView *)sender touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)touchView:(UIView *)sender touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)touchView:(UIView *)sender touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)touchView:(UIView *)sender touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end


//
#define _DeclareTouchView(TouchView, ParentView)	\
	\
@interface TouchView : ParentView	\
@property(nonatomic, assign) BOOL showTouchHighlight;	\
@property(nonatomic, assign) BOOL acceptOutsideTouch;	\
@property(nonatomic, assign) id<TouchViewDelegate> touchDelegate;	\
@end


//
#define _ImplementTouchView(TouchView)	\
@implementation TouchView	\
	\
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event	\
{	\
	if (_showTouchHighlight)	\
	{	\
		self.alpha = 0.75;	\
	}	\
	if ([_touchDelegate respondsToSelector:@selector(touchView: touchesBegan: withEvent:)] == NO ||	\
		[_touchDelegate touchView:self touchesBegan:touches withEvent:event] == NO)	\
		[super touchesBegan:touches withEvent:event];	\
}	\
	\
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event	\
{	\
	if (_showTouchHighlight)	\
	{	\
		self.alpha = 0.75;	\
	}	\
	if ([_touchDelegate respondsToSelector:@selector(touchView: touchesMoved: withEvent:)] == NO ||	\
		[_touchDelegate touchView:self touchesMoved:touches withEvent:event] == NO)	\
		[super touchesMoved:touches withEvent:event];	\
}	\
	\
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event	\
{	\
	if (_showTouchHighlight)	\
	{	\
		self.alpha = 1;	\
	}	\
	if (_acceptOutsideTouch == NO)	\
	{	\
		UITouch *touch = [touches anyObject];	\
		CGPoint location = [touch locationInView:self];	\
		if ([self pointInside:location withEvent:event] == NO)	\
		{	\
			[super touchesEnded:touches withEvent:event];	\
			return;	\
		}	\
	}	\
	if ([_touchDelegate respondsToSelector:@selector(touchView: touchesEnded: withEvent:)] == NO ||	\
		[_touchDelegate touchView:self touchesEnded:touches withEvent:event] == NO)	\
		[super touchesEnded:touches withEvent:event];	\
}	\
	\
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event	\
{	\
	if (_showTouchHighlight)	\
	{	\
		self.alpha = 1;	\
	}	\
	if ([_touchDelegate respondsToSelector:@selector(touchView: touchesCancelled: withEvent:)] == NO ||	\
		[_touchDelegate touchView:self touchesCancelled:touches withEvent:event] == NO)	\
		[super touchesCancelled:touches withEvent:event];	\
}	\
@end

//
//_DeclareTouchView(TouchView, UIView);
_DeclareTouchView(TouchImageView, UIImageView);
_DeclareTouchView(TouchScrollView, UIScrollView);


