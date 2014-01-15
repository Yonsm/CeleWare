
#import <Foundation/Foundation.h>

//
class NSUtil
{
#pragma mark Appcalition path methods
public:
	//
	NS_INLINE NSBundle *Bundle()
	{
		return [NSBundle mainBundle];
	}
	
	//
	NS_INLINE id BundleInfo(NSString *key)
	{
		return [Bundle() objectForInfoDictionaryKey:key];
	}
	
	//
	NS_INLINE NSString *BundleName()
	{
		return BundleInfo(@"CFBundleName");
	}
	
	//
	NS_INLINE NSString *BundleDisplayName()
	{
		return BundleInfo(@"CFBundleDisplayName");
	}
	
	//
	NS_INLINE NSString *BundleVersion()
	{
		return BundleInfo(@"CFBundleShortVersionString");
	}
	
	//
	NS_INLINE NSString *BundlePath()
	{
		return [Bundle() bundlePath];
	}
	
	//
	NS_INLINE NSString *BundlePath(NSString *file)
	{
		return [BundlePath() stringByAppendingPathComponent:file];
	}
	
	//
	NS_INLINE NSString *AssetPath()
	{
#ifdef kAssetBundle
		return [BundlePath() stringByAppendingPathComponent:kAssetBundle];
#else
		return BundlePath();
#endif
	}
	
	//
	NS_INLINE NSString *AssetPath(NSString *file)
	{
		return [AssetPath() stringByAppendingPathComponent:file];
	}
	
#pragma mark File manager methods
public:
	//
	NS_INLINE NSFileManager *FileManager()
	{
		return [NSFileManager defaultManager];
	}
	
	//
	NS_INLINE BOOL IsPathExist(NSString* path)
	{
		return [FileManager() fileExistsAtPath:path];
	}
	
	//
	NS_INLINE BOOL IsFileExist(NSString* path)
	{
		BOOL isDirectory;
		return [FileManager() fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory;
	}
	
	//
	NS_INLINE BOOL IsDirectoryExist(NSString* path)
	{
		BOOL isDirectory;
		return [FileManager() fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory;
	}
	
	//
	NS_INLINE BOOL RemovePath(NSString* path)
	{
		return [FileManager() removeItemAtPath:path error:nil];
	}
	
#pragma mark User directory methods
public:
	//
	NS_INLINE NSString *UserDirectoryPath(NSSearchPathDirectory directory)
	{
		return [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) objectAtIndex:0];
	}
	
	//
	NS_INLINE NSString *DocumentPath()
	{
		return UserDirectoryPath(NSDocumentDirectory);
	}
	
	//
	NS_INLINE NSString *DocumentPath(NSString *file)
	{
		return [DocumentPath() stringByAppendingPathComponent:file];
	}
	
#pragma mark User defaults
public:
	//
	NS_INLINE NSUserDefaults *UserDefaults()
	{
		return [NSUserDefaults standardUserDefaults];
	}
	
	//
	NS_INLINE id DefaultForKey(NSString *key)
	{
		return [UserDefaults() objectForKey:key];
	}
	
	//
	NS_INLINE void SetDefaultForKey(NSString *key, id value)
	{
		return [UserDefaults() setObject:value forKey:key];
	}
	
	//
	NS_INLINE NSString *PhoneNumber()
	{
		return DefaultForKey(@"SBFormattedPhoneNumber");
	}
	
	//
	NS_INLINE NSString *DefaultLanguage()
	{
		return [[NSLocale preferredLanguages] objectAtIndex:0];
		//return [DefaultForKey(@"AppleLanguages") objectAtIndex:0];
	}
	
	//
	static NSString *CountryAreaCode(NSString *country = (NSString *)[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]);
	static NSString *TrimCountryAreaCode(NSString *number);
	
#pragma mark Cache methods
public:
	//
	NS_INLINE NSString *CachePath()
	{
		//return DocumentPath(@"Cache");
		return [UserDirectoryPath(NSCachesDirectory) stringByAppendingPathComponent:@"Cache"];
	}
	
	//
	NS_INLINE void ClearCache()
	{
		[FileManager() removeItemAtPath:CachePath() error:nil];
	}
	
	//
	NS_INLINE NSString *CachePath(NSString *file)
	{
		NSString *dir = CachePath();
		if (IsDirectoryExist(dir) == NO)
		{
			[FileManager() createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
		}
		return [dir stringByAppendingPathComponent:file];
	}
	
	//
	NS_INLINE NSString *CacheUrlPath(NSString *url)
	{
		unichar chars[256];
		NSRange range = {0, MIN(url.length, 256)};
		[url getCharacters:chars range:range];
		for (NSUInteger i = 0; i < range.length; i++)
		{
			switch (chars[i])
			{
				case '|':
				case '/':
				case '\\':
				case '?':
				case '*':
				case ':':
				case '<':
				case '>':
				case '"':
					chars[i] = '_';
					break;
			}
		}
		NSString *file = [NSString stringWithCharacters:chars length:range.length];
		return CachePath(file);
	}
	
	//
	NS_INLINE unsigned long long CacheSize()
	{
		NSString *dir = NSUtil::CachePath();
		
		//
		unsigned long long size = 0;
		NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:dir];
		for (NSString *file in files)
		{
			NSString *path = [dir stringByAppendingPathComponent:file];
			NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
			size += [dict fileSize];
		}
		
		return size;
	}
	
#pragma mark Format methods
public:
	// Convert number to string
	static NSString *FormatNumber(NSNumber *number, NSNumberFormatterStyle style = NSNumberFormatterNoStyle);
	
	// Convert date to string
	static NSString *FormatDate(NSDate *date, NSString *format);
	
	// Convert date to string
	static NSString *FormatDate(NSDate *date, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle = NSDateFormatterNoStyle);
	
	// Convert string to date
	static NSDate *FormatDate(NSString *string, NSString *format = @"yyyy-MM-dd HH:mm:ss", NSLocale *locale = nil);
	
	// Convert string to date
	static NSDate *FormatDate(NSString *string, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle = NSDateFormatterNoStyle, NSLocale *locale = nil);
	
	// Convert date to relative string.
	static NSString *RelativeTime(NSDate *date, NSDate *now = NSDate.date);
	
	// Convert date to readable string. Return nil on fail
	static NSString *SmartTime(NSDate *date, NSDate *now = NSDate.date);

	// Convert date to readable string. Return nil on fail
	static NSString *SmartDate(NSDate *date, NSDate *now = NSDate.date);
	
	// Convert date to smart string
	static NSString *SmartDate(NSDate *date, NSString *format);
	
	// Convert date to smart string
	static NSString *SmartDate(NSDate *date, NSString *format, NSString *timeFormat);
	
	// Convert date to smart string
	static NSString *SmartDate(NSDate *date, NSString *format, NSDateFormatterStyle timeStyle);
	
	// Convert date to smart string
	static NSString *SmartDate(NSDate *date, NSDateFormatterStyle dateStyle);
	
	// Convert date to smart string
	static NSString *SmartDate(NSDate *date, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle);
	
	//
	static NSString *SmartCurrency(NSString *amount);
	
#pragma mark Misc methods
public:
	// Check email address
	static BOOL IsEmailAddress(NSString *emailAddress);
	
	// Check mobile phone number in China
	static BOOL IsMobileNumberInChina(NSString *phoneNumber);
	
	// Check phone number equal
	static BOOL IsPhoneNumberEqual(NSString *phoneNumber1, NSString *phoneNumber2, NSUInteger minEqual = 10);
	
	// Calculate MD5
	static NSString *MD5(NSString *str);
	
	// Calculate HMAC SHA1
	static NSString *HmacSHA1(NSString *text, NSString *secret);
	
	// BASE64 encode
	static NSString *BASE64Encode(const unsigned char *data, NSUInteger length, NSUInteger lineLength = 0);
	
	// BASE64 decode
	static NSData *BASE64Decode(NSString *string);
	
	// BASE64 encode data
	NS_INLINE NSString *BASE64EncodeData(NSData *data, NSUInteger lineLength = 0)
	{
		return BASE64Encode((const unsigned char *)data.bytes, data.length, lineLength);
	}
	
	// BASE64 encode string
	NS_INLINE NSString *BASE64EncodeString(NSString *string, NSUInteger lineLength = 0)
	{
		return BASE64EncodeData([string dataUsingEncoding:NSUTF8StringEncoding], lineLength);
	}
	
	// BASE64 decode string
	NS_INLINE NSString *BASE64DecodeString(NSString *string)
	{
		NSData *data = BASE64Decode(string);
		return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	
	// Encrypt string use private method
	NS_INLINE NSString *EncryptString(NSString *str)
	{
		if (str.length == 0) return str;

		const char *p = str.UTF8String;
		NSUInteger length = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		char *q = (char *)malloc(length * 2);
		unsigned char m = 3;
		for (NSUInteger i = 0; i < length; i++)
		{
			unsigned char t = m ^ p[i];
			q[i * 2] = m = 0x35 + (t & 0x0F);
			q[i * 2 + 1] = 0x23 + ((t & 0xF0) >> 4);
			q[i * 2] -= 0x0F;
		}
		return [[NSString alloc] initWithBytesNoCopy:q length:length * 2 encoding:NSUTF8StringEncoding freeWhenDone:YES];
	}

	// Decrypt string use private method
	NS_INLINE NSString *DecryptString(NSString *str)
	{
		if (str.length == 0) return str;
		
		const char *q = str.UTF8String;
		NSUInteger length = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding] / 2;
		char *p = (char *)malloc(length);
		unsigned char m = 3;
		for (NSUInteger i = 0; i < length; i++)
		{
			unsigned char n = (q[i * 2] + 0x0F);
			unsigned char t = (n - 0x35) | ((q[i * 2 + 1] - 0x23) << 4);
			p[i] = t ^ m;
			m = n;
		}
		return [[NSString alloc] initWithBytesNoCopy:p length:length encoding:NSUTF8StringEncoding freeWhenDone:YES];
	}
	
	//
	NS_INLINE NSString *MaskString(NSString *str, NSInteger location, NSInteger length = -1)
	{
		NSUInteger strLen = str.length;
		if (location < 0) location = strLen + location - 1;
		if (length < 0) length = strLen - location + length;
		if (strLen > location && length > 0)
		{
			NSMutableString *secure = [NSMutableString string];
			if (location) [secure appendString:[str substringToIndex:location]];
			NSInteger n = str.length - location - 1;
			if (n > length) n = length;
			NSInteger m = str.length - location - n;
			while (n--)
			{
				[secure appendString:@"*"];
			}
			if (m > 0) [secure appendString:[str substringFromIndex:strLen - m]];
			return secure;
		}
		return str;
	}
	
public:
#if __has_feature(objc_arc)
	//
	NS_INLINE NSDictionary *URLQuery(NSString *query)
	{
		NSArray *params = [query componentsSeparatedByString:@"&"];
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:params.count];
		for (NSString *param in params)
		{
			NSRange range = [param rangeOfString:@"="];
			if (range.location != NSNotFound)
			{
				NSString *key = [param substringToIndex:range.location];
				NSString *value = [param substringFromIndex:range.location + 1];
				[dict setObject:URLUnEscape(value) forKey:key];
			}
		}
		return dict;
	}

	//
	NS_INLINE NSString *URLQuery(NSDictionary *params)
	{
		NSMutableString *query = [NSMutableString string];
		NSArray *keys = params.allKeys;
		NSInteger count = keys.count;
		for (NSInteger i = 0; i < count; i++)
		{
			NSString *key = keys[i];
			id value = params[key];
			if (i) [query appendString:@"&"];
			[query appendFormat:@"%@=%@", key, [value isKindOfClass:[NSString class]] ? URLEscape(value) : value];
		}
		return query;
	}
	
	//
	NS_INLINE NSString *URLQuery(NSArray *params)
	{
		NSMutableString *query = [NSMutableString string];
		NSInteger count = params.count;
		for (NSInteger i = 0; i < count; i++)
		{
			NSArray *param = params[i];
			//if (param.count >= 2)
			{
				NSString *key = param[i];
				id value = param[2];
				if (i) [query appendString:@"&"];
				[query appendFormat:@"%@=%@", key, [value isKindOfClass:[NSString class]] ? URLEscape(value) : value];
			}
		}
		return query;
	}

	//
	NS_INLINE NSString *URLEscape(NSString *string)
	{
		return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																					 (CFStringRef)string,
																					 NULL,
																					 CFSTR("!*'();:@&=+$,/?%#[]"),
																					 kCFStringEncodingUTF8);
	}
	
	//
	NS_INLINE NSString *URLUnEscape(NSString *string)
	{
		return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																									 (CFStringRef)string,
																									 CFSTR(""),
																									 kCFStringEncodingUTF8);
	}
	
	//
	NS_INLINE NSString *UUID()
	{
		CFUUIDRef uuid = CFUUIDCreate(NULL);
		NSString *string = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
		CFRelease(uuid);
		return string;
	}
#endif
	
	//
	NS_INLINE NSString *TS()
	{
		return [NSString stringWithFormat:@"%ld", time(NULL)];
	}
};
