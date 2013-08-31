
#import "FoldViews.h"

#define kFoldViewTag 12445

@implementation FoldViews

// Constructor
- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image withNumberOfFolds:(NSUInteger)numberOfFolds
{
	self = [super initWithFrame:frame];
	self.clipsToBounds = YES;
	_numberOfFolds = numberOfFolds;
	
	frame.origin.x = 0;
	frame.origin.y = 0;
	frame.size.height = image.size.height / _numberOfFolds;
	for (NSUInteger i = 0; i < _numberOfFolds; i++)
	{
		CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, frame.size.height*i*image.scale, image.size.width*image.scale, frame.size.height*image.scale));
		UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
		CFRelease(imageRef);

		FoldView *foldView = [[[FoldView alloc] initWithFrame:frame foldDirection:FoldDirectionVertical] autorelease];
		foldView.tag = kFoldViewTag + i;
		foldView.image = croppedImage;
		//[foldView unfoldWithParentOffset:frame.size.height];
		[self insertSubview:foldView atIndex:0];

		frame.origin.y += frame.size.height;
	}

	return self;
}

//
//- (void)setFrame:(CGRect)frame
- (void)layoutSubviews
{
	[super layoutSubviews];

	CGRect frame = self.frame;
	float foldHeight = frame.size.height / _numberOfFolds;
	
	for (NSUInteger i = 0; i < _numberOfFolds; i++)
	{
		FoldView *foldView = (FoldView*)[self viewWithTag:kFoldViewTag+i];

		CGRect frame = foldView.frame;
		frame.origin.y = frame.size.height * i - (frame.size.height - foldHeight) * (i + 1);
		foldView.frame = frame;
		if (foldHeight >= frame.size.height) foldHeight = frame.size.height - 0.1;

		[foldView unfoldWithParentOffset:foldHeight];
	}
}

@end
