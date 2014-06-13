
#import "FoldView.h"

//
@interface FoldViews : UIView
{
	NSUInteger _numberOfFolds;
}

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image withNumberOfFolds:(NSUInteger)numberOfFolds;

@end
