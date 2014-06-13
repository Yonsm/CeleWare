
@implementation UIButton (EXButton)

//
+ (id)buttonWithTitle:(NSString *)title name:(NSString *)name width:(CGFloat)width font:(UIFont *)font
{
	UIImage *image = UIUtil::ImageNamed([name stringByAppendingString:@"Button.png"]);
	UIImage *image_ = UIUtil::ImageNamed([name stringByAppendingString:@"Button_.png"]);
	UIImage *imaged = UIUtil::ImageNamed([name stringByAppendingString:@"Button-.png"]);
	
	if (width == 0) width = image.size.width;
	else if (width < 0) width = [title sizeWithFont:font].width + image.size.width;
	
	CGRect frame = {0, 0, width, image.size.height};
	if (width != image.size.width)
	{
		image = UIUtil::StretchableImage(image);
		imaged = UIUtil::StretchableImage(imaged);
		image_ = UIUtil::StretchableImage(image_);
	}
	
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	button.titleLabel.font = font;
	[button setBackgroundImage:image forState:UIControlStateNormal];
	[button setBackgroundImage:imaged forState:UIControlStateDisabled];
	[button setBackgroundImage:image_ forState:UIControlStateHighlighted];
	[button setTitle:title forState:UIControlStateNormal];
	
	[button setTitleColor:[UIColor colorWithWhite:0x99/255.0 alpha:1] forState:UIControlStateDisabled];
	
	return button;
}

//
#ifndef kCommonButtonFont
#define kCommonButtonFont [UIFont boldSystemFontOfSize:16]
#endif
+ (id)buttonWithTitle:(NSString *)title name:(NSString *)name width:(CGFloat)width
{
	return [self buttonWithTitle:title name:name width:width font:kCommonButtonFont];
}

//
+ (id)buttonWithTitle:(NSString *)title name:(NSString *)name
{
	return [self buttonWithTitle:title name:name width:0];
}

//
+ (id)buttonWithTitle:(NSString *)title width:(CGFloat)width
{
	return [self buttonWithTitle:title name:@"Major" width:width];
}

//
#ifndef kShortButtonWidth
#define kShortButtonWidth 147
#endif
#ifndef kLongButtonWidth
#define kLongButtonWidth 302
#endif
+ (id)buttonWithTitle:(NSString *)title
{
	return [self buttonWithTitle:title width:kShortButtonWidth];
}

//
+ (id)longButtonWithTitle:(NSString *)title
{
	return [self buttonWithTitle:title width:kLongButtonWidth];
}

//
+ (id)minorButtonWithTitle:(NSString *)title width:(CGFloat)width
{
	UIButton *button = [self buttonWithTitle:title name:@"Minor" width:width];
	[button setTitleColor:[UIColor colorWithRed:0x66/255.0 green:0x88/255.0 blue:0xBB/255.0 alpha:1] forState:UIControlStateNormal];
	return button;
}

//
+ (id)minorButtonWithTitle:(NSString *)title
{
	return [self minorButtonWithTitle:title width:kShortButtonWidth];
}

//
+ (id)longMinorButtonWithTitle:(NSString *)title
{
	return [self minorButtonWithTitle:title width:kLongButtonWidth];
}

//
+ (id)buttonWithImage:(UIImage *)image
{
	CGRect frame = {0, 0, image.size.width, image.size.height};
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	[button setImage:image forState:UIControlStateNormal];
	return button;
}

+ (id)buttonWithImageNamed:(NSString *)imageName
{
	UIImage *image = UIUtil::ImageNamed(imageName);
	UIImage *image_ = UIUtil::ImageNamed([imageName stringByAppendingString:@"_"]);
	UIButton *button = [UIButton buttonWithImage:image];
	if (image_)
	{
		[button setImage:image_ forState:UIControlStateHighlighted];
	}
	return button;
}

//
+ (id)checkButtonWithTitle:(NSString *)title frame:(CGRect)frame
{
	UIFont *font = [UIFont systemFontOfSize:14];
	
#ifndef _CheckBoxImage
#define _CheckBoxImage UIUtil::Image(@"CheckBox")
#endif
#ifndef _CheckBoxImage_
#define _CheckBoxImage_ UIUtil::Image(@"CheckBox_")
#endif
	UIImage *image = _CheckBoxImage;
	UIImage *image_ = _CheckBoxImage_;
	
	if (frame.size.width == 0) frame.size.width = image.size.width + 2 + [title sizeWithFont:font].width + 2;
	if (frame.size.height == 0) frame.size.height = MAX(image.size.height, 22);
	
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	button.titleLabel.font = font;
	
	[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	[button setImage:image forState:UIControlStateNormal];
	[button setImage:image_ forState:UIControlStateSelected];
	
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
	
	[button addTarget:button action:@selector(checkBoxClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

//
- (void)checkBoxClicked:(UIButton *)sender
{
	sender.selected = !sender.selected;
	[sender sendActionsForControlEvents:UIControlEventValueChanged];
}

//
+ (id)linkButtonWithTitle:(NSString *)title
{
	return [self linkButtonWithTitle:title frame:CGRectZero];
}

//
+ (id)linkButtonWithTitle:(NSString *)title frame:(CGRect)frame
{
#ifndef kLinkButtonFont
#define kLinkButtonFont [UIFont systemFontOfSize:14]
#endif
#ifndef kLinkButtonColor
#define kLinkButtonColor UIUtil::Color(0, 136, 221)
#endif
#ifndef kLinkButtonColor_
#define kLinkButtonColor_ UIUtil::Color(20, 166, 241)
#endif
	
	UIFont *font = kLinkButtonFont;
	if (frame.size.width == 0) frame.size.width = [title sizeWithFont:font].width + 2;
	if (frame.size.height == 0) {frame.size.height = [title sizeWithFont:font].height; if (frame.size.height < 22) frame.size.height = 22;}
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	[button setTitleColor:kLinkButtonColor forState:UIControlStateNormal];
	[button setTitleColor:kLinkButtonColor_ forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	[button setTitle:title forState:UIControlStateNormal];
	button.titleLabel.font = font;
	//button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	
	return button;
}

//
+ (id)colorButtonWithTitle:(NSString *)title width:(CGFloat)width
{
	UIFont *font = [UIFont systemFontOfSize:14];
	if (width == 0) width =[title sizeWithFont:font].width + 18;
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
	[button setBackgroundImage:UIUtil::ImageWithColor(0x00aeef) forState:UIControlStateNormal];
	[button setBackgroundImage:UIUtil::ImageWithColor(0x0092e9) forState:UIControlStateHighlighted];
	button.titleLabel.font = font;
	return button;
}

//
+ (id)colorButtonWithTitle:(NSString *)title
{
	return [self colorButtonWithTitle:title width:0];
}

//
+ (id)roundButtonWithTitle:(NSString *)title color:(UIColor *)color color_:(UIColor *)color_ frame:(CGRect)frame
{
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	[button setTitle:title forState:UIControlStateNormal];
	[button setBackgroundImage:UIUtil::ImageWithColor(color) forState:UIControlStateNormal];
	[button setBackgroundImage:UIUtil::ImageWithColor(color_) forState:UIControlStateHighlighted];
	button.titleLabel.font = [UIFont systemFontOfSize:17];
	button.layer.cornerRadius = 4;
	button.clipsToBounds = YES;
	return button;
}

@end
