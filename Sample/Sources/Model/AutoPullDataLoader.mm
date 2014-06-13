
#import "AutoPullDataLoader.h"

#ifdef _TODOCheckTimerLeakForARC
@implementation AutoPullDataLoader

//
- (void)dealloc
{
	[_abortTimer invalidate];
	[_autoTimer invalidate];
}

//
- (void)loadPause
{
	[super loadPause];
	
	// 隐藏就取消自动刷新？
	[_abortTimer invalidate];
	_abortTimer = nil;
	[_autoTimer invalidate];
	_autoTimer = nil;
}

//
- (void)loadSlient
{
	self.checkError = NO;
	[self loadBegin];
}

//
- (void)loadAuto
{
	_autoReload = YES;	// 60 秒钟后，自动重新刷新
	[self loadSlient];
	//[self performSelector:@selector(loadAbort) withObject:nil afterDelay:60 * 5];	// 5 分钟后，取消自动刷新机制
	
	[_abortTimer invalidate];
	_abortTimer = [NSTimer timerWithTimeInterval:60 * 5 target:self selector:@selector(loadAbort) userInfo:nil repeats:NO];
}

//
- (void)loadAbort
{
	_autoReload = NO;
}

//
- (void)loadStop:(NSDictionary *)dict
{
	if (self.error == DataLoaderNoError)
	{
		[self loadAbort];
	}
	
	if (_autoReload)
	{
		[_autoTimer invalidate];
		_autoTimer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(loadSlient) userInfo:nil repeats:NO];
		//[self performSelector:@selector(loadSlient) withObject:nil afterDelay:60];	// 60 秒钟后，自动重新刷新
	}
	
	[super loadStop:dict];
}

@end
#endif
