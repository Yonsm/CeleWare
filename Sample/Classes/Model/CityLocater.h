

#import "NearLocater.h"

//
@interface CityLocater : NearLocater
{
}
+ (NSDictionary *)city;
@property(nonatomic,retain) NSDictionary *city;

- (NSDictionary *)syncUpdateCity;

@end
