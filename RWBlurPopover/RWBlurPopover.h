//
//  RWBlurPopover.h
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-07-07.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

@import UIKit;

@interface RWBlurPopover : UIViewController

/// create a popover with a content view controller
/// size of the popover is determined by [contentViewController preferredContentSize]
- (instancetype)initWithContentViewController:(UIViewController *)contentViewController;

/// set to YES if you want content view controller to be dismissed by "throwing away"
@property (nonatomic, assign, getter = isThrowingGestureEnabled) BOOL throwingGestureEnabled;

@property (nonatomic, weak, readonly) UIViewController *contentViewController;

@end
