
#import "UIUtil.h"

NSUInteger UIUtil::_networkIndicatorRef = 0;

//
@implementation UIViewController (EXViewController)
- (void)dismissModalViewController
{
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end

//
@implementation EXTapGestureRecognizer
- (id)initWithTarget:(id)target action:(SEL)action
{
	self = [super initWithTarget:target action:action];
	self.cancelsTouchesInView = NO;
	self.delegate = self;
	return self;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	UIView *view = touch.view;
	return (view == gestureRecognizer.view) || ![view isKindOfClass:[UIButton class]];
}
@end

//
void UIUtil::LogIndentString(NSUInteger indent, NSString *str)
{
	NSString *log = @"";
	for (NSUInteger i = 0; i < indent; i++)
	{
		log = [log stringByAppendingString:@"\t"];
	}
	log = [log stringByAppendingString:str];
	_Log(@"%@", log);
}

// Log controller and sub-controllers
void UIUtil::LogController(UIViewController *controller, NSUInteger indent)
{
	LogIndentString(indent, [NSString stringWithFormat:@"<Controller Description=\"%@\">", [controller description]]);
	
	if (controller.presentedViewController)
	{
		LogController(controller, indent + 1);
	}
	
	if ([controller isKindOfClass:[UINavigationController class]])
	{
		for (UIViewController *child in ((UINavigationController *)controller).viewControllers)
		{
			LogController(child, indent + 1);
		}
	}
	else if ([controller isKindOfClass:[UITabBarController class]])
	{
		UITabBarController *tabBarController = (UITabBarController *)controller;
		for (UIViewController *child in tabBarController.viewControllers)
		{
			LogController(child, indent + 1);
		}
		
		if (tabBarController.moreNavigationController)
		{
			LogController(tabBarController.moreNavigationController, indent + 1);
		}
	}
	
	LogIndentString(indent, @"</Controller>");
}

// Log view and subviews
void UIUtil::LogView(UIView *view, NSUInteger indent)
{
	CGRect frame = [view.superview convertRect:view.frame toView:nil];
	NSString *rect = NSStringFromCGRect(frame);
	
	LogIndentString(indent, [NSString stringWithFormat:@"<View%@ Description=\"%@\">", rect, [view description]]);
	
	for (UIView *child in view.subviews)
	{
		LogView(child, indent + 1);
	}
	
	LogIndentString(indent, @"</View>");
	
}

//
void UIUtil::LogConstraints(UIView *view)
{
	NSArray *constraints = view.constraints;
	_LogObj(view);
	_LogObj(constraints);
	
	const static NSString *_attributes[] =
	{
		@"None",
		@"Left",
		@"Right",
		@"Top",
		@"Bottom",
		@"Leading",
		@"Trailing",
		@"Width",
		@"Height",
		@"CenterX",
		@"CenterY",
		@"Baseline",
	};
	
	for (NSLayoutConstraint *constraint in constraints)
	{
		NSLog(@"{%.0f: %@/%@ %c %@/%@ %.1f%@}",
			 constraint.priority,
			 NSStringFromClass([constraint.firstItem class]),
			 _attributes[constraint.firstAttribute],
			 (constraint.relation > 0) ? '>' : ((constraint.relation < 0) ? '<' : '='),
			 NSStringFromClass([constraint.secondItem class]),
			 _attributes[constraint.secondAttribute],
			 constraint.constant,
			 ((constraint.multiplier == 1.0) ? @"" : [NSString stringWithFormat:@"x%.1f", constraint.multiplier])
			 );
	}
}

//
BOOL UIUtil::NormalizePngFile(NSString *dst, NSString *src)
{
	NSString *dir = dst.stringByDeletingLastPathComponent;
	if ([[NSFileManager defaultManager] fileExistsAtPath:dir] == NO)
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	UIImage *image = [UIImage imageWithContentsOfFile:src];
	if (image == nil) return NO;
	
	NSData *data = UIImagePNGRepresentation(image);
	if (data == nil) return NO;
	
	return [data writeToFile:dst atomically:NO];
}

//
void UIUtil::NormalizePngFolder(NSString *dst, NSString *src)
{
	NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:src];
	for (NSString *file in files)
	{
		if ([file.lowercaseString hasSuffix:@".png"])
		{
			NormalizePngFile([dst stringByAppendingPathComponent:file], [src stringByAppendingPathComponent:file]);
		}
	}
}

//
UIImageView *UIUtil::ShowSplashView(UIView *fadeInView, CGFloat duration)
{
	//
	CGRect frame = UIUtil::ScreenBounds();
	UIImageView *splashView = [[UIImageView alloc] initWithFrame:frame];
	splashView.image = [UIImage imageNamed:UIUtil::IsPad() ? @"Default@iPad.png" : (UIUtil::IsPhone5() ? @"Default-568h.png" : @"Default.png")];
	splashView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[UIUtil::KeyWindow() addSubview:splashView];
	
	//
	//UIImage *logoImage = [UIImage imageWithContentsOfFile:NSUtil::BundlePath(UIUtil::IsPad() ? @"Splash@2x.png" : @"Splash.png")];
	//UIImageView *logoView = [[[UIImageView alloc] initWithImage:logoImage] autorelease];
	//logoView.center = CGPointMake(frame.size.width / 2, (frame.size.height / 2));
	//logoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	//splashView.tag = (NSInteger)logoView;
	//[splashView addSubview:logoView];
	
	//
	fadeInView.alpha = 0;
	
	[UIView animateWithDuration:duration animations:^()
	 {
		 //
		 fadeInView.alpha = 1;
		 splashView.alpha = 0;
		 //splashView.frame = CGRectInset(frame, -frame.size.width / 2, -frame.size.height / 2);
		 //splashView.frame = CGRectInset(frame, frame.size.width / 2, frame.size.height / 2);
	 } completion:^(BOOL finished)
	 {
		 [splashView removeFromSuperview];
	 }];
	
	return splashView;
}

//
UIImage *UIUtil::ImageWithColor(UIColor *color, CGSize size)
{
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

// Scale to specified size if needed
#define _Radians(d) (d * M_PI/180)
UIImage *UIUtil::ScaleImage(UIImage *self, CGSize size)
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
UIImage *UIUtil::CropImage(UIImage *self, CGRect rect)
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
UIImage *UIUtil::MaskImage(UIImage * self ,UIImage *mask)
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
CGAffineTransform UIUtil::ImageOrientation(UIImage *self, CGSize *newSize)
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
UIImage *UIUtil::StraightenAndScaleImage(UIImage *self, NSUInteger maxDimension)
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
	
	CGAffineTransform transform = ImageOrientation(self, &size);
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

//
#ifdef _BlurImage
#import <Accelerate/Accelerate.h>
#define scaleDownFactor 4
UIImage *UIUtil::BlurImage(UIImage *image, CGRect bounds, CGSize size, CGFloat blurRadius, UIColor *tintColor, CGFloat saturationDeltaFactor, UIImage *maskImage)
{
	if (image.size.width < 1 || image.size.height < 1)
	{
		_Log(@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", image.size.width, image.size.height, image);
		return nil;
	}
	
	if (!image.CGImage)
	{
		_Log(@"*** error: image must be backed by a CGImage: %@", image);
		return nil;
	}
	
	if (maskImage && !maskImage.CGImage)
	{
		_Log(@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
		return nil;
	}
	
	//Crop
	UIImage *outputImage = nil;
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], bounds);
	outputImage = [UIImage imageWithCGImage:imageRef];
	
	CGImageRelease(imageRef);
	
	//Re-Size
	CGImageRef sourceRef = [outputImage CGImage];
	NSUInteger sourceWidth = CGImageGetWidth(sourceRef);
	NSUInteger sourceHeight = CGImageGetHeight(sourceRef);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	unsigned char *sourceData = (unsigned char*) calloc(sourceHeight * sourceWidth * 4, sizeof(unsigned char));
	
	NSUInteger bytesPerPixel = 4;
	NSUInteger sourceBytesPerRow = bytesPerPixel * sourceWidth;
	NSUInteger bitsPerComponent = 8;
	
	CGContextRef context = CGBitmapContextCreate(sourceData, sourceWidth, sourceHeight, bitsPerComponent, sourceBytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
	
	CGContextDrawImage(context, CGRectMake(0, 0, sourceWidth, sourceHeight), sourceRef);
	CGContextRelease(context);
	
	NSUInteger destWidth = (NSUInteger) size.width / scaleDownFactor;
	NSUInteger destHeight = (NSUInteger) size.height / scaleDownFactor;
	NSUInteger destBytesPerRow = bytesPerPixel * destWidth;
	
	unsigned char *destData = (unsigned char*) calloc(destHeight * destWidth * 4, sizeof(unsigned char));
	
	vImage_Buffer src =
	{
		.data = sourceData,
		.height = sourceHeight,
		.width = sourceWidth,
		.rowBytes = sourceBytesPerRow
	};
	
	vImage_Buffer dest =
	{
		.data = destData,
		.height = destHeight,
		.width = destWidth,
		.rowBytes = destBytesPerRow
	};
	
	vImageScale_ARGB8888 (&src, &dest, NULL, kvImageNoInterpolation);
	
	free(sourceData);
	
	CGContextRef destContext = CGBitmapContextCreate(destData, destWidth, destHeight, bitsPerComponent, destBytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
	
	CGImageRef destRef = CGBitmapContextCreateImage(destContext);
	
	outputImage = [UIImage imageWithCGImage:destRef];
	
	CGImageRelease(destRef);
	
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(destContext);
	
	free(destData);
	
	//Blur
	CGRect imageRect = { CGPointZero, outputImage.size };
	
	BOOL hasBlur = blurRadius > __FLT_EPSILON__;
	BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
	
	if (hasBlur || hasSaturationChange)
	{
		UIGraphicsBeginImageContextWithOptions(outputImage.size, NO, 1);
		
		CGContextRef effectInContext = UIGraphicsGetCurrentContext();
		
		CGContextScaleCTM(effectInContext, 1.0, -1.0);
		CGContextTranslateCTM(effectInContext, 0, -outputImage.size.height);
		CGContextDrawImage(effectInContext, imageRect, outputImage.CGImage);
		
		vImage_Buffer effectInBuffer;
		
		effectInBuffer.data	 = CGBitmapContextGetData(effectInContext);
		effectInBuffer.width	= CGBitmapContextGetWidth(effectInContext);
		effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
		effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
		
		UIGraphicsBeginImageContextWithOptions(outputImage.size, NO, 1);
		
		CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
		vImage_Buffer effectOutBuffer;
		
		effectOutBuffer.data	 = CGBitmapContextGetData(effectOutContext);
		effectOutBuffer.width	= CGBitmapContextGetWidth(effectOutContext);
		effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
		effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
		
		if (hasBlur)
		{
			CGFloat inputRadius = blurRadius * 1;
			NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
			
			if (radius % 2 != 1)
			{
				radius += 1;
			}
			
			vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
			vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
			vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
		}
		
		BOOL effectImageBuffersAreSwapped = NO;
		
		if (hasSaturationChange)
		{
			
			CGFloat s = saturationDeltaFactor;
			CGFloat floatingPointSaturationMatrix[] = {
				0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
				0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
				0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
				0,					0,					0,  1,
			};
			
			const int32_t divisor = 256;
			NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
			int16_t saturationMatrix[matrixSize];
			
			for (NSUInteger i = 0; i < matrixSize; ++i)
			{
				saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
			}
			
			if (hasBlur)
			{
				vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
				effectImageBuffersAreSwapped = YES;
			}
			else
			{
				vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
			}
		}
		
		if (!effectImageBuffersAreSwapped)
		{
			outputImage = UIGraphicsGetImageFromCurrentImageContext();
		}
		UIGraphicsEndImageContext();
		
		if (effectImageBuffersAreSwapped)
		{
			outputImage = UIGraphicsGetImageFromCurrentImageContext();
		}
		UIGraphicsEndImageContext();
	}
	
	UIGraphicsBeginImageContextWithOptions(outputImage.size, NO, 1);
	CGContextRef outputContext = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(outputContext, 1.0, -1.0);
	CGContextTranslateCTM(outputContext, 0, -outputImage.size.height);
	
	CGContextDrawImage(outputContext, imageRect, outputImage.CGImage);
	
	if (hasBlur)
	{
		CGContextSaveGState(outputContext);
		if (maskImage)
		{
			CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
		}
		CGContextDrawImage(outputContext, imageRect, outputImage.CGImage);
		CGContextRestoreGState(outputContext);
	}
	
	if (tintColor)
	{
		CGContextSaveGState(outputContext);
		CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
		CGContextFillRect(outputContext, imageRect);
		CGContextRestoreGState(outputContext);
	}
	
	outputImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return outputImage;
}
#endif

//
UIView *UIUtil::FindFirstResponder(UIView *self)
{
	if ([self isFirstResponder])
	{
		return self;
	}
	
	for (UIView *view in self.subviews)
	{
		UIView* ret = FindFirstResponder(view);
		if (ret)
		{
			return ret;
		}
	}
	return nil;
}

//
UIView *UIUtil::FindSubview(UIView *self, NSString *cls)
{
	for (UIView *child in self.subviews)
	{
		if ([child isKindOfClass:NSClassFromString(cls)])
		{
			return child;
		}
		else
		{
			UIView *ret = FindSubview(child, cls);
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
UIActivityIndicatorView *ShowActivityIndicator(UIView *self, BOOL show)
{
	UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[self viewWithTag:kActivityViewTag];
	if (show == NO)
	{
		[activityView removeFromSuperview];
		return nil;
	}
	else if (activityView == nil)
	{
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
		activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:activityView];
		[activityView startAnimating];
		activityView.tag = kActivityViewTag;
	}
	return activityView;
}

//
void UIUtil::ShakeAnimating(UIView *self, void (^completion)(BOOL finished))
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
UIImage *UIUtil::Snapshot(UIView *self, BOOL optimized)
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
				// else, the screen shot in retina display devices will be of a less text map (note, it is not the size of the screenshot, but it is the level of text of the screenshot
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
UIView *UIUtil::SuperviewWithClass(UIView *self, Class viewClass)
{
	UIView *view = self;
	while ((view = view.superview))
	{
		if ([view isKindOfClass:viewClass])
		{
			return view;
		}
	}
	return nil;
}
