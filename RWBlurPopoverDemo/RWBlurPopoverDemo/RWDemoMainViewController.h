//
//  RWDemoMainViewController.h
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-07-07.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

@import UIKit;

@interface RWDemoMainViewController : UIViewController

@property (nonatomic, assign, getter = isThrowingGestureEnabled) BOOL throwingGestureEnabled;
@property (nonatomic, assign, getter = isTapBlurToDismissEnabled) BOOL tapBlurToDismissEnabled;

@end
