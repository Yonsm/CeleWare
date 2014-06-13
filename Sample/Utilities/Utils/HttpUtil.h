
#import <Foundation/Foundation.h>

//
enum DownloadMode
{
	DownloadFromLocal,		// Load from local cache only
	DownloadFromOnline,		// Download from online (and cache it)
	DownloadCheckLocal,		// Check local cache: DownloadFromLocal on existing; DownloadFromOnline otherwise.
	DownloadCheckOnline,	// Check online update: DownloadFromOnline on updating; DownloadFromLocal otherwize.
};


//
class HttpUtil
{
public:
	// Download data from local or online
	static NSData *DownloadData(NSString *url, NSString *to, DownloadMode mode = DownloadCheckOnline);

public:
	// Request HTTP data
	static NSData *HttpData(NSString *url, NSData *post = nil, NSURLRequestCachePolicy cachePolicy = NSURLRequestReloadIgnoringCacheData, NSURLResponse **response = nil, NSError **error = nil, NSString *contentType = nil);

	// Upload HTTP multipart
	static NSData *HttpUpload(NSString *url, NSArray *multipart, NSURLRequestCachePolicy cachePolicy, NSURLResponse **response, NSError **error);

	// Request HTTP string
	static NSString *HttpString(NSString *url, NSString *post = nil);
	
	// Request HTTP JSON
	static id HttpJSON(NSString *url, NSString *post = nil, NSJSONReadingOptions options = 0);
	
	// Request HTTP file
	// Return error string, or nil on success
	static NSString *HttpFile(NSString *url, NSString *path);

public:
	// Upload HTTP data as multipart
	NS_INLINE NSData *HttpUpload(NSString *url, NSData *data, NSString *mine = @"application/octet-stream", NSString *name = @"UPLOAD", NSString *file = @"UPLOAD", NSURLRequestCachePolicy cachePolicy = NSURLRequestReloadIgnoringCacheData, NSURLResponse **response = nil, NSError **error = nil)
	{
		return HttpUpload(url, @[@{@"name":name, @"file":file, @"mine":mine, @"data":data}], cachePolicy, response, error);
	}
	
	// Upload HTTP Image as multipart
	NS_INLINE NSData *HttpUpload(NSString *url, UIImage *image, NSString *name = @"IMAGE", NSString *file = @"IMAGE.JPG", NSURLRequestCachePolicy cachePolicy = NSURLRequestReloadIgnoringCacheData, NSURLResponse **response = nil, NSError **error = nil)
	{
		return HttpUpload(url, UIImageJPEGRepresentation(image, 0.75), @"image/jpeg", name, file, cachePolicy, response, error);
	}
};
