
#import "UIUtil.h"
#import "MessageComposer.h"

@implementation SMSComposer
@synthesize autoSend=_autoSend;

// Compose SMS
+ (id)composerWithBody:(NSString *)body to:(NSArray *)recipients 
{
	// Check
	if ([MFMessageComposeViewController canSendText] == NO)
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Could not send SMS on this device.", @"在此设备上无法发送短信。")];
		return nil;
	}
	
	// Display composer
	SMSComposer *composer = [[SMSComposer alloc] init];
	composer.messageComposeDelegate = composer;
	if (body) composer.body = body;
	if (recipients) composer.recipients = recipients;
	return composer;
}

//
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

//
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (_autoSend)
	{
		_autoSend = NO;
		UIView *entryView = [UIUtil::KeyWindow() findSubview:@"CKMessageEntryView"];
		for (UIView *child in entryView.subviews)
		{
			if ([child isKindOfClass:[UIButton class]] && (child.frame.size.width > child.frame.size.height))
			{
				_autoSend = YES;
				[((UIButton *)child) sendActionsForControlEvents:UIControlEventTouchUpInside];
				break;
			}
		}
	}
}

// The user's completion of message composition.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;
{
	if (result == MessageComposeResultFailed)
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Failed to send SMS.", @"发送短信失败。")];
	}
	else
	{
		[self dismissViewControllerAnimated:!_autoSend completion:nil];
		
		if ((result == MessageComposeResultSent) && _autoSend)
		{
			[UIAlertView alertWithTitle:NSLocalizedString(@"Send SMS successfully.", @"发送短信成功。")];
		}
	}
}

@end


@implementation MailComposer

// Compose mail
+ (id)composerWithBody:(NSString *)body subject:(NSString *)subject to:(NSArray *)recipients
{
	// Check for email account
	if ([MFMailComposeViewController canSendMail] == NO)
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Please setup your email account first.", @"请先设置您的邮件账户。")];
		return nil;
	}

	// Display composer
	MailComposer *composer = [[MailComposer alloc] init];
	composer.mailComposeDelegate = composer;
	if (recipients) [composer setToRecipients:recipients];
	if (subject) [composer setSubject:subject];
	if (body) [composer setMessageBody:body isHTML:[body hasPrefix:@"<"]];
	return composer;
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	if (result == MFMailComposeResultFailed)
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Failed to send email.", @"发送邮件失败。")];
	}
	else
	{
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

@end

//
@implementation UIViewController (MessageComposer)

//
- (SMSComposer *)composeSMS:(NSString *)body to:(NSArray *)recipients
{
	SMSComposer *composer = [SMSComposer composerWithBody:body to:recipients];
	if (composer)
	{
		composer.autoSend = recipients.count && body.length;
		[self presentViewController:composer animated:!composer.autoSend completion:nil];
	}
	return composer;
}

//
- (MailComposer *)composeMail:(NSString *)body subject:(NSString *)subject to:(NSArray *)recipients
{
	MailComposer *composer = [MailComposer composerWithBody:body subject:subject to:recipients];
	if (composer) [self presentViewController:composer animated:YES completion:nil];
	return composer;
}

@end