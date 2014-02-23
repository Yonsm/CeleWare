

#import "HookMain.h"

FUNPTR(void, MSHookFunction, void *symbol, void *replace, void **result) = NULL;
FUNPTR(void, MSHookMessageEx, Class _class, SEL sel, IMP imp, IMP *result) = NULL;

void StorePeekInit(NSString *processName);

//
extern "C" void AppInit()
{
	@autoreleasepool
	{
		NSString *processName = NSProcessInfo.processInfo.processName;
		_PTRFUN(/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate, MSHookFunction);
		_PTRFUN(/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate, MSHookMessageEx);
		
		NSLog(@"StorePeek new process %@ MSHookFunction=%p, MSHookMessageEx=%p", processName, _MSHookFunction, _MSHookMessageEx);

		StorePeekInit(processName);
		
		return;
	}
}
