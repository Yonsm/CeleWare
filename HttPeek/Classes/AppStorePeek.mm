

#import "HookMain.h"
#define DEBUG

#if 0
//
MSGHOOK(void, SUScriptInterface_gotoStoreURL_ofType_withAuthentication_forceAuthentication, id a3, id a4, char a5, char a6)
{
	NSLog(@"HTTPEEK:>>>SUScriptInterface_gotoStoreURL_ofType_withAuthentication_forceAuthentication: <%@> <%@> <%c> <%c>", a3, a4, a5, a6);
	return _SUScriptInterface_gotoStoreURL_ofType_withAuthentication_forceAuthentication(self, sel, a3, a4, a5,a6);
} ENDHOOK

//
MSGHOOK(void, SUStorePageViewController__performActionForProtocolButton, id a3)
{
	NSLog(@"HTTPEEK:>>>SUStorePageViewController__performActionForProtocolButton: %@", a3);
	return _SUStorePageViewController__performActionForProtocolButton(self, sel, a3);
} ENDHOOK

//
MSGHOOK(BOOL, SUStructuredPageViewController__gotoURLForItem_withURLIndex, id a3, int a4)
{
	NSLog(@"HTTPEEK:>>>UIApplication_canOpenURL: %@, %d", a3, a4);
	return _SUStructuredPageViewController__gotoURLForItem_withURLIndex(self, sel, a3, a4);
} ENDHOOK

//
MSGHOOK(void, SUTermsAndConditionsView_alertView_didDismissWithButtonIndex, id a3, int a4)
{
	NSLog(@"HTTPEEK:>>>SUTermsAndConditionsView_alertView_didDismissWithButtonIndex: %@, %d", a3, a4);
	return _SUTermsAndConditionsView_alertView_didDismissWithButtonIndex(self, sel, a3, a4);
} ENDHOOK

//
MSGHOOK(id, SUClient__newAccountViewControllerForButtonAction, id a3)
{
	NSLog(@"HTTPEEK:>>>HTTPEEK:>>>SUClient__newAccountViewControllerForButtonAction: %@", a3);
	return _SUClient__newAccountViewControllerForButtonAction(self, sel, a3);
} ENDHOOK

//
MSGHOOK(id, SUScriptAccountPageViewController_newNativeViewController)
{
	NSLog(@"HTTPEEK:>>>SUScriptAccountPageViewController_newNativeViewController: %@", self);
	return _SUScriptAccountPageViewController_newNativeViewController(self, sel);
} ENDHOOK

//
MSGHOOK(void, SUStoreController__handleAccountURL, id a3)
{
	NSLog(@"HTTPEEK:>>>SUStoreController__handleAccountURL: %@", a3);
	return _SUStoreController__handleAccountURL(self, sel, a3);
} ENDHOOK

//
MSGHOOK(id, SUClientController__newAccountViewControllerForButtonAction, id a3)
{
	NSLog(@"HTTPEEK:>>>SUClientController__newAccountViewControllerForButtonAction: %@", a3);
	return _SUClientController__newAccountViewControllerForButtonAction(self, sel, a3);
} ENDHOOK

//
MSGHOOK(void, SUClientApplicationController__handleAccountURL, id a3)
{
	NSLog(@"HTTPEEK:>>>SUClientApplicationController__handleAccountURL: %@", a3);
	return _SUClientApplicationController__handleAccountURL(self, sel, a3);
} ENDHOOK

#endif

//
MSGHOOK(void, SUAccountViewController__mescalDidOpenWithSession_error, id a3, id a4)
{
	NSLog(@"HTTPEEK:>>>SUAccountViewController__mescalDidOpenWithSession_error: %@, %@", a3, a4);
	_SUAccountViewController__mescalDidOpenWithSession_error(self, sel, a3, a4);
} ENDHOOK

//
MSGHOOK(id, SUAccountViewController_init)
{
	Dl_info info = {0};
	dladdr(__builtin_return_address(0), &info);
	
	NSString *str = [NSString stringWithFormat:@"FROM %s(%p)-%s(%p=>%#08lx)\n<%@>\n\n", info.dli_fname, info.dli_fbase, info.dli_sname, info.dli_saddr, (long)info.dli_saddr-(long)info.dli_fbase-0x1000, [NSThread callStackSymbols]];
	NSLog(@"HTTPEEK SUAccountViewController_init: %@", str);
	
	NSLog(@"HTTPEEK:>>>SUAccountViewController_init");
	return _SUAccountViewController_init(self, sel);
} ENDHOOK

//
MSGHOOK(id, SUAccountViewController_initWithExternalAccountURL, id a3)
{
	Dl_info info = {0};
	dladdr(__builtin_return_address(0), &info);
	
	NSString *str = [NSString stringWithFormat:@"FROM %s(%p)-%s(%p=>%#08lx)\n<%@>\n\n", info.dli_fname, info.dli_fbase, info.dli_sname, info.dli_saddr, (long)info.dli_saddr-(long)info.dli_fbase-0x1000, [NSThread callStackSymbols]];
	NSLog(@"HTTPEEK SUAccountViewController_alloc: %@", str);
	
	NSLog(@"HTTPEEK:>>>SUAccountViewController_initWithExternalAccountURL: %@", a3);
	return _SUAccountViewController_initWithExternalAccountURL(self, sel, a3);
} ENDHOOK

@interface FakeUnderlyingURL : NSObject
@end
@implementation FakeUnderlyingURL
- (NSURL *)underlyingURL
{
	return [NSURL URLWithString:@"https://?url=itms-appss://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/com.apple.jingle.app.finance.DirectAction/convertWizard%3Frmp%3D0%26workflowID%3D4846%26why%3DsignIn%26guid%3D37c3b16de9df1b2bc059919370f41a3f75b97fd4%26createSession%3Dtrue%26attempt%3D0&action=account"];
}
@end

//
@protocol ASAppDelegate <NSObject>
- (void)_showAccountViewControllerWithURL:(FakeUnderlyingURL *)URL;
@end

@interface AppStoreFaker : NSObject
@end

@implementation AppStoreFaker
- (void)peek
{
	_LineLog();
	FakeUnderlyingURL *URL = [[FakeUnderlyingURL alloc] init];
	id<ASAppDelegate> delegate = (id<ASAppDelegate>)[[UIApplication sharedApplication] delegate];
	[delegate _showAccountViewControllerWithURL:URL];
}
@end

//
void AppStorePeekInit(NSString *processName)
{
	if (![processName isEqualToString:@"AppStore"] && ![processName isEqualToString:@"SUTest"]) return;
	
	_HOOKMSG(SUAccountViewController_init, SUAccountViewController, init);
	_HOOKMSG(SUAccountViewController_initWithExternalAccountURL, SUAccountViewController, initWithExternalAccountURL:);
	_HOOKMSG(SUAccountViewController__mescalDidOpenWithSession_error, SUAccountViewController, _mescalDidOpenWithSession:error:);
	
	AppStoreFaker *peeker = [[AppStoreFaker alloc] init];
	[NSTimer scheduledTimerWithTimeInterval:5 target:peeker selector:@selector(peek) userInfo:nil repeats:NO];
	
#if 0
	_HOOKMSG(SUScriptInterface_gotoStoreURL_ofType_withAuthentication_forceAuthentication, SUScriptInterface, gotoStoreURL:ofType:withAuthentication:forceAuthentication:);
	
	_HOOKMSG(SUStorePageViewController__performActionForProtocolButton, SUStorePageViewController, _performActionForProtocolButton:);
	_HOOKMSG(SUStructuredPageViewController__gotoURLForItem_withURLIndex, SUStructuredPageViewController, _gotoURLForItem:withURLIndex:);
	_HOOKMSG(SUTermsAndConditionsView_alertView_didDismissWithButtonIndex, SUTermsAndConditionsView, alertView:didDismissWithButtonIndex:);
	_HOOKMSG(SUClient__newAccountViewControllerForButtonAction, SUClient, _newAccountViewControllerForButtonAction:);
	
	_HOOKMSG(SUScriptAccountPageViewController_newNativeViewController, SUScriptAccountPageViewController, newNativeViewController);
	_HOOKMSG(SUStoreController__handleAccountURL, SUStoreController, _handleAccountURL:);
	_HOOKMSG(SUClientController__newAccountViewControllerForButtonAction, SUClientController, _newAccountViewControllerForButtonAction:);
	_HOOKMSG(SUClientApplicationController__handleAccountURL, SUClientApplicationController, _handleAccountURL:);
#endif
	
	return;
}
