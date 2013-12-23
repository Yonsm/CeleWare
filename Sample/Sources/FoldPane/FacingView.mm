

#import "FacingView.h"

@implementation FacingView

- (id)initWithFrame:(CGRect)frame foldDirection:(FoldDirection)foldDirection
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_shadowView = [[ShadowView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) foldDirection:foldDirection];
		[self addSubview:_shadowView];
		[_shadowView setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame foldDirection:FoldDirectionHorizontal];
}

@end
