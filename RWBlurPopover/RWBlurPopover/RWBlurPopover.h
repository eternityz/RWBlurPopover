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

@end
