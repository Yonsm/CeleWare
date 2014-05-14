
#import "UIUtil.h"
#import "ShareComposer.h"


@implementation WeiboComposer

//
+ (id)composerWithBody:(NSString *)body pic:(NSString *)pic link:(NSString *)link
{
	NSString *uid = NSUtil::BundleInfo(@"WeiboAppUid");
	NSString *key = NSUtil::BundleInfo(@"WeiboAppKey");
	NSString *url = [NSString stringWithFormat:@"http://service.weibo.com/share/share.php?title=%@&url=%@&appkey=%@&pic=%@&ralateUid=%@",
					 
					 [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
					 (link ? [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @""), 
					 (key ? key : @""),
					 (pic ? [pic stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @""),
					 (uid ? uid : @"")
					 ];
	return [[WebController alloc] initWithUrl:url];	// Sure, we fake WebController as WeiboComposer:)
}

//
+ (id)composerWithBody:(NSString *)body
{
	NSString *uid = NSUtil::BundleInfo(@"WeiboAppUid");
	NSString *url = [NSString stringWithFormat:@"http://m.weibo.cn/u/%@?", (uid ? uid : @"")];
	WeiboComposer *composer = [[WeiboComposer alloc] initWithUrl:url];
	composer.body = body;
	return composer;
}

//

//
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	_Log(@"NAVI%d: %@", (int)navigationType, request.URL.absoluteString);
	if (_body && [request.URL.absoluteString hasSuffix:@"#publisher"])
	{
		_tryTimes = 0;
		[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showComposer:) userInfo:nil repeats:YES];
	}
	return YES;
}

//
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//	[super webViewDidFinishLoad:webView];
//}

//
- (void)showComposer:(NSTimer *)timer
{
	NSString *className = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName(\"content\")[0].className"];
	_LogObj(className);
	if ([className isEqualToString:@"J-textarea txt-publisher"])
	{
		NSString *js = [NSString stringWithFormat:@"document.getElementsByName(\"content\")[0].value = \"%@\";", _body];
		[self.webView stringByEvaluatingJavaScriptFromString:js];
		self.body = nil;
		[timer invalidate];
	}
	else if (_tryTimes++ > 10)
	{
		[timer invalidate];
	}
}

@end


@implementation FacebookComposer

//
+ (id)composerWithBody:(NSString *)body link:(NSString *)link
{
	FacebookComposer *composer = [[FacebookComposer alloc] initWithUrl:@"https://m.facebook.com"];
	composer.link = link;
	composer.body = body;
	return composer;
}

//

//
- (void)loadView
{
	[super loadView];
	self.webView.scalesPageToFit = NO;
}

//
//- (void)viewDidLoad
//{
//	[super viewDidLoad];
//}

//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
//{
//	_Log(@"NAVI%d: %@", navigationType, request.URL.absoluteString);
//	return YES;
//}

//
#ifdef _QUICK_SHARER
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[super webViewDidStartLoad:webView];
	
	if (_link && (_done == 0))
	{
		[self.webView stopLoading];
		self.url = [NSString stringWithFormat:@"https://www.facebook.com/sharer.php?u=%@&t=%@",
					[_link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
					[_body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		_done = 1;
	}
}
#endif

//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[super webViewDidFinishLoad:webView];
	
#ifdef _QUICK_SHARER
	if (_link)
	{
		if (_done == 1)
		{
			NSString *name = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName(\"message\")[0].name"];
			if ([name isEqualToString:@"message"])
			{
				// Fuck Facebook's developer param t is not responed, AND this code is not working also!
				NSString *js = [NSString stringWithFormat:@"document.getElementsByName(\"message\")[0].value = \"%@\"", _body];
				[webView stringByEvaluatingJavaScriptFromString:js];
				_done = 2;
			}
		}
	}
	else
#endif
		if (_done == 0)
		{
			NSString *sigil = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"button\")[0].getAttribute(\"data-sigil\")"];
			if ([sigil hasPrefix:@"show_composer"])
			{
				_done = 1;
				NSString *js = [NSString stringWithFormat:@"document.getElementsByTagName(\"button\")[0].click(); document.getElementsByName(\"status\")[0].value = \"%@\";", _link ? [_body stringByAppendingFormat:@" %@", _link] : _body];
				[webView stringByEvaluatingJavaScriptFromString:js];
			}
		}
}

@end


//
@implementation UIViewController (ShareComposer)

//
- (WeiboComposer *)composeWeibo:(NSString *)body pic:(NSString *)pic link:(NSString *)link
{
	WeiboComposer *composer = [WeiboComposer composerWithBody:body pic:pic link:link];
	UIUtil::PresentModalNavigationController(self, composer);
	return composer;
}

//
- (FacebookComposer *)composeFacebook:(NSString *)body link:(NSString *)link
{
	FacebookComposer *composer = [FacebookComposer composerWithBody:body link:link];
	UIUtil::PresentModalNavigationController(self, composer);
	return composer;
}

@end