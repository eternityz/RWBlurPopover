//
//  RWTestViewController.m
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-07-07.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

#import "RWTestViewController.h"
#import "RWBlurPopover.h"

@interface RWTestViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *tapContentToDismissSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *tapBlurToDismissSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *throwingGestureSwitch;

@property (nonatomic, strong) UITapGestureRecognizer *contentTapGesture;

@end

@implementation RWTestViewController

- (CGSize)preferredContentSize {
    return CGSizeMake(280, 320);
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
    self.contentTapGesture = tap;
    self.contentTapGesture.enabled = NO;
    [self.view addGestureRecognizer:tap];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    self.tapBlurToDismissSwitch.on = self.delegate.isTapBlurToDismissEnabled;
    self.throwingGestureSwitch.on = self.delegate.isThrowingGestureEnabled;
    self.tapContentToDismissSwitch.on = self.contentTapGesture.enabled;
}

- (IBAction)switchChanged:(id)sender {
    if (sender == self.tapBlurToDismissSwitch) {
        self.delegate.tapBlurToDismissEnabled = self.tapBlurToDismissSwitch.on;
    } else if (sender == self.throwingGestureSwitch) {
        self.delegate.throwingGestureEnabled = self.throwingGestureSwitch.on;
    } else if (sender == self.tapContentToDismissSwitch) {
        self.contentTapGesture.enabled = self.tapContentToDismissSwitch.on;
    }
}
    
@end
