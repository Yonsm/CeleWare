

#import <CoreLocation/CoreLocation.h>

//
@interface NearLocater : NSObject <CLLocationManagerDelegate>
{
	NSCondition *_condition;
}

// 此方法可以在后台线程中调用
- (id)initWithDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy;

+ (CLLocation *)location;
@property(nonatomic,strong) CLLocation *location;
@property(nonatomic,strong) CLLocationManager *manager;

- (CLLocation *)syncUpdateLocation;

// For subclass only
- (void)located;

@end
