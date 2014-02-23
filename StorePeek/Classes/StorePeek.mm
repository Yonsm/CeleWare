

#import "HookMain.h"

//
@protocol SUMescalSession <NSObject>
- (NSData *)primeForAccountCreationWithData:(NSData *)data error:(NSError **)error;
@end

MSGHOOK(void, SUAccountViewController__mescalDidOpenWithSession_error, id<SUMescalSession> a3, id a4)
{
	NSLog(@"HTTPEEK:>>>SUAccountViewController__mescalDidOpenWithSession_error: %@, %@", a3, a4);
	_SUAccountViewController__mescalDidOpenWithSession_error(self, sel, a3, a4);
	
	NSData *data = [a3 primeForAccountCreationWithData:NSData.data error:nil];
	_ObjLog(data);
	
	
	
} ENDHOOK

FUNPTR(NSString *, ISCopyEncodedBase64, const void *bytes, NSUInteger length) = NULL;

MSGHOOK(NSData *, SUMescalSession_primeForAccountCreationWithData_error, NSData *data, id *error)
{
	NSLog(@"HTTPEEK:>>>SUMescalSession_primeForAccountCreationWithData_error: %@, %p", data, error);
	NSData *ret = _SUMescalSession_primeForAccountCreationWithData_error(self, sel, data, error);
	_ObjLog(ret);
	if (ret)
	{
		if (_ISCopyEncodedBase64 == NULL)
		{
			_LineLog();
			_PTRFUN(/System/Library/PrivateFrameworks/iTunesStore.framework/iTunesStore, ISCopyEncodedBase64);
			if (_ISCopyEncodedBase64 == NULL)
			{
				_LineLog();
				return ret;
			}
		}
		NSString *primingSignature = _ISCopyEncodedBase64(ret.bytes, ret.length);
		_ObjLog(primingSignature);
	}
	return ret;
	
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
	NSLog(@"HTTPEEK SUAccountViewController_initWithExternalAccountURL: %@", str);
	
	NSLog(@"HTTPEEK:>>>SUAccountViewController_initWithExternalAccountURL: %@", a3);
	return _SUAccountViewController_initWithExternalAccountURL(self, sel, a3);
} ENDHOOK

//
MSGHOOK(BOOL, ASAppDelegate_application_openURL_sourceApplication_annotation, UIApplication *applicaiton, NSString *URL, NSString * sourceApplication, id annotation)
{
	Dl_info info = {0};
	dladdr(__builtin_return_address(0), &info);
	
	NSString *str = [NSString stringWithFormat:@"FROM %s(%p)-%s(%p=>%#08lx)\n<%@>\n\n", info.dli_fname, info.dli_fbase, info.dli_sname, info.dli_saddr, (long)info.dli_saddr-(long)info.dli_fbase-0x1000, [NSThread callStackSymbols]];
	NSLog(@"HTTPEEK ASAppDelegate_application_openURL_sourceApplication_annotation: %@", str);
	
	NSLog(@"HTTPEEK:>>>ASAppDelegate_application_openURL_sourceApplication_annotation: %@ %@ %@ %@", applicaiton, URL, sourceApplication, annotation);
	return _ASAppDelegate_application_openURL_sourceApplication_annotation(self, sel, applicaiton, URL, sourceApplication, annotation);
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
@protocol ASAppDelegate <UIApplicationDelegate>
- (void)_showAccountViewControllerWithURL:(FakeUnderlyingURL *)URL;
@end

@interface AppStoreFaker : NSObject
@end

@implementation AppStoreFaker
- (void)peek
{
	_LineLog();
	
	//FakeUnderlyingURL *URL = [[FakeUnderlyingURL alloc] init];
	NSURL *URL = [NSURL URLWithString:
				  @"itms-apps://?url=itms-appss://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/com.apple.jingle.app.finance.DirectAction/convertWizard%3Frmp%3D0%26workflowID%3D4846%26why%3DsignIn%26guid%3D37c3b16de9df1b2bc059919370f41a3f75b97fd4%26createSession%3Dtrue%26attempt%3D0&action=account"];
	UIApplication *application = [UIApplication sharedApplication];
	id<ASAppDelegate> delegate = (id<ASAppDelegate>)[application delegate];
	
	[delegate application:application openURL:URL sourceApplication:nil annotation:nil];
	//[delegate _showAccountViewControllerWithURL:URL];
}
@end

//
void StorePeekInit(NSString *processName)
{
	if (![processName isEqualToString:@"AppStore"] && ![processName isEqualToString:@"SUTest"]) return;
	
	_HOOKMSG(SUAccountViewController_init, SUAccountViewController, init);
	_HOOKMSG(SUAccountViewController_initWithExternalAccountURL, SUAccountViewController, initWithExternalAccountURL:);
	_HOOKMSG(SUAccountViewController__mescalDidOpenWithSession_error, SUAccountViewController, _mescalDidOpenWithSession:error:);
	_HOOKMSG(SUMescalSession_primeForAccountCreationWithData_error, SUMescalSession, primeForAccountCreationWithData:error:);
	
	_HOOKMSG(ASAppDelegate_application_openURL_sourceApplication_annotation, ASAppDelegate, application:openURL:sourceApplication:annotation:);
	
	AppStoreFaker *peeker = [[AppStoreFaker alloc] init];
	[NSTimer scheduledTimerWithTimeInterval:8 target:peeker selector:@selector(peek) userInfo:nil repeats:NO];
	
	return;
}
