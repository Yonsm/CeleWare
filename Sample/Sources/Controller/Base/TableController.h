

#import "BaseController.h"

//
@interface TableController : BaseController <UITableViewDataSource, UITableViewDelegate>
{
	UITableViewStyle _style;
}
- (id)initWithStyle:(UITableViewStyle)style;
@property(nonatomic,readonly) UITableView *tableView;
@end
