

// App Store URL
#define kStoreUrl(x)	[NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", x]
#define kAppStoreID		[NSBundle.mainBundle objectForInfoDictionaryKey:@"AppStoreID"]
#define kAppStoreUrl	kStoreUrl(kAppStoreID)

// Array count
#ifndef _NumOf
#define _NumOf(a)		(sizeof(a) / sizeof(a[0]))
#endif

// Log Helper
#ifdef DEBUG
#ifdef _LOG_TO_FILE
#define _Log(s, ...)	{NSString *str = [NSString stringWithFormat:s, ##__VA_ARGS__]; FILE *fp = fopen("/tmp/NSUtil.log", "a"); if (fp) {fprintf(fp, "[%s] %s\n", NSProcessInfo.processInfo.processName.UTF8String, str.UTF8String); fclose(fp);}}
#else
#define _Log(s, ...)	NSLog(s, ##__VA_ARGS__)
#endif
#define _ObjLog(o)		if (o) _Log(@"Object Log: %s (%u), %@ (%@)", __FUNCTION__, __LINE__, NSStringFromClass([o class]), o)
#define _LineLog()		_Log(@"Line Log: %s (%u)", __FUNCTION__, __LINE__)
#ifdef __cplusplus
#define _AutoLog()		AutoLog _al(__FUNCTION__, __LINE__)
#else
#define _AutoLog()		_LineLog()
#endif
#else
#define _Log(s, ...)	((void) 0)
#define _LineLog()		((void) 0)
#define _AutoLog()		((void) 0)
#define _ObjLog(o)		((void) 0)
#endif

// Auto Log
#ifdef __cplusplus
#import <Foundation/Foundation.h>
#import <mach/mach_time.h>
class AutoLog
{
private:
	int _line;
	uint64_t _start;
	const char *_name;
public:
	inline AutoLog(const char *name, int line): _line(line), _name(name), _start(mach_absolute_time())
	{
		_Log(@"Enter %s:%d", name, line);
	}
	inline ~AutoLog()
	{
		_Log(@"Leave %s:%d Elapsed %qu", _name, _line, mach_absolute_time() - _start);
	}
};
#endif

// Suppress warning
#define _SuppressPerformSelectorLeakWarning(Stuff) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop")

// Extend an object
#define _EXObject(object, ref, type, name)	\
@interface object##_##name : object	\
@property(nonatomic,ref) type name;	\
@end	\
@implementation object##_##name	\
@end
