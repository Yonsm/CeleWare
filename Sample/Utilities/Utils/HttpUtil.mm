
#import "NSUtil.h"
#import "UIUtil.h"
#import "HttpUtil.h"

#ifdef TEST
@implementation NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
	return YES;
}
@end
#endif

//
NSData *HttpUtil::DownloadData(NSString *url, NSString *to, DownloadMode mode)
{
	if (url == nil) return nil;
	
	if ((mode == DownloadFromLocal) || ((mode == DownloadCheckLocal) && NSUtil::IsFileExist(to)))
	{
		return [NSData dataWithContentsOfFile:to];
	}
	
	//UIUtil::ShowNetworkIndicator(YES);
	NSError *error = nil;
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:((mode == DownloadCheckOnline) ? 0 : NSUncachedRead) error:&error];
	[data writeToFile:to atomically:NO];
	//UIUtil::ShowNetworkIndicator(NO);
	return data;
}

// Request HTTP data
NSData *HttpUtil::HttpData(NSString *url, NSData *post, NSURLRequestCachePolicy cachePolicy, NSURLResponse **response, NSError **error, NSString *contentType)
{
	//UIUtil::ShowNetworkIndicator(YES);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]cachePolicy:cachePolicy timeoutInterval:30];
	if (post)
	{
		request.HTTPMethod =@"POST";
		request.HTTPBody = post;
		if (contentType) [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	}
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
	
	//UIUtil::ShowNetworkIndicator(NO);
	return data;
}

//
NSData *HttpUtil::HttpUpload(NSString *url, NSArray *multipart, NSURLRequestCachePolicy cachePolicy, NSURLResponse **response, NSError **error)
{
	NSMutableData *post = [NSMutableData data];
	NSString *boundary = @"---FORM-BOUNDARY---";
	for (NSDictionary *part in multipart)
	{
		if (part[@"data"])
		{
			NSMutableString *header = [NSMutableString stringWithFormat:@"--%@\r\n", boundary];
			[header appendString:@"Content-Disposition: form-data"];
			if (part[@"name"]) [header appendFormat:@"; name=\"%@\"", part[@"name"]];
			if (part[@"file"]) [header appendFormat:@"; filename=\"%@\"", part[@"file"]];
			[header appendString:@"\r\n"];
			if (part[@"mine"]) [header appendFormat:@"Content-Type: %@\r\n", part[@"mine"]];
			[header appendString:@"\r\n"];

			[post appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
			[post appendData:part[@"data"]];
			[post appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	NSString *footer = [NSString stringWithFormat:@"--%@--\r\n", boundary];
	[post appendData:[footer dataUsingEncoding:NSUTF8StringEncoding]];
	
	return HttpData(url, post, cachePolicy, response, error, [@"multipart/form-data; boundary=" stringByAppendingString:boundary]);
}

// Request HTTP string
NSString *HttpUtil::HttpString(NSString *url, NSString *post)
{
	NSData *send = post ? [NSData dataWithBytes:[post UTF8String] length:[post length]] : nil;
	NSData *recv = HttpData(url, send);
	return recv ? [[NSString alloc] initWithData:recv encoding:NSUTF8StringEncoding] : nil;
}

//
id HttpUtil::HttpJSON(NSString *url, NSString *post, NSJSONReadingOptions options)
{
	NSError *error = nil;
	NSURLResponse *response = nil;
	_Log(@"curl %@ -d \"%@\"", url, post);
	NSData *data = HttpUtil::HttpData(url, [post dataUsingEncoding:NSUTF8StringEncoding], NSURLRequestReloadIgnoringCacheData, &response, &error);
	if (data)
	{
		id dict = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
		if (dict == nil)
		{
			_Log(@"Data: %@\n\n Error: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error);
		}
		return dict;
	}
	return nil;
}

// Request HTTP file
// Return error string, or nil on success
NSString *HttpUtil::HttpFile(NSString *url, NSString *path)
{
	UIUtil::ShowNetworkIndicator(YES);
	
	NSError *error = nil;
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url] options:NSUncachedRead error:&error];
	if (data != nil)
	{
		[data writeToFile:path atomically:NO];
	}
	
	UIUtil::ShowNetworkIndicator(NO);
	
	return data ? nil : error.localizedDescription;
}
