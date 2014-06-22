// 注意：此功能无法通过 AppStore 审核
//#include <sys/sysctl.h>
#import <mach/mach_host.h>

#pragma mark IOKit methods
/* iOS SDK 7.0+ 中 IOKit 被隐藏，需要做如下操作（注意版本号），然后把IOKit拖放进
 cd /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.1.sdk/System/Library/Frameworks/IOKit.framework
 sudo ln -s Versions/A/IOKit
 */

//
extern "C"
{
#define kIODeviceTreePlane "IODeviceTree"
	typedef mach_port_t io_object_t;
	typedef io_object_t io_registry_entry_t;
	typedef char io_name_t[128];
	typedef UInt32 IOOptionBits;
	enum {kIORegistryIterateRecursively = 1, kIORegistryIterateParents = 2};
	
	//
	io_registry_entry_t IORegistryGetRootEntry(mach_port_t masterPort);
	kern_return_t IOMasterPort(mach_port_t bootstrapPort, mach_port_t *masterPort);
	CFTypeRef IORegistryEntrySearchCFProperty(io_registry_entry_t entry, const io_name_t plane, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options);
	kern_return_t IORegistryEntryCreateCFProperties(io_registry_entry_t entry, CFDictionaryRef **properties, CFAllocatorRef allocator, IOOptionBits options);
	kern_return_t mach_port_deallocate(ipc_space_t task, mach_port_name_t name);
}

//
class SystemUtil
{
public:
	//
	NS_INLINE id IOSearch(NSString *ioSearch)
	{
		id ret = nil;
		mach_port_t masterPort;
		if (IOMasterPort(MACH_PORT_NULL, &masterPort) == noErr)
		{
			io_registry_entry_t entry = IORegistryGetRootEntry(masterPort);
			if (entry != MACH_PORT_NULL)
			{
				ret = (__bridge_transfer id)IORegistryEntrySearchCFProperty(entry, kIODeviceTreePlane, (__bridge CFStringRef)ioSearch, nil, kIORegistryIterateRecursively);
			}
			mach_port_deallocate(mach_task_self(), masterPort);
		}
		return ret;
	}
	
	//
	NS_INLINE NSString *IOSearchData(NSString *ioSearch)
	{
		NSData *data = IOSearch(ioSearch);
		if ([data isKindOfClass:NSData.class])
		{
			return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		}
		return nil;
	}
	
	//
//	NS_INLINE NSString *IMEI()
//	{
//		return IOSearchData(@"device-imei");
//	}

	//
	NS_INLINE NSString *SN()
	{
		return IOSearchData(@"serial-number");
	}
};
