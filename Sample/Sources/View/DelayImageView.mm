
#import "NSUtil.h"
#import "HttpUtil.h"
#import "DelayImageView.h"


//
@implementation DelayImageView
@synthesize url=_url;
@synthesize def=_def;
@synthesize loaded=_loaded;

//
- (void)stopAnimating
{
	[_activityView stopAnimating];
	[_activityView removeFromSuperview];
	_activityView = nil;
}

//
- (void)startAnimating
{
	[self stopAnimating];
	
	_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	_activityView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
	_activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	[self addSubview:_activityView];
	[_activityView startAnimating];
}

//
- (void)downloading
{
	@autoreleasepool {
	
		NSString *path = NSUtil::CacheUrlPath(_url);
		NSData *data = HttpUtil::DownloadData(_url, path, _force ? DownloadFromOnline : DownloadCheckLocal /*DownloadCheckOnline*/);
		[self performSelectorOnMainThread:@selector(downloaded:) withObject:data waitUntilDone:YES];
	}
}

//
- (void)downloaded:(NSData *)data
{
	self.image = [UIImage imageWithData:data];
	
	if (self.image)
	{
		CGFloat alpha = self.alpha;
		self.alpha = 0;
		[UIView animateWithDuration:0.5 animations:^()
		 {
			 self.alpha = alpha;
		 }];
	}
	
	if (self.image || _force)
	{
		[self stopAnimating];
		if (self.image == nil)
		{
			if (_def)
			{
				self.image = UIUtil::ImageNamed(_def);
			}
		}
		else
		{
			_loaded = YES;
		}
	}
	else
	{
		_force = YES;
		[self performSelectorInBackground:@selector(downloading) withObject:nil];
	}
}

//
- (void)setUrl:(NSString *)url
{
	
	_force = NO;
	self.image = nil;
	if (url)
	{
		_url = url;
		
		NSString *path = NSUtil::CacheUrlPath(_url);
		self.image = [UIImage imageWithContentsOfFile:path];
		if (self.image == nil)
		{
			_loaded = NO;
			if (_def) self.image = UIUtil::ImageNamed(_def);
			[self startAnimating];
			[self performSelectorInBackground:@selector(downloading) withObject:nil];
		}
		else
		{
			_loaded = YES;
		}
	}
	else
	{
		_url = nil;
	}
}

//
#ifdef _AnimatingSetImageInDelayImageView
- (void)setImage:(UIImage *)image
{
	[super setImage:image];
	if (image)
	{
		CGFloat alpha = self.alpha;
		self.alpha = 0;
		[UIView animateWithDuration:0.5 animations:^()
		 {
			 self.alpha = alpha;
		 }];
	}
}
#endif

//
- (id)initWithUrl:(NSString *)url frame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	self.url = url;
	return self;
}

//

@end
