
#import "AppDelegate.h"
#import "WaveView.h"


@implementation WaveView

// Constructor
- (id)initWithFrame:(CGRect)frame dataSource:(id/*<WaveViewDataSource>*/)dataSource
{
	self = [super initWithFrame:frame];
	self.backgroundColor = UIColor.clearColor;
	self.clearsContextBeforeDrawing = YES;
	
	_dataSource = dataSource;
	
	_timer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(redraw) userInfo:nil repeats:YES];
	
	return self;
}

// Destructor
- (void)dealloc
{
	[_timer invalidate];
}

//
#define _Wave
- (void)redraw
{
	if (_dataSource.isMeteringEnabled)
	{
		[_dataSource updateMeters];
		
		float power = pow(10, (0.05 * [_dataSource peakPowerForChannel:0]));
		if (_maxPower < power)
		{
			_maxPower = power;
		}
		if (_minPower > power)
		{
			_minPower = power;
		}
		
		_powers.push_back(power);
		if (_powers.size() > 1200)
		{
			_powers.erase(_powers.begin());
		}

		[self setNeedsDisplay];
	}
}

//
- (void)drawRect:(CGRect)rect
{
	if (_maxPower != _minPower)
	{
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextBeginPath(context);
		CGContextSetStrokeColorWithColor(context, UIColor.whiteColor.CGColor);

		NSUInteger count = _powers.size();
		for (NSUInteger i = 0; i < count; i++)
		{
			CGFloat x = rect.size.width * i / count;
			CGFloat y = rect.size.height - (rect.size.height * (_powers[i] - _minPower) / (_maxPower - _minPower));
			if (i == 0)
			{
				CGContextMoveToPoint(context, x, y);
			}
			else
			{
				CGContextAddLineToPoint(context, x, y);
			}
		}

		CGContextStrokePath(context);
	}
	
}

@end
