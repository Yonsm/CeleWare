
#import "RootController.h"
#import "WaveView.h"
#import "IconPane.h"
#import "IPADeploy.h"

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
	frame.size.height -= 95;
	self.tableView.frame = frame;
	self.tableView.rowHeight = 57;

	frame.origin.y = frame.size.height;
	frame.size.height = 95;
	IconPane *pane = [[IconPane alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 95, 320, 95)];
	pane.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:pane];

	_refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
	[_refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];

	[_refreshControl beginRefreshing];
	[self loadData];
	[self initSession];
	[self initPlayer];

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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse];
		//cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		cell.backgroundColor = UIColor.whiteColor;
		cell.detailTextLabel.textColor = UIColor.darkGrayColor;
	}
	
	MPMediaItem *item = _items[indexPath.row];
	cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
								 [item valueForProperty:MPMediaItemPropertyArtist] ?: @"未知表演者",
								 [item valueForProperty:MPMediaItemPropertyAlbumTitle] ?: @"未知专辑"];
	MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
	cell.imageView.image = artwork ? [artwork imageWithSize:CGSizeMake(50, 50)] : UIUtil::ImageWithColor(UIColor.whiteColor, CGSizeMake(50, 50));
	return cell;
}

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma Event methods

//
- (void)loadData
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
		NSArray *items = MPMediaQuery.songsQuery.items;
		dispatch_async(dispatch_get_main_queue(), ^ {
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
	// 创建播放器
	NSURL *URL = [NSURL fileURLWithPath:NSUtil::AssetPath(@"Null.mp3")];
	_player = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:nil];
	[_player prepareToPlay];
}

//
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	if (event.type == UIEventTypeRemoteControl)
	{
		switch (event.subtype)
		{
			case UIEventSubtypeRemoteControlPause:
				if (!_player.isPlaying) [_player pause];
				break;

			case UIEventSubtypeRemoteControlPlay:
				if (_player.isPlaying) [_player play];
				break;
				
			case UIEventSubtypeRemoteControlTogglePlayPause:
				if (_player.isPlaying)
					[_player pause];
				else
					[_player play];
				break;
				
			default:
				break;
		}
	}
}

@end
