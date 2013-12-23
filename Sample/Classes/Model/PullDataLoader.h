
#import "DataLoader.h"

//
@interface PullDataLoader: DataLoader
{
	BOOL _disableShowLoginOnce;
	
	UIView *_emptyView;
	UIView *_authView;
}

@property(nonatomic,assign) BOOL needAuth;
@property(nonatomic,readonly) BOOL needLogin;
//@property(nonatomic,assign) BOOL disableLoadOnResumeOnce;
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,readonly) ODRefreshControl *refreshControl;

// load 表示触发刷新；loadPage 表示刷新完成后装载页面；reload 表示重新装载
//- (void)loadFirst;	// 第一次刷新
- (void)loadRefresh;	// 用户下拉刷新
- (void)loadResume;	// 切换页面刷新
- (void)loadPause;	// 隐藏页面取消刷新
//- (BOOL)loadExpire;		// 如果上次是成功刷新或无变化，且上次刷新到当前时间间隔超过 1 分钟，则刷新，否则不刷新

- (void)setEmpty:(BOOL)empty;
- (void)setRefreshEnabled:(BOOL)enabled;

@end


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
