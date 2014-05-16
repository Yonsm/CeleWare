
#import "RootController.h"
#import "WaveView.h"
#import "IconPane.h"
#import "IPADeploy.h"
#import "EXButton.h"

@interface MusicItemCell : UITableViewCell
@end

@implementation MusicItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	//cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	self.backgroundColor = UIColor.whiteColor;
	self.detailTextLabel.textColor = UIColor.darkGrayColor;
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	self.imageView.clipsToBounds = YES;
	return self;
}

//
- (void)layoutSubviews
{
	[super layoutSubviews];

	CGRect frame = {10, 3, 50, 50};
	self.imageView.frame = frame;
	_Log(@"imageView: %@", NSStringFromCGRect(frame));

	frame = self.detailTextLabel.frame;
	frame.origin.x = 70;
	frame.origin.y = 35;
	self.detailTextLabel.frame = frame;
	_Log(@"detailTextLabel: %@", NSStringFromCGRect(frame));

	frame = self.textLabel.frame;
	frame.origin.x = 70;
	frame.origin.y = 10;
	self.textLabel.frame = frame;

	_Log(@"textLabel: %@", NSStringFromCGRect(frame));
}

@end

@implementation RootController

#pragma mark Generic methods

// Constructor
- (id)init
{
	self = [super initWithStyle:UITableViewStylePlain];
	return self;
}

#pragma mark View methods

// Creates the view that the controller manages.
//- (void)loadView
//{
//	[super loadView];
//}

// Do additional setup after loading the view.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSUtil::BundleDisplayName();
	self.view.backgroundColor = UIUtil::Color(69,79,120);
	
	CGRect frame = self.tableView.frame;
	frame.size.height -= 95 + 80;
	self.tableView.frame = frame;
	self.tableView.rowHeight = 57;
	self.tableView.contentInset = UIEdgeInsetsMake(UIUtil::IsOS7() ? 22 : 0, 0, 22, 0);
	if (UIUtil::IsOS7()) self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);

	frame.origin.y = frame.size.height;
	frame.size.height = 80;
	UIView *toolbar = [[UIView alloc] initWithFrame:frame];
	toolbar.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];//UIUtil::Color(69,79,120,0.8);
	[self.view addSubview:toolbar];

	_prevButton = [UIButton buttonWithImageNamed:@"PrevIcon"];
	[_prevButton addTarget:self action:@selector(prevButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	_prevButton.center = CGPointMake(80, 40);
	[toolbar addSubview:_prevButton];

	_playButton = [UIButton buttonWithImageNamed:@"PlayIcon"];
	[_playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	_playButton.center = CGPointMake(160, 40);
	[toolbar addSubview:_playButton];

	_nextButton = [UIButton buttonWithImageNamed:@"NextIcon"];
	[_nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	_nextButton.center = CGPointMake(240, 40);
	[toolbar addSubview:_nextButton];

	frame.origin.y += frame.size.height;
	frame.size.height = 95;
	IconPane *pane = [[IconPane alloc] initWithFrame:frame];
	pane.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:pane];

	_refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
	[_refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];

	[_refreshControl beginRefreshing];
	[self initSession];
	[self loadData];

	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

// Called after the view controller's view is released and set to nil.
//- (void)viewDidUnload
//{
//	[super viewDidUnload];
//}

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//[self accessoryDidConnect:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:) name:AVAudioSessionRouteChangeNotification object:nil];
}

// Called after the view was dismissed, covered or otherwise hidden.
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//}

//
#pragma Table view methods

//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _items.count;
}

//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *reuse = @"Cell";//[NSString stringWithFormat:@"Cell%d@%d", indexPath.row, indexPath.section];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
	if (cell == nil)
	{
		cell = [[MusicItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse];
	}
	
	NSUInteger row = indexPath.row;
	MPMediaItem *item = _items[row];
	cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
								 [item valueForProperty:MPMediaItemPropertyArtist] ?: @"未知表演者",
								 [item valueForProperty:MPMediaItemPropertyAlbumTitle] ?: @"未知专辑"];
	MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
	cell.imageView.image = artwork ? [artwork imageWithSize:CGSizeMake(50, 50)] : UIUtil::ImageWithColor(UIColor.lightGrayColor);
	
	cell.accessoryView = (row == _current) ? [[UIImageView alloc] initWithImage:UIUtil::Image(_player.isPlaying ? @"PlayingIndicator" : @"PauseIndicator")] : nil;
	
	return cell;
}

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[self play:indexPath.row];
}


#pragma Event methods

//
- (void)loadData
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
		NSArray *items = MPMediaQuery.songsQuery.items;
		dispatch_async(dispatch_get_main_queue(), ^ {
			[self initPlayer];
			self.items = items;
			[self.tableView reloadData];
			[_refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.5];
		});
	});
}

//
- (void)initSession
{
	// 后台播放代码
	AVAudioSession *session = [AVAudioSession sharedInstance];
	[session setActive:YES error:nil];
	[session setCategory:AVAudioSessionCategoryPlayback error:nil];

	//AudioSessionSetActive(YES);
	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	
	UInt32 doChangeDefaultRoute = 1;
	AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
	
	UInt32 allowBluetoothInput = 1;
	AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput, sizeof(allowBluetoothInput), &allowBluetoothInput);
	
#if !TARGET_IPHONE_SIMULATOR
	CFStringRef audioRouteOverride = kAudioSessionOutputRoute_BluetoothHFP;
	AudioSessionSetProperty(kAudioSessionProperty_OutputDestination, sizeof(audioRouteOverride), &audioRouteOverride);
#endif
}

//
- (void)initPlayer
{
	_current = -1;
	_prevButton.enabled = NO;
	_nextButton.enabled = NO;

	NSURL *URL = [NSURL fileURLWithPath:NSUtil::AssetPath(@"Null.mp3")];
	_player = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:nil];
	[_player performSelector:@selector(prepareToPlay) withObject:nil afterDelay:0];
}

//
- (void)play:(NSUInteger)index
{
	if (index < _items.count)
	{
		if (_current != -1)
		{
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_current inSection:0]];
			cell.accessoryView = nil;
		}

		_current = index;
		_prevButton.enabled = index > 0;
		_nextButton.enabled = index < _items.count - 1;

		NSURL *URL = [_items[_current] valueForProperty:MPMediaItemPropertyAssetURL];
		_player = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:nil];
		_player.delegate = self;
		[self play];
	}
}

//
- (void)prevButtonClicked:(id)sender
{
	[self play:_current - 1];
}

//
- (void)playButtonClicked:(id)sender
{
	if (_current == -1)
	{
		[self play:0];
		return;
	}

	if (_player.isPlaying)
		[self pause];
	else
		[self play];
}

//
- (void)play
{
	[_player performSelector:@selector(play) withObject:nil afterDelay:0];
	[_playButton setImage:UIUtil::Image(@"PauseIcon") forState:UIControlStateNormal];

	NSIndexPath *currentPath = [NSIndexPath indexPathForRow:_current inSection:0];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:currentPath];
	cell.accessoryView = [[UIImageView alloc] initWithImage:UIUtil::Image(@"PlayingIndicator")];
	
	[self.tableView scrollToRowAtIndexPath:currentPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

//
- (void)pause
{
	[_player performSelector:@selector(pause) withObject:nil afterDelay:0];
	[_playButton setImage:UIUtil::Image(@"PlayIcon") forState:UIControlStateNormal];

	NSIndexPath *currentPath = [NSIndexPath indexPathForRow:_current inSection:0];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:currentPath];
	cell.accessoryView = [[UIImageView alloc] initWithImage:UIUtil::Image(@"PauseIndicator")];
}

//
- (void)nextButtonClicked:(id)sender
{
	[self play:_current + 1];
}

//
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[self nextButtonClicked:nil];
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	[self nextButtonClicked:nil];
}

/* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	[self pause];
}

/* audioPlayerEndInterruption:withOptions: is called when the audio session interruption has ended and this player had been interrupted while playing. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
	[self play];
}

//
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	if (event.type == UIEventTypeRemoteControl)
	{
		switch (event.subtype)
		{
			case UIEventSubtypeRemoteControlPause:
				if (!_player.isPlaying) [self pause];
				break;

			case UIEventSubtypeRemoteControlPlay:
				if (_player.isPlaying) [self play];
				break;
				
			case UIEventSubtypeRemoteControlTogglePlayPause:
				if (_player.isPlaying)
					[self pause];
				else
					[self play];
				break;
				
			default:
				break;
		}
	}
}

@end
