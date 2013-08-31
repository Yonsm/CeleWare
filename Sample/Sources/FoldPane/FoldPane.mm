
#import "FoldPane.h"

@implementation FoldPane

// Constructor
- (id)initWithContentView:(UIView *)contentView buttonImage:(UIImage *)image buttonImage_:(UIImage *)image_
{
	CGRect contentFrame = contentView.frame;
	
	CGRect frame = contentFrame;
	frame.origin.y += frame.size.height - image.size.height;
	frame.size.height += image_.size.height;
	if (frame.size.width < image.size.width)
	{
		frame.origin.x -= (image.size.width - frame.size.width) / 2;
		frame.size.width = image.size.width;
	}
	self = [super initWithFrame:frame];
	
	self.userInteractionEnabled = YES;
	self.clipsToBounds = YES;
	self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	
	_image = image.retain;
	_image_ = image_.retain;
	
	//
	contentFrame.origin.x = (frame.size.width - contentFrame.size.width) / 2;
	contentFrame.origin.y = image_.size.height;
	contentView.frame = contentFrame;
	[self addSubview:contentView];
	_contentView = contentView;

	//
	_foldButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, image.size.height)] autorelease];
	[_foldButton setImage:image forState:UIControlStateNormal];
	[_foldButton addTarget:self action:@selector(togglePane:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_foldButton];
	
	//
	UIPanGestureRecognizer *gesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPane:)] autorelease];
	[_foldButton addGestureRecognizer:gesture];
	
#ifdef _FoldBeep
	NSURL *URL = [NSURL fileURLWithPath:NSUtil::ResourcePath(@"FoldBeep.wav") isDirectory:NO];
	AudioServicesCreateSystemSoundID((CFURLRef)URL, &_beepSound);
#endif

	return self;
}

//
- (void)removeFoldView
{
	[_foldView removeFromSuperview];
	[_foldView release];
	_foldView = nil;
}

//
- (void)setFoldIndicator:(UIView *)foldIndicator
{
	if (_foldIndicator != foldIndicator)
	{
		[_foldIndicator release];
		_foldIndicator = foldIndicator.retain;
		
		if (foldIndicator && !foldIndicator.superview)
		{
			[self.foldButton addSubview:foldIndicator];
		}
	}
}

// Destructor
- (void)dealloc
{
#ifdef _FoldBeep
	if (_beepSound) AudioServicesDisposeSystemSoundID(_beepSound);
#endif
	[self removeFoldView];
	[_foldIndicator release];
	[_image release];
	[_image_ release];
	[super dealloc];
}

//
- (void)foldBegan
{
	CGRect frame = _contentView.frame;
	_contentView.hidden = NO;
	_foldView = [[FoldViews alloc] initWithFrame:frame andImage:_contentView.screenshot withNumberOfFolds:3];
	_contentView.hidden = YES;
	_foldView.clipsToBounds = YES;
	_foldView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self insertSubview:_foldView belowSubview:_foldButton];
	
	[_foldButton setImage:_image_ forState:UIControlStateNormal];

	if (!_touchMask)
	{
		_touchMask = [[UIControl alloc] initWithFrame:self.superview.bounds];
		_touchMask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.42];
		_touchMask.alpha = 0;
		[self.superview insertSubview:_touchMask belowSubview:self];
		[_touchMask addTarget:self action:@selector(touchMaskClicked:) forControlEvents:UIControlEventTouchDown];
	}

	if ([_delegate respondsToSelector:@selector(foldPaneFoldBegin:)])
	{
		[_delegate foldPaneFoldBegin:self];
	}
	[_delegate retain];
}

//
- (void)foldEnded:(BOOL)open
{	
	_contentView.hidden = NO;
	[self removeFoldView];
#ifdef _FoldBeep
	if (_beepSound)
	{
		AudioServicesPlaySystemSound(_beepSound);
	}
#endif
	
	_open = open;
	if (!open)
	{
		[_foldButton setImage:_image forState:UIControlStateNormal];
		[_touchMask removeFromSuperview];
		[_touchMask release];
		_touchMask = nil;
	}

	if ([_delegate respondsToSelector:@selector(foldPaneFoldEnded:)])
	{
		[_delegate foldPaneFoldEnded:self];
	}
	[_delegate release];
	
	[_timer invalidate];
	_timer = nil;
}

//
- (void)autoFold:(NSTimer *)sender
{
	CGRect frame = self.frame;
	
	CGFloat delta = [sender.userInfo floatValue];
	if (delta > 0)
	{
		CGFloat y = self.superview.frame.size.height - _foldButton.frame.size.height;
		if (frame.origin.y + delta < y)
		{
			frame.origin.y += delta;
		}
		else
		{
			frame.origin.y = y;
			[self foldEnded:NO];
		}
	}
	else if (delta < 0)
	{
		CGFloat y = self.superview.frame.size.height - frame.size.height;
		if (frame.origin.y + delta > y)
		{
			frame.origin.y += delta;
		}
		else
		{
			frame.origin.y = y;
			[self foldEnded:YES];
		}
	}
	else
	{
		[self foldEnded:(frame.origin.y < self.superview.frame.size.height - _foldButton.frame.size.height)];
	}
	self.frame = frame;
}

//
- (void)touchMaskClicked:(UIControl *)sender
{
	if (_foldView == nil)
	{
		[self togglePane:sender];
	}
}

//
- (void)togglePane:(id)sender
{
	if (_timer) return;
	
	CGRect frame = self.frame;
	BOOL fold = frame.origin.y > self.superview.frame.size.height - (frame.size.height * (_open ? 7 : 2) / 8);
	if (sender)
	{
		fold = !fold;
		[self foldBegan];
	}

	const NSUInteger times = 0.4 / 0.02;
	
	CGFloat y = fold ? (self.superview.frame.size.height - _foldButton.frame.size.height) : (self.superview.frame.size.height - frame.size.height);
	CGFloat delta = (y - frame.origin.y) / times;
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(autoFold:) userInfo:[NSNumber numberWithFloat:delta] repeats:YES];
}

//
- (void)panPane:(UIPanGestureRecognizer *)gesture
{
	if (_timer) return;
	
	if (_foldView == nil)
	{
		if (gesture.state == UIGestureRecognizerStateBegan)
		{
			[self foldBegan];
		}
		return;
	}
	
	if (gesture.state == UIGestureRecognizerStateChanged)
	{
		CGPoint translation = [gesture translationInView:self];
		{
			CGRect frame = self.frame;
			
			frame.origin.y += translation.y;
			if ((frame.origin.y <= self.superview.frame.size.height - _foldButton.frame.size.height) &&
				(frame.origin.y >= self.superview.frame.size.height - frame.size.height))
			{
				self.frame = frame;
			}
		}
		[gesture setTranslation:CGPointZero inView:self.superview];
	}
	else //if ((gesture.state == UIGestureRecognizerStateEnded) || (gesture.state == UIGestureRecognizerStateCancelled))
	{
		[self togglePane:nil];
	}
}

//
- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];

	CGRect foldFrame = _foldView.frame;
	foldFrame.size.height = self.superview.frame.size.height - frame.origin.y - _foldButton.frame.size.height;
	_foldView.frame = foldFrame;

	CGFloat alpha = _touchMask.alpha = (foldFrame.size.height / (frame.size.height - _foldButton.frame.size.height));

	_foldIndicator.transform = CGAffineTransformMakeRotation((M_PI / 180.0) * (180 * alpha));
}

@end
