//
//  RWBlurPopover.h
//  RWBlurPopover
//
//  Created by Bin Zhang on 13-4-19.
//  Copyright (c) 2013年 Fresh-Ideas Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RWBlurPopover : NSObject

+ (instancetype)instance;

- (void)presentViewController:(UIViewController *)viewController withHeight:(CGFloat)height;
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;

@property (nonatomic, assign) BOOL skipOldDevices;
        // default NO.
        // If set to YES, blurring will only works on iPhone >= 4S, iPad >= 2G, iPad mini, iPod touch >= 5G

@end
