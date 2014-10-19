//
//  RWBlurPopover.m
//  RWBlurPopoverDemo
//
//  Created by Zhang Bin on 2014-07-07.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

#import <objc/runtime.h>
#import "RWBlurPopover.h"
#import "RWBlurPopoverView.h"


@interface UIViewController (RWBlurPopover)

- (void)RWBlurPopover_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
@property (nonatomic, strong) RWBlurPopover *RWBlurPopover_associatedPopover;

@end


@interface RWBlurPopover ()

@property (nonatomic, weak) UIViewController *contentViewController;
@property (nonatomic, weak) UIViewController *presentingViewController;
@property (nonatomic, strong) RWBlurPopoverView *popoverView;

@end

@implementation RWBlurPopover

+ (void)load {
    // use method swizzling to capture content view controller 'dismissViewController' message
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class viewControllerClass = [UIViewController class];
        
        SEL origSelector = @selector(dismissViewControllerAnimated:completion:);
        SEL swizzledSelector = @selector(RWBlurPopover_dismissViewControllerAnimated:completion:);
        
        Method origMethod = class_getInstanceMethod(viewControllerClass, origSelector);
        Method swizzledMethod = class_getInstanceMethod(viewControllerClass, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(viewControllerClass, origSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(viewControllerClass, swizzledSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
        } else {
            method_exchangeImplementations(origMethod, swizzledMethod);
        }
    });
}

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController {
    self = [super init];
    if (self)
    {
        self.contentViewController = contentViewController;
        
        self.throwingGestureEnabled = YES;
        
        self.contentViewController.RWBlurPopover_associatedPopover = self;
    }
    return self;
}

- (void)setThrowingGestureEnabled:(BOOL)throwingGestureEnabled {
    _throwingGestureEnabled = throwingGestureEnabled;
    [self.popoverView setThrowingGestureEnabled:throwingGestureEnabled];
}

- (void)showInViewController:(UIViewController *)presentingViewController {
    if (presentingViewController.RWBlurPopover_associatedPopover != nil) {
        NSLog(@"failed to present a RWBlurPopover while another popover is presenting. ");
        return;
    }
    
    self.presentingViewController = presentingViewController;
    self.presentingViewController.RWBlurPopover_associatedPopover = self;
    
    self.popoverView = [[RWBlurPopoverView alloc] initWithContentView:self.contentViewController.view contentSize:[self.contentViewController preferredContentSize]];
    self.popoverView.throwingGestureEnabled = self.throwingGestureEnabled;
    self.popoverView.frame = self.presentingViewController.view.bounds;
    self.popoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.popoverView.translatesAutoresizingMaskIntoConstraints = YES;
    self.popoverView.throwingGestureEnabled = self.throwingGestureEnabled;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.popoverView.blurView addGestureRecognizer:tapGesture];
    
    [self.presentingViewController addChildViewController:self.contentViewController];
    [self.presentingViewController.view addSubview:self.popoverView];
    [self.contentViewController didMoveToParentViewController:self.presentingViewController];
    
    __weak typeof(self) weakSelf = self;
    self.popoverView.dismissalBlock = ^{
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.contentViewController willMoveToParentViewController:nil];
        [strongSelf.popoverView removeFromSuperview];
        [strongSelf.contentViewController removeFromParentViewController];
        
        strongSelf.popoverView = nil;
        strongSelf.contentViewController.RWBlurPopover_associatedPopover = nil;
        strongSelf.presentingViewController.RWBlurPopover_associatedPopover = nil;
    };
    
    [self.popoverView animatePresentation];
}

- (void)dealloc {
    NSLog(@"RWBlurPopover dealloc");
}

- (void)dismiss {
    [self.popoverView animateDismissalWithCompletion:nil];
}

- (void)dismissWithCompletion:(dispatch_block_t)completion {
    [self.popoverView animateDismissalWithCompletion:completion];
}

+ (void)showContentViewController:(UIViewController *)contentViewController
             insideViewController:(UIViewController *)presentingViewController
       withThrowingGestureEnabled:(BOOL)throwingGestureEnabled {
    RWBlurPopover *popoer = [[RWBlurPopover alloc] initWithContentViewController:contentViewController];
    popoer.throwingGestureEnabled = throwingGestureEnabled;
    [popoer showInViewController:presentingViewController];
}

@end

@implementation UIViewController (RWBlurPopover_dismiss)

- (void)RWBlurPopover_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    RWBlurPopover *popover = self.RWBlurPopover_associatedPopover;
    if (popover) {
        // this view controller is displayed inside a RWBlurPopover
        // and about to be dismissed
        [popover dismissWithCompletion:completion];
    } else {
        // perform regular dismissal
        [self RWBlurPopover_dismissViewControllerAnimated:flag completion:completion];
    }
    
}

static const char *RWBlurPopoverKey = "RWBlurPopoverKey";

- (RWBlurPopover *)RWBlurPopover_associatedPopover {
    return objc_getAssociatedObject(self, RWBlurPopoverKey);
}

- (void)setRWBlurPopover_associatedPopover:(RWBlurPopover *)RWBlurPopover_associatedPopover {
    objc_setAssociatedObject(self, RWBlurPopoverKey, RWBlurPopover_associatedPopover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
