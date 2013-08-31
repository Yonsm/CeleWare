//
//  UMContactViewController.h
//  Demo
//
//  Created by liuyu on 4/2/13.
//  Copyright (c) 2013 iOS@Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMContactViewControllerDelegate;

#ifndef BaseViewController
#define BaseViewController UIViewController
#endif
@interface UMContactViewController : BaseViewController

@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, assign) id <UMContactViewControllerDelegate> delegate;

@end

@protocol UMContactViewControllerDelegate <NSObject>

@optional

- (void)updateContactInfo:(UMContactViewController *)controller contactInfo:(NSString *)info;

@end