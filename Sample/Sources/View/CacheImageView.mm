
#import "NSUtil.h"
#import "HttpUtil.h"
#import "CacheImageView.h"


@implementation UIView (CacheImage)


//
- (void)setCacheImageUrl:(NSString *)cacheImageUrl
{
	NSString *path = NSUtil::CacheUrlPath(cacheImageUrl);
	UIImage *image = [UIImage imageWithContentsOfFile:path];
	if (image == nil)
	{
		[self showActivityIndicator:YES];
		[self performSelectorInBackground:@selector(cacheImageDownloading:) withObject:cacheImageUrl];
	}
	else if ([self respondsToSelector:@selector(setImage:)])
	{
		// TODO: Check no display image
		[self performSelector:@selector(setImage:) withObject:image];
	}
}

//
- (void)cacheImageDownloading:(NSString *)cacheImageUrl
{
	@autoreleasepool
	{
		NSString *path = NSUtil::CacheUrlPath(cacheImageUrl);
		NSData *data = HttpUtil::DownloadData(cacheImageUrl, path, DownloadFromOnline);
		UIImage *image = [UIImage imageWithData:data];
		[self performSelectorOnMainThread:@selector(cacheImageDownloaded:) withObject:image waitUntilDone:YES];
	}
}

//
- (void)cacheImageDownloaded:(UIImage *)image
{
	[self showActivityIndicator:NO];
	if (image)
	{
		if ([self respondsToSelector:@selector(setImage:)])
		{
			[self performSelector:@selector(setImage:) withObject:image];
			
			//CGFloat alpha = self.alpha;
			//self.alpha = 0;
			CGRect frame = self.frame;
			self.frame = CGRectMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2, 0, 0);
			[UIView animateWithDuration:0.5 animations:^()
			 {
				 //self.alpha = alpha;
				 self.frame = frame;
			 }];
		}
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

