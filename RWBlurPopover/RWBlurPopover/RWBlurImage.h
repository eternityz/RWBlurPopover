//
//  RWBlurImage.h
//  RWBlurPopover
//
//  Created by Zhang Bin on 2014-04-22.
//  Copyright (c) 2014年 Fresh-Ideas Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RWBlurImage : NSObject

+ (UIImage *)blurImage:(UIImage *)image withRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
