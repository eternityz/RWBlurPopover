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
    NSLog(@"content dismiss");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.view addGestureRecognizer:tap];
}

@end
