
#import <deque>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


//
@protocol WaveViewDataSource<NSObject>

@property(readonly) NSTimeInterval currentTime;

/* metering */

@property(getter=isMeteringEnabled) BOOL meteringEnabled; /* turns level metering on or off. default is off. */

- (void)updateMeters; /* call to refresh meter values */

- (float)peakPowerForChannel:(NSUInteger)channelNumber; /* returns peak power in decibels for a given channel */
- (float)averagePowerForChannel:(NSUInteger)channelNumber; /* returns average power in decibels for a given channel */

@end


//
@interface WaveView : UIView
{
	NSTimer *_timer;
	float _minPower;
	float _maxPower;
	//float _power;
	std::deque<float> _powers;
	id<WaveViewDataSource> _dataSource;
}

- (id)initWithFrame:(CGRect)frame dataSource:(id/*<WaveViewDataSource>*/)dataSource;

@end
