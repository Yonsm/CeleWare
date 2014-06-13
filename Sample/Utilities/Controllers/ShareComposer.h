

#import "WebController.h"

// 
@interface WeiboComposer : WebBrowser
{
	int _tryTimes;
}
@property(nonatomic,strong) NSString *body;
+ (id)composerWithBody:(NSString *)body pic:(NSString *)pic link:(NSString *)link;
+ (id)composerWithBody:(NSString *)body;	// Alter mode, use it carefully
@end


// 
@interface FacebookComposer : WebController
{
	NSUInteger _done;
}
@property(nonatomic,strong) NSString *link;
@property(nonatomic,strong) NSString *body;
+ (id)composerWithBody:(NSString *)body link:(NSString *)link;
@end


//
@interface UIViewController (ShareComposer)
- (WeiboComposer *)composeWeibo:(NSString *)body pic:(NSString *)pic link:(NSString *)link;
- (FacebookComposer *)composeFacebook:(NSString *)body link:(NSString *)link;
@end