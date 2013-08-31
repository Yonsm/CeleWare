
#import <mach/mach_host.h>
#import <mach-o/nlist.h>
#import <objc/runtime.h>
#import <dlfcn.h>

//
#define DLSYM(lib, func)				dlsym(dlopen(k##lib.UTF8String, RTLD_LAZY), k##func.UTF8String)
#define _DLSYM(lib, func)				dlsym(dlopen(#lib, RTLD_LAZY), #func)	// Without k- string

#define FUNPTR(ret, func, ...)			ret (*_##func)(__VA_ARGS__)
#define PTRSET(func, val)				*((void **)&_##func) = val
#define PTRFUN(lib, func)				PTRSET(func, DLSYM(lib, func))
#define _PTRFUN(lib, func)				PTRSET(func, _DLSYM(lib, func))

//
#define FUNHOOK(ret, func, ...)			ret (*_##func)(__VA_ARGS__); ret $##func(__VA_ARGS__) {{/*_Log(@"FUNHOAK %s(%s)", #hook, #__VA_ARGS__);*/
#define FUNHOAK(ret, func, ...)			ret (*_##func)(__VA_ARGS__); ret $##func(__VA_ARGS__) {@autoreleasepool{
#define HOOKFUN(lib, func)				_MSHookFunction(DLSYM(lib, func), (void *)$##func, (void **)&_##func)
#define _HOOKFUN(lib, func)				_MSHookFunction(_DLSYM(lib, func), (void *)$##func, (void **)&_##func)	// Without encrypt string
#define MSGHOOK(ret, hook, ...)			ret (*_##hook)(id self, SEL sel, ##__VA_ARGS__); ret $##hook(id self, SEL sel, ##__VA_ARGS__) {{/*_Log(@"MSGHOAK [%@ %@] %s(id self, %s)", NSStringFromClass([self class]), NSStringFromSelector(sel), #hook, #__VA_ARGS__);*/
#define MSGHOAK(ret, hook, ...)			ret (*_##hook)(id self, SEL sel, ##__VA_ARGS__); ret $##hook(id self, SEL sel, ##__VA_ARGS__) {@autoreleasepool{
#define HOOKMSG(hook, cls, sel)			_MSHookMessageEx(NSClassFromString(k##cls), @selector(sel), (IMP)$##hook, (IMP *)&_##hook)
#define _HOOKMSG(hook, cls, sel)		_MSHookMessageEx(NSClassFromString(@#cls), @selector(sel), (IMP)$##hook, (IMP *)&_##hook)	// Without encrypt string
#define HOOKCLS(hook, cls, sel)			_MSHookMessageEx(objc_getMetaClass([k##cls UTF8String]), @selector(sel), (IMP)$##hook, (IMP *)&_##hook)
#define _HOOKCLS(hook, cls, sel)		_MSHookMessageEx(objc_getMetaClass(#cls), @selector(sel), (IMP)$##hook, (IMP *)&_##hook)	// Without encrypt string

#define ENDHOOK							}}

extern FUNPTR(void, MSHookFunction, void *symbol, void *replace, void **result);
extern FUNPTR(void, MSHookMessageEx, Class _class, SEL sel, IMP imp, IMP *result);
extern FUNPTR(void *, SubstrateMemoryCreate, void *allocator, void *process, void *data, size_t size);
extern FUNPTR(void, SubstrateMemoryRelease, void * memory);

//
struct HookWritable
{
	void *handle;
	
	inline HookWritable(void *data, size_t size = 4)
	{
		if (_SubstrateMemoryCreate == NULL) Init();
		_Log(@"HOOK Writable: %p", data);
		handle = _SubstrateMemoryCreate ? _SubstrateMemoryCreate(NULL, NULL, data, size) : NULL;
	}
	
	inline ~HookWritable()
	{
		if (handle) _SubstrateMemoryRelease(handle);
	}
	
	NS_INLINE void Init()
	{
		if (unsigned char *base = Base(@"/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate", @"MSHookFunction", 0x242C))
		{
			PTRSET(SubstrateMemoryCreate, base + 0x29BC);
			PTRSET(SubstrateMemoryRelease, base + 0x293C);
		}
	}
	
	NS_INLINE unsigned char *Base(NSString *path, NSString *func, unsigned int offset = 0x1000)
	{
		unsigned char *base = (unsigned char *)dlsym(dlopen(path.UTF8String, RTLD_LAZY), func.UTF8String);
		if (base == nil)
		{
			_Log(@"HOOK Base symbol not found");
			return nil;
		}
		
		if (((unsigned int)base & 0x0FF0) != (offset & 0x0FF0))
		{
			_Log(@"HOOK Base symbol miss match: %p !=! %08X", base, offset);
			return nil;
		}
		
		base -= offset;
		_Log(@"HOOK Base: %@ at %p", path, base);
		return base;
	}
};
#define _HookWritable(...) HookWritable _writable##__LINE__(__VA_ARGS__); if (_writable##__LINE__.handle)

//
void LogRequest(NSURLRequest *request, void *returnAddress);
#define _LogRequest(request) LogRequest(request, __builtin_return_address(0))
