
#import "PullTableController.h"

//
@interface PagingTableController : PullTableController
{
}
- (id)initWithService:(NSString *)service params:(NSDictionary *)params;
- (id)initWithService:(NSString *)service;

// For subclass only
- (UITableViewCell *)allocCellWithReuseIdentifier:(NSString *)reuse atIndexPath:(NSIndexPath *)indexPath;
- (void)updateCell:(id)cell withDict:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath;
@end
