

#import "TableController.h"
#import "PullDataLoader.h"

//
@interface PullTableController : TableController <DataLoaderDelegate, WizardControllerDelegate>
{
	PullDataLoader *_loader;
}
@property(nonatomic,readonly) PullDataLoader *loader;

- (id)initWithService:(NSString *)service params:(NSDictionary *)params;
- (id)initWithService:(NSString *)service;
- (void)loadEnded:(DataLoader *)loader;
- (void)reloadForce;
- (void)reloadPage;

// For subclass only
- (void)loadPage;
- (BOOL)isEmpty;
@end
