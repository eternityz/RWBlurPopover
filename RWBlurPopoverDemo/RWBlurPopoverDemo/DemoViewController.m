//
//  DemoViewController.m
//  RWBlurPopoverDemo
//
//  Created by Bin Zhang on 13-4-19.
//  Copyright (c) 2013年 Fresh-Ideas Studio. All rights reserved.
//

#import <RWBlurPopover/RWBlurPopover.h>
#import "DemoViewController.h"
#import "Test1ViewController.h"
#import "Test2ViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)loadView
{
    [super loadView];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic.jpg"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
}

- (void)test1
{
    Test1ViewController *vc = [Test1ViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    nav.navigationBar.translucent = YES;
    nav.navigationBar.opaque = YES;
    nav.navigationBar.tintColor = [UIColor clearColor];
    nav.navigationBar.backgroundColor = [UIColor clearColor];
    [[RWBlurPopover instance] presentViewController:nav withHeight:self.view.frame.size.height - 150];
}

- (void)test2
{
    Test2ViewController *vc = [Test2ViewController new];
    [[RWBlurPopover instance] presentViewController:vc withHeight:self.view.frame.size.height - 200];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Demo";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test 1"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(test1)
                                             ];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test 2"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(test2)
                                              ];
}

@end
