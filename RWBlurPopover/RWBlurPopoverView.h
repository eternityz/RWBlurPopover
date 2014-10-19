//
//  RWBlurPopoverView.h
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-10-16.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

@import UIKit;

@interface RWBlurPopoverView : UIView

@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, weak) UIView *container;
@property (nonatomic, copy) dispatch_block_t dismissalBlock;

@property (nonatomic, assign, getter = isThrowingGestureEnabled) BOOL throwingGestureEnabled;

- (instancetype)initWithContentView:(UIView *)contentView contentSize:(CGSize)contentSize;

- (void)animatePresentation;
- (void)animateDismissalWithCompletion:(dispatch_block_t)completion;

@end
