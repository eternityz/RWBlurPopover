//
//  RWBlurPopover.h
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-07-07.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

@import UIKit;

@interface RWBlurPopover : NSObject

/// create a popover with a content view controller
/// size of the popover is determined by [contentViewController preferredContentSize]
- (instancetype)initWithContentViewController:(UIViewController *)contentViewController;

/// set to YES if you want content view controller to be dismissed by "throwing away"
@property (nonatomic, assign, getter = isThrowingGestureEnabled) BOOL throwingGestureEnabled;

/// shows a popover inside presenting view controller
- (void)showInViewController:(UIViewController *)presentingViewController;

/// convenient method
+ (void)showContentViewController:(UIViewController *)contentViewController
             insideViewController:(UIViewController *)presentingViewController;

@end
