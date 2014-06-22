
#import "CopyableLabel.h"

#ifndef _AnimatableLabelAnimateTimes
#define _AnimatableLabelAnimateTimes	30.0f
#endif

#ifndef _AnimatableLabelAnimateInterval
#define _AnimatableLabelAnimateInterval	0.025f
#endif

#ifndef _AnimatableLabelAnimateDuration
#define _AnimatableLabelAnimateDuration	(_AnimatableLabelAnimateTimes * _AnimatableLabelAnimateInterval + 0.1)
#endif

@interface AnimatableLabel : CopyableLabel

- (void)prepareAimating;
- (void)startAnimating;

@property(nonatomic,strong) NSString *from;
@property(nonatomic,strong) NSString *to;

//
+ (id)animatableLabelWithFrame:(CGRect)frame
						  from:(NSString *)from
							to:(NSString *)to
						 color:(UIColor *)color
						  font:(UIFont *)font
					 alignment:(NSTextAlignment)alignment;
@end
