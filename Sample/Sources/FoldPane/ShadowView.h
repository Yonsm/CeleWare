

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum
{
	FoldDirectionHorizontal = 0,
	FoldDirectionVertical = 1,
} FoldDirection;


@interface ShadowView : UIView
@property (nonatomic, strong) NSMutableArray *colorsArray;
@property (nonatomic, strong) CAGradientLayer *gradient;

- (id)initWithFrame:(CGRect)frame foldDirection:(FoldDirection)foldDirection;
- (void)setColorArrays:(NSArray*)colors;

@end
