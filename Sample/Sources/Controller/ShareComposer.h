

#import "WebController.h"

// 
@interface WeiboComposer : WebBrowser
{
	BOOL _isLast;
}
@property(nonatomic,retain) NSString *body;
+ (id)composerWithBody:(NSString *)body pic:(NSString *)pic link:(NSString *)link;
+ (id)composerWithBody:(NSString *)body;	// Alter mode, use it carefully
@end


// 
@interface FacebookComposer : WebController
{
	NSUInteger _done;
}
@property(nonatomic,retain) NSString *link;
@property(nonatomic,retain) NSString *body;
+ (id)composerWithBody:(NSString *)body link:(NSString *)link;
@end


//
@interface UIViewController (ShareComposer)
- (WeiboComposer *)composeWeibo:(NSString *)body pic:(NSString *)pic link:(NSString *)link;
- (FacebookComposer *)composeFacebook:(NSString *)body link:(NSString *)link;
@end