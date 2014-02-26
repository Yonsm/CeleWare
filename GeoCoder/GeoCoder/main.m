//
//  main.m
//  GeoCoder
//
//  Created by Yonsm on 14-1-11.
//  Copyright (c) 2014年 Yonsm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NSArray *lines;
NSMutableString *results;
void geocode(NSUInteger index)
{
	 if (index >= lines.count)
	 {
		  [results writeToFile:@"/Volumes/RAM/泰康保险-医院列表.csv" atomically:YES encoding:NSUTF8StringEncoding error:nil];
		  exit(0);
		  return;
	 }
	 
	 if (index && (index % 40 == 0))
	 {
		  [results writeToFile:@"/Volumes/RAM/Results.cvs" atomically:NO encoding:NSUTF8StringEncoding error:nil];
		  [NSThread sleepForTimeInterval:70];
	 }
	 
	 @autoreleasepool
	 {
		  NSString *line = lines[index];
		  [results appendString:line];
		  NSArray *fields = [line componentsSeparatedByString:@","];
		  if (fields.count > 1)
		  {
				printf("GeoCoding %ld/%ld %s...", index + 1, lines.count, [fields[1] UTF8String]);
				CLGeocoder *coder = [[CLGeocoder alloc] init];
				[coder geocodeAddressString:fields[1] completionHandler:^(NSArray *placemarks, NSError *error)
				 {
					  if (placemarks.count)
					  {
							CLPlacemark *placemark = placemarks[0];
							[results appendFormat:@",%lf,%lf,%.0lf\r\n", placemark.region.center.latitude, placemark.region.center.longitude, placemark.region.radius];
							printf("(%lf,%lf)~%.0lf\n",placemark.region.center.latitude, placemark.region.center.longitude, placemark.region.radius);
							geocode(index + 1);
					  }
					  else if (fields.count > 17)
					  {
							[coder geocodeAddressString:fields[17] completionHandler:^(NSArray *placemarks, NSError *error)
							 {
								  if (placemarks.count)
								  {
										CLPlacemark *placemark = placemarks[0];
										[results appendFormat:@",%lf,%lf,%.0lf\r\n", placemark.region.center.latitude, placemark.region.center.longitude, placemark.region.radius];
										printf("(%lf,%lf)~%.0lf\n",placemark.region.center.latitude, placemark.region.center.longitude, placemark.region.radius);
								  }
								  else
								  {
										printf("失败：%s\n", error.localizedDescription.UTF8String);
										[results appendString:@",经度,纬度,范围\r\n"];
								  }
								  geocode(index + 1);
							 }];
					  }
					  else
					  {
							printf("失败：%s\n", error.localizedDescription.UTF8String);
							[results appendString:@",经度,纬度,范围\r\n"];
							geocode(index + 1);
					  }
				 }];
		  }
		  else
		  {
				[results appendString:@"\r\n"];
		  }
	 }
}

@interface GeoCoder : NSObject
@end
@implementation GeoCoder
- (void)startIt:(id)params
{
	 
}
@end


int main(int argc, const char * argv[])
{
	 @autoreleasepool
	 {
		  NSStringEncoding encoding;
		  NSString *file = [NSString stringWithContentsOfFile:@"/Users/Yonsm/Desktop/泰康保险-医院列表.csv" usedEncoding:&encoding error:nil];
		  lines = [file componentsSeparatedByString:@"\r\n"];
		  results = [NSMutableString string];
		  geocode(0);
		  
		  //start a timer so that the process does not exit, this will GPS time to fetch and come back.
		  NSDate *now = [[NSDate alloc] init];
		  NSTimer *timer = [[NSTimer alloc] initWithFireDate:now
																  interval:100000000
																	 target:[[GeoCoder alloc] init]
																  selector:@selector(startIt:)
																  userInfo:nil
																	repeats:YES];
		  
		  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		  [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
		  [runLoop run];
	 }
    return 0;
}

