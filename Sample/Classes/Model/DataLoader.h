
#define TEST
#ifdef TEST
#define kServerUrl				@"http://dohko.api.qingchifan.com"
#else
#define kServerUrl				@"http://api.qingchifan.com"
#endif

#define kAuthPostUrl			@"http://api.qingchifan.com/xauth/access_token"
#define kServiceUrl(s)			[kServerUrl stringByAppendingString:s]

#define kAuthConsumerKey		@"028fa5cddf7e5130dfd35344299ffbba"
#define kAuthConsumerSecret		@"e0822b7d71ba50d4"

#define kUsername				@"Username"
#define kPassword				@"Password"

#define _NSDateToEDTime(date)	[NSString stringWithFormat:@"%013.0lf", date.timeIntervalSince1970 * 1000]
#define _EDTimeToNSDate(time)	[NSDate dateWithTimeIntervalSince1970:[(NSString *)time longLongValue] / 1000]
#define _EDTimeToNSString(time)	NSUtil::SmartDate(_EDTimeToNSDate(time), NSDateFormatterMediumStyle, NSDateFormatterShortStyle)
#define _EDTimeToShortString(time)	NSUtil::SmartDate(_EDTimeToNSDate(time), @"MM-dd HH:mm", @"HH:mm")

// Data error
typedef enum
{
	DataLoaderNoData,
	DataLoaderNoChange,
	DataLoaderDataError,
	DataLoaderNetworkError,
	DataLoaderLocationError,
	DataLoaderNoError = 99999,
	DataLoaderNotLogin = 10002,
	DataLoaderPasswordError = 40006,
}
DataLoaderError;


// Data loader delegate
@class DataLoader;
@protocol DataLoaderDelegate <NSObject>
@optional
- (BOOL)loadBegin:(DataLoader *)sender;				// Before loading on main thread
- (void)loadEnded:(DataLoader *)sender;				// After loading on main thread

- (DataLoaderError)beforeLoading:(DataLoader *)sender;		// Before loading on loading thread
- (NSDictionary *)doLoading:(DataLoader *)sender;			// Do custom loading on loading thread, should set sender.error on failure
- (DataLoaderError)afterLoading:(DataLoader *)sender withDict:(NSDictionary *)dict;				// Before loading on loading thread
@end


// Data loader
@interface DataLoader : NSObject
{
@protected
	NSString *_service;
	NSDictionary *_params;
	id<DataLoaderDelegate> _delegate;
	void (^_completion)(DataLoader *loader);
	BOOL _completionOnSuccess;
	
	BOOL _checkChange;
	BOOL _checkError;
	NSJSONReadingOptions _jsonOptions;
	
	BOOL _loading;
	NSDate *_date;
	NSDictionary *_dict;
	DataLoaderError _error;
}

@property(nonatomic,retain) NSString *service;
@property(nonatomic,retain) id params;			/// NSDictionary 或 NSArray
@property(nonatomic,assign) id<DataLoaderDelegate> delegate;
@property(nonatomic,copy) void (^completion)(DataLoader *loader);
@property(nonatomic,assign) BOOL completionOnSuccess;

@property(nonatomic,assign) BOOL checkChange;	// 比较是否相同
@property(nonatomic,assign) BOOL checkError;	// 提示错误消息，默认为 YES
@property(nonatomic,assign) NSJSONReadingOptions jsonOptions;	// JSON 解析参数

@property(nonatomic,readonly) BOOL loading;
@property(nonatomic,retain) NSDate *date;
@property(nonatomic,readonly) NSString *stamp;
@property(nonatomic,retain) NSDictionary *dict;
@property(nonatomic,assign) DataLoaderError error;
@property(nonatomic,readonly) NSString *errorString;

//
+ (id)loaderWithService:(NSString *)service params:(NSDictionary *)params success:(void (^)(DataLoader *loader))success;
+ (id)loaderWithService:(NSString *)service params:(NSDictionary *)params completion:(void (^)(DataLoader *loader))completion;

//
+ (void)login;		// 注销并显示登录界面
+ (void)logout;		// 注销
+ (BOOL)isLogon;	// 是否已登录

//
- (void)loadBegin;		// 刷新
- (void)clearData;		// 清除数据

// For subclass only
- (void)loadBegin;
- (void)loadStart;
- (NSDictionary *)loadDoing;
- (NSData *)loadData;
- (id)parseData:(NSData *)data;
- (void)loadStop:(NSDictionary *)dict;
- (void)loadEnded:(NSDictionary *)dict;
- (void)loadError:(NSString *)message;

@end
