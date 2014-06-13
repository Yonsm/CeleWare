
#define _CacheDataLoaderWithPullSupport
#ifdef _CacheDataLoaderWithPullSupport
#import "PullDataLoader.h"
#define _CacheDataParentLoader PullDataLoader
#else
#import "DataLoader.h"
#define _CacheDataParentLoader DataLoader
#endif

//
@interface CacheDataLoader : _CacheDataParentLoader
{
@private
	BOOL _online;
}

@property(nonatomic,assign) BOOL online;

- (void)loadIfOffline;

@end
