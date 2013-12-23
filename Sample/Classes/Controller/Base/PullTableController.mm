
#import "PullTableController.h"

@implementation PullTableController

// Constructor
- (id)initWithParam:(id)param
{
	if ([param isKindOfClass:NSString.class])
	{
		return [self initWithService:param];
	}
	else if ([param isKindOfClass:NSArray.class] && ([param count] == 2))
	{
		[self initWithService:param[0] params:param[1]];
	}
	return nil;
}

//
- (id)initWithService:(NSString *)service params:(NSDictionary *)params
{
	self = [super init];
	_loader = [[PullDataLoader alloc] init];
	_loader.delegate = self;
	_loader.service = service;
	_loader.params = params;
	return self;
}

//
- (id)initWithService:(NSString *)service
{
	self = [self initWithService:service params:nil];
	return self;
}

//
- (void)dealloc
{
	[_loader release];
	[super dealloc];
}

//
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_loader.scrollView = self.tableView;
	//[_loader loadFirst];
}

//
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (_loader.needLogin)
	{
		[self reloadForce];
	}
	else
	{
		[_loader loadResume];
	}
}

//
- (void)viewWillDisappear:(BOOL)animated
{
	[_loader loadPause];
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Data loader methods

//
- (void)loadEnded:(DataLoader *)sender
{
	if (sender.error == DataLoaderNoError)
	{
		[self reloadPage];

		// TODO: 没有数据的情况和界面整理，提到更上的层级？
		// TODO: 只有成功时才有这个界面吗？
		_loader.empty = self.isEmpty;
	}
}

#pragma mark -
#pragma mark Content methods

//
- (void)reloadForce
{
	[_loader clearData];
	[self reloadPage];
	[_loader loadBegin];
}

//
 - (void)reloadPage
{
	[self loadPage];
	[self.tableView reloadData];
}

//
- (void)loadPage
{
}

//
- (BOOL)isEmpty
{
	for (NSInteger i = self.tableView.numberOfSections - 1; i >= 0; i--)
	{
		if ([self.tableView numberOfRowsInSection:i])
		{
			return NO;
		}
	}
	return YES;
}

@end
