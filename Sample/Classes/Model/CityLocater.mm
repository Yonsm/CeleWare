
#import "CityLocater.h"

@implementation CityLocater

//
+ (NSDictionary *)city
{
	return [[[CityLocater alloc] initWithDesiredAccuracy:kCLLocationAccuracyThreeKilometers] syncUpdateCity];
}

//
- (NSDictionary *)syncUpdateCity
{
	[super syncUpdateLocation];
	if (_city == nil)
	{
		self.city = @{@"code":@"86", @"name":@"全国"};
	}
	return _city;
}

//
- (void)located
{
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error)
	 {
		 self.city = [CityLocater cityForPlacemarks:placemarks];
		 [super located];
	 }];
}

//
+ (NSDictionary *)cityForPlacemarks:(NSArray *)placemarks
{
	NSData *data = [NSData dataWithContentsOfFile:NSUtil::AssetPath(@"dp_city.json")];
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	for (CLPlacemark *placemark in placemarks)
	{
		NSString *locality = placemark.locality;
		if (locality == nil) locality = placemark.addressDictionary[@"State"];
		if (locality == nil) locality = placemark.administrativeArea;
		for (NSString *group in dict.allKeys)
		{
			NSArray *citys = dict[group];
			for (NSDictionary *city in citys)
			{
				NSString *name = city[@"name"];
				if (name.length > 2) name = [name substringToIndex:2];
				if ([locality hasPrefix:name])
				{
					return city;
				}
			}
		}
	}
	return nil;
}

//
+ (NSDictionary *)cityForCode:(NSString *)code
{
	if (code && ![code isEqualToString:@"86"])
	{
		NSData *data = [NSData dataWithContentsOfFile:NSUtil::AssetPath(@"dp_city.json")];
		NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		for (NSString *group in dict.allKeys)
		{
			NSArray *citys = dict[group];
			for (NSDictionary *city in citys)
			{
				if ([code hasPrefix:city[@"code"]])
				{
					return city;
				}
			}
		}
	}
	return @{@"code":@"86", @"name":@"全国"};
}

@end
