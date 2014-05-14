
#import "RootController.h"
#import <AVFoundation/AVFoundation.h>
#import "WaveView.h"

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
	
	self.view.backgroundColor = /*UIColor.blackColor;//*/[UIColor colorWithPatternImage:[UIImage imageNamed:@"Icon"]];
	
	// 后台播放代码
	AVAudioSession *session = [AVAudioSession sharedInstance];
	[session setActive:YES error:nil];
	[session setCategory:AVAudioSessionCategoryPlayback error:nil];
	
	// 设置支持接受远程控制事件代码。设置支持接受远程控制事件，
	// 其实就是在dock中可以显示应用程序图标，同时点击该图片时，打开app。
	// 或者锁屏时，双击home键，屏幕上方出现应用程序播放控制按钮。
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	
	// 创建播放器
	NSURL *URL = [NSURL fileURLWithPath:NSUtil::AssetPath(@"Song.mp3")];
	static AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:nil];
	[player prepareToPlay];
	[player setVolume:1];
	player.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
	player.meteringEnabled = YES;
	[player play]; //播放
	
	WaveView *waveView = [[WaveView alloc] initWithFrame:self.view.bounds dataSource:player];
	waveView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:waveView];
}

// Called after the view controller's view is released and set to nil.
//- (void)viewDidUnload
//{
//	[super viewDidUnload];
//}

// Called when the view is about to made visible.
//- (void)viewWillAppear:(BOOL)animated
//{
//	[super viewWillAppear:animated];
//}

// Called after the view was dismissed, covered or otherwise hidden.
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//}

#pragma Event methods

@end
