
#import "NearLocater.h"

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
	[self located];
}

//
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[self located];
}

//
- (void)located
{
	[_condition lock];
	[_condition signal];
	[_condition unlock];
}

@end
