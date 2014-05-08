
#import "AnimatableLabel.h"

@implementation AnimatableLabel

//
+ (id)animatableLabelWithFrame:(CGRect)frame
						  from:(NSString *)from
							to:(NSString *)to
						 color:(UIColor *)color
						  font:(UIFont *)font
					 alignment:(NSTextAlignment)alignment
{
	AnimatableLabel *label = [[AnimatableLabel alloc] initWithFrame:frame text:nil color:color font:font alignment:alignment];
	label.adjustsFontSizeToFitWidth = YES;
	label.from = from;
	label.to = to;
	return label;
}

//
+ (NSString *)formatFromText:(NSString *)text
{
	int length = text.length;
	NSInteger float_location = [text rangeOfString:@"."].location;
	int float_length = (float_location != NSNotFound) ? (length - float_location - 1) : 0;
	return [NSString stringWithFormat:@"%%0%d.%df", length, float_length];
}

//
- (void)prepareAimating
{
	NSString *format = [AnimatableLabel formatFromText:_to];
	self.text = [NSString stringWithFormat:format, _from.floatValue];
}

//
- (void)startAnimating
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
				   {
					   NSString *format = [AnimatableLabel formatFromText:_to];
					   
					   float to = _to.floatValue;
					   float from = _from.floatValue;
					   float delta = (to - from) / _AnimatableLabelAnimateTimes;
					   float current = from;
					   while (YES)
					   {
						   current += delta;
						   if (((from < to) && (current >= to)) ||
							   ((from >= to) && (current <= to)))
						   {
							   break;
						   }
						   
						   NSString *text = [NSString stringWithFormat:format, current];
						   dispatch_async(dispatch_get_main_queue(), ^{self.text = text;});
						   
						   [NSThread sleepForTimeInterval:_AnimatableLabelAnimateInterval];
					   }
					   
					   dispatch_async(dispatch_get_main_queue(), ^{self.text = _to;});
				   });
}

@end
