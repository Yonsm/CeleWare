
#import <QuartzCore/QuartzCore.h>

//
@interface UIDevice (UDID)
- (NSString *)uniqueIdentifier;
@end


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
	NS_INLINE UIViewController *CurrentViewController()
	{
		UIViewController *controller = FrontViewController();
		if ([controller isKindOfClass:[UINavigationController class]]) return ((UINavigationController *)controller).visibleViewController;
		if ([controller isKindOfClass:[UITabBarController class]]) return ((UITabBarController *)controller).selectedViewController;
		return controller;
	}

	//
	NS_INLINE BOOL CanOpenURL(NSString *url)
	{
		return [Application() canOpenURL:[NSURL URLWithString:url]];
	}
	
	//
	NS_INLINE BOOL OpenURL(NSString *url)
	{
		url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		BOOL ret = [Application() openURL:[NSURL URLWithString:url]];
		if (ret == NO)
		{
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not open", @"无法打开")
																 message:url
																delegate:nil
													   cancelButtonTitle:NSLocalizedString(@"Dismiss", @"关闭")
													   otherButtonTitles:nil] autorelease];
			[alertView show];
		}
		return ret;
	}
	
	//
	NS_INLINE BOOL MakeCall(NSString *number, BOOL direct = YES)
	{
		NSString *url = [NSString stringWithFormat:(direct ? @"tel://%@" : @"telprompt://%@"), [number stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		NSURL *URL = [NSURL URLWithString:url];
		
		BOOL ret = [Application() openURL:URL];
		if (ret == NO)
		{
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not make call", @"无法拨打电话")
																 message:number
																delegate:nil
													   cancelButtonTitle:NSLocalizedString(@"Dismiss", @"关闭")
													   otherButtonTitles:nil] autorelease];
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
	
	//
	static UIImageView *ShowSplashView(UIView *fadeInView = nil, CGFloat duration = 0.6);
	
#pragma mark Misc methods
	
	//
	NS_INLINE UIImage *Image(NSString *file)
	{
#ifdef _UncacheImage
		return [UIImage imageWithContentsOfFile:NSUtil::ResourcePath(file)];
#else
		return ImageNamed(file);
#endif
	}
	
	//
	NS_INLINE UIImage *ImageNamed(NSString *name)
	{
#ifdef kResourceBundle
		name = [kResourceBundle stringByAppendingPathComponent:name];
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
	
#pragma mark Debug methods
public:
	// Print log with indent
	static void PrintIndentString(NSUInteger indent, NSString *str);
	
	// Print controller and sub-controllers
	static void PrintController(UIViewController *controller, NSUInteger indent = 0);
	
	// Print view and subviews
	static void PrintView(UIView *view, NSUInteger indent = 0);
	
	// Nomalize png file
	static BOOL NormalizePngFile(NSString *dst, NSString *src);
	
	// Nomalize png folder
	static void NormalizePngFolder(NSString *dst, NSString *src);
};
