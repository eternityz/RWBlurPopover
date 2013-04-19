//
//  RWBlurPopover.m
//  RWBlurPopover
//
//  Created by Bin Zhang on 13-4-19.
//  Copyright (c) 2013年 Fresh-Ideas Studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <GPUImage.h>
#import "RWBlurPopover.h"


@interface RWBlurPopover ()

@property (nonatomic, strong) UIImage *origImage;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation RWBlurPopover

+ (RWBlurPopover *)instance
{
    static RWBlurPopover *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [RWBlurPopover new];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.alpha = 1.0;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (UIImage *)imageFromView:(UIView *)v
{
    CGSize size = v.bounds.size;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    size.width *= scale;
    size.height *= scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(ctx, scale, scale);
    
    [v.layer renderInContext:ctx];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)prepareBlurredImage
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.origImage = [self imageFromView:rootViewController.view];
    self.blurredImageView = [[UIImageView alloc] initWithFrame:rootViewController.view.bounds];
    self.blurredImageView.alpha = 0;
    [rootViewController.view addSubview:self.blurredImageView];
}

- (void)presentBlurredViewAnimated:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"before filter");
        GPUImageFastBlurFilter *filter = [[GPUImageFastBlurFilter alloc] init];
        filter.blurSize = [UIScreen mainScreen].scale * 2;
        filter.blurPasses = 5;
        
        self.blurredImageView.image = [filter imageByFilteringImage:self.origImage];
        NSLog(@"after filter");
        self.origImage = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (animated)
            {
                [UIView animateWithDuration:0.4 animations:^{
                    self.blurredImageView.alpha = 1.0;
                } completion:^(BOOL finished) {
                }];
            }
            else
            {
                self.blurredImageView.alpha = 1.0;
            }
        });
    });
}

- (void)removeBlurredViewAnimated:(BOOL)animated
{
    if (!animated)
    {
        [self.blurredImageView removeFromSuperview];
        self.blurredImageView = nil;
    }
    else
    {
        [UIView animateWithDuration:0.4 animations:^{
            self.blurredImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.blurredImageView removeFromSuperview];
            self.blurredImageView = nil;
        }];
    }
}

- (void)presentViewController:(UIViewController *)viewController withHeight:(CGFloat)height
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.contentViewController = viewController;
    [self prepareBlurredImage];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.contentViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        [rootViewController presentModalViewController:self.contentViewController animated:YES];
        [self presentBlurredViewAnimated:YES];
    }
    else
    {
        self.contentView.frame = CGRectMake(0,
                                            rootViewController.view.bounds.size.height,
                                            rootViewController.view.bounds.size.width,
                                            height
                                            );
        [self.contentView addSubview:self.contentViewController.view];
        self.contentViewController.view.frame = self.contentView.bounds;
        
        [rootViewController viewWillDisappear:YES];
        [rootViewController.view addSubview:self.contentView];
        
        [self.contentViewController viewWillAppear:YES];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.contentView.frame = CGRectMake(0,
                                                rootViewController.view.bounds.size.height - height,
                                                rootViewController.view.bounds.size.width,
                                                height
                                                );
        } completion:^(BOOL finished) {
            [self presentBlurredViewAnimated:YES];
            [self.contentViewController viewDidAppear:YES];
            [rootViewController viewDidDisappear:YES];
        }];
    }
    
}

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self removeBlurredViewAnimated:YES];
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self.contentViewController viewWillDisappear:YES];
        [[UIApplication sharedApplication].keyWindow.rootViewController viewWillAppear:YES];
        [UIView animateWithDuration:0.4 animations:^{
            CGRect rect = self.contentView.frame;
            rect.origin.y += rect.size.height;
            self.contentView.frame = rect;
            self.blurredImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.contentView removeFromSuperview];
            [self.contentViewController.view removeFromSuperview];
            [[UIApplication sharedApplication].keyWindow.rootViewController viewDidAppear:YES];
            [self.contentViewController viewDidDisappear:YES];
            self.contentViewController = nil;
            [self removeBlurredViewAnimated:NO];
        }];
    }
    
}

@end
