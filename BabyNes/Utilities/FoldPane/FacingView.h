
#import "ShadowView.h"



@interface FacingView : UIView
@property (strong, nonatomic) ShadowView *shadowView;
- (id)initWithFrame:(CGRect)frame foldDirection:(FoldDirection)foldDirection;
@end
