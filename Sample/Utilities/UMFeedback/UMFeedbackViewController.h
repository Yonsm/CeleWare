//
//  UMFeedbackViewController.h
//  UMeng Analysis
//
//  Created by liu yu on 7/12/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMFeedback.h"
#import "UMEGORefreshTableHeaderView.h"


#ifndef _BaseViewController
#define _BaseViewController UIViewController
#endif
@interface UMFeedbackViewController : _BaseViewController <UMFeedbackDataDelegate> {
    UMFeedback *feedbackClient;
    BOOL _reloading;
    UMEGORefreshTableHeaderView *_refreshHeaderView;
    CGFloat _tableViewTopMargin;
    BOOL _shouldScrollToBottom;
	UITapGestureRecognizer *_tapRecognizer;
}

@property(nonatomic, strong) IBOutlet UITableView *mTableView;
@property(nonatomic, strong) IBOutlet UIToolbar *mToolBar;
@property(nonatomic, strong) IBOutlet UIView *mContactView;

@property(nonatomic, strong) UITextField *mTextField;
@property(nonatomic, strong) UIBarButtonItem *mSendItem;
@property(nonatomic, strong) NSArray *mFeedbackData;
@property(nonatomic, copy) NSString *appkey;

- (IBAction)sendFeedback:(id)sender;
@end
