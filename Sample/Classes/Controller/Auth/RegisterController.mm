
#import "RegisterController.h"
//#import "Register2Controller.h"

@implementation RegisterController

#pragma mark Generic methods

// Constructor
- (id)init
{
	self = [super initWithAutoHide:YES autoNext:NO autoScroll:NO];
	self.title = @"注册帐号 1/3";
	
	//self.navigationItem.rightBarButtonItem = [UIBarButtonItem buttonItemWithTitle:@"下一步" target:self action:@selector(doneButtonClicked:)];
	//self.navigationItem.rightBarButtonItem.enabled = NO;
	
	return self;
}

#pragma mark View methods

// Creates the view that the controller manages.
//- (void)loadView
//{
//	[super loadView];
//}

// Do additional setup after loading the view.
//- (void)viewDidLoad
//{
//	[super viewDidLoad];
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

#pragma mark Data methods

//
- (void)loadPage
{
}

#pragma mark Event methods

//
- (void)updateDoneButton
{
}

//
- (void)doneAction
{
}

@end
