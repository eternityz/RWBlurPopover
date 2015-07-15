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
    RWBlurPopoverViewStateInteractiveDismissing,
    RWBlurPopoverViewStateAnimatedDismissing,
    RWBlurPopoverViewStateDismissed,
};

@interface RWBlurPopoverView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *backgroundTappingView;
@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, assign) RWBlurPopoverViewState state;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapGesture;

@property (nonatomic, assign) CGPoint interactiveStartPoint;
// compute angular velocity
@property (nonatomic, assign) CFTimeInterval interactiveLastTime;
@property (nonatomic, assign) CGFloat interactiveLastAngle;
@property (nonatomic, assign) CGFloat interactiveAngularVelocity;

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
            self.container = v.contentView;
        } else {
            UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
            toolbar.barStyle = UIBarStyleBlack;
            self.blurView = toolbar;
            self.container = toolbar;
        }
        
        [self addSubview:self.blurView];
        
        self.backgroundTappingView = [[UIView alloc] init];
        self.backgroundTappingView.backgroundColor = [UIColor clearColor];
        [self.backgroundTappingView addGestureRecognizer:self.backgroundTapGesture];
        
        [self.container addSubview:self.backgroundTappingView];
        [self.container addSubview:self.contentView];
        
        [self configureViewForState:self.state];
        
        [self.contentView addGestureRecognizer:self.panGesture];
    }
    return self;
}

- (void)configureViewForState:(RWBlurPopoverViewState)state {
    if (state >= RWBlurPopoverViewStateShowing) {
        self.contentView.transform = CGAffineTransformIdentity;
        // self.contentView.alpha = 1.0;
    } else  {
        CGFloat offset = (CGRectGetHeight(self.container.bounds) + self.contentSize.height) / 2.0;
        self.contentView.transform = CGAffineTransformMakeTranslation(0, -offset);
        // self.contentView.alpha = 0;
    }
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.blurView.frame = self.bounds;
    self.backgroundTappingView.frame = self.container.bounds;
    
    if (self.state <= RWBlurPopoverViewStateShowing) {
        self.contentView.frame = CGRectMake((CGRectGetWidth(self.container.bounds) - self.contentSize.width) / 2.0,
                                            (CGRectGetHeight(self.container.bounds) - self.contentSize.height) / 2.0,
                                            self.contentSize.width,
                                            self.contentSize.height
                                            );
    }
}

- (void)animatePresentation {
    [self layoutSubviews];
    [self configureViewForState:RWBlurPopoverViewStateInitial];
    self.state = RWBlurPopoverViewStatePresenting;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
        [self configureViewForState:RWBlurPopoverViewStateShowing];
    } completion:^(BOOL finished) {
        self.state = RWBlurPopoverViewStateShowing;
    }];
}

- (void)animateDismissalWithCompletion:(void (^)(void))completion {
    if (self.state >= RWBlurPopoverViewStateAnimatedDismissing) {
        return;
    }
    self.state = RWBlurPopoverViewStateAnimatedDismissing;
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
        angularVelocity *= 0.5;
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
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.dismissalBlock) {
                    self.dismissalBlock();
                }
                if (completion) {
                    completion();
                }
            });
        }
    };

}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)backgroundTapGesture {
    if (!_backgroundTapGesture) {
        _backgroundTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTapGesture:)];
    }
    return _backgroundTapGesture;
}

- (void)setThrowingGestureEnabled:(BOOL)throwingGestureEnabled {
    [self.panGesture setEnabled:throwingGestureEnabled];
}

- (BOOL)isThrowingGestureEnabled {
    return self.panGesture.isEnabled;
}

- (void)setTapBlurToDismissEnabled:(BOOL)tapBlurToDismissEnabled {
    [self.backgroundTapGesture setEnabled:tapBlurToDismissEnabled];
}

- (BOOL)isTapBlurToDismissEnabled {
    return self.backgroundTapGesture.enabled;
}

- (void)startInteractiveTransitionWithTouchLocation:(CGPoint)location {
    self.state = RWBlurPopoverViewStateInteractiveDismissing;
    self.interactiveStartPoint = location;
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    CGPoint anchorPoint = self.interactiveStartPoint;
    UIOffset anchorOffset = UIOffsetMake(anchorPoint.x - CGRectGetMidX(self.contentView.frame), anchorPoint.y - CGRectGetMidY(self.contentView.frame));
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.contentView offsetFromCenter:anchorOffset attachedToAnchor:anchorPoint];

    // http://stackoverflow.com/questions/21325057/implement-uikitdynamics-for-dragging-view-off-screen
    self.interactiveLastTime = CACurrentMediaTime();
    self.interactiveLastAngle = angleOfView(self.contentView);
    __weak typeof(self) weakSelf = self;
    self.attachmentBehavior.action = ^{
        typeof(weakSelf) strongSelf = weakSelf;
        CFTimeInterval t = CACurrentMediaTime();
        CGFloat angle = angleOfView(strongSelf.contentView);
        if (t > strongSelf.interactiveLastTime)
        {
            CGFloat av = (angle - strongSelf.interactiveLastAngle) / (t - strongSelf.interactiveLastTime);
            if (fabs(av) > 1E-6)
            {
                strongSelf.interactiveAngularVelocity = av;
                strongSelf.interactiveLastTime = t;
                strongSelf.interactiveLastAngle = angle;
            }
        }
    };
    
    [self.animator addBehavior:self.attachmentBehavior];
}

- (void)updateInteractiveTransitionWithTouchLocation:(CGPoint)location {
    self.attachmentBehavior.anchorPoint = location;
}

- (void)finishInteractiveTransitionWithTouchLocation:(CGPoint)location velocity:(CGPoint)velocity {
    // http://stackoverflow.com/questions/21325057/implement-uikitdynamics-for-dragging-view-off-screen
    
    self.state = RWBlurPopoverViewStateAnimatedDismissing;

    [self.animator removeAllBehaviors];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.contentView]];
    [itemBehavior addLinearVelocity:velocity forItem:self.contentView];
    [itemBehavior addAngularVelocity:self.interactiveAngularVelocity forItem:self.contentView];
    [itemBehavior setAngularResistance:2];
    
    __weak typeof(self) weakSelf = self;
    itemBehavior.action = ^{
        if (!CGRectIntersectsRect(weakSelf.bounds, weakSelf.contentView.frame))
        {
            weakSelf.state = RWBlurPopoverViewStateDismissed;
            [weakSelf.animator removeAllBehaviors];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.dismissalBlock) {
                    weakSelf.dismissalBlock();
                }
            });
        }
    };
    [self.animator addBehavior:itemBehavior];
}

- (void)cancelInteractiveTransitionWithTouchLocation:(CGPoint)location {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
        [self.animator removeAllBehaviors];
        self.contentView.transform = CGAffineTransformIdentity;
        self.state = RWBlurPopoverViewStateShowing;
        [self layoutSubviews];
        
    } completion:^(BOOL finished) {
    }];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gr {
    CGPoint location = [gr locationInView:self];
    switch (gr.state) {
        case UIGestureRecognizerStateBegan: {
            [self startInteractiveTransitionWithTouchLocation:location];
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            [self updateInteractiveTransitionWithTouchLocation:location];
            break;
        }
            
        case UIGestureRecognizerStateEnded: case UIGestureRecognizerStateCancelled: {
            CGPoint velocity = [gr velocityInView:self];
            if (fabs(velocity.x) + fabs(velocity.y) <= 1000 || gr.state == UIGestureRecognizerStateCancelled) {
                [self cancelInteractiveTransitionWithTouchLocation:location];
            } else {
                [self finishInteractiveTransitionWithTouchLocation:location velocity:velocity];
            }

        }
        default: break;
    }
}

- (void)handleBackgroundTapGesture:(UITapGestureRecognizer *)gr {
    [self animateDismissalWithCompletion:nil];
}

@end
