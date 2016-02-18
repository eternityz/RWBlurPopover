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

/// set to NO if you don't want content view controller to be dismissed by "throwing away", default is YES
@property (nonatomic, assign, getter = isThrowingGestureEnabled) BOOL throwingGestureEnabled;

/// set to NO if you don't want content view controller to be dissmissed by tap background blur view, default is YES
@property (nonatomic, assign, getter = isTapBlurToDismissEnabled) BOOL tapBlurToDismissEnabled;

/// shows a popover inside presenting view controller
- (void)showInViewController:(UIViewController *)presentingViewController;

/// convenient method
+ (void)showContentViewController:(UIViewController *)contentViewController
             insideViewController:(UIViewController *)presentingViewController;

@end
