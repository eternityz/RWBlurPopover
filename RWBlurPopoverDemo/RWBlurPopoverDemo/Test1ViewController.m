//
//  Test1ViewController.m
//  RWBlurPopoverDemo
//
//  Created by Bin Zhang on 13-4-20.
//  Copyright (c) 2013年 Fresh-Ideas Studio. All rights reserved.
//

#import <RWBlurPopover/RWBlurPopover.h>
#import "Test1ViewController.h"

@interface Test1ViewController ()

@end

@implementation Test1ViewController

- (void)loadView
{
    [super loadView];
    UILabel *l = [[UILabel alloc] initWithFrame:self.view.bounds];
    l.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont boldSystemFontOfSize:18];
    l.textAlignment = UITextAlignmentCenter;
    l.text = @"Test 1";
    [self.view addSubview:l];
}

- (void)done
{
    [[RWBlurPopover instance] dismissViewControllerAnimated:YES completion:nil];
}

- (void)next
{
    UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Test One";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(done)
                                             ];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(next)
                                              ];
}

@end
