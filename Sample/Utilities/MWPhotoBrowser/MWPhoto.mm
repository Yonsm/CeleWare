//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

// Private
@interface MWPhoto () {

	// Image Sources
	NSString *_photoPath;
	NSString *_photoUrl;

	// Image
	UIImage *_underlyingImage;

	// Other
	NSString *_caption;
	BOOL _loadingInProgress;
		
}

// Properties
@property (nonatomic, retain) UIImage *underlyingImage;

// Methods
- (void)imageDidFinishLoadingSoDecompress;
- (void)imageLoadingComplete;

@end

// MWPhoto
@implementation MWPhoto

// Properties
@synthesize underlyingImage = _underlyingImage, 
caption = _caption;

#pragma mark Class Methods

+ (MWPhoto *)photoWithImage:(UIImage *)image {
	return [[MWPhoto alloc] initWithImage:image];
}

+ (MWPhoto *)photoWithFilePath:(NSString *)path {
	return [[MWPhoto alloc] initWithFilePath:path];
}

+ (MWPhoto *)photoWithUrl:(NSString *)url {
	return [[MWPhoto alloc] initWithUrl:url];
}

#pragma mark NSObject

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
		self.underlyingImage = image;
	}
	return self;
}

- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
		_photoPath = [path copy];
	}
	return self;
}

- (id)initWithUrl:(NSString *)url {
	if ((self = [super init])) {
		_photoUrl = [url copy];
	}
	return self;
}

#pragma mark MWPhoto Protocol Methods

- (UIImage *)underlyingImage {
	return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify
{
	NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
	_loadingInProgress = YES;
	if (self.underlyingImage)
	{
		// Image already loaded
		[self imageLoadingComplete];
	} else {
		if (_photoPath)
		{
			// Load async from file
			[self performSelectorInBackground:@selector(loadImageFromFileAsync) withObject:nil];
		}
		else if (_photoUrl)
		{
			// Load async from web
			NSString *path = NSUtil::CacheUrlPath(_photoUrl);
			UIImage *cachedImage = [UIImage imageWithContentsOfFile:path];
			if (cachedImage)
			{
				// Use the cached image immediatly
				self.underlyingImage = cachedImage;
				[self imageDidFinishLoadingSoDecompress];
			}
			else
			{
				// Start an async download
				[self performSelectorInBackground:@selector(cacheImageDownloading:) withObject:_photoUrl];
			}
		}
		else
		{
			// Failed - no source
			self.underlyingImage = nil;
			[self imageLoadingComplete];
		}
	}
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
	_loadingInProgress = NO;
	if (self.underlyingImage && (_photoPath || _photoUrl)) {
		self.underlyingImage = nil;
	}
}

#pragma mark - Async Loading

// Called in background
// Load image in background from local file
- (void)loadImageFromFileAsync {
	@autoreleasepool {
	@try {
		NSError *error = nil;
		NSData *data = [NSData dataWithContentsOfFile:_photoPath options:NSDataReadingUncached error:&error];
		if (!error) {
			self.underlyingImage = [[UIImage alloc] initWithData:data];
		} else {
			self.underlyingImage = nil;
			MWLog(@"Photo from file error: %@", error);
		}
	} @catch (NSException *exception) {
	} @finally {
		[self performSelectorOnMainThread:@selector(imageDidFinishLoadingSoDecompress) withObject:nil waitUntilDone:NO];
	}
	}
}

// Called on main
- (void)imageDidFinishLoadingSoDecompress {
	if (self.underlyingImage)
	{
#ifdef _DecodingAsync
		// Decode image async to avoid lagging when UIKit lazy loads
		[[SDWebImageDecoder sharedImageDecoder] decodeImage:self.underlyingImage withDelegate:self userInfo:nil];
#else
		[self performSelector:@selector(imageLoadingComplete) withObject:nil afterDelay:0.1];
#endif
	}
	else
	{
		// Failed
		[self imageLoadingComplete];
	}
}

- (void)imageLoadingComplete {
	NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
	// Complete so notify
	_loadingInProgress = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
														object:self];
}

#pragma mark Downloading methods

//
- (void)cacheImageDownloading:(NSString *)cacheImageUrl
{
	@autoreleasepool
	{
		_Log(@"cacheImageDownloading %@", cacheImageUrl);
		NSString *path = NSUtil::CacheUrlPath(cacheImageUrl);
		NSData *data = HttpUtil::DownloadData(cacheImageUrl, path, DownloadFromOnline);
		UIImage *image = [UIImage imageWithData:data];
		[self performSelectorOnMainThread:@selector(cacheImageDownloaded:) withObject:image waitUntilDone:YES];
	}
}

//
- (void)cacheImageDownloaded:(UIImage *)image
{
	self.underlyingImage = image;
	[self imageDidFinishLoadingSoDecompress];
}

// Called on main
- (void)imageDecoder:(SDWebImageDecoder *)decoder didFinishDecodingImage:(UIImage *)image userInfo:(NSDictionary *)userInfo {
	// Finished compression so we're complete
	self.underlyingImage = image;
	[self imageLoadingComplete];
}

@end
