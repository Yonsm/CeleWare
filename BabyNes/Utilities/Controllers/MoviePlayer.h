
//TODO: Check iPad/iPhone 3.x behavior
#import <MediaPlayer/MediaPlayer.h>

// TODO: Check viewDidUnload, etc.

@interface MoviePlayer : UIViewController 
{
	MPMoviePlayerController *_player;
	BOOL _playerRemoved;
	NSURL *_URL;
}

- (id)initWithURL:(NSURL *)URL;

@end
