

#import "TableController.h"
#import "PullDataLoader.h"

//
@interface PullTableController : TableController <DataLoaderDelegate, WizardControllerDelegate>
{
	PullDataLoader *_loader;
}
- (id)initWithService:(NSString *)service params:(NSDictionary *)params;
- (id)initWithService:(NSString *)service;
- (void)loadEnded:(DataLoader *)sender;
- (void)reloadForce;
- (void)reloadPage;

// For subclass only
- (void)loadPage;
- (BOOL)isEmpty;
@end
