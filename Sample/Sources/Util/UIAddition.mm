
#import "UIAddition.h"
#import "UIUtil.h"


#pragma mark UIImage methods

@implementation UIImage (ImageEx)

//
+ (UIImage *)imageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

//
- (UIImage *)stretchableImage
{
	return [self stretchableImageWithLeftCapWidth:self.size.width / 2 topCapHeight:self.size.height / 2];
}

// Scale to specified size if needed
#define _Radians(d) (d * M_PI/180)
- (UIImage *)scaleImageToSize:(CGSize)size
{
	CGSize imageSize = self.size;
	if (size.width == 0)
	{
		if (imageSize.height)
		{
			size.width = (NSUInteger)(imageSize.width * size.height / imageSize.height);
		}
	}
	else if (size.height == 0)
	{
		if (imageSize.width)
		{
			size.height = (NSUInteger)(imageSize.height * size.width / imageSize.width);
		}
	}
	
	if ((size.width == imageSize.width) && (size.height == imageSize.height))
	{
		return self;
	}
	
	// Get scale
	CGFloat scale = UIUtil::ScreenScale();
	size.width *= scale;
	size.height *= scale;
	
	// Scale image
	CGImageRef imageRef = self.CGImage;
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	if (alphaInfo == kCGImageAlphaNone)
	{
		alphaInfo = kCGImageAlphaNoneSkipLast;
	}
	else if ((alphaInfo == kCGImageAlphaLast) || (alphaInfo == kCGImageAlphaFirst))
	{
		alphaInfo = kCGImageAlphaPremultipliedLast;
	}
	CGFloat bytesPerRow = 4 * ((size.width > size.height) ? size.width : size.height);
	CGContextRef bitmap = CGBitmapContextCreate(NULL,
												size.width,
												size.height,
												8, //CGImageGetBitsPerComponent(imageRef),	// really needs to always be 8
												bytesPerRow, //4 * thumbRect.size.width,	// rowbytes
												CGImageGetColorSpace(imageRef),
												alphaInfo);
	
	//
	switch (self.imageOrientation)
	{
		case UIImageOrientationLeft:
		{
			CGContextRotateCTM(bitmap, _Radians(90));
			CGContextTranslateCTM(bitmap, 0, -size.height);
			break;
		}
		case UIImageOrientationRight:
		{
			CGContextRotateCTM(bitmap, _Radians(-90));
			CGContextTranslateCTM(bitmap, -size.width, 0);
			break;
		}
		case UIImageOrientationUp:
		{
			break;
		}
		case UIImageOrientationDown:
		{
			CGContextTranslateCTM(bitmap, size.width, size.height);
			CGContextRotateCTM(bitmap, _Radians(-180.));
			break;
		}
		default:
		{
			break;
		}
	}
	
	// Draw into the context, this scales the image
	CGRect rect = {0, 0, size.width, size.height};
	CGContextDrawImage(bitmap, rect, imageRef);
	
	// Get an image from the context and a UIImage
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	
	UIImage *image;
	if (scale == 1)
	{
		image = [UIImage imageWithCGImage:ref];
	}
	else
	{
		image = [UIImage imageWithCGImage:ref scale:scale orientation:UIImageOrientationUp/*self.imageOrientation*/];
	}
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return image;
}

//
#if 0
- (UIImage *)cropImageToRect:(CGRect)rect
{
	CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
	
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	CGContextRef bitmap = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
	
 	switch (self.imageOrientation)
	{
		case UIImageOrientationLeft:
		{
			CGContextRotateCTM(bitmap, _Radians(90));
			CGContextTranslateCTM(bitmap, 0, -rect.size.height);
			break;
		}
		case UIImageOrientationRight:
		{
			CGContextRotateCTM(bitmap, _Radians(-90));
			CGContextTranslateCTM(bitmap, -rect.size.width, 0);
		}
		case UIImageOrientationUp:
		{
			break;
		}
		case UIImageOrientationDown:
		{
			CGContextTranslateCTM(bitmap, rect.size.width, rect.size.height);
			CGContextRotateCTM(bitmap, _Radians(-180.));
			break;
		}
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, rect.size.width, rect.size.height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	
	UIImage *resultImage=[UIImage imageWithCGImage:ref];
	CGImageRelease(imageRef);
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return resultImage;
}
#endif

//
- (UIImage *)cropImageInRect:(CGRect)rect
{
	UIImage *image;
	CGImageRef ref;
	CGFloat scale = UIScreen.mainScreen.scale;
	rect.origin.x *= scale;
	rect.origin.y *= scale;
	rect.size.width *= scale;
	rect.size.height *= scale;
	ref = CGImageCreateWithImageInRect(self.CGImage, rect);
	image = [UIImage imageWithCGImage:ref scale:scale orientation:self.imageOrientation];
	CGImageRelease(ref);
	return image;
}

//
- (UIImage *)maskImageWithImage:(UIImage *)mask
{
	UIGraphicsBeginImageContextWithOptions(self.size, NO, UIUtil::ScreenScale());
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
	CGContextScaleCTM(context, 1, -1);
	CGContextTranslateCTM(context, 0, -rect.size.height);
	
	CGImageRef maskRef = mask.CGImage;
	CGImageRef maskImage = CGImageMaskCreate(CGImageGetWidth(maskRef),
											 CGImageGetHeight(maskRef),
											 CGImageGetBitsPerComponent(maskRef),
											 CGImageGetBitsPerPixel(maskRef),
											 CGImageGetBytesPerRow(maskRef),
											 CGImageGetDataProvider(maskRef), NULL, false);
	
	CGImageRef masked = CGImageCreateWithMask(self.CGImage, maskImage);
	CGImageRelease(maskImage);
	
	CGContextDrawImage(context, rect, masked);
	CGImageRelease(masked);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return newImage;
}

//
- (CGAffineTransform)orientationTransform:(CGSize *)newSize
{
	CGImageRef img = self.CGImage;
	CGFloat width = CGImageGetWidth(img);
	CGFloat height = CGImageGetHeight(img);
	CGSize size = CGSizeMake(width, height);
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGFloat origHeight = size.height;
	switch (self.imageOrientation)
	{
		case UIImageOrientationUp:
			break;
		case UIImageOrientationUpMirrored:
			transform = CGAffineTransformMakeTranslation(width, 0.0f);
			transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
			break;
		case UIImageOrientationDown:
			transform = CGAffineTransformMakeTranslation(width, height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformMakeTranslation(0.0f, height);
			transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
			break;
		case UIImageOrientationLeftMirrored:
			size.height = size.width;
			size.width = origHeight;
			transform = CGAffineTransformMakeTranslation(height, width);
			transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
			transform = CGAffineTransformRotate(transform, 3.0f * M_PI / 2.0f);
			break;
		case UIImageOrientationLeft:
			size.height = size.width;
			size.width = origHeight;
			transform = CGAffineTransformMakeTranslation(0.0f, width);
			transform = CGAffineTransformRotate(transform, 3.0f * M_PI / 2.0f);
			break;
		case UIImageOrientationRightMirrored:
			size.height = size.width;
			size.width = origHeight;
			transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0f);
			break;
		case UIImageOrientationRight:
			size.height = size.width;
			size.width = origHeight;
			transform = CGAffineTransformMakeTranslation(height, 0.0f);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0f);
			break;
		default:
			break;
	}
	*newSize = size;
	return transform;
}

//
- (UIImage *)straightenAndScaleImage:(NSUInteger)maxDimension
{
	CGImageRef img = self.CGImage;
	CGFloat width = CGImageGetWidth(img);
	CGFloat height = CGImageGetHeight(img);
	CGRect bounds = CGRectMake(0, 0, width, height);
	
	CGSize size = bounds.size;
	if (width > maxDimension || height > maxDimension)
	{
		CGFloat ratio = width/height;
		if (ratio > 1.0f)
		{
			size.width = maxDimension;
			size.height = size.width / ratio;
		}
		else
		{
			size.height = maxDimension;
			size.width = size.height * ratio;
		}
	}
	CGFloat scale = size.width/width;
	
	CGAffineTransform transform = [self orientationTransform:&size];
	size.width *= scale;
	size.height *= scale;
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Flip
	UIImageOrientation orientation = self.imageOrientation;
	if (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft)
	{
		CGContextScaleCTM(context, -scale, scale);
		CGContextTranslateCTM(context, -height, 0);
	}
	else
	{
		CGContextScaleCTM(context, scale, -scale);
		CGContextTranslateCTM(context, 0, -height);
	}
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, bounds, img);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
@end


#pragma mark UIView methods

@implementation UIView (ViewEx)

//
- (void)removeSubviews
{
	while (self.subviews.count)
	{
		UIView* child = self.subviews.lastObject;
		[child removeFromSuperview];
	}
}

//
- (void)hideKeyboard
{
	[self.findFirstResponder resignFirstResponder];
}

//
- (UIView *)findFirstResponder
{
	if ([self isFirstResponder])
	{
		return self;
	}
	
	for (UIView *view in self.subviews)
	{
		UIView* ret = [view findFirstResponder];
		if (ret)
		{
			return ret;
		}
	}
	return nil;
}

//
- (UIView *)findSubview:(NSString *)cls
{
	for (UIView *child in self.subviews)
	{
		if ([child isKindOfClass:NSClassFromString(cls)])
		{
			return child;
		}
		else
		{
			UIView *ret = [child findSubview:cls];
			if (ret)
			{
				return ret;
			}
		}
	}
	
	return nil;
}

//
#define kActivityViewTag 53217
- (UIActivityIndicatorView *)showActivityIndicator:(BOOL)show
{
	UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[self viewWithTag:kActivityViewTag];
	if (show == NO)
	{
		[activityView removeFromSuperview];
		return nil;
	}
	else if (activityView == nil)
	{
		activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		activityView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
		activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:activityView];
		[activityView startAnimating];
		activityView.tag = kActivityViewTag;
	}
	return activityView;
}

//
- (void)fadeForAction:(SEL)action target:(id)target
{
	[self fadeForAction:action target:target duration:0.3];
}

//
- (void)fadeForAction:(SEL)action target:(id)target duration:(CGFloat)duration
{
	[self fadeForAction:action target:target duration:duration delay:0];
}

//
- (void)fadeForAction:(SEL)action target:(id)target duration:(CGFloat)duration delay:(CGFloat)delay
{
	[UIView beginAnimations:nil context:[[NSArray alloc] initWithObjects:target, [NSValue valueWithPointer:action], [NSNumber numberWithFloat:duration], [NSNumber numberWithFloat:delay], nil]];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeInForAction: finished: context:)];
	self.alpha = (self.alpha == 0) ? 1 : 0;
	[UIView commitAnimations];
}

//
- (void)fadeInForAction:(NSString *)animationID finished:(NSNumber *)finished context:(NSArray *)context
{
	id target = [context objectAtIndex:0];
	NSValue *value = [context objectAtIndex:1];
	CGFloat duration = [[context objectAtIndex:2] floatValue];
	CGFloat delay = [[context objectAtIndex:3] floatValue];
	SEL action = (SEL)value.pointerValue;
	if (delay == 0)
	{
		[target performSelector:action withObject:self];
	}
	[context release];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	if (delay != 0)
	{
		[UIView setAnimationDelay:delay];
		[UIView setAnimationDelegate:target];
		[UIView setAnimationDidStopSelector:action];
	}
	self.alpha = (self.alpha == 1) ? 0 : 1;
	[UIView commitAnimations];
}

//
- (void)shakeAnimatingWithCompletion:(void (^)(BOOL finished))completion
{
	[UIView animateWithDuration:0.1 animations:^()
	 {
		 self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -20, 0);
	 } completion:^(BOOL finished)
	 {
		 [UIView animateWithDuration:0.1 animations:^()
		  {
			  self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 20, 0);
		  } completion:^(BOOL finished)
		  {
			  [UIView animateWithDuration:0.1 animations:^()
			   {
				   self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -20, 0);
				   
			   } completion:^(BOOL finished)
			   {
				   [UIView animateWithDuration:0.1 animations:^()
					{
						self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
					} completion:completion];
			   }];
			  
		  }];
	 }];
}

//
- (void)shakeAnimating
{
	[self shakeAnimatingWithCompletion:nil];
}

//
- (UIImage*)screenshotWithOptimization:(BOOL)optimized
{
	if (optimized)
	{
		// take screenshot of the view
		if ([self isKindOfClass:NSClassFromString(@"MKMapView")])
		{
			if ([[[UIDevice currentDevice] systemVersion] floatValue]>=6.0)
			{
				// in iOS6, there is no problem using a non-retina screenshot in a retina display screen
				UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1.0);
			}
			else
			{
				// if the view is a mapview in iOS5.0 and below, screenshot has to take the screen scale into consideration
				// else, the screen shot in retina display devices will be of a less detail map (note, it is not the size of the screenshot, but it is the level of detail of the screenshot
				UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
			}
		}
		else
		{
			// for performance consideration, everything else other than mapview will use a lower quality screenshot
			UIGraphicsBeginImageContext(self.frame.size);
		}
	}
	else
	{
		UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
	}
	
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return screenshot;
}

//
- (UIImage*)screenshot
{
	return [self screenshotWithOptimization:NO];
}

@end


#pragma mark UIAlertView methods

@implementation UIAlertView (AlertViewEx)

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle, ...
{
	va_list arg;
	va_start(arg, otherButtonTitle);
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:title
														 message:message
														delegate:delegate
											   cancelButtonTitle:cancelButtonTitle
											   otherButtonTitles:otherButtonTitle,
							   va_arg(arg, NSString *),
							   va_arg(arg, NSString *),
							   va_arg(arg, NSString *),
							   va_arg(arg, NSString *),
							   nil] autorelease];
	va_end(arg);
	[alertView show];
	return alertView;
}

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle
{
	return [self alertWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
}

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle
{
	return [self alertWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
}

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message
{
	return [self alertWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"关闭") otherButtonTitle:nil];
}

//
+ (id)alertWithTitle:(NSString *)title
{
	return [self alertWithTitle:title message:nil];
}

//
+ (id)alertWithTask:(id/*<AlertViewExDelegate>*/)delegate title:(NSString *)title
{
	UIAlertView *alertView = [self alertWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitle:nil];
	[alertView.activityIndicator startAnimating];
	[delegate performSelectorInBackground:@selector(taskForAlertView:) withObject:alertView];
	return alertView;
}

//
#define kTextFieldTag 1923
- (UITextField *)textField
{
	UITextField *textField = (UITextField *)[self viewWithTag:kTextFieldTag];
	if (textField == nil)
	{
		textField = [[[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 32)] autorelease];
		textField.borderStyle = UITextBorderStyleRoundedRect;
		textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		textField.tag = kTextFieldTag;
		
		[self addSubview:textField];
		[textField becomeFirstResponder];
	}
	return textField;
}

//
#define kActivityIndicatorTag 1924
- (UIActivityIndicatorView *)activityIndicator
{
	UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self viewWithTag:kActivityIndicatorTag];
	if (activityIndicator == nil)
	{
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height - 40);
		activityIndicator.tag = kActivityIndicatorTag;
		activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:activityIndicator];
		[activityIndicator release];
	}
	return activityIndicator;
}

//
- (void)dismissOnMainThread
{
	[self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
}

//
- (void)dismiss
{
	[self dismissWithClickedButtonIndex:0 animated:YES];
}

@end


#pragma mark UITabBarController methods

@implementation UITabBarController (TabBarControllerEx)

//
- (UIViewController *)currentViewController
{
	if (UIUtil::IsPad())
	{
		return self.selectedIndex < 7 ? self.selectedViewController : self.moreNavigationController;
	}
	else
	{
		return self.selectedIndex < 4 ? self.selectedViewController : self.moreNavigationController;
	}
}

@end


#pragma mark UIViewController methods

@implementation UIViewController (ViewControllerEx)

//
#ifndef BaseNavigationController
#define BaseNavigationController UINavigationController
#endif
- (UINavigationController *)presentNavigationController:(UIViewController *)controller animated:(BOOL)animated
{
	UINavigationController *navigator = [[[BaseNavigationController alloc] initWithRootViewController:controller] autorelease];
	navigator.modalTransitionStyle = controller.modalTransitionStyle;
	navigator.modalPresentationStyle = controller.modalPresentationStyle;
	
#ifdef kNavigationBarTintColor
	navigator.toolbar.tintColor = navigator.navigationBar.tintColor = kNavigationBarTintColor;
#endif

	[self presentModalViewController:navigator animated:animated];
	return navigator;
}

//
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated dismissButtonTitle:(NSString *)dismissButtonTitle
{
#ifdef _ALIPAY
	controller.navigationItem.leftBarButtonItem = [ALPBarButtonItem buttonItemWithTitle:dismissButtonTitle
																				 target:self.navigationController
																				 action:@selector(dismissModalViewController)];
#else
	controller.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:dismissButtonTitle
																					style:UIBarButtonItemStyleDone
																				   target:self
																				   action:@selector(dismissModalViewController)] autorelease];
#endif
	return [self presentNavigationController:controller animated:animated];
}

//
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated
{
	return [self presentModalNavigationController:controller animated:animated dismissButtonTitle:NSLocalizedString(@"Back", @"返回")];
}

//
- (void)dismissModalViewController
{
	[self dismissModalViewControllerAnimated:YES];
}

@end


// Solid navigtion controller to avoid set tab bar item's title
@implementation SolidNavigationController
- (void)setTitle:(NSString *)title
{
	UITabBarItem *barItem = [self.tabBarItem retain];
	self.tabBarItem = nil;
	[super setTitle:title];
	self.tabBarItem = barItem;
	[barItem release];
}
@end


#pragma mark Button methods

@implementation UIButton (ButtonEx)

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
		image = image.stretchableImage;
		imaged = imaged.stretchableImage;
		image_ = image_.stretchableImage;
	}

	UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
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
	UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
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

@end


#pragma mark Bar button item methods

@implementation UIBarButtonItem (BarButtonItemEx)

//
+ (id)barButtonItemWithImage:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)action
{
	UIFont *font = title ? [UIFont boldSystemFontOfSize:13] : nil;
	CGRect frame = {0, 0, [title sizeWithFont:font].width + image.size.width, image.size.height};
	UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
	
	if (title)
	{
		button.titleLabel.font = font;
		[button setTitle:title forState:UIControlStateNormal];
		[button setBackgroundImage:image.stretchableImage forState:UIControlStateNormal];
	}
	else
	{
		button.showsTouchWhenHighlighted = YES;
		[button setImage:image forState:UIControlStateNormal];
	}

	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}

//
+ (id)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
	return [self barButtonItemWithImage:image title:nil target:target action:action];
}

@end

#pragma mark UILabel methods

@implementation UILabel (LabelEx)

//
+ (id)labelAtPoint:(CGPoint)point
		  withText:(NSString *)text
		 withWidth:(float)width
		 withColor:(UIColor *)color
		  withFont:(UIFont*)font
	 withAlignment:(NSTextAlignment)alignment
{
	CGSize size = [text sizeWithFont:font
				   constrainedToSize:CGSizeMake(width, 1000)];
	
	CGRect frame = CGRectMake(point.x, point.y, width, size.height);
	
	UILabel *label = [UILabel labelWithFrame:frame withText:text withColor:color withFont:font withAlignment:alignment];
	label.numberOfLines = 0;
	return label;
}

//
+ (id)labelWithFrame:(CGRect)frame
			withText:(NSString *)text
		   withColor:(UIColor *)color
			withFont:(UIFont *)font
	   withAlignment:(NSTextAlignment)alignment
{
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.textColor = color;
	label.backgroundColor = [UIColor clearColor];
	label.font = font;
	label.text = text;
	label.textAlignment = alignment;
	
	return label;
}

@end
