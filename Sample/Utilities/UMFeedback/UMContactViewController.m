//
//  UMContactViewController.m
//  Demo
//
//  Created by liuyu on 4/2/13.
//  Copyright (c) 2013 iOS@Umeng. All rights reserved.
//

#import "UMContactViewController.h"

@implementation UMContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"Fill in the Contact1", @"填写联系信息");
    self.view.backgroundColor = [UIColor colorWithRed:238.0 / 255 green:238.0 / 255 blue:238.0 / 255 alpha:1.0];

    self.textView.text = NSLocalizedString(@"Fill in the Contact2", @"请留下您的QQ，邮箱，电话等联系方式");
    [self.textView selectAll:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.textView becomeFirstResponder];
}

//
 - (void)viewWillDisappear:(BOOL)animated
{
	if ([self.delegate respondsToSelector:@selector(updateContactInfo:contactInfo:)]) {
        [self.delegate updateContactInfo:self contactInfo:self.textView.text];
    }
}

@end
