

#import "AutoWizardController.h"
#import "PullDataLoader.h"

//
@interface PullWizardController : AutoWizardController <DataLoaderDelegate, WizardControllerDelegate>
{
	PullDataLoader *_loader;
}
- (id)initWithService:(NSString *)service params:(NSDictionary *)params;
- (id)initWithService:(NSString *)service;
- (void)loadEnded:(DataLoader *)sender;
- (void)reloadForce;
@end
