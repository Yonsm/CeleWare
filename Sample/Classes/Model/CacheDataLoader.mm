

#import "CacheDataLoader.h"


@implementation CacheDataLoader

//
- (NSString *)cachePath
{
	return NSUtil::CacheUrlPath(self.service);
}

//
- (NSString *)stampKey
{
	return [self.service stringByDeletingPathExtension];
}

//
- (NSDate *)date
{
	return self.date ? self.date : Settings::Get(self.stampKey);
}

//
- (void)loadIfOffline
{
	if (!_online)
	{
		[self loadBegin];
	}
}

//
- (void)loadStart
{
	if (_online) [super loadStart];
}

//
- (NSData *)loadData
{
	NSData *data;
	NSString *cache = self.cachePath;
	if (_online)
	{
		data = [super loadData];
		[data writeToFile:cache atomically:YES];
	}
	else
	{
		data = [NSData dataWithContentsOfFile:cache];
	}
	return data;
}

//
- (void)loadStop:(NSDictionary *)dict
{
	//
	if (_online)
	{
		[super loadStop:dict];
		Settings::Save(self.stampKey, self.date);
	}
	else
	{
		_online = YES;
		[self performSelector:@selector(loadBegin) withObject:nil afterDelay:1.0];
	}
}

@end
