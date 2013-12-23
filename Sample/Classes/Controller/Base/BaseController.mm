

#import "BaseController.h"

@implementation BaseController

#pragma mark Generic methods

// Constructor
//- (id)init
//{
//	[super init];
//	return self;
//}

// Destructor
//- (void)dealloc
//{
//	[super dealloc];
//}

#pragma mark View methods

//
//- (void)loadView
//{
//	[super loadView];
//	self.view.backgroundColor = UIUtil::Color(239, 239, 244);
//}

// Do additional setup after loading the view.
//- (void)viewDidLoad
//{
//	[super viewDidLoad];
//}

// Called after the view controller's view is released and set to nil.
//- (void)viewDidUnload
//{
//	[super viewDidUnload];
//}

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	StatPageBegin(NSStringFromClass([self class]));
	
	//if (!UIUtil::IsOS7())
	{
//		if (!self.navigationItem.hidesBackButton && !self.navigationItem.leftBarButtonItem && (self.navigationController.viewControllers.count > 1))
//		{
//			self.navigationItem.leftBarButtonItem = [UIBarButtonItem _backItemWithTitle:@"返回" target:self action:@selector(backButtonClicked:)];
//		}
	}
}

// Called after the view was dismissed, covered or otherwise hidden.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	StatPageEnded(NSStringFromClass([self class]));
}

// Override to allow rotation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

// Release any cached data, images, etc that aren't in use.
//- (void)didReceiveMemoryWarning
//{
//	[super didReceiveMemoryWarning];
//}

#pragma Data methods

//
- (UIView *)emptyView
{
	UIImage *image = UIUtil::Image(@"EmptyIcon");
	UIImageView *view = [[UIImageView alloc] initWithImage:image];
	view.contentMode = UIViewContentModeCenter;
	CGRect frame = self.view.bounds;
	frame.size.height -= 50;
	view.frame = frame;
	frame.origin.y = (frame.size.height + image.size.height) / 2;
	frame.size.height = 30;
	UILabel *label = [UILabel labelWithFrame:frame
										text:self.emptyTips
									   color:[UIColor darkGrayColor]
										font:[UIFont systemFontOfSize:14]
								   alignment:NSTextAlignmentCenter];
	[view addSubview:label];
	return view;
}

//
- (NSString *)emptyTips
{
	return @"暂时是空的";
}

#pragma mark Event methods

//
- (void)backButtonClicked:(UIButton *)sender
{
	NSArray *controller = self.navigationController.viewControllers;
	if (self.navigationController && (controller[0] != self))
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
