
//
#ifndef _BaseViewController
#define _BaseViewController UIViewController
#endif
@interface WebController : _BaseViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
	NSURL *_URL;
	UIWebView *_webView;
	NSUInteger _loading;
	UIBarButtonItem *_rightButton;
}

@property(nonatomic,retain) NSURL *URL;
@property(nonatomic,retain) NSString *url;
@property(nonatomic,assign) NSString *HTML;
@property(nonatomic,readonly) UIWebView *webView;

- (id)initWithURL:(NSURL *)URL;
- (id)initWithUrl:(NSString *)url;
- (id)initWithHTML:(NSString *)HTML;
- (void)loadHTML:(NSString *)HTML baseURL:(NSURL *)baseURL;

@end


//
@interface WebBrowser : WebController
{
	BOOL _toolBarHidden;
}

@end
