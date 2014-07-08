//
//  RWBlurPopoverTransitionController.h
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-07-07.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

@import UIKit;

@interface RWBlurPopoverTransitionController : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresentation;

@end

@interface RWBlurPopoverInteractiveTransitionController : NSObject <UIViewControllerInteractiveTransitioning>

- (void)startInteractiveTransitionWithTouchLocation:(CGPoint)location;
- (void)updateInteractiveTransitionWithTouchLocation:(CGPoint)location;
- (void)finishInteractiveTransitionWithTouchLocation:(CGPoint)location velocity:(CGPoint)velocity;
- (void)cancelInteractiveTransitionWithTouchLocation:(CGPoint)location;


@end