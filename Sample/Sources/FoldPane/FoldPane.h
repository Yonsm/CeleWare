
#import "FoldViews.h"
#import <AVFoundation/AVFoundation.h>

@class FoldPane;
@protocol FoldPaneDelegate <NSObject>
@optional
- (void)foldPaneFoldBegin:(FoldPane *)sender;
- (void)foldPaneFoldEnded:(FoldPane *)sender;
@end

//
@interface FoldPane : UIView
{
	UIImage *_image;
	UIImage *_image_;
	
	NSTimer *_timer;
	FoldViews *_foldView;
	UIControl *_touchMask;
	UIView *_contentView;
	UIButton *_foldButton;
	UIView *_foldIndicator;

	BOOL _open;
#ifdef _FoldBeep
	SystemSoundID _beepSound;
#endif
	id<FoldPaneDelegate> _delegate;
}

@property(nonatomic,readonly) BOOL open;
@property(nonatomic,readonly) UIButton *foldButton;
@property(nonatomic,retain) UIView *foldIndicator;
@property(nonatomic,assign) id<FoldPaneDelegate> delegate;

- (id)initWithContentView:(UIView *)contentView buttonImage:(UIImage *)image buttonImage_:(UIImage *)image_;

@end
