//
//  RWTestViewController.m
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-07-07.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

#import "RWTestViewController.h"

@interface RWTestViewController ()

@end

@implementation RWTestViewController

- (CGSize)preferredContentSize {
    return CGSizeMake(280, 160);
}

- (void)dismiss {
    NSLog(@"content issued dismissal started");
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"content issued dismissal ended");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.view addGestureRecognizer:tap];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
}

@end
