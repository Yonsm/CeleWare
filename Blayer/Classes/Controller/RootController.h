
#import "TableController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

//
@interface RootController : TableController
{
	AVAudioPlayer *_player;
	ODRefreshControl *_refreshControl;
}
@property(nonatomic,strong) NSArray *items;
@end
