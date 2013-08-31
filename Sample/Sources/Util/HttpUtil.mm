
#import "NSUtil.h"
#import "UIUtil.h"
#import "HttpUtil.h"

//
NSData *HttpUtil::DownloadData(NSString *url, NSString *to, DownloadMode mode)
{
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
NSData *HttpUtil::HttpData(NSString *url, NSData *post, NSURLRequestCachePolicy cachePolicy, NSURLResponse **response, NSError **error)
{
	//UIUtil::ShowNetworkIndicator(YES);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]cachePolicy:cachePolicy timeoutInterval:30];
	if (post)
	{
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:post];
	}
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
	
	//UIUtil::ShowNetworkIndicator(NO);
	return data;
}

// Request HTTP string
NSString *HttpUtil::HttpString(NSString *url, NSString *post)
{
	NSData *send = post ? [NSData dataWithBytes:[post UTF8String] length:[post length]] : nil;
	NSData *recv = HttpData(url, send);
	return recv ? [[[NSString alloc] initWithData:recv encoding:NSUTF8StringEncoding] autorelease] : nil;
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
		[data release];
	}
	
	UIUtil::ShowNetworkIndicator(NO);
	
	return data ? nil : error.localizedDescription;
}

//
NSData *HttpUtil::UploadData(NSString *url, NSData *data, NSString *fileName, NSString *mimeType, NSHTTPURLResponse **response)
{
	NSURL *URL = [NSURL URLWithString:url];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
	request.timeoutInterval = 60;
	
	// Just some random text that will never occur in the body
	NSString *boundaryString = @"----HttpUploadDataBoundary";
	NSMutableData *formData = [NSMutableData data];
	
	//
	NSMutableString *formString = [NSMutableString string];
	[formString appendFormat:@"--%@\r\n", boundaryString];
	[formString appendFormat:@"Content-Disposition: form-data; name=\"upload\"; filename=\"%@\"\r\n", fileName];
	[formString appendFormat:@"Content-Type: %@\r\n\r\n", mimeType];
	
	[formData appendData:[formString dataUsingEncoding:NSUTF8StringEncoding]];
	[formData appendData:data];
	
	//
	formString = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundaryString];
	[formData appendData:[formString dataUsingEncoding:NSUTF8StringEncoding]];
	
	//
	NSString *contentLength = [NSString stringWithFormat:@"%u", formData.length];
	NSString *contentType = [@"multipart/form-data; boundary=" stringByAppendingString:boundaryString];
	[request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	request.HTTPMethod = @"POST";
	request.HTTPBody = formData;
	
	//
	return [NSURLConnection sendSynchronousRequest:request returningResponse:response error:nil];
}
