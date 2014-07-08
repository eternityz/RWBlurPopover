//
//  RWBlurPopoverTransitionController.m
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-07-07.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

#import <objc/runtime.h>
#import "RWBlurPopoverTransitionController.h"

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
    UIView *container = [transitionContext containerView];
    
    UIView *snapshotView = [fromVC.view snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = fromVC.view.frame;
    [container insertSubview:snapshotView aboveSubview:fromVC.view];
    
    UIToolbar *blurView = [[UIToolbar alloc] initWithFrame:CGRectZero];
    blurView.frame = fromVC.view.frame;
    blurView.barStyle = UIBarStyleBlack;
    blurView.translucent = YES;
    
    [container insertSubview:blurView aboveSubview:snapshotView];
    blurView.alpha = 0;
    blurView.userInteractionEnabled = YES;
    
    [blurView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:toVC action:@selector(_RWBlurPopoverDismiss)]];
    
    objc_setAssociatedObject(toVC, RWBlurViewKey, blurView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(toVC, RWSnapshotViewKey, snapshotView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CGRect initialRect = [[self class] presentationFrameForViewController:toVC inContainer:container];
    initialRect.origin.y = CGRectGetMaxY(container.bounds);
    toVC.view.frame = initialRect;
    
    [container addSubview:toVC.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
        blurView.alpha = 1.0;
        
        toVC.view.frame = [[self class] presentationFrameForViewController:toVC inContainer:container];
    } completion:^(BOOL finished) {
        [fromVC.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    UIToolbar *blurView = objc_getAssociatedObject(fromVC, RWBlurViewKey);
    UIView *snapshotView = objc_getAssociatedObject(fromVC, RWSnapshotViewKey);
    [container insertSubview:toVC.view belowSubview:snapshotView];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:container];
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[fromVC.view]];
    gravityBehavior.magnitude = 4;
    [self.animator addBehavior:gravityBehavior];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[fromVC.view]];
    {
        CGFloat angularVelocity = M_PI_2;
        if (rand() % 2 == 1)
        {
            angularVelocity = -M_PI_2;
        }
        [itemBehavior addAngularVelocity:angularVelocity forItem:fromVC.view];
    }
    [self.animator addBehavior:itemBehavior];
    
    __weak typeof(self) weakSelf = self;
    
    void (^completion)(void) = ^{
        
        [fromVC.view removeFromSuperview];
        [blurView removeFromSuperview];
        [snapshotView removeFromSuperview];
        objc_setAssociatedObject(fromVC, RWBlurViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(fromVC, RWSnapshotViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [transitionContext completeTransition:YES];
        
    };
    
    itemBehavior.action = ^{
        if (!CGRectIntersectsRect(fromVC.view.frame, container.bounds))
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
    
    /*
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
        CGRect rect = fromVC.view.frame;
        rect.origin.y = CGRectGetMaxY(container.bounds);
        fromVC.view.frame = rect;
        blurView.alpha = 0;
    } completion:^(BOOL finished) {
        completion();
    }];
     */
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
@property (nonatomic, assign) CFAbsoluteTime interactiveLastTime;
@property (nonatomic, assign) CGFloat interactiveLastAngle;
@property (nonatomic, assign) CGFloat interactiveAngularVelocity;

@end

@implementation RWBlurPopoverInteractiveTransitionController

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.interactiveContext = transitionContext;
    
    UIView *container = [self.interactiveContext containerView];
    UIViewController *fromVC = [self.interactiveContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:container];
    CGPoint anchorPoint = [container convertPoint:self.interactiveStartPoint fromView:fromVC.view];
    UIOffset anchorOffset = UIOffsetMake(self.interactiveStartPoint.x - CGRectGetMidX(fromVC.view.bounds), self.interactiveStartPoint.y - CGRectGetMidY(fromVC.view.bounds));
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:fromVC.view offsetFromCenter:anchorOffset attachedToAnchor:anchorPoint];
    
    // http://stackoverflow.com/questions/21325057/implement-uikitdynamics-for-dragging-view-off-screen
    self.interactiveLastTime = CFAbsoluteTimeGetCurrent();
    self.interactiveLastAngle = angleOfView(fromVC.view);
    __weak typeof(self) weakSelf = self;
    self.attachmentBehavior.action = ^{
        CFAbsoluteTime t = CFAbsoluteTimeGetCurrent();
        CGFloat angle = angleOfView(fromVC.view);
        typeof(weakSelf) strongSelf = weakSelf;
        if (t > strongSelf.interactiveLastTime)
        {
            strongSelf.interactiveAngularVelocity = (angle - strongSelf.interactiveLastAngle) / (t - strongSelf.interactiveLastTime);
            strongSelf.interactiveLastTime = t;
            strongSelf.interactiveLastAngle = angle;
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
    UIView *container = [self.interactiveContext containerView];
    UIViewController *fromVC = [self.interactiveContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGPoint anchorPoint = [container convertPoint:location fromView:fromVC.view];
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
    
    NSTimeInterval t = 5;// [self transitionDuration:self.interactiveContext];
    CGPoint destination = location;
    destination.x += velocity.x * t;
    destination.y += velocity.y * t;
    
    UIView *container = [self.interactiveContext containerView];
    UIViewController *fromVC = [self.interactiveContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [self.interactiveContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIToolbar *blurView = objc_getAssociatedObject(fromVC, RWBlurViewKey);
    UIView *snapshotView = objc_getAssociatedObject(fromVC, RWSnapshotViewKey);
    
    toVC.view.frame = [self.interactiveContext finalFrameForViewController:toVC];
    [container insertSubview:toVC.view belowSubview:blurView];
    
    [self.animator removeAllBehaviors];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[fromVC.view]];
    [itemBehavior addLinearVelocity:velocity forItem:fromVC.view];
    [itemBehavior addAngularVelocity:self.interactiveAngularVelocity forItem:fromVC.view];
    [itemBehavior setAngularResistance:2];
    
    itemBehavior.action = ^{
        if (!CGRectIntersectsRect(fromVC.view.frame, container.bounds))
        {
            [self.animator removeAllBehaviors];
            [fromVC.view removeFromSuperview];
            [UIView animateWithDuration:[self transitionDuration:self.interactiveContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
                blurView.alpha = 0;
            } completion:^(BOOL finished) {
                [blurView removeFromSuperview];
                [snapshotView removeFromSuperview];
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
    UIView *container = [self.interactiveContext containerView];
    UIViewController *fromVC = [self.interactiveContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:[self transitionDuration:self.interactiveContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
        [self.animator removeAllBehaviors];
        fromVC.view.transform = CGAffineTransformIdentity;
        fromVC.view.frame = [RWBlurPopoverTransitionController presentationFrameForViewController:fromVC inContainer:container];
    } completion:^(BOOL finished) {
        [self.interactiveContext cancelInteractiveTransition];
        [self.interactiveContext completeTransition:NO];
        [self interactiveTransitionCleanup];
    }];
}


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4;
}

@end