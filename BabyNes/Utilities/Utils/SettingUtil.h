
#import "NSUtil.h"

//
#define kSettingsFile	@"Settings.plist"

//
class Settings
{
public:
	//
	static NSMutableDictionary *_settings;

public:
	//
	Settings()
	{
		@autoreleasepool {
		//if (_settings == nil)
			{
				NSString *path = NSUtil::DocumentPath(kSettingsFile);
				_settings = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
				if (_settings == nil) _settings = [[NSMutableDictionary alloc] init];
			}
		}
	}
	
	//
	~Settings()
	{
		_settings = nil;
	}

public:
	//
	NS_INLINE void Save()
	{
		[_settings writeToFile:NSUtil::DocumentPath(kSettingsFile) atomically:YES];
	}
	
	//
	NS_INLINE id Get(NSString *key)
	{
		return [_settings valueForKey:key];
	}

	//
	NS_INLINE NSString *DecryptGet(NSString *key)
	{
		return NSUtil::DecryptString(Get(key));
	}
	
	//
	NS_INLINE void Set(NSString *key, id value = nil)
	{
		[_settings setValue:value forKey:key];
	}

	//
	NS_INLINE void EncryptSet(NSString *key, id value = nil)
	{
		[_settings setValue:NSUtil::EncryptString(value) forKey:key];
	}
	
	//
	NS_INLINE void EncryptSave(NSString *key, id value = nil)
	{
		EncryptSet(key, value);
		Save();
	}

	//
	NS_INLINE void Save(NSString *key, id value = nil)
	{
		Set(key, value);
		Save();
	}
};
