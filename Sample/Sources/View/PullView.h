
// TODO: 改成 ODRefreshControl 的风格
#import <QuartzCore/QuartzCore.h>

//
typedef enum
{
	PullViewStateNormal,
	PullViewStatePulling,
	PullViewStateLoading,	
}
PullViewState;


//
@protocol PullViewDelegate;
@interface PullView : UIView
{
	BOOL _ignore;
}

@property(nonatomic,assign) PullViewState state;
@property(nonatomic,weak) id<PullViewDelegate> delegate;

@property(weak, nonatomic,readonly) CALayer *arrowImage;
@property(nonatomic,readonly) UILabel *stampLabel;
@property(nonatomic,readonly) UILabel *stateLabel;
@property(nonatomic,readonly) UIActivityIndicatorView *activityView;

- (void)didScroll;
- (BOOL)endDragging;
- (void)beginLoading;
- (void)finishLoading;

@end


//
@protocol PullViewDelegate
@optional
- (NSString *)pullView:(PullView *)pullView textForState:(PullViewState)state;
@end


//
@interface UIScrollView (PullScrollView)
@property(nonatomic,readonly) PullView *pullView;
@end


