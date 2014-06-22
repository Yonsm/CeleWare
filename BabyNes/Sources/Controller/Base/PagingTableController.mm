
#import "PagingTableController.h"

#define kMaxItemsPerPage	20

@implementation PagingTableController

#pragma mark Generic methods

// Constructor
- (id)initWithService:(NSString *)service params:(NSDictionary *)params;
{
	// 参数可写模式
	// NEXT: 参数可写模式要移动到PullTableController或者PullDataLoader甚至DataLoader中去吗？
	self = [super initWithService:service params:[NSMutableDictionary dictionaryWithDictionary:params]];
	_loader.params[@"start"] = [NSNumber numberWithInt:0];
	_loader.params[@"size"] = [NSNumber numberWithInt:kMaxItemsPerPage];
	return self;
}

//
- (id)initWithService:(NSString *)service
{
	return [self initWithService:service params:nil];
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

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_loader.dict[@"results"] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *reuse = @"Cell";
	id cell = [tableView dequeueReusableCellWithIdentifier:reuse];
	if (cell == nil)
	{
		cell = [self allocCellWithReuseIdentifier:reuse atIndexPath:indexPath];
	}
	[self updateCell:cell withDict:_loader.dict[@"results"][indexPath.row] atIndexPath:indexPath];
	return cell;
}

//
- (UITableViewCell *)allocCellWithReuseIdentifier:(NSString *)reuse atIndexPath:(NSIndexPath *)indexPath
{
	return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
}

//
- (void)updateCell:(id)cell withDict:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath
{
	[cell setDict:dict];
}

//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if ((scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.bottom))
	{
		NSUInteger count = [_loader.dict[@"results"] count];
		if (!_loader.loading && (count < [_loader.dict[@"total"] unsignedIntegerValue]))
		{
			_loader.params[@"start"] = [NSNumber numberWithInteger:count];
			//UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			//[indicator startAnimating];
			//self.tableView.tableFooterView = indicator;
			[_loader loadBegin];
		}
	}
}

//
- (BOOL)loadBegan:(DataLoader *)loader
{
	return YES;
}

//
- (id)loadDoing:(DataLoader *)loader
{
	NSMutableDictionary *dict = [loader loadDoing];
	if (loader.error == DataLoaderNoError)
	{
		if ([_loader.params[@"start"] intValue] && [_loader.dict[@"results"] count])
		{
			NSMutableArray *results = [NSMutableArray arrayWithArray:_loader.dict[@"results"]];
			if ([dict[@"results"] count]) [results addObjectsFromArray:dict[@"results"]];
			dict[@"results"] = results;
		}
	}
	return dict;
}

//
- (void)loadEnded:(DataLoader *)loader
{
	//	self.tableView.tableFooterView = nil;
	_loader.params[@"start"] = [NSNumber numberWithInt:0];
	
	[super loadEnded:loader];
}

@end
