
#import "TabStripButton.h"


#ifndef TabStripButtonTextColor
#define TabStripButtonTextColor		[UIColor colorWithRed:181/255.0f green:161/255.0f blue:191/255.0f alpha:1.0f]
#define TabStripButtonTextShadow	[UIColor colorWithWhite:1.0f alpha:0.7f]
#define TabStripButtonSelectColor	[UIColor colorWithRed:71/255.0f green:62/255.0f blue:63/255.0f alpha:1.0f]
#endif


@implementation TabStripButton

//
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	UIImage *image = UIUtil::ImageNamed(@"TabStripOver.png");
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (frame.size.height - image.size.height) / 2, frame.size.width, image.size.height)];
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	imageView.backgroundColor = [UIColor clearColor];
	imageView.image = [image stretchableImageWithLeftCapWidth:(image.size.width / 2) topCapHeight:0.0f];
	imageView.alpha = 0;
	//imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, -1.0f, frame.size.width, frame.size.height)];
	label.textAlignment = NSTextAlignmentCenter;
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:14.0f];
	label.textColor = TabStripButtonTextColor;
#ifdef TabStripButtonTextShadow
	label.shadowColor = TabStripButtonTextShadow;
	label.shadowOffset = CGSizeMake(0.0f, -1.0f);
#endif
	[self addSubview:imageView];
	[self addSubview:label];
	
	self.backgroundColor = [UIColor clearColor];
	
	return self;
}

//
- (void)drawRect:(CGRect)rect
{
	// Drawing code
}

//
- (void)setText:(NSString*)text
{
	label.text = text;
}

//
- (void)markSelected
{
	label.textColor = TabStripButtonSelectColor;
#ifdef TabStripButtonTextShadow
	label.shadowColor = TabStripButtonTextColor;
#endif
	
	[UIView animateWithDuration:0.4 animations:^()
	 {
		 imageView.alpha = 1;
	 }];
	self.selected = YES;
}

//
- (void)markUnselected
{
	label.textColor = TabStripButtonTextColor;
#ifdef TabStripButtonTextShadow
	label.shadowColor = TabStripButtonTextShadow;
#endif
	
	[UIView animateWithDuration:0.4 animations:^()
	 {
		 imageView.alpha = 0;
	 }];
	self.selected = NO;
}

//
- (NSString*)text
{
	return label.text;
}

//
- (UIFont*)font
{
	return label.font;
}

//
- (void)dealloc
{
	[label release];
	[super dealloc];
}


@end
