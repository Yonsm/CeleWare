

#import "HookMain.h"

FUNPTR(void, MSHookFunction, void *symbol, void *replace, void **result) = NULL;
FUNPTR(void, MSHookMessageEx, Class _class, SEL sel, IMP imp, IMP *result) = NULL;
FUNPTR(void *, SubstrateMemoryCreate, void *allocator, void *process, void *data, size_t size) = NULL;
FUNPTR(void, SubstrateMemoryRelease, void * memory) = NULL;


//
#import <vector>
#import <algorithm>

//
void LogRequest(NSURLRequest *request, void *returnAddress)
{
	static int s_index = 0;
	static NSString *_logDir = nil;
	static std::vector<NSURLRequest *> _requests;

	if (_logDir == nil)
	{
		_logDir = [[NSString alloc] initWithFormat:@"/tmp/%@.req", NSProcessInfo.processInfo.processName];
		[[NSFileManager defaultManager] createDirectoryAtPath:_logDir withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	if ([request respondsToSelector:@selector(HTTPMethod)])
	{
		if (std::find(_requests.begin(), _requests.end(), request) == _requests.end())
		{
			_requests.push_back(request);
			if (_requests.size() > 1024)
			{
				_requests.erase(_requests.begin(), _requests.begin() + 512);
			}
			
			Dl_info info = {0};
			dladdr(returnAddress, &info);
			
			NSString *str = [NSString stringWithFormat:@"FROM %s(%p)-%s(%p=>%#08lx)\n<%@>\n%@: %@\n%@\n\n", info.dli_fname, info.dli_fbase, info.dli_sname, info.dli_saddr, (long)info.dli_saddr-(long)info.dli_fbase-0x1000, [NSThread callStackSymbols], request.HTTPMethod, request.URL.absoluteString, request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @""];
			NSLog(@"HTTPEEK REQUEST: %@", str);
			
			NSString *file = [NSString stringWithFormat:@"%@/%d=%@.txt", _logDir, s_index++, NSUtil::UrlPath([request.URL.host stringByAppendingString:request.URL.path])];
			if (request.HTTPBody.length && request.HTTPBody.length < 10240)
			{
				NSString *str2 = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
				if (str2)
				{
					[[str stringByAppendingString:str2] writeToFile:file atomically:NO encoding:NSUTF8StringEncoding error:nil];
					[str2 release];
					return;
				}
			}
			
			[str writeToFile:file atomically:NO encoding:NSUTF8StringEncoding error:nil];
			[request.HTTPBody writeToFile:[file stringByAppendingString:@".dat"] atomically:NO];
		}
	}
}

//
void WebViewPeekInit(NSString *processName);
void ConnectionPeekInit(NSString *processName);
void ReadStreamPeekInit(NSString *processName);
void ApplicationPeekInit(NSString *processName);

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


//
extern "C" void AppInit()
{
	@autoreleasepool
	{
		NSString *processName = NSProcessInfo.processInfo.processName;
		_PTRFUN(/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate, MSHookFunction);
		_PTRFUN(/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate, MSHookMessageEx);
		
		if (![processName isEqualToString:@"AppStore"] && ![processName isEqualToString:@"SUTest"]) return;
	
		NSLog(@"HTTPEEK new process %@ MSHookFunction=%p, MSHookMessageEx=%p", processName, _MSHookFunction, _MSHookMessageEx);
				
		//WebViewPeekInit(processName);
		//ConnectionPeekInit(processName);
		//ReadStreamPeekInit(processName);
		//ApplicationPeekInit(processName);
				
		_HOOKMSG(SUAccountViewController_init, SUAccountViewController, init);
//		_HOOKMSG(SUAccountViewController_initWithExternalAccountURL, SUAccountViewController, initWithExternalAccountURL:);
//		_HOOKMSG(SUScriptInterface_gotoStoreURL_ofType_withAuthentication_forceAuthentication, SUScriptInterface, gotoStoreURL:ofType:withAuthentication:forceAuthentication:);
//		
//		_HOOKMSG(SUStorePageViewController__performActionForProtocolButton, SUStorePageViewController, _performActionForProtocolButton:);
//		_HOOKMSG(SUStructuredPageViewController__gotoURLForItem_withURLIndex, SUStructuredPageViewController, _gotoURLForItem:withURLIndex:);
//		_HOOKMSG(SUTermsAndConditionsView_alertView_didDismissWithButtonIndex, SUTermsAndConditionsView, alertView:didDismissWithButtonIndex:);
//		_HOOKMSG(SUClient__newAccountViewControllerForButtonAction, SUClient, _newAccountViewControllerForButtonAction:);
//		
//		_HOOKMSG(SUScriptAccountPageViewController_newNativeViewController, SUScriptAccountPageViewController, newNativeViewController);
//		_HOOKMSG(SUStoreController__handleAccountURL, SUStoreController, _handleAccountURL:);
//		_HOOKMSG(SUClientController__newAccountViewControllerForButtonAction, SUClientController, _newAccountViewControllerForButtonAction:);
//		_HOOKMSG(SUClientApplicationController__handleAccountURL, SUClientApplicationController, _handleAccountURL:);
		
		_HOOKMSG(SUAccountViewController__mescalDidOpenWithSession_error, SUAccountViewController, _mescalDidOpenWithSession:error:);
		
		return;
	}
}
