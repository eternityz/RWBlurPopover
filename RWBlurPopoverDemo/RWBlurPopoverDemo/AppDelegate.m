//
//  AppDelegate.m
//  RWBlurPopoverDemo
//
//  Created by Bin Zhang on 13-4-19.
//  Copyright (c) 2013年 Fresh-Ideas Studio. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    
    DemoViewController *vc = [[DemoViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
