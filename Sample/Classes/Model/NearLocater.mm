
#import "NearLocater.h"
#import "DataLoader.h"

//
@implementation CLLocation (Distance)
- (NSString *)distanceFromLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
	CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
	CLLocationDistance meters = [self distanceFromLocation:location];
	if (meters > 1000) return [NSString stringWithFormat:@"%.0lf公里", (meters / 1000)];
	return [NSString stringWithFormat:@"%d米", (int)meters];
}
@end

@implementation NearLocater

//
+ (CLLocation *)location
{
	return [[[NearLocater alloc] initWithDesiredAccuracy:kCLLocationAccuracyBest] syncUpdateLocation];
}

//
- (id)initWithDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy
{
	self = [super init];
	[self performSelectorOnMainThread:@selector(initManager) withObject:nil waitUntilDone:YES];
	_manager.desiredAccuracy = desiredAccuracy;
	return self;
}

//
- (id)init
{
	self = [super init];
	[self performSelectorOnMainThread:@selector(initManager) withObject:nil waitUntilDone:YES];
	_manager.desiredAccuracy = kCLLocationAccuracyBest;
	return self;
}

// CLLocationManager 必须在主线程中调用
- (void)initManager
{
	_manager = [[CLLocationManager alloc] init];
	_manager.distanceFilter = 100.0f;
	_manager.delegate = self;
}

// 暂不支持二次调用
- (CLLocation *)syncUpdateLocation
{
	_condition = [[NSCondition alloc] init];
	[_manager startUpdatingLocation];
	[_condition lock];
	[_condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:2 * 60]];
	[_condition unlock];
	_condition = nil;
	return _location;
}

//
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	self.location = newLocation;
	[manager stopUpdatingLocation];
	[self locationEnded];
	
#define _UpdateLocation
#ifdef _UpdateLocation
	if (Settings::Get(kPassword))
	{
		[DataLoader loadWithService:@"/api/user/updateUserPosition.json"
							 params:@{
									  @"lat":[NSNumber numberWithDouble:newLocation.coordinate.latitude],
									  @"lng":[NSNumber numberWithDouble:newLocation.coordinate.longitude],
									  }
						showLoading:NO
						 checkError:NO
						 completion:^(DataLoader *loader)
		 {
			 _Log(@"UpdateLocation: %@", loader.errorString);
		 }];
	}
#endif
}

//
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[self locationEnded];
}

//
- (void)locationEnded
{
	[_condition lock];
	[_condition signal];
	[_condition unlock];
}

@end
