
#import "UIUtil.h"

NSUInteger UIUtil::_networkIndicatorRef = 0;

//
void UIUtil::PrintIndentString(NSUInteger indent, NSString *str)
{
	NSString *log = @"";
	for (NSUInteger i = 0; i < indent; i++)
	{
		log = [log stringByAppendingString:@"\t"];
	}
	log = [log stringByAppendingString:str];
	_Log(@"%@", log);
}

// Print controller and sub-controllers
void UIUtil::PrintController(UIViewController *controller, NSUInteger indent)
{
	PrintIndentString(indent, [NSString stringWithFormat:@"<Controller Description=\"%@\">", [controller description]]);

	if (controller.presentedViewController)
	{
		PrintController(controller, indent + 1);
	}
	
	if ([controller isKindOfClass:[UINavigationController class]])
	{
		for (UIViewController *child in ((UINavigationController *)controller).viewControllers)
		{
			PrintController(child, indent + 1);
		}
	}
	else if ([controller isKindOfClass:[UITabBarController class]])
	{
		UITabBarController *tabBarController = (UITabBarController *)controller;
		for (UIViewController *child in tabBarController.viewControllers)
		{
			PrintController(child, indent + 1);
		}

		if (tabBarController.moreNavigationController)
		{
			PrintController(tabBarController.moreNavigationController, indent + 1);
		}
	}

	PrintIndentString(indent, @"</Controller>");
}

// Print view and subviews
void UIUtil::PrintView(UIView *view, NSUInteger indent)
{
	PrintIndentString(indent, [NSString stringWithFormat:@"<View Description=\"%@\">", [view description]]);
	
	for (UIView *child in view.subviews)
	{
		PrintView(child, indent + 1);
	}
	
	PrintIndentString(indent, @"</View>");
	
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
