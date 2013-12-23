

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
	_style = UIUtil::IsOS7() ? UITableViewStyleGrouped : UITableViewStylePlain/*TODO:iOS6 Plain Default UI*/;
	return self;
}

//
- (void)loadView
{
	[super loadView];
	
	_tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:_style] autorelease];
	_tableView.showsVerticalScrollIndicator = YES;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.tableFooterView = [[[UIView alloc] init] autorelease];
	[self.view addSubview:_tableView];

	_tableView.backgroundView.backgroundColor = UIColor.whiteColor;

	if (_style == UITableViewStylePlain)
	{
		_tableView.contentInset = UIEdgeInsetsMake(0, 0, kScrollViewBottomPad, 0);
	}
}

//
- (void)viewDidUnload
{
	[super viewDidUnload];
	_tableView = nil;
}

#pragma mark -
#pragma mark Table view methods

//
#if 0 //TODO:再检查
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return ((_style == UITableViewStylePlain) && [self tableView:tableView titleForHeaderInSection:section]) ? 44 : 0;
}

//
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

//
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (_style == UITableViewStylePlain)
	{
		NSString *title = [self tableView:tableView titleForHeaderInSection:section];
		if (title)
		{
			UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
			UIFont *font = [UIFont boldSystemFontOfSize:15];
			UILabel *label = [UILabel labelWithFrame:CGRectMake(14, 22, 300, 16)
												text:title
											   color:UIUtil::Color(0x4d4d4d)
												font:font
										   alignment:NSTextAlignmentLeft];
			[view addSubview:label];

			UIView *line = [[[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 0.5)] autorelease];
			line.backgroundColor = UIUtil::Color(0xcccccc);
			[view addSubview:line];
			
			view.clipsToBounds = NO;
			return view;
		}
	}
	return nil;
}
#endif

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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuse] autorelease];
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