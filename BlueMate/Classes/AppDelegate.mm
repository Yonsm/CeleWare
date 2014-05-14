
#import "AppDelegate.h"
#import "RootController.h"

//
@implementation AppDelegate

#pragma mark Generic methods

#pragma mark Monitoring Application State Changes

// The application has launched and may have additional launch options to handle.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIUtil::ShowStatusBar(YES/*, UIStatusBarAnimationSlide*/);
	
	// Create window
	_window = [[UIWindow alloc] initWithFrame:UIUtil::ScreenBounds()];
	
	// Create controller
	// TODO: Remove navigation controller
	UIViewController *controller = [[RootController alloc] init];
	//UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:controller];
	//navigator.navigationBarHidden = YES;
	//navigator.navigationBar.translucent = YES;

	// Show main view
	_window.rootViewController = controller;
	[_window makeKeyAndVisible];
	
	//UIUtil::ShowSplashView(navigator.view);
	
	StatStart();

	return YES;
}

// The application is about to terminate.
//- (void)applicationWillTerminate:(UIApplication *)application
//{
//}

// Tells the delegate that the application is about to become inactive.
//- (void)applicationWillResignActive:(UIApplication *)application
//{
//}

// The application has become active.
//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//}

// Tells the delegate that the application is about to enter the foreground.
//- (void)applicationWillEnterForeground:(UIApplication *)application
//{
//}

// Tells the delegate that the application is now in the background.
//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//}


#pragma mark Managing Status Bar Changes

//The interface orientation of the status bar is about to change.
//- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration
//{
//}

// The interface orientation of the status bar has changed.
//- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation
//{
//}

// The frame of the status bar is about to change.
//- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
//{
//}

// The frame of the status bar has changed.
//- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
//{
//}


#pragma mark Responding to System Notifications

// There is a significant change in the time.
//- (void)applicationSignificantTimeChange:(UIApplication *)application
//{
//}

// The application receives a memory warning from the system.
//- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
//{
//}

// Open a resource identified by URL.
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//	return NO;
//}

@end
