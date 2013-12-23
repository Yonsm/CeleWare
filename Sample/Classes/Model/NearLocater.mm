
#import "NearLocater.h"

@implementation NearLocater

//
+ (CLLocation *)location
{
	return [[[NearLocater alloc] init] syncUpdateLocation];
}

// Destructor

//
- (CLLocation *)syncUpdateLocation
{
	_condition = [[NSCondition alloc] init];
	[self performSelectorOnMainThread:@selector(asyncaUpdateLocation) withObject:nil waitUntilDone:NO];
	[_condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:2 * 60]];
	_condition = nil;
	return _location;
}

//
- (void)asyncaUpdateLocation
{
	CLLocationManager *manager = [[CLLocationManager alloc] init];
	manager.delegate = self;
	[self configManager:manager];
	[manager startUpdatingLocation];
}

//
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	self.location = newLocation;
	[manager stopUpdatingLocation];
	[self located];
}

//
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[self located];
}

//
- (void)configManager:(CLLocationManager *)manager
{
	manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
	manager.distanceFilter = 1000.0f;
}

//
- (void)located
{
	[_condition signal];
}

@end
