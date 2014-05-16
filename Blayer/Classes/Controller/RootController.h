
#import "TableController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

//
@interface RootController : TableController <AVAudioPlayerDelegate>
{
	NSUInteger _current;
	AVAudioPlayer *_player;

	UIButton *_prevButton;
	UIButton *_playButton;
	UIButton *_nextButton;
	ODRefreshControl *_refreshControl;
}
@property(nonatomic,strong) NSArray *items;
@end
