//
//  RWBlurPopoverView.m
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-10-16.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

#import "RWBlurPopoverView.h"

static CGFloat angleOfView(UIView *view) {
    // http://stackoverflow.com/a/2051861/1271826
    return atan2(view.transform.b, view.transform.a);
}


typedef NS_ENUM(NSInteger, RWBlurPopoverViewState) {
    RWBlurPopoverViewStateInitial = 0,
    RWBlurPopoverViewStatePresenting,
    RWBlurPopoverViewStateShowing,
    RWBlurPopoverViewStateDismissing,
    RWBlurPopoverViewStateDismissed,
};

@interface RWBlurPopoverView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, assign) RWBlurPopoverViewState state;

@property (nonatomic, strong) UIDynamicAnimator *animator;

@end

@implementation RWBlurPopoverView

- (instancetype)initWithContentView:(UIView *)contentView contentSize:(CGSize)contentSize {
    self = [super init];
    if (self) {
        self.contentView = contentView;
        self.contentSize = contentSize;
        self.state = RWBlurPopoverViewStateInitial;
        
        if (NSClassFromString(@"UIVisualEffectView") != nil) {
            UIVisualEffectView *v = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            self.blurView = v;
            self.container = self;
        } else {
            UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
            toolbar.barStyle = UIBarStyleBlack;
            self.blurView = toolbar;
            self.container = self;
        }
        
        [self addSubview:self.blurView];
        [self.container addSubview:self.contentView];
        
        [self configureViewForState:self.state];
    }
    return self;
}

- (void)configureViewForState:(RWBlurPopoverViewState)state {
    if (state == RWBlurPopoverViewStateShowing) {
        self.contentView.transform = CGAffineTransformIdentity;
    } else  {
        self.contentView.transform = CGAffineTransformMakeTranslation(0, (CGRectGetHeight(self.container.bounds) - self.contentSize.height) / 2.0);
    }
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.blurView.frame = self.bounds;
    
    if (self.state <= RWBlurPopoverViewStateShowing) {
        self.contentView.frame = CGRectMake((CGRectGetWidth(self.container.bounds) - self.contentSize.width) / 2.0,
                                            (CGRectGetHeight(self.container.bounds) - self.contentSize.height) / 2.0,
                                            self.contentSize.width,
                                            self.contentSize.height
                                            );
    }
}

- (void)animatePresentationWithCompletion:(void (^)(void))completion {
    [self configureViewForState:RWBlurPopoverViewStateInitial];
    self.state = RWBlurPopoverViewStatePresenting;
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
        [self configureViewForState:RWBlurPopoverViewStateShowing];
    } completion:^(BOOL finished) {
        self.state = RWBlurPopoverViewStateShowing;
        if (completion) {
            completion();
        }
    }];
}

- (void)animateDismissalWithCompletion:(void (^)(void))completion {
    self.state = RWBlurPopoverViewStateDismissing;
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.container];
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.contentView]];
    gravityBehavior.magnitude = 4;
    
    [self.animator addBehavior:gravityBehavior];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.contentView]];
    {
        CGFloat angularVelocity = M_PI_2;
        if (arc4random() % 2 == 1) {
            angularVelocity = -M_PI_2;
        }
        [itemBehavior addAngularVelocity:angularVelocity forItem:self.contentView];
    }
    
    [self.animator addBehavior:itemBehavior];

    __weak typeof(self) weakSelf = self;

    itemBehavior.action = ^{
        if (!CGRectIntersectsRect(self.container.bounds, self.contentView.frame)) {
            typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.animator removeAllBehaviors];
            strongSelf.animator = nil;
            
            strongSelf.state = RWBlurPopoverViewStateDismissed;
            completion();
        }
    };

}

@end
