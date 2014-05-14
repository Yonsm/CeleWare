
#import <QuartzCore/QuartzCore.h>

//
@interface UIDevice (EXDevice)
- (NSString *)uniqueIdentifier;
@end

//
@interface UIViewController (EXViewController)
- (void)dismissModalViewController;
@end

//
@interface EXTapGestureRecognizer : UITapGestureRecognizer <UIGestureRecognizerDelegate>
@end

//
#define EXTableViewCellAccessoryButton (UIUtil::IsOS7() ? UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryDetailDisclosureButton)

//
@class AppDelegate;
class UIUtil
{
#pragma mark Device methods
public:
	//
	NS_INLINE UIDevice *Device()
	{
		return [UIDevice currentDevice];
	}
	
	//
	NS_INLINE NSString *DeviceID()
	{
		if ([Device() respondsToSelector:@selector(identifierForVendor)])
		{
			return Device().identifierForVendor.UUIDString;
		}
		return [Device() uniqueIdentifier];
	}
	
	//
	NS_INLINE float SystemVersion()
	{
		return [[Device() systemVersion] floatValue];
	}
	
	//
	NS_INLINE BOOL IsPad()
	{
		return [Device() userInterfaceIdiom] == UIUserInterfaceIdiomPad;
	}
	
	//
	NS_INLINE BOOL IsRetina()
	{
		return ScreenScale() == 2;
	}
	
	//
	NS_INLINE BOOL IsPhone5()
	{
		return ScreenBounds().size.height > 480;
	}
	
	//
	NS_INLINE BOOL IsOS7()
	{
		return SystemVersion() >= 7.0;
	}
	
	//
	NS_INLINE UIScreen *Screen()
	{
		return [UIScreen mainScreen];
	}
	
	//
	NS_INLINE CGFloat ScreenScale()
	{
		return Screen().scale;
	}
	
	//
	NS_INLINE CGRect AppFrame()
	{
		return Screen().applicationFrame;
	}
	
	//
	NS_INLINE CGSize ScreenSize()
	{
		CGRect frame = AppFrame();
		return CGSizeMake(frame.size.width, frame.size.height + frame.origin.y);
	}
	
	//
	NS_INLINE CGRect ScreenBounds()
	{
		return Screen().bounds;
	}
	
	
#pragma mark Application methods
public:
	//
	NS_INLINE UIApplication *Application()
	{
		return UIApplication.sharedApplication;
	}
	
	//
	NS_INLINE AppDelegate *Delegate()
	{
		return (AppDelegate *)Application().delegate;
	}
	
	//
	NS_INLINE UIViewController *RootViewController()
	{
		return UIApplication.sharedApplication.delegate.window.rootViewController;
	}
	
	//
	NS_INLINE UIViewController *FrontViewController()
	{
		UIViewController *controller = RootViewController();
		UIViewController *presented = controller.presentedViewController;
		return presented ? presented : controller;
	}
	
	//
	NS_INLINE UIViewController *VisibleViewController()
	{
		UIViewController *controller = FrontViewController();
		while (YES)
		{
			if ([controller isKindOfClass:[UINavigationController class]])
			{
				controller = ((UINavigationController *)controller).visibleViewController;
			}
			else if ([controller isKindOfClass:[UITabBarController class]])
			{
				controller = ((UITabBarController *)controller).selectedViewController;
			}
			else
			{
				return controller;
			}
		}
	}
	
	//
	NS_INLINE BOOL CanOpenUrl(NSString *url)
	{
		return [Application() canOpenURL:[NSURL URLWithString:url]];
	}
	
	//
	NS_INLINE BOOL OpenUrl(NSString *url)
	{
		BOOL ret = [Application() openURL:[NSURL URLWithString:url]];
		if (ret == NO)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not open", @"无法打开")
																message:url
															   delegate:nil
													  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"关闭")
													  otherButtonTitles:nil];
			[alertView show];
		}
		return ret;
	}
	
	//
	NS_INLINE BOOL OpenUrlWithEscape(NSString *url)
	{
		return OpenUrl([url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
	}
	
	//
	NS_INLINE BOOL MakeCall(NSString *number, BOOL direct = YES)
	{
		NSString *url = [NSString stringWithFormat:(direct ? @"tel://%@" : @"telprompt://%@"), [number stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		NSURL *URL = [NSURL URLWithString:url];
		
		BOOL ret = [Application() openURL:URL];
		if (ret == NO)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not make call", @"无法拨打电话")
																message:number
															   delegate:nil
													  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"关闭")
													  otherButtonTitles:nil];
			[alertView show];
		}
		return ret;
	}
	
	//
	NS_INLINE UIWindow *KeyWindow()
	{
		return Application().keyWindow;
	}
	
	//
	NS_INLINE BOOL IsWindowLandscape()
	{
		CGSize size = KeyWindow().frame.size;
		return size.width > size.height;
	}
	
	//
	NS_INLINE BOOL IsKeyboardInDisplay()
	{
		Class keyboardClass = NSClassFromString(@"UIPeripheralHostView");
		for (UIWindow *window in Application().windows)
		{
			for (UIView *subview in window.subviews )
			{
				if ([subview isKindOfClass:keyboardClass])
				{
					return YES;
				}
			}
		}
		return NO;
	}
	
	//
	NS_INLINE void ShowStatusBar(BOOL show = YES, UIStatusBarAnimation animated = UIStatusBarAnimationFade)
	{
		[Application() setStatusBarHidden:!show withAnimation:animated];
	}
	
	//
	static NSUInteger _networkIndicatorRef;
	NS_INLINE void ShowNetworkIndicator(BOOL show = YES)
	{
		if (show)
		{
			if (_networkIndicatorRef == 0) Application().networkActivityIndicatorVisible = YES;
			_networkIndicatorRef++;
		}
		else
		{
			if (_networkIndicatorRef != 0) _networkIndicatorRef--;
			if (_networkIndicatorRef == 0) Application().networkActivityIndicatorVisible = NO;
		}
	}
	
public:
	// Log log with indent
	static void LogIndentString(NSUInteger indent, NSString *str);
	
	// Log controller and sub-controllers
	static void LogController(UIViewController *controller, NSUInteger indent = 0);
	
	// Log view and subviews
	static void LogView(UIView *view, NSUInteger indent = 0);
	
	// Log layout constraints
	static void LogConstraints(UIView *view);
	
public:
	// Nomalize png file
	static BOOL NormalizePngFile(NSString *dst, NSString *src);
	
	// Nomalize png folder
	static void NormalizePngFolder(NSString *dst, NSString *src);
	
public:
	//
	static UIImageView *ShowSplashView(UIView *fadeInView = nil, CGFloat duration = 0.6);
	
#pragma mark Misc methods
	
	//
	NS_INLINE UIImage *Image(NSString *file)
	{
#ifdef _UncacheImage
		// 支持无 @1x 时使用
		if (![file hasPrefix:@".png"]) file = [file stringByAppendingString:@"@2x.png"];
		return [UIImage imageWithContentsOfFile:NSUtil::AssetPath(file)];
#else
		return ImageNamed(file);
#endif
	}
	
	//
	NS_INLINE UIImage *ImageNamed(NSString *name)
	{
#ifdef kAssetBundle
		name = [kAssetBundle stringByAppendingPathComponent:name];
#endif
		return [UIImage imageNamed:name];
	}
	
	// Param name must NOT have suffix @".png"
	NS_INLINE UIImage *ImageNamed2X(NSString *name)
	{
		return ImageNamed([name stringByAppendingString:IsPad() ? @"@2x.png" : @".png"]);
	}
	
	// UIColor from HTML color
	NS_INLINE UIColor *Color(NSString *code)
	{
		NSUInteger length = code.length;
		if ((length == 6) || (length == 8))
		{
			unsigned char color[8];
			sscanf(code.UTF8String, "%02X%02X%02X%02X", (unsigned int *)&color[0], (unsigned int *)&color[1], (unsigned int *)&color[2], (unsigned int *)&color[3]);
			if (length == 6)
			{
				color[3] = 0xFF;
			}
			return [UIColor colorWithRed:color[0]/255.0 green:color[1]/255.0 blue:color[2]/255.0 alpha:color[3]/255.0];
		}
		return [UIColor blackColor];
	}
	
	// UIColor from RGBO
	NS_INLINE UIColor *Color(NSUInteger rgbt)
	{
		NSUInteger transparent = (rgbt & 0xFF000000) >> 24;
		NSUInteger alpha = 0xFF - transparent;
		return [UIColor colorWithRed:((rgbt & 0x00FF0000) >> 16) / 255.0
							   green:((rgbt & 0x0000FF00) >> 8) / 255.0
								blue:((rgbt & 0x000000FF)) / 255.0
							   alpha:alpha / 255.0];
	}
	
	// UIColor from RGBA
	NS_INLINE UIColor *Color(unsigned char r, unsigned char g, unsigned char b, CGFloat a = 1)
	{
		return [UIColor colorWithRed:r / 255.0
							   green:g / 255.0
								blue:b / 255.0
							   alpha:a];
	}
	
public:
	//
	NS_INLINE UIImage *StretchableImage(UIImage *self)
	{
		return [self stretchableImageWithLeftCapWidth:self.size.width / 2 topCapHeight:self.size.height / 2];
	}
	
	//
	static UIImage *ImageWithColor(UIColor *color, CGSize size = CGSizeMake(1, 1));
	
	//
	NS_INLINE UIImage *ImageWithColor(unsigned char r, unsigned char g, unsigned char b, CGFloat a = 1, CGSize size = CGSizeMake(1, 1))
	{
		return ImageWithColor(Color(r, g, b, a), size);
	}
	
	//
	NS_INLINE UIImage *ImageWithColor(NSUInteger rgbt, CGSize size = CGSizeMake(1, 1))
	{
		return ImageWithColor(Color(rgbt), size);
	}
	
	// Scale to specified size if needed
	static UIImage *ScaleImage(UIImage *self, CGSize size);
	
	//
	static UIImage *CropImage(UIImage *self, CGRect rect);
	
	//
	static UIImage *MaskImage(UIImage * self ,UIImage *mask);
	
	//
	static CGAffineTransform ImageOrientation(UIImage *self, CGSize *newSize);
	
	//
	static UIImage *StraightenAndScaleImage(UIImage *self, NSUInteger maxDimension);
	
	//
#ifdef _BlurImage
	static UIImage *BlurImage(UIImage *image, CGRect bounds, CGSize size, CGFloat blurRadius, UIColor *tintColor, CGFloat saturationDeltaFactor = 1.0, UIImage *maskImage = nil);
#endif
	
#pragma mark UIView methods
	//
	NS_INLINE UIView *ViewWithColor(CGRect frame, UIColor *backgroundColor = Color(0xcc, 0xcc, 0xcc))
	{
		UIView *view = [[UIView alloc] initWithFrame:frame];
		view.backgroundColor = backgroundColor;
		return view;
	}
	
	//
	NS_INLINE void RemoveSubviews(UIView *self)
	{
		while (self.subviews.count)
		{
			UIView* child = self.subviews.lastObject;
			[child removeFromSuperview];
		}
	}
	
	//
	NS_INLINE void HideKeyboard(UIView *self = KeyWindow())
	{
		[FindFirstResponder(self) resignFirstResponder];
	}
	
	//
	static UIView *FindFirstResponder(UIView *self);
	
	//
	static UIView *FindSubview(UIView *self, NSString *cls);
	
	//
	static UIActivityIndicatorView *ShowActivityIndicator(UIView *self, BOOL show);
	
	//
	static void ShakeAnimating(UIView *self, void (^completion)(BOOL finished) = nil);
	
	//
	static UIImage *Snapshot(UIView *self, BOOL optimized = NO);
	
	//
	static UIView *SuperviewWithClass(UIView *self, Class viewClass);
	
#pragma mark UIAlertView methods
	//
	NS_INLINE UIAlertView *ShowAlert(NSString *title, NSString *message, id delegate, NSString *cancelButtonTitle, NSString *otherButtonTitles, ...)
	{
		va_list arg;
		va_start(arg, otherButtonTitles);
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
															message:message
														   delegate:delegate
												  cancelButtonTitle:cancelButtonTitle
												  otherButtonTitles:otherButtonTitles,
								  va_arg(arg, NSString *),
								  va_arg(arg, NSString *),
								  va_arg(arg, NSString *),
								  va_arg(arg, NSString *),
								  nil];
		va_end(arg);
		[alertView show];
		return alertView;
	}
	
	//
	NS_INLINE UIAlertView *ShowAlert(NSString *title, NSString *message = nil, id delegate = nil, NSString *cancelButtonTitle = NSLocalizedString(@"Dismiss", @"关闭"))
	{
		return ShowAlert(title, message, delegate, cancelButtonTitle, nil);
	}
	
	//
#define kActivityIndicatorTag 1924
	NS_INLINE UIActivityIndicatorView *AlertActivityIndicator(UIAlertView *self)
	{
		UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self viewWithTag:kActivityIndicatorTag];
		if (activityIndicator == nil)
		{
			activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			activityIndicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height - 40);
			activityIndicator.tag = kActivityIndicatorTag;
			activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
			[self addSubview:activityIndicator];
		}
		return activityIndicator;
	}
	
#pragma mark UITabBarController methods
	//
	NS_INLINE UIViewController *CurrentControllerInTab(UITabBarController *self)
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
	
#pragma mark UIViewController methods
#ifndef _NavigationController
#define _NavigationController UINavigationController
#endif
	//
	NS_INLINE UINavigationController *PresentNavigationController(UIViewController *self, UIViewController *controller, BOOL animated = YES)
	{
		UINavigationController *navigator = [[_NavigationController alloc] initWithRootViewController:controller];
		navigator.modalTransitionStyle = controller.modalTransitionStyle;
		navigator.modalPresentationStyle = controller.modalPresentationStyle;
		
#ifdef _NavigationBarTintColor
		navigator.toolbar.tintColor = navigator.navigationBar.tintColor = _NavigationBarTintColor;
#endif
		
		[self presentViewController:navigator animated:animated completion:nil];
		return navigator;
	}
	
	//
	NS_INLINE UINavigationController *PresentModalNavigationController(UIViewController *self, UIViewController *controller, BOOL animated = YES, NSString *dismissButtonTitle = NSLocalizedString(@"Back", @"返回"))
	{
		controller.navigationItem.leftBarButtonItem = BarButtonTitleItem(dismissButtonTitle, self.navigationController, @selector(dismissModalViewController));
		return PresentNavigationController(self, controller, animated);
	}
	
	//
	NS_INLINE void PresentViewController(UIViewController *self, UIViewController *controller, BOOL animated = YES)
	{
		[self presentViewController:controller animated:animated completion:nil];
	}
	
#pragma mark Bar button item methods
	NS_INLINE id BarButtonItem(UIImage *image, NSString *title, id target = nil, SEL action = nil)
	{
		UIFont *font = title ? [UIFont boldSystemFontOfSize:13] : nil;
		CGRect frame = {0, 0, [title sizeWithFont:font].width + image.size.width, image.size.height};
		UIButton *button = [[UIButton alloc] initWithFrame:frame];
		
		if (title)
		{
			button.titleLabel.font = font;
			[button setTitle:title forState:UIControlStateNormal];
			[button setBackgroundImage:StretchableImage(image) forState:UIControlStateNormal];
		}
		else
		{
			button.showsTouchWhenHighlighted = YES;
			[button setImage:image forState:UIControlStateNormal];
		}
		
		[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		return [[UIBarButtonItem alloc] initWithCustomView:button];
	}
	
	//
	NS_INLINE id BarButtonImageItem(UIImage *image, id target = nil, SEL action = nil)
	{
		return BarButtonItem(image, nil, target, action);
	}
	
	//
	NS_INLINE id BarButtonTitleItem(NSString *title, id target = nil, SEL action = nil)
	{
		return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:target action:action];
	}
	
#pragma mark UILabel methods
	//
	NS_INLINE UILabel *LabelAtPoint(CGPoint point, CGFloat width, NSString *text, UIFont* font = [UIFont systemFontOfSize:13], UIColor *color = UIColor.blackColor, NSTextAlignment alignment = NSTextAlignmentLeft)
	{
		CGSize size = [text sizeWithFont:font
					   constrainedToSize:CGSizeMake(width, 1000)];
		
		CGRect frame = CGRectMake(point.x, point.y, width, ceil(size.height));
		
		UILabel *label = LabelWithFrame(frame, text, font, color, alignment);
		label.numberOfLines = 0;
		return label;
	}
	
	//
	NS_INLINE UILabel *LabelWithFrame(CGRect frame, NSString *text, UIFont* font = [UIFont systemFontOfSize:13], UIColor *color = UIColor.blackColor, NSTextAlignment alignment = NSTextAlignmentLeft)
	{
		UILabel *label = [[UILabel alloc] initWithFrame:frame];
		label.textColor = color;
		label.backgroundColor = [UIColor clearColor];
		label.font = font;
		label.text = text;
		label.textAlignment = alignment;
		
		return label;
	}
	
#pragma mark Gesture methods
	//
	NS_INLINE UITapGestureRecognizer *AddTapGesture(UIView *self, id target, SEL action)
	{
		UITapGestureRecognizer *gesture = [[EXTapGestureRecognizer alloc] initWithTarget:target action:action];
		[self addGestureRecognizer:gesture];
		return gesture;
	}
	
	//
	NS_INLINE UILongPressGestureRecognizer *AddHoldGesture(UIView *self, id target, SEL action)
	{
		UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
		[self addGestureRecognizer:gesture];
		return gesture;
	}
};

#if defined(DEBUG) || defined(TEST)
#define _LogView(v)			UIUtil::LogView(v)
#define _LogController(c)	UIUtil::LogController(c)
#define _LogConstraints(v)	UIUtil::LogConstraints(v)
#else
#define _LogView(v)			((void) 0)
#define _LogConstraints(v)	((void) 0)
#define _LogController(c)	((void) 0)
#endif
