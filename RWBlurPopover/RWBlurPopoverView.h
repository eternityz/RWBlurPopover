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

- (instancetype)initWithContentView:(UIView *)contentView contentSize:(CGSize)contentSize;

@end
