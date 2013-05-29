RWBlurPopover
=============

Show a UIViewController in a popover with background blurred. Support iOS 5.1+ on iPhone and iPad. Inspired by [Twitter #music](https://itunes.apple.com/us/app/twitter-music/id625541612).

[![](http://zhangbin.cc/temp/blur-iphone-thumb.jpg)](http://zhangbin.cc/temp/blur-iphone.jpg)
[![](http://zhangbin.cc/temp/blur-ipad-thumb.jpg)](http://zhangbin.cc/temp/blur-ipad.jpg)

This project uses GPUImageFastBlurFilter from [GPUImage](https://github.com/BradLarson/GPUImage) to do the blurring. [GPUImage](https://github.com/BradLarson/GPUImage) is faster than Core Image CIGaussianFilter according to this article [Blur Effect in iOS Applications](http://blog.denivip.ru/index.php/2013/01/blur-effect-in-ios-applications/?lang=en), and CIGaussianFilter is only available on iOS 6+, while GPUImage supports iOS 4.0+.

ARC is required.

Installation
----

1. Add to your project as a submodule: 
    
        git submodule add https://github.com/eternityz/RWBlurPopover.git RWBlurPopover
        git submodule update --init --recursive

2. Open your project in Xcode, drag and drop `RWBlurPopover.xcodeproj` onto your project or workspace.
3. Select your target in project settings, and go to the **Build Phases** tab. Add RWBlurPopover into **Target Dependencies**. Add `libRWBlurPopover.a` into **Link Binary With Libraries**. 
4. Add these frameworks to your project (required by GPUImage): CoreMedia, CoreVideo, OpenGLES, QuartzCore, AVFoundation.
5. Include RWBlurPopover whenever you need it with `#import <RWBlurPopover/RWBlurPopover.h>`.

Useage
----
- Present a UIViewController inside a popover with background blurred:

```objective-c
[[RWBlurPopover instance] presentViewController:viewController withHeight:300];
```

Note: On iPad, the `height` parameter is unused.

- Dismiss the view controller presented by RWBlurPopover:

```objective-c
[[RWBlurPopover instance] dismissViewControllerAnimated:YES completion:^(void){
    // some completion work
}];
```

License
----
MIT License
