
#import "PagingTableController.h"

@implementation PagingTableController

#pragma mark Generic methods

// Constructor
- (id)initWithService:(NSString *)service params:(NSDictionary *)params;
{
	// 参数可写模式
	// TODO: 参数可写模式要移动到PullTableController或者PullDataLoader甚至DataLoader中去吗？
	self = [super initWithService:service params:[NSMutableDictionary dictionaryWithDictionary:params]];
	_loader.params[@"start"] = @"0";
	_loader.params[@"size"] = @"20";
	return self;
}

//
- (id)initWithService:(NSString *)service
{
	return [self initWithService:service params:nil];
}

// Destructor
//- (void)dealloc
//{
//	[super dealloc];
//}

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

//
//- (void)viewDidAppear:(BOOL)animated
//{
//	[super viewDidAppear:animated];
//}

// Called after the view was dismissed, covered or otherwise hidden.
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//}

#pragma mark Table view delegate

@end
