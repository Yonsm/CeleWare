//
//  UMContactViewController.h
//  Demo
//
//  Created by liuyu on 4/2/13.
//  Copyright (c) 2013 iOS@Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMContactViewControllerDelegate;

#ifndef _BaseViewController
#define _BaseViewController UIViewController
#endif
@interface UMContactViewController : _BaseViewController

@property(nonatomic, strong) IBOutlet UITextView *textView;
@property(nonatomic, weak) id <UMContactViewControllerDelegate> delegate;

@end

@protocol UMContactViewControllerDelegate <NSObject>

@optional

- (void)updateContactInfo:(UMContactViewController *)controller contactInfo:(NSString *)info;

@end