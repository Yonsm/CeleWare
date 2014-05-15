
#import "RootController.h"
#import "WaveView.h"
#import "IconPane.h"
//#import <MediaPlayer/MediaPlayer.h>
#import "IPADeploy.h"

@implementation RootController

#pragma mark Generic methods

// Constructor
//- (id)init
//{
//	self = [super init];
//	return self;
//}

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
	
	CGRect frame = self.view.bounds;
	frame.origin.y = frame.size.height - 95;
	frame.size.height = 95;
	IconPane *pane = [[IconPane alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 95, 320, 95)];
	[self.view addSubview:pane];
	
	[self accessoryDidConnect:nil];
	
	//_LogObj(IPAInstalledApps());
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

#pragma Event methods

//
- (void)accessoryDidConnect:(NSNotification *)sender
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
	
	//	// 设置支持接受远程控制事件代码。设置支持接受远程控制事件，
	//	// 其实就是在dock中可以显示应用程序图标，同时点击该图片时，打开app。
	//	// 或者锁屏时，双击home键，屏幕上方出现应用程序播放控制按钮。
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	
	//NSArray *items = MPMediaQuery.songsQuery.items;
	//MPMediaItem *item = items[0];
	//NSURL *URL = [item valueForProperty:MPMediaItemPropertyAssetURL];
	//_LogObj(URL);

	//
	//	// 创建播放器
	NSURL *URL = [NSURL fileURLWithPath:NSUtil::AssetPath(@"Null.mp3")];
	_player = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:nil];
	[_player prepareToPlay];
	//[_player play]; //播放
	//
	//_player.meteringEnabled = YES;
	//	WaveView *waveView = [[WaveView alloc] initWithFrame:self.view.bounds dataSource:_player];
	//	waveView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	//	[self.view addSubview:waveView];
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
