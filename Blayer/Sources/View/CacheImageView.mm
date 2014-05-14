
#import "NSUtil.h"
#import "HttpUtil.h"
#import "CacheImageView.h"


@implementation UIView (CacheImage)


//
- (void)setCacheImageUrl:(NSString *)cacheImageUrl
{
#ifdef _SizingImageUrl
	CGRect frame = self.frame;
	cacheImageUrl = _SizingImageUrl(cacheImageUrl, frame.size.width, frame.size.height);
#endif
	
	NSString *path = NSUtil::CacheUrlPath(cacheImageUrl);
	UIImage *image = [UIImage imageWithContentsOfFile:path];
	[(id<CacheImageProtocol>)self setImage:image];
	if (image == nil)
	{
#ifdef _CacheImageShowingWithIndicator
		[self showActivityIndicator:YES];
#endif
#ifdef _CacheDefaultImage
		[(id<CacheImageProtocol>)self setImage:_CacheDefaultImage];
#endif
		if ([self respondsToSelector:@selector(setCacheImageUrl2:)])
		{
			[(id<CacheImageProtocol>)self setCacheImageUrl2:cacheImageUrl];
		}
		[self performSelectorInBackground:@selector(cacheImageDownloading:) withObject:cacheImageUrl];
	}
}

//
- (void)cacheImageDownloading:(NSString *)cacheImageUrl
{
	@autoreleasepool
	{
		_Log(@"cacheImageDownloading %@", cacheImageUrl);
		NSString *path = NSUtil::CacheUrlPath(cacheImageUrl);
		NSData *data = HttpUtil::DownloadData(cacheImageUrl, path, DownloadFromOnline);
		UIImage *image = data ? [UIImage imageWithData:data] : nil;
		
		if ([self respondsToSelector:@selector(cacheImageDownloaded2:)])
		{
			NSArray *params = [NSArray arrayWithObjects:cacheImageUrl, image, nil];
			[self performSelectorOnMainThread:@selector(cacheImageDownloaded2:) withObject:params waitUntilDone:YES];
		}
		else
		{
			[self performSelectorOnMainThread:@selector(cacheImageDownloaded:) withObject:image waitUntilDone:YES];
		}
	}
}

//
- (void)cacheImageDownloaded:(UIImage *)image
{
#ifdef _CacheImageShowingWithIndicator
	[self showActivityIndicator:NO];
#endif
	if (image)
	{
		[(id<CacheImageProtocol>)self setImage:image];
		
		//CGFloat alpha = self.alpha;
		//self.alpha = 0;
#ifdef _CacheImageShowingWithAnimation
		CGRect frame = self.frame;
		self.frame = CGRectMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2, 0, 0);
		[UIView animateWithDuration:0.5 animations:^()
		 {
			 //self.alpha = alpha;
			 self.frame = frame;
		 }];
#endif
	}
}

@end


//
@implementation CacheImageButton
- (void)setImage:(UIImage *)image
{
	[self setImage:image forState:UIControlStateNormal];
}
@end


//
@implementation CacheBackgroundImageButton
- (void)setImage:(UIImage *)image
{
	[self setBackgroundImage:image forState:UIControlStateNormal];
}
@end


//
@implementation CacheImageView
- (void)cacheImageDownloaded2:(NSArray *)params
{
	NSString *cacheImageUrl2 = params[0];
	if (cacheImageUrl2 == _cacheImageUrl2)
	{
		UIImage *image = (params.count > 1) ? params[1] : nil;
		[self cacheImageDownloaded:image];
	}
}
@end
