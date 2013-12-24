
#import "PullDataLoader.h"

#ifdef _TODOCheckTimerLeakForARC
@interface AutoPullDataLoader: PullDataLoader
{
	BOOL _autoReload;
	NSTimer *_autoTimer;
	NSTimer *_abortTimer;
}
//- (void)loadSlient;	// 安静模式刷新
- (void)loadAuto;	// 自动刷新到成功或超时
//- (void)loadAbort;	// 取消自动刷新
@end
#endif
