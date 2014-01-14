
#define TEST
#ifdef TEST
#define kServerUrl				@"http://api.apple.com"
#else
#define kServerUrl				@"http://test.apple.com"
#endif

#define kServiceUrl(s)			[kServerUrl stringByAppendingString:s]

#define kAuthConsumerKey		@"XXX"
#define kAuthConsumerSecret		@"XXX"

#define kUsername				@"Username"
#define kPassword				@"Password"
#define kLogoutNotification			@"LogoutNotification"

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
- (BOOL)loadBegan:(DataLoader *)loader;	// Before loading on main thread
- (void)loadEnded:(DataLoader *)loader;	// After loading on main thread

- (id)loadDoing:(DataLoader *)loader;	// Do custom loading on loading thread, should set sender.error on failure
- (NSData *)loadData:(DataLoader *)loader url:(NSString *)url;	// Do custom data loading on loading thread, should set sender.error on failure
@end


// Data loader
@interface DataLoader : NSObject
{
	id<DataLoaderDelegate> _retained_delegate;
}
@property(nonatomic,strong) NSString *service;
@property(nonatomic,strong) id/*NSDictionary or NSArray*/ params;	/// NSDictionary 或 NSArray
@property(nonatomic,weak) id<DataLoaderDelegate> delegate;
@property(nonatomic,copy) void (^completion)(DataLoader *loader);
@property(nonatomic,copy) BOOL (^failure)(DataLoader *loader, NSString *error);	// return NO 则不处理错误
@property(nonatomic,assign) BOOL completionOnSuccess;	// 仅成功时调用

@property(nonatomic,assign) BOOL checkChange;	// 比较是否相同
@property(nonatomic,assign) BOOL checkError;	// 提示错误消息，默认为 YES
@property(nonatomic,assign) BOOL showLoading;	// 显示加载状态，默认为 YES
@property(nonatomic,assign) NSJSONReadingOptions jsonOptions;	// JSON 解析参数

@property(nonatomic,readonly) BOOL loading;
@property(nonatomic,strong) NSDate *date;
@property(weak, nonatomic,readonly) NSString *stamp;
@property(nonatomic,strong) id/*NSDictionary or NSArray*/ dict;
@property(nonatomic,assign) DataLoaderError error;
@property(weak, nonatomic,readonly) NSString *errorString;

//
+ (void)loadWithService:(NSString *)service params:(id)params success:(void (^)(DataLoader *loader))success failure:(BOOL (^)(DataLoader *loader, NSString *error))failure;
+ (void)loadWithService:(NSString *)service params:(id)params success:(void (^)(DataLoader *loader))success;
+ (void)loadWithService:(NSString *)service params:(id)params completion:(void (^)(DataLoader *loader))completion;
+ (void)loadWithService:(NSString *)service params:(id)params showLoading:(BOOL)showLoading checkError:(BOOL)checkError completion:(void (^)(DataLoader *loader))completion;
+ (void)loadWithService:(NSString *)service params:(id)params delegate:(id<DataLoaderDelegate>)delegate completion:(void (^)(DataLoader *loader))completion;
//+ (id)loaderWithService:(NSString *)service params:(id)params completion:(void (^)(DataLoader *loader))completion;	// 注意：需要手动调用 loadBegin，可以自己配置 DataLoader

//
+ (void)login;		// 注销并显示登录界面
+ (void)logout;		// 注销
+ (BOOL)isLogon;	// 是否已登录
+ (int)self_id;
+ (NSString *)access_token;

//
- (BOOL)loadBegin;		// 刷新
- (void)clearData;		// 清除数据

// For subclass only
- (void)loadStart;
- (id)loadDoing;
- (NSData *)loadData;
- (NSData *)loadData:(NSString *)url;
- (id)parseData:(NSData *)data;
- (void)loadStop:(NSDictionary *)dict;
- (void)loadEnded:(NSDictionary *)dict;
- (void)loadError:(NSString *)message;

@end
