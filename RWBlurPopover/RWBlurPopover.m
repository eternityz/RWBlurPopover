//
//  RWBlurPopover.m
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-07-07.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

#import "RWBlurPopover.h"
#import "RWBlurPopoverTransitionController.h"

@interface RWBlurPopover () <UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIViewController *contentViewController;
@property (nonatomic, strong) RWBlurPopoverTransitionController *transitionController;
@property (nonatomic, strong) RWBlurPopoverInteractiveTransitionController *interactiveTransitionController;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) BOOL isInteractiveDismissal;

@end

@implementation RWBlurPopover

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.contentViewController = contentViewController;
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.throwingGestureEnabled = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.clipsToBounds = NO;
    self.contentViewController.view.frame = self.view.bounds;
    self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.contentViewController.view];
    
    if ([self isThrowingGestureEnabled])
    {
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self.view addGestureRecognizer:self.panGestureRecognizer];
    }
}

- (CGSize)preferredContentSize
{
    return [self.contentViewController preferredContentSize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addChildViewController:self.contentViewController];
    [self.contentViewController didMoveToParentViewController:self];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gr
{
    switch (gr.state) {
        case UIGestureRecognizerStateBegan: {
            self.isInteractiveDismissal = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.interactiveTransitionController startInteractiveTransitionWithTouchLocation:[gr locationInView:self.view]];
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            [self.interactiveTransitionController updateInteractiveTransitionWithTouchLocation:[gr locationInView:self.view]];
            break;
        }
            
        case UIGestureRecognizerStateEnded: case UIGestureRecognizerStateCancelled: {
            CGPoint velocity = [gr velocityInView:self.view];
            self.isInteractiveDismissal = NO;
            if (fabs(velocity.x) + fabs(velocity.y) <= 1000 || gr.state == UIGestureRecognizerStateCancelled)
            {
                [self.interactiveTransitionController cancelInteractiveTransitionWithTouchLocation:[gr locationInView:self.view]];
            }
            else
            {
                [self.interactiveTransitionController finishInteractiveTransitionWithTouchLocation:[gr locationInView:self.view] velocity:velocity];
            }
            break;
        }
            
        default:
            break;
    }
}

- (RWBlurPopoverTransitionController *)transitionController
{
    @synchronized(self)
    {
        if (!_transitionController)
        {
            _transitionController = [RWBlurPopoverTransitionController new];
        }
        return _transitionController;
    }
}

- (RWBlurPopoverInteractiveTransitionController *)interactiveTransitionController
{
    @synchronized(self)
    {
        if (!_interactiveTransitionController)
        {
            _interactiveTransitionController = [RWBlurPopoverInteractiveTransitionController new];
        }
        return _interactiveTransitionController;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.transitionController.isPresentation = YES;
    return self.transitionController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transitionController.isPresentation = NO;
    return self.transitionController;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if ([self isInteractiveDismissal] && [animator isKindOfClass:[RWBlurPopoverTransitionController class]])
    {
        return self.interactiveTransitionController;
    }
    return nil;
}

@end
