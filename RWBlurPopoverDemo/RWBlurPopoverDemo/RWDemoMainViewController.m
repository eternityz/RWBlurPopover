//
//  RWDemoMainViewController.m
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-07-07.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

#import "RWDemoMainViewController.h"
#import "RWBlurPopover.h"
#import "RWTestViewController.h"

@interface RWDemoMainViewController ()

@end

@implementation RWDemoMainViewController

- (void)loadView
{
    [super loadView];
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic.jpg"]];
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    imageview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageview.frame = self.view.bounds;
    [self.view addSubview:imageview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Demo";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Show" style:UIBarButtonItemStylePlain target:self action:@selector(showTestPopover)];
}

- (void)showTestPopover
{
    RWTestViewController *vc = [[RWTestViewController alloc] initWithNibName:nil bundle:nil];
    RWBlurPopover *popover = [[RWBlurPopover alloc] initWithContentViewController:vc];
    [self presentViewController:popover animated:YES completion:nil];
}

@end
