

#import <CoreLocation/CoreLocation.h>

//
@interface CLLocation (Distance)
- (NSString *)distanceFromLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
@end

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
- (void)locationEnded;

@end
