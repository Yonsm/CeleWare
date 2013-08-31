
#import "NSUtil.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>


// Convert number to string
NSString *NSUtil::FormatNumber(NSNumber *number, NSNumberFormatterStyle style)
{
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:style];
	NSString *result = [formatter stringFromNumber:number];
	[formatter release];
	return result;
}

// Convert date to string
NSString *NSUtil::FormatDate(NSDate *date, NSString *format)
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = format;
	return [formatter stringForObjectValue:date];
}

// Convert date to string
NSString *NSUtil::FormatDate(NSDate *date, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle)
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateStyle:dateStyle];
	[formatter setTimeStyle:timeStyle];
	return [formatter stringForObjectValue:date];
}

// Convert string to date
NSDate *NSUtil::FormatDate(NSString *string, NSString *format, NSLocale *locale)
{
	if (string == nil) return nil;
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = format;
	if (locale) formatter.locale = locale;
	return [formatter dateFromString:string];
}

// Convert string to date
NSDate *NSUtil::FormatDate(NSString *string, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle, NSLocale *locale)
{
	if (string == nil) return nil;
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateStyle:dateStyle];
	[formatter setTimeStyle:timeStyle];
	if (locale) formatter.locale = locale;
	return [formatter dateFromString:string];
}

// Convert date to readable string. Return nil on fail
NSString *NSUtil::SmartDate(NSDate *date)
{
	NSDate *now = [NSDate date];
	NSTimeInterval t1 = [now timeIntervalSinceReferenceDate];
	NSTimeInterval t2 = [date timeIntervalSinceReferenceDate];
	NSTimeInterval t = [[NSTimeZone defaultTimeZone] secondsFromGMT];
	NSInteger d1 = (t1 + t) / (24 * 60 * 60);
	NSInteger d2 = (t2 + t) / (24 * 60 * 60);
	NSInteger days = d2 - d1;
	switch (days)
	{
		case -2: return NSLocalizedString(@"Before Yesterday ", @"前天");
		case -1: return NSLocalizedString(@"Yesterday ", @"昨天");
		case 0: return NSLocalizedString(@"Today ", @"今天");
		case 1: return NSLocalizedString(@"Tomorrow ", @"明天");
		case 2: return NSLocalizedString(@"After Tomorrow ", @"后天");
	}
	return nil;
}	


// Convert date to smart string
NSString *NSUtil::SmartDate(NSDate *date, NSString *format)
{
	NSString *string = SmartDate(date);
	return string ? string : FormatDate(date, format);
}

// Convert date to smart string
NSString *NSUtil::SmartDate(NSDate *date, NSDateFormatterStyle dateStyle)
{
	NSString *string = SmartDate(date);
	return string ? string : FormatDate(date, dateStyle, NSDateFormatterNoStyle);
}

// Convert date to smart string
NSString *NSUtil::SmartDate(NSDate *date, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle)
{
	NSString *string = SmartDate(date);
	return string ? [string stringByAppendingFormat:@" %@", FormatDate(date, NSDateFormatterNoStyle, timeStyle)] : FormatDate(date, dateStyle, timeStyle);
}


// Check email address
BOOL NSUtil::IsEmailAddress(NSString *emailAddress)
{
	NSString *emailRegEx = 
	@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
	@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
	@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
	@"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
	@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
	@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
	@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
	
	NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
	return [regExPredicate evaluateWithObject:[emailAddress lowercaseString]];
}

// Check phone number equal
BOOL NSUtil::IsPhoneNumberEqual(NSString *phoneNumber1, NSString *phoneNumber2, NSUInteger minEqual)
{
	if (!phoneNumber1 || !phoneNumber2) return NO;
	
	const char *number1 = phoneNumber1.UTF8String;
	const char *number2 = phoneNumber2.UTF8String;
	
	const char *end1 = number1 + strlen(number1);
	const char *end2 = number2 + strlen(number2);
	const char *p1 = end1 - 1;
	const char *p2 = end2 - 1;
	while ((p1 >= number1) && (p2 >= number2))
	{
		if ((*p1 < '0') || (*p1 > '9'))
		{
			p1--;
		}
		else if ((*p2 < '0') || (*p2 > '9'))
		{
			p2--;
		}
		else if (*p1 == *p2)
		{
			p1--;
			p2--;
		}
		else
		{
			break;
		}
	}
	return ((p1 < number1) && (p2 < number2)) || (end1 - p1 >= minEqual);
}

// Calculate MD5
NSString *NSUtil::MD5(NSString *str)
{
	if (str == nil) return nil;
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	const char *cstr = [str UTF8String];
	CC_MD5(cstr, strlen(cstr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

// Calculate SHA1
NSString *NSUtil::HmacSHA1(NSString *text, NSString *secret)
{
	NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
	NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
	
	unsigned char result[20];
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
	return BASE64Encode(result, 20);
}

// BASE64 encode
NSString *NSUtil::BASE64Encode(const unsigned char *data, NSUInteger length, NSUInteger lineLength)
{
	// BASE64 table
	const static char c_baseTable[64] =
	{
		'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
		'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
		'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
		'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
	};
	
	NSMutableString *result = [NSMutableString stringWithCapacity:length];
	unsigned long ixtext = 0;
	unsigned long lentext = length;
	long ctremaining = 0;
	unsigned char inbuf[3], outbuf[4];
	short i = 0;
	short charsonline = 0, ctcopy = 0;
	unsigned long ix = 0;
	
	while (YES)
	{
		ctremaining = lentext - ixtext;
		if (ctremaining <= 0) break;
		
		for (i = 0; i < 3; i++)
		{
			ix = ixtext + i;
			if (ix < lentext)
			{
				inbuf[i] = data[ix];
			}
			else
			{
				inbuf [i] = 0;
			}
		}
		
		outbuf [0] = (inbuf [0] & 0xFC) >> 2;
		outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
		outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
		outbuf [3] = inbuf [2] & 0x3F;
		ctcopy = 4;
		
		switch (ctremaining)
		{
			case 1: 
				ctcopy = 2; 
				break;
			case 2: 
				ctcopy = 3; 
				break;
		}
		
		for (i = 0; i < ctcopy; i++)
		{
			[result appendFormat:@"%c", c_baseTable[outbuf[i]]];
		}
		
		for (i = ctcopy; i < 4; i++)
		{
			[result appendFormat:@"%c",'='];
		}
		
		ixtext += 3;
		charsonline += 4;
		
		if (lineLength > 0)
		{
			if (charsonline >= lineLength)
			{
				charsonline = 0;
				[result appendString:@"\n"];
			}
		}
	}
	
	return result;
}

// BASE64 decode
NSData *NSUtil::BASE64Decode(NSString *string)
{
	NSMutableData *mutableData = nil;
	
	if (string)
	{
		unsigned long ixtext = 0;
		unsigned long lentext = 0;
		unsigned char ch = 0;
		unsigned char inbuf[4], outbuf[4];
		short i = 0, ixinbuf = 0;
		BOOL flignore = NO;
		BOOL flendtext = NO;
		NSData *base64Data = nil;
		const unsigned char *base64data = nil;
		
		// Convert the string to ASCII data.
		base64Data = [string dataUsingEncoding:NSASCIIStringEncoding];
		base64data = (const unsigned char *)[base64Data bytes];
		mutableData = [NSMutableData dataWithCapacity:[base64Data length]];
		lentext = [base64Data length];
		
		while (YES)
		{
			if (ixtext >= lentext)
			{
				break;
			}
			ch = base64data[ixtext++];
			flignore = NO;
			
			if ((ch >= 'A') && (ch <= 'Z')) ch = ch - 'A';
			else if ((ch >= 'a') && (ch <= 'z')) ch = ch - 'a' + 26;
			else if ((ch >= '0') && (ch <= '9')) ch = ch - '0' + 52;
			else if (ch == '+') ch = 62;
			else if (ch == '=') flendtext = YES;
			else if (ch == '/') ch = 63;
			else flignore = YES; 
			
			if (!flignore)
			{
				short ctcharsinbuf = 3;
				BOOL flbreak = NO;
				
				if (flendtext)
				{
					if (!ixinbuf) break;
					if ((ixinbuf == 1) || (ixinbuf == 2)) ctcharsinbuf = 1;
					else ctcharsinbuf = 2;
					ixinbuf = 3;
					flbreak = YES;
				}
				
				inbuf[ixinbuf++] = ch;
				
				// Please ignore any warning here
				if (ixinbuf == 4)
				{
					outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
					outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
					outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
					ixinbuf = 0;
					
					for (i = 0; i < ctcharsinbuf; i++)
					{
						[mutableData appendBytes:&outbuf[i] length:1];
					}
				}
				
				if (flbreak)
				{
					break;
				}
			}
		}
	}
	
	return mutableData;
}

