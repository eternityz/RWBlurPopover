//
//  RWBlurPopoverTransitionController.m
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-07-07.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

#import <objc/runtime.h>
#import "RWBlurPopoverTransitionController.h"
#import "RWBlurPopover.h"

static const void *RWBlurViewKey = "RWBlurViewKey";
static const void *RWSnapshotViewKey = "RWSnapshotViewKey";

static CGFloat angleOfView(UIView *view)
{
    // http://stackoverflow.com/a/2051861/1271826
    return atan2(view.transform.b, view.transform.a);
}

@interface UIViewController (RWBlurPopoverDismiss)

- (void)_RWBlurPopoverDismiss;

@end

@implementation UIViewController (RWBlurPopoverDismiss)

- (void)_RWBlurPopoverDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@interface RWBlurPopoverTransitionController()

@property (nonatomic, strong) UIDynamicAnimator *animator;

@end

@implementation RWBlurPopoverTransitionController

+ (CGRect)presentationFrameForViewController:(UIViewController *)vc inContainer:(UIView *)container
{
    CGRect rect = {.origin = CGPointZero, .size = [vc preferredContentSize]};
    rect.origin.x = (CGRectGetWidth(container.bounds) - rect.size.width) / 2;
    rect.origin.y = (CGRectGetHeight(container.bounds) - rect.size.height) / 2;
    return rect;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4;
}

- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    assert([toVC isKindOfClass:[RWBlurPopover class]]);
    UIView *content = [(RWBlurPopover *)toVC contentViewController].view;
    
    UIView *container = [transitionContext containerView];
    
    UIView *snapshotView = [fromVC.view snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = fromVC.view.bounds;
    snapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [toVC.view insertSubview:snapshotView atIndex:0];
    
    UIToolbar *blurView = [[UIToolbar alloc] initWithFrame:CGRectZero];
    blurView.frame = fromVC.view.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurView.barStyle = UIBarStyleBlack;
    blurView.translucent = YES;
    [toVC.view insertSubview:blurView aboveSubview:snapshotView];
    
    blurView.alpha = 0;
    blurView.userInteractionEnabled = YES;
    
    [blurView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:toVC action:@selector(_RWBlurPopoverDismiss)]];
    
    objc_setAssociatedObject(toVC, RWBlurViewKey, blurView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(toVC, RWSnapshotViewKey, snapshotView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    toVC.view.frame = container.bounds;
    
    [container addSubview:toVC.view];
    [fromVC.view removeFromSuperview];
    
    content.transform = CGAffineTransformMakeTranslation(0, CGRectGetMaxY(content.frame));
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
        blurView.alpha = 1.0;
        content.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    assert([fromVC isKindOfClass:[RWBlurPopover class]]);
    UIView *content = [(RWBlurPopover *)fromVC contentViewController].view;
    
    UIToolbar *blurView = objc_getAssociatedObject(fromVC, RWBlurViewKey);
    UIView *snapshotView = objc_getAssociatedObject(fromVC, RWSnapshotViewKey);
    [container insertSubview:toVC.view belowSubview:fromVC.view];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:fromVC.view];
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[content]];
    gravityBehavior.magnitude = 4;
    [self.animator addBehavior:gravityBehavior];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[content]];
    {
        CGFloat angularVelocity = M_PI_2;
        if (rand() % 2 == 1)
        {
            angularVelocity = -M_PI_2;
        }
        [itemBehavior addAngularVelocity:angularVelocity forItem:content];
    }
    [self.animator addBehavior:itemBehavior];
    
    __weak typeof(self) weakSelf = self;
    
    void (^completion)(void) = ^{
        
        [blurView removeFromSuperview];
        [snapshotView removeFromSuperview];
        [fromVC.view removeFromSuperview];
        objc_setAssociatedObject(fromVC, RWBlurViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(fromVC, RWSnapshotViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [transitionContext completeTransition:YES];
        
    };
    
    itemBehavior.action = ^{
        if (!CGRectIntersectsRect(fromVC.view.bounds, content.frame))
        {
            typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.animator removeAllBehaviors];
            strongSelf.animator = nil;
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
                blurView.alpha = 0;
            } completion:^(BOOL finished) {
                completion();
            }];
        }
    };
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isPresentation)
    {
        return [self animatePresentation:transitionContext];
    }
    else
    {
        return [self animateDismissal:transitionContext];
    }
}

@end



@interface RWBlurPopoverInteractiveTransitionController ()

@property (nonatomic, strong) id<UIViewControllerContextTransitioning> interactiveContext;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, assign) CGPoint interactiveStartPoint;

// compute angular velocity, 
@property (nonatomic, assign) CFTimeInterval interactiveLastTime;
@property (nonatomic, assign) CGFloat interactiveLastAngle;
@property (nonatomic, assign) CGFloat interactiveAngularVelocity;

@end

@implementation RWBlurPopoverInteractiveTransitionController

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.interactiveContext = transitionContext;
    
    UIViewController *fromVC = [self.interactiveContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    assert([fromVC isKindOfClass:[RWBlurPopover class]]);
    UIView *content = [(RWBlurPopover *)fromVC contentViewController].view;
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:fromVC.view];
    CGPoint anchorPoint = self.interactiveStartPoint;
    UIOffset anchorOffset = UIOffsetMake(anchorPoint.x - CGRectGetMidX(content.frame), anchorPoint.y - CGRectGetMidY(content.frame));
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:content offsetFromCenter:anchorOffset attachedToAnchor:anchorPoint];
    
    // http://stackoverflow.com/questions/21325057/implement-uikitdynamics-for-dragging-view-off-screen
    self.interactiveLastTime = CACurrentMediaTime();
    self.interactiveLastAngle = angleOfView(content);
    __weak typeof(self) weakSelf = self;
    self.attachmentBehavior.action = ^{
        CFTimeInterval t = CACurrentMediaTime();
        CGFloat angle = angleOfView(content);
        typeof(weakSelf) strongSelf = weakSelf;
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

- (void)startInteractiveTransitionWithTouchLocation:(CGPoint)location
{
    
    self.interactiveStartPoint = location;
}

- (void)updateInteractiveTransitionWithTouchLocation:(CGPoint)location
{
    CGPoint anchorPoint = location;
    self.attachmentBehavior.anchorPoint = anchorPoint;
}

- (void)interactiveTransitionCleanup
{
    self.interactiveContext = nil;
    self.animator = nil;
    self.interactiveStartPoint = CGPointZero;
}

- (void)finishInteractiveTransitionWithTouchLocation:(CGPoint)location velocity:(CGPoint)velocity
{
    // http://stackoverflow.com/questions/21325057/implement-uikitdynamics-for-dragging-view-off-screen
    
    UIView *container = [self.interactiveContext containerView];
    UIViewController *fromVC = [self.interactiveContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [self.interactiveContext viewControllerForKey:UITransitionContextToViewControllerKey];
    assert([fromVC isKindOfClass:[RWBlurPopover class]]);
    UIView *content = [(RWBlurPopover *)fromVC contentViewController].view;
    
    UIToolbar *blurView = objc_getAssociatedObject(fromVC, RWBlurViewKey);
    UIView *snapshotView = objc_getAssociatedObject(fromVC, RWSnapshotViewKey);
    
    toVC.view.frame = [self.interactiveContext finalFrameForViewController:toVC];
    [container insertSubview:toVC.view belowSubview:fromVC.view];
    
    [self.animator removeAllBehaviors];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[content]];
    [itemBehavior addLinearVelocity:velocity forItem:content];
    [itemBehavior addAngularVelocity:self.interactiveAngularVelocity forItem:content];
    [itemBehavior setAngularResistance:2];
    
    itemBehavior.action = ^{
        if (!CGRectIntersectsRect(fromVC.view.bounds, content.frame))
        {
            [self.animator removeAllBehaviors];
            [UIView animateWithDuration:[self transitionDuration:self.interactiveContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
                blurView.alpha = 0;
            } completion:^(BOOL finished) {
                [blurView removeFromSuperview];
                [snapshotView removeFromSuperview];
                [fromVC.view removeFromSuperview];
                objc_setAssociatedObject(fromVC, RWBlurViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                objc_setAssociatedObject(fromVC, RWSnapshotViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                [self.interactiveContext finishInteractiveTransition];
                [self.interactiveContext completeTransition:YES];
                [self interactiveTransitionCleanup];
            }];
        }
    };
    [self.animator addBehavior:itemBehavior];
}

- (void)cancelInteractiveTransitionWithTouchLocation:(CGPoint)location
{
    UIViewController *fromVC = [self.interactiveContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    assert([fromVC isKindOfClass:[RWBlurPopover class]]);
    UIViewController *contentViewController = [(RWBlurPopover *)fromVC contentViewController];
    UIView *content = contentViewController.view;
    
    [UIView animateWithDuration:[self transitionDuration:self.interactiveContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
        [self.animator removeAllBehaviors];
        content.transform = CGAffineTransformIdentity;
        
        CGRect frame = CGRectZero;
        frame.size = contentViewController.preferredContentSize;
        frame.origin.x = (CGRectGetWidth(fromVC.view.bounds) - frame.size.width) / 2;
        frame.origin.y = (CGRectGetHeight(fromVC.view.bounds) - frame.size.height) / 2;
        
        content.frame = frame;
        
    } completion:^(BOOL finished) {
        CGAffineTransform containerTransform = fromVC.view.superview.transform;
        CGRect frame = fromVC.view.frame;
        
        [self.interactiveContext cancelInteractiveTransition];
        [self.interactiveContext completeTransition:NO];
        [self interactiveTransitionCleanup];
        
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
        {
            // fix final state for landscape
            frame.size = (CGSize){.width = frame.size.height, .height = frame.size.width};
            fromVC.view.transform = containerTransform;
            fromVC.view.frame = frame;
        }
    }];
}


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4;
}

@end