
#import "UIUtil.h"

NSUInteger UIUtil::_networkIndicatorRef = 0;

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

#if defined(DEBUG) || defined(TEST)

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
	_ObjLog(view);
	_ObjLog(constraints);
	
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
		_Log(@"{%.0f: %@/%@ %c %@/%@ %.1f%@}",
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

#endif
