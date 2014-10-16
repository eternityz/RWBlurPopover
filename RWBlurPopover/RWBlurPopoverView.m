//
//  RWBlurPopoverView.m
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-10-16.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

#import "RWBlurPopoverView.h"

@interface RWBlurPopoverView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CGSize contentSize;

@end

@implementation RWBlurPopoverView

- (instancetype)initWithContentView:(UIView *)contentView contentSize:(CGSize)contentSize {
    self = [super init];
    if (self) {
        self.contentView = contentView;
        self.contentSize = contentSize;
        
        if (NO) { // (NSClassFromString(@"UIVisualEffectView") != nil) {
            UIVisualEffectView *v = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            self.blurView = v;
            self.container = v.contentView;
        } else {
            UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
            toolbar.barStyle = UIBarStyleBlack;
            self.blurView = toolbar;
            self.container = self;
        }
        
        [self addSubview:self.blurView];
        [self.container addSubview:self.contentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.blurView.frame = self.bounds;
    self.contentView.frame = CGRectMake((CGRectGetWidth(self.container.bounds) - self.contentSize.width) / 2.0,
                                        (CGRectGetHeight(self.container.bounds) - self.contentSize.height) / 2.0,
                                        self.contentSize.width,
                                        self.contentSize.height
                                        );
    
}

@end
