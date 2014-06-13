

#import "BaseController.h"

@implementation BaseController

#pragma mark Generic methods

// Constructor
//- (id)init
//{
//	[super init];
//	return self;
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

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	StatPageBegin(NSStringFromClass([self class]));
	
//	if (self.navigationItem.leftBarButtonItem == nil/*!UIUtil::IsOS7()*/)
//	{
//		if (!self.navigationItem.hidesBackButton && !self.navigationItem.leftBarButtonItem && (self.navigationController.viewControllers.count > 1))
//		{
//			[self.view addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonClicked:)]];
//
//			self.navigationItem.leftBarButtonItem = [UIBarButtonItem buttonItemWithTitle:@"返回" target:self action:@selector(backButtonClicked:)];
//		}
//	}
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

#pragma mark Event methods

//
- (void)backButtonClicked:(id)sender
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
