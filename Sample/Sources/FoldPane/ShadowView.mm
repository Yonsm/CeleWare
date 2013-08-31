

#import "ShadowView.h"


@implementation ShadowView

- (id)initWithFrame:(CGRect)frame foldDirection:(FoldDirection)foldDirection
{
	self = [super initWithFrame:frame];
	if (self) {
		
		_gradient = [CAGradientLayer layer];
		[_gradient setFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
		if (foldDirection==FoldDirectionHorizontal)
		{
			[_gradient setStartPoint:CGPointMake(0, 0)];
			[_gradient setEndPoint:CGPointMake(1, 0)];
		}
		else if (foldDirection==FoldDirectionVertical)
		{
			[_gradient setStartPoint:CGPointMake(0, 1)];
			[_gradient setEndPoint:CGPointMake(0, 0)];
		}
		[self.layer insertSublayer:_gradient atIndex:0];
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame foldDirection:FoldDirectionHorizontal];
}

- (void)setColorArrays:(NSArray*)colors
{
	_colorsArray = [NSMutableArray array];
	for (UIColor *color in colors)
	{
		[self.colorsArray addObject:(id)[color CGColor]];
	}
	
	if ([self.colorsArray count]>0)
	{
		[self.gradient setColors:self.colorsArray];
	}
}

@end
