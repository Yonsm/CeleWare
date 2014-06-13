
#import "PullWizardController.h"

@implementation PullWizardController

// Constructor
- (id)initWithParam:(id)param
{
	if ([param isKindOfClass:NSString.class])
	{
		return [self initWithService:param];
	}
	else if ([param isKindOfClass:NSArray.class] && ([param count] == 2))
	{
		if (!(self = [self initWithService:param[0] params:param[1]])) return nil;
	}
	return nil;
}

//
- (id)initWithService:(NSString *)service
{
	self = [super init];
	_loader = [[PullDataLoader alloc] init];
	_loader.delegate = self;
	_loader.service = service;
	return self;
}

//
- (id)initWithService:(NSString *)service params:(NSDictionary *)params
{
	self = [self initWithService:service];
	_loader.params = params;
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
	_loader.scrollView = _scrollView;
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
- (void)loadData
{
	//[_loader loadFirst];
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
	if (_loader.dict)
	{
		[super reloadPage];
	}
	else
	{
		_contentHeight = 0;
		UIUtil::RemoveSubviews(_contentView);
		_scrollView.contentSize = CGSizeZero;
	}
}

@end
