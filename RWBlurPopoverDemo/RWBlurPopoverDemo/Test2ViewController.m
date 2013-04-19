//
//  Test2ViewController.m
//  RWBlurPopoverDemo
//
//  Created by Bin Zhang on 13-4-20.
//  Copyright (c) 2013年 Fresh-Ideas Studio. All rights reserved.
//

#import <RWBlurPopover/RWBlurPopover.h>
#import "Test2ViewController.h"

@interface Test2ViewController ()

@end

@implementation Test2ViewController

- (void)dismiss
{
    [[RWBlurPopover instance] dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)loadView
{
    [super loadView];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popover_bg"]];
        bg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        bg.frame = CGRectMake(0, 0, self.view.bounds.size.width, bg.image.size.height);
        [self.view addSubview:bg];
    }
    
    UIImage *btnImage = [[UIImage imageNamed:@"btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(10,
                           self.view.bounds.size.height - 10 - btnImage.size.height,
                           self.view.bounds.size.width - 20,
                           btnImage.size.height
                           );
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [btn setBackgroundImage:btnImage forState:UIControlStateNormal];
    [btn setTitle:@"Dismiss" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                           0,
                                                           self.view.bounds.size.width,
                                                           200
                                                           )
                  ];
    l.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont boldSystemFontOfSize:18];
    l.textAlignment = UITextAlignmentCenter;
    l.text = @"Regular View";
    [self.view addSubview:l];
}

@end
