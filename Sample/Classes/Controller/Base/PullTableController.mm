
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
		return [self initWithService:param[0] params:param[1]];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kLogoutNotification object:nil];
}

//
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_loader.scrollView = self.tableView;
	//[_loader loadFirst];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearPage) name:kLogoutNotification object:nil];
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
- (void)loadEnded:(DataLoader *)loader
{
	if (loader.error == DataLoaderNoError)
	{
		[self reloadPage];
	}
}

#pragma mark -
#pragma mark Content methods

//
- (void)clearPage
{
	[_loader clearData];
	[self reloadPage];
}

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
	_loader.empty = self.isEmpty;
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
