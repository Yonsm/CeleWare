

#import <CoreLocation/CoreLocation.h>

//
@interface NearLocater : NSObject <CLLocationManagerDelegate>
{
	NSCondition *_condition;
}

+ (CLLocation *)location;
@property(nonatomic,retain) CLLocation *location;

- (void)asyncaUpdateLocation;
- (CLLocation *)syncUpdateLocation;

// For subclass only
- (void)located;
- (void)configManager:(CLLocationManager *)manager;

@end
