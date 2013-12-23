

#import "BaseController.h"

//
@interface TableController : BaseController <UITableViewDataSource, UITableViewDelegate>
{
@private
	UITableViewStyle _style;
}
- (id)initWithStyle:(UITableViewStyle)style;
@property(nonatomic,readonly) UITableView *tableView;
@end
