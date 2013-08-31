
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

// 
@interface SMSComposer : MFMessageComposeViewController <MFMessageComposeViewControllerDelegate>
{
	BOOL _autoSend;
}
@property(nonatomic) BOOL autoSend;
+ (id)composerWithBody:(NSString *)body to:(NSArray *)recipients;
@end


// 
@interface MailComposer : MFMailComposeViewController <MFMailComposeViewControllerDelegate>
{
}
+ (id)composerWithBody:(NSString *)body subject:(NSString *)subject to:(NSArray *)recipients;
@end

//
@interface UIViewController (MessageComposer)
- (SMSComposer *)composeSMS:(NSString *)body to:(NSArray *)recipients;
- (MailComposer *)composeMail:(NSString *)body subject:(NSString *)subject to:(NSArray *)recipients;
@end