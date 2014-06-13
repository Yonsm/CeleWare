
#import "UIUtil.h"
#import "WebController.h"

@implementation WebController

#pragma mark Generic methods

// Contructor
- (id)initWithURL:(NSURL *)URL
{
	self = [super init];
	self.URL = URL;
	return self;
}

//
- (id)initWithHTML:(NSString *)HTML
{
	self = [super init];
	self.HTML = HTML;
	return self;
}

// Contructor
- (id)initWithUrl:(NSString *)url
{
	return [self initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

// Destructor
- (void)dealloc
{
	if (_loading) UIUtil::ShowNetworkIndicator(NO);
}

//
- (UIWebView *)webView
{
	[self view];
	return _webView;
}

//
- (NSString *)url
{
	return self.URL.absoluteString;
}

//
- (void)setUrl:(NSString *)url
{
	self.URL = [NSURL URLWithString:url];
}

//
- (void)setURL:(NSURL *)URL
{
	if (URL != _URL)
	{
		_URL = URL;
	}
	if (URL) [self.webView loadRequest:[NSURLRequest requestWithURL:_URL]];
}

//
- (NSString *)HTML
{
	return [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
}

//
- (void)setHTML:(NSString *)HTML
{
	[self.webView loadHTMLString:HTML baseURL:nil];
}

//
- (void)loadHTML:(NSString *)HTML baseURL:(NSURL *)baseURL
{
	[self.webView loadHTMLString:HTML baseURL:baseURL];
}


#pragma mark View methods

//
- (void)loadView
{
	[super loadView];
	
	_webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_webView.scalesPageToFit = YES;
	_webView.delegate = self;
	[self.view addSubview:_webView];
}

// Do additional setup after loading the view.
//- (void)viewDidLoad
//{
//	[super viewDidLoad];
//
//	//self.URL = _URL;
//}

// Override to allow rotation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark -
#pragma mark Web view delegate

//
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	_Log(@"shouldStartLoadWithRequest %d: <url:%@>", (int)navigationType, request.URL);
	if ([request.URL.scheme isEqualToString:@"close"])
	{
		if (self.navigationController && ([self.navigationController.viewControllers objectAtIndex:0] != self))
		{
			[self.navigationController popViewControllerAnimated:YES];
		}
		else
		{
			[self dismissViewControllerAnimated:YES completion:nil];
		}
		return NO;
	}
	return YES;
}

//
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	if (_loading++ == 0) UIUtil::ShowNetworkIndicator(YES);
	self.title = NSLocalizedString(@"Loading...", @"加载中⋯");
	
	_rightButton = self.navigationItem.rightBarButtonItem;

	UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:indicator];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	[indicator startAnimating];
}

//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if (_loading != 0) _loading--;
	if (_loading == 0) UIUtil::ShowNetworkIndicator(NO);
	self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	[self.navigationItem setRightBarButtonItem:_rightButton animated:YES];
	
	_rightButton = nil;
}

//
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self webViewDidFinishLoad:webView];
	if (error.code != -999)
	{
#ifdef _WebViewInlineError
		NSString *string = [NSString stringWithFormat:
							@"<head>"
							@"<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"/>"
							@"<title>%@</title>"
							@"<head>"
							@"<body>%@</body>", 
							NSLocalizedString(@"Error", @"错误"),
							error.localizedDescription];
		
		[((UIWebView *)self.view) loadHTMLString:string baseURL:nil];
#else
		UIUtil::ShowAlert(NSLocalizedString(@"Error", @"错误"), error.localizedDescription);
#endif
	}
}


@end


@implementation WebBrowser


#pragma mark Generic methods

#pragma mark View methods

// Do additional setup after loading the view.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
//	CGRect frame = self.webView.frame;
//	frame.size.height -= 44;
//	self.webView.frame = frame;
//	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;

	// Create toolbar
	const static struct {void* title; SEL action;} c_buttons[] =
	{
		{(void *)UIBarButtonSystemItemRefresh, @selector(reload)},
		{(void *)@"BackwardIcon.png", @selector(goBack)},
		{(void *)@"ForwardIcon.png", @selector(goForward)},
		{(void *)UIBarButtonSystemItemAction, @selector(actionButtonClicked:)},
	};
	
	NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:3 * sizeof(c_buttons)/sizeof(c_buttons[0])];
	for (NSUInteger i = 0; i < sizeof(c_buttons) / sizeof(c_buttons[0]); ++i)
	{
		UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[buttons addObject:space];
		
		id target = ((NSUInteger)c_buttons[i].title == UIBarButtonSystemItemAction) ? (id)self : (id)self.webView;
		UIBarButtonItem *button;
		if ((NSUInteger)c_buttons[i].title < 256) 
		{
			button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItem)(NSUInteger)c_buttons[i].title  target:target action:c_buttons[i].action];
		}
		else
		{
			button = [[UIBarButtonItem alloc] initWithImage:UIUtil::ImageNamed((__bridge NSString *)c_buttons[i].title) style:UIBarButtonItemStylePlain target:target action:c_buttons[i].action];
		}
		[buttons addObject:button];

		UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[buttons addObject:space2];
	}	
	
	self.toolbarItems = buttons;
}

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	_toolBarHidden = self.navigationController.toolbarHidden;
	[self.navigationController setToolbarHidden:NO animated:YES];
}

// Called after the view was dismissed, covered or otherwise hidden.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.navigationController setToolbarHidden:_toolBarHidden animated:YES];
}


#pragma mark -
#pragma mark Web view delegate

//
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[super webViewDidStartLoad:webView];
	
	UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self.webView action:@selector(stopLoading)];

	NSMutableArray *buttons = [NSMutableArray arrayWithArray:self.toolbarItems];
	[buttons replaceObjectAtIndex:(0 * 3 + 1) withObject:stopButton];
	((UIBarButtonItem *)[buttons objectAtIndex:1 * 3 + 1]).enabled = NO;
	((UIBarButtonItem *)[buttons objectAtIndex:2 * 3 + 1]).enabled = NO;
	[self setToolbarItems:buttons animated:YES];
}

//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[super webViewDidFinishLoad:webView];
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)];
	NSMutableArray *buttons = [NSMutableArray arrayWithArray:self.toolbarItems];
	[buttons replaceObjectAtIndex:(0 * 3 + 1) withObject:refreshButton];
	((UIBarButtonItem *)[buttons objectAtIndex:1 * 3 + 1]).enabled = self.webView.canGoBack;
	((UIBarButtonItem *)[buttons objectAtIndex:2 * 3 + 1]).enabled = self.webView.canGoForward;
	[self setToolbarItems:buttons animated:YES];
}


#pragma mark Event methods

//
- (void)actionButtonClicked:(UIBarButtonItem *)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Share", @"分享")
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
											   destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"Open with Safari", @"在 Safari 中打开")/*, NSLocalizedString(@"Send via Email", @"发送邮件链接")*/, nil];
	[actionSheet showFromBarButtonItem:sender animated:YES];
}


#pragma mark Action sheet delegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		NSString *URL = [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
	}
}

@end
