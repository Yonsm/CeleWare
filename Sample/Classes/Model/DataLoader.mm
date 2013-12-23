

#import "DataLoader.h"
#import "LoginController.h"

@implementation DataLoader

//
+ (id)loaderWithService:(NSString *)service params:(NSDictionary *)params success:(void (^)(DataLoader *loader))success
{
	DataLoader *loader = [DataLoader loaderWithService:service params:params completion:success];
	loader.completionOnSuccess = YES;
	return loader;
}

//
+ (id)loaderWithService:(NSString *)service params:(NSDictionary *)params completion:(void (^)(DataLoader *loader))completion
{
	DataLoader *loader = [[[DataLoader alloc] init] autorelease];
	loader.service = service;
	loader.params = params;
	loader.completion = completion;
	[loader loadBegin];
	return loader;
}

#pragma mark Auth methods


static NSString *_access_token = nil;

//
+ (BOOL)isLogon
{
	return _access_token != nil;
}

//
+ (void)logout
{
	_access_token = nil;
	Settings::Save(kPassword);
}

//
+ (void)login
{
	[self logout];
	UIViewController *controller = [[[LoginController alloc] init] autorelease];
	[UIUtil::RootViewController() presentModalNavigationController:controller animated:YES];
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
#ifdef DEBUG
	_jsonOptions = NSJSONReadingMutableContainers;
#endif
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

// Destructor
- (void)dealloc
{
	[_service release];
	[_params release];
	[_date release];
	[_dict release];
	[_completion release];
	[super dealloc];
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
- (void)loadBegin
{
	if (_loading == NO)
	{
		if ([_delegate respondsToSelector:@selector(loadBegin:)])
		{
			if (![_delegate loadBegin:self])
			{
				return;
			}
		}
		
		//
		_loading = YES;
		[_delegate retain];
		[self loadStart];
		[self performSelectorInBackground:@selector(loadThread) withObject:nil];
	}
}

//
- (void)loadStart
{
	UIUtil::ShowNetworkIndicator(YES);
	if (!_dict)
	{
		UIViewController *controller = [_delegate respondsToSelector:@selector(view)] ? (UIViewController *)_delegate : UIUtil::VisibleViewController();
		[controller.view showLoading];
		_LineLog();
	}
}

//
- (void)loadThread
{
	@autoreleasepool
	{
		//[NSThread sleepForTimeInterval:5];
		
		//
		if ([_delegate respondsToSelector:@selector(beforeLoading:)])
		{
			_error = [_delegate beforeLoading:self];
		}
		else
		{
			_error = DataLoaderNoError;
		}
		
		NSDictionary *dict = nil;
		if (_error == DataLoaderNoError)
		{
			dict = [_delegate respondsToSelector:@selector(doLoading:)] ? [_delegate doLoading:self] : [self loadDoing];
		}
		
		if ([_delegate respondsToSelector:@selector(afterLoading: withDict:)])
		{
			if (_error == DataLoaderNoError)
			{
				_error = [_delegate afterLoading:self withDict:dict];
			}
		}
		
		[self performSelectorOnMainThread:@selector(loadEnded:) withObject:dict waitUntilDone:YES];
	}
}

//
- (NSDictionary *)loadDoing
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
					_access_token = [dict[@"access_token"] retain];
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
	//
	NSMutableString *post = [NSMutableString stringWithFormat:@"access_token=%@", _access_token ? [kAuthConsumerKey stringByAppendingString:_access_token] : kAuthConsumerKey];
	
	if ([_params isKindOfClass:[NSDictionary class]])
	{
		for (NSString *key in _params.allKeys)
		{
			id value = _params[key];
			[post appendFormat:@"&%@=%@", key, [value isKindOfClass:[NSString class]] ? NSUtil::URLEscape(value) : value];
		}
	}
	else if ([_params isKindOfClass:[NSArray class]])
	{
		for (NSArray *param in _params)
		{
			if (param.count >= 2)
			{
				id value = param[1];
				[post appendFormat:@"&%@=%@", param[0], [value isKindOfClass:[NSString class]] ? NSUtil::URLEscape(value) : value];
			}
		}
	}
	
	//
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSString *url = kServiceUrl(_service);
	_Log(@"%@?%@", url, post);
	NSData *data = HttpUtil::HttpData(url, [post dataUsingEncoding:NSUTF8StringEncoding], NSURLRequestReloadIgnoringCacheData, &response, &error);
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
	else if (_error == DataLoaderNotLogin)
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
	[_delegate release];
	
	//
	if (_completion && (!_completionOnSuccess || _error == DataLoaderNoError))
	{
		_completion(self);
	}
}

//
- (void)loadStop:(NSDictionary *)dict
{
	UIUtil::ShowNetworkIndicator(NO);
	{
		UIViewController *controller = [_delegate respondsToSelector:@selector(view)] ? (UIViewController *)_delegate : UIUtil::VisibleViewController();
		[controller.view hideLoading];
		_LineLog();
	}
	
	// 记住时间戳
	if ((_error == DataLoaderNoError) || (_error == DataLoaderNoChange))
	{
		self.date = [NSDate date];
	}
	else
	{
		// 处理错误
		//StatEvent(@"error", (NSString *)[NSString stringWithFormat:@"%d", _error]);
		
		NSString *message = [dict objectForKey:@"info"];
		if (message.length == 0) message = self.errorString;
		
		// 延迟是为了解决网络没连接时，下拉松开后，快速返回错误后弹框，点击后导致不能下拉
		// 同时也是为了解决要求登录时弹出 Toast 被遮住的问题
		[self performSelector:@selector(loadError:) withObject:message afterDelay:0.2];
		//[self loadError:message];
	}
}

//
static UIAlertView *_alertView = nil;
- (void)loadError:(NSString *)message
{
	if (_error == DataLoaderNotLogin)
	{
		[UIView showToast:message];
	}
	else if (_checkError && _alertView == nil)
	{
		//[self retain];

		//[_delegate retain];
		//[UIView showToast:message];
		_alertView = [UIAlertView alertWithTitle:message
										 message:nil
										delegate:self
							   cancelButtonTitle:@"确定"
								otherButtonTitle:nil
					  ];
	}
}

//
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	//[_delegate autorelease];
	//[self autorelease];
	_alertView = nil;
}


@end
