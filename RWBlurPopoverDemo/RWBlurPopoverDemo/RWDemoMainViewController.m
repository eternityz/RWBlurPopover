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

- (void)loadView {
    [super loadView];
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic.jpg"]];
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    imageview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageview.frame = self.view.bounds;
    [self.view addSubview:imageview];
}

- (void)showFormSheet {
    RWDemoMainViewController *vc = [[RWDemoMainViewController alloc] initWithNibName:nil bundle:nil];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Demo";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Show" style:UIBarButtonItemStylePlain target:self action:@selector(showTestPopover)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.modalPresentationStyle != UIModalPresentationFormSheet) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Form Sheet" style:UIBarButtonItemStylePlain target:self action:@selector(showFormSheet)];
        } else  {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
        }
    }
}

- (void)showTestPopover {
    RWTestViewController *vc = [[RWTestViewController alloc] initWithNibName:nil bundle:nil];
    [RWBlurPopover showContentViewController:vc insideViewController:self];
}

@end
