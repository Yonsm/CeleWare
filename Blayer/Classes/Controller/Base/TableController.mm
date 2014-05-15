

#import "TableController.h"

@implementation TableController


- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super init];
	_style = style;
	return self;
}

//
- (id)init
{
	self = [super init];
	_style = UIUtil::IsOS7() ? UITableViewStyleGrouped : UITableViewStylePlain;
	return self;
}

//
- (void)loadView
{
	[super loadView];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:_style];
	_tableView.showsVerticalScrollIndicator = YES;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.tableFooterView = [[UIView alloc] init];
	[self.view addSubview:_tableView];
	
	_tableView.backgroundColor = UIColor.whiteColor;
	
	if (_style == UITableViewStylePlain)
	{
		_tableView.contentInset = UIEdgeInsetsMake(0, 0, kScrollViewBottomPad, 0);
	}
}

#pragma mark -
#pragma mark Table view methods

//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *reuse = @"Cell";//[NSString stringWithFormat:@"Cell%d@%d", indexPath.row, indexPath.section];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuse];
		//cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		cell.backgroundColor = UIColor.whiteColor;
	}
	return cell;
}

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end