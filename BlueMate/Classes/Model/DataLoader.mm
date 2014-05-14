

#import "DataLoader.h"
#import "LoginController.h"

//
@interface ErrorAlertView : UIAlertView
@property(nonatomic,strong) DataLoader *loader;
@property(nonatomic,strong) id<DataLoaderDelegate> loader_delegate;
+ (id)alertWithError:(NSString *)error loader:(DataLoader *)loader;
@end

@implementation ErrorAlertView

//
static ErrorAlertView *_alertView = nil;
+ (id)alertWithError:(NSString *)error loader:(DataLoader *)loader
{
	if (_alertView == nil)
	{
		_alertView = [[ErrorAlertView alloc] init];
		_alertView.title = error;
		_alertView.delegate = _alertView;
		if (loader.error == DataLoaderNoData || loader.error == DataLoaderNetworkError)
		{
			[_alertView addButtonWithTitle:@"取消"];
			[_alertView addButtonWithTitle:@"重试"];
		}
		else
		{
			[_alertView addButtonWithTitle:@"确定"];
		}
		_alertView.loader = loader;
		_alertView.loader_delegate = loader.delegate;
		//[_alertView show];
	}
	return _alertView;
}

//
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[_loader loadBegin];
		_loader_delegate = nil;
		_loader = nil;
	}
//	else if (_loader.error == DataLoaderProfileIncomplete)
//	{
//		UIViewController *controller = [[BasicProfileController alloc] init];
//		[UIUtil::RootViewController() presentNavigationController:controller animated:YES];
//	}
	_alertView = nil;
}
@end


@implementation DataLoader

//
+ (void)loadWithService:(NSString *)service params:(id)params success:(void (^)(DataLoader *loader))success failure:(BOOL (^)(DataLoader *loader, NSString *error))failure
{
	DataLoader *loader = [DataLoader loaderWithService:service params:params completion:success];
	loader.completionOnSuccess = YES;
	loader.failure = failure;
	[loader loadBegin];
}

//
+ (void)loadWithService:(NSString *)service params:(id)params success:(void (^)(DataLoader *loader))success
{
	DataLoader *loader = [DataLoader loaderWithService:service params:params completion:success];
	loader.completionOnSuccess = YES;
	[loader loadBegin];
}

//
+ (void)loadWithService:(NSString *)service params:(id)params delegate:(id<DataLoaderDelegate>)delegate completion:(void (^)(DataLoader *loader))completion
{
	DataLoader *loader = [DataLoader loaderWithService:service params:params completion:completion];
	loader.delegate = delegate;
	[loader loadBegin];
}

//
+ (void)loadWithService:(NSString *)service params:(id)params showLoading:(BOOL)showLoading checkError:(BOOL)checkError completion:(void (^)(DataLoader *loader))completion
{
	DataLoader *loader = [DataLoader loaderWithService:service params:params completion:completion];
	loader.checkError = checkError;
	loader.showLoading = showLoading;
	[loader loadBegin];
}

//
+ (void)loadWithService:(NSString *)service params:(id)params completion:(void (^)(DataLoader *loader))completion
{
	[[DataLoader loaderWithService:service params:params completion:completion] loadBegin];
}

//
+ (id)loaderWithService:(NSString *)service params:(id)params completion:(void (^)(DataLoader *loader))completion
{
	DataLoader *loader = [[DataLoader alloc] init];
	loader.service = service;
	loader.params = params;
	loader.completion = completion;
	return loader;
}

#pragma mark Auth methods

static int _self_id = nil;
static NSString *_access_token = nil;
//
+ (int)self_id
{
	return _self_id;
}

//
+ (NSString *)access_token
{
	return _access_token;
}

//
+ (BOOL)isLogon
{
	return _access_token != nil;
}

//
+ (void)logout
{
	_self_id = nil;
	_access_token = nil;
	Settings::Save(kPassword);
	[[NSNotificationCenter defaultCenter] postNotificationName:kLogoutNotification object:nil];
}

//
+ (void)login
{
	[self logout];
	UIViewController *controller = [[LoginController alloc] init];
	UIUtil::PresentModalNavigationController(UIUtil::RootViewController(), controller);
}

//
+ (NSDictionary *)login:(NSString *)username password:(NSString *)password
{
	return nil;
}

#pragma mark Generic methods

// Constructor
- (id)init
{
	self = [super init];
	_checkError = YES;
	_showLoading = YES;
	return self;
}

//
- (void)clearData
{
	//self.service = nil;
	//self.params = nil;
	self.checkError = YES;
	self.checkChange = NO;
	self.dict = nil;
	self.date = nil;
	//self.error = DataLoaderNoData;
}

//
- (NSString *)stamp
{
	NSDate *date = self.date;
	NSString *stamp = date ? NSUtil::SmartDate(date, NSDateFormatterMediumStyle, NSDateFormatterShortStyle) : NSLocalizedString(@"Never", @"从未");
	return [NSString stringWithFormat:NSLocalizedString(@"Last Updated: %@", @"最近更新：%@"), stamp];
}

//
- (NSString *)errorString
{
	const static NSString *c_strings[] =
	{
		@"尚未初始化",
		@"数据无变化",
		@"数据服务错误",
		@"网络连接不给力啊",
		@"定位不成功\n请检查 系统设置->隐私->位置 中已经开启定位功能",
	};
	return (_error < _NumOf(c_strings)) ? (NSString *)c_strings[_error] : [NSString stringWithFormat:@"未知错误，代码：%d", _error];
}

#pragma mark Data loading methods

//
- (BOOL)loadBegin
{
	if (_loading) return NO;

	if ([_delegate respondsToSelector:@selector(loadBegan:)])
	{
		if (![_delegate loadBegan:self])
		{
			return NO;
		}
	}
	
	//
	_loading = YES;
	_retained_delegate = _delegate;
	[self loadStart];
	[self performSelectorInBackground:@selector(loadThread) withObject:nil];
	return YES;
}

//
- (void)loadStart
{
	UIUtil::ShowNetworkIndicator(YES);
	if (!_dict && _showLoading)
	{
		UIViewController *controller = [_delegate respondsToSelector:@selector(view)] ? (UIViewController *)_delegate : UIUtil::VisibleViewController();
		[controller.view toastWithLoading];
		_LogLine();
	}
}

//
- (void)loadThread
{
	@autoreleasepool
	{
		//[NSThread sleepForTimeInterval:5];
		
		id dict =[_delegate respondsToSelector:@selector(loadDoing:)] ? [_delegate loadDoing:self] : [self loadDoing];
		[self performSelectorOnMainThread:@selector(loadEnded:) withObject:dict waitUntilDone:YES];
	}
}

//
- (id)loadDoing
{
	// 登录
	if (_access_token == nil || _service == nil)
	{
		NSString *username = Settings::Get(kUsername);
		NSString *password = Settings::DecryptGet(kPassword);
		if (username && password)
		{
			NSDictionary *dict = [DataLoader login:username password:password];
			if ([dict isKindOfClass:[NSDictionary class]])
			{
				_error = (DataLoaderError)[dict[@"code"] intValue];
				if (_error == DataLoaderNoError)
				{
					_self_id = [dict[@"user"][@"userId"] intValue];
					_access_token = dict[@"access_token"];
					dict = [dict objectForKey:@"user"];
					if (_service == nil) return dict;
				}
				else
				{
					return dict;
				}
			}
			else
			{
				_error = DataLoaderNetworkError;
				return dict;
			}
		}
		else if (_service == nil)
		{
			_error = DataLoaderNoData;
			return nil;
		}
	}
	
	// 装载数据并解析
	NSDictionary *dict = nil;
	NSData *data = [self loadData];
	if (data)
	{
		dict = [self parseData:data];
		if ([dict isKindOfClass:[NSDictionary class]])
		{
			_error = (DataLoaderError)[dict[@"code"] intValue];
			if (_error == DataLoaderNoError)
			{
				dict = [dict objectForKey:@"data"];
				if (_checkChange && [_dict isEqualToDictionary:dict])
				{
					_error = DataLoaderNoChange;
				}
			}
		}
		else
		{
			_error = DataLoaderDataError;
		}
	}
	else
	{
		_error = DataLoaderNetworkError;
	}
	
	return dict;
}

//
- (NSData *)loadData
{
	NSString *access_token = _access_token ? [kAuthConsumerKey stringByAppendingString:_access_token] : kAuthConsumerKey;
	NSString *url = [NSString stringWithFormat:@"%@?access_token=%@", kServiceUrl(_service), access_token];
	return [_delegate respondsToSelector:@selector(loadData: url:)] ? [_delegate loadData:self url:url] : [self loadData:url];
}

//
- (NSData *)loadData:(NSString *)url
{
	NSError *error = nil;
	NSURLResponse *response = nil;
	id params = [_params isKindOfClass:[NSDictionary class]] ? NSUtil::URLQuery((NSDictionary *)_params) : _params;
	_Log(@"%@%@", url, params ? [@"&" stringByAppendingString:params] : @"");
	NSData *post = [params dataUsingEncoding:NSUTF8StringEncoding];
	NSData *data = HttpUtil::HttpData(url, post, NSURLRequestReloadIgnoringCacheData, &response, &error);
	if (data == nil)
	{
		_Log(@"Response: %@\n\nError: %@\n\n", response, error);
	}
	return data;
}

//
- (id)parseData:(NSData *)data
{
	NSError *error = nil;
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:_jsonOptions error:&error];
	if (dict == nil)
	{
		_Log(@"Data: %@\n\n Error: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error);
	}
	return dict;
}

//
- (void)loadEnded:(NSDictionary *)dict
{
	_loading = NO;
	if (_error == DataLoaderNoError)
	{
		self.dict = dict;
	}
	else if (_error == DataLoaderNotLogin/*NEXT:后置判断往前移动，弹出登录回来后继续Loading，同时增加needAuth前置处理*/)
	{
		[DataLoader login];
	}
	else if (_error == DataLoaderPasswordError)
	{
		[DataLoader logout];
	}
	else
	{
		_Log(@"%@: %d =>\n%@", (_error == DataLoaderNoChange) ? @"NOCHANGE" : @"ERROR", _error, dict);
	}
	
	[self loadStop:dict];
	
	//
	if ([_delegate respondsToSelector:@selector(loadEnded:)])
		[_delegate loadEnded:self];
	
	//
	if (_completion && (!_completionOnSuccess || _error == DataLoaderNoError))
	{
		_completion(self);
	}
	
	_retained_delegate = nil;
}

//
- (void)loadStop:(NSDictionary *)dict
{
	UIUtil::ShowNetworkIndicator(NO);
	if (_showLoading)
	{
		UIViewController *controller = [_delegate respondsToSelector:@selector(view)] ? (UIViewController *)_delegate : UIUtil::VisibleViewController();
		[controller.view dismissToast];
		_LogLine();
	}
	
	// 记住时间戳
	if ((_error == DataLoaderNoError) || (_error == DataLoaderNoChange))
	{
		self.date = [NSDate date];
	}
	else
	{
		// 处理错误
		StatEvent(@"error", (NSString *)[NSString stringWithFormat:@"%d", _error]);
		
		NSString *error = [dict objectForKey:@"info"];
		if (error.length == 0) error = self.errorString;
		
		[self loadError:error];
	}
}

//
- (void)loadError:(NSString *)error
{
	if (_failure)
	{
		if (!_failure(self, error))
		{
			return;
		}
	}
	if (_error == DataLoaderNotLogin)
	{
		[ToastView toastWithError:error];
	}
	else if (_checkError)
	{
		// 延迟是为了解决网络没连接时，下拉松开后，快速返回错误后弹框，点击后导致不能下拉
		// 同时也是为了解决要求登录时弹出 Toast 被遮住的问题
		[[ErrorAlertView alertWithError:error loader:self] performSelector:@selector(show) withObject:nil afterDelay:0.2];
	}
}

@end
