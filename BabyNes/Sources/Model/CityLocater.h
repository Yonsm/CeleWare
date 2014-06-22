

#import "NearLocater.h"

//
@interface CityLocater : NearLocater
{
}
+ (NSDictionary *)city;
@property(nonatomic,strong) NSDictionary *city;

- (NSDictionary *)syncUpdateCity;

+ (NSDictionary *)cityForCode:(NSString *)code;

@end
