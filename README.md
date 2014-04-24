RWBlurPopover
=============

Show a UIViewController in a popover with background blurred. Support iOS 5.1+ on iPhone and iPad. Inspired by [Twitter #music](https://itunes.apple.com/us/app/twitter-music/id625541612). ARC is required.

[![](http://zhangbin.cc/temp/RWBlurPopover/demo-iPhone.jpg)](http://zhangbin.cc/temp/RWBlurPopover/demo-iPhone.mp4)
[![](http://zhangbin.cc/temp/RWBlurPopover/demo-iPad.jpg)](http://zhangbin.cc/temp/RWBlurPopover/demo-iPad.mp4)

Click on the images above to view demo videos.

Installation
----

1. Add to your project as a submodule: 
    
        git submodule add https://github.com/eternityz/RWBlurPopover.git RWBlurPopover

2. Open your project in Xcode, drag and drop `RWBlurPopover.xcodeproj` onto your project or workspace.
3. Select your target in project settings, and go to the **Build Phases** tab. Add RWBlurPopover into **Target Dependencies**. Add `libRWBlurPopover.a` into **Link Binary With Libraries**. 
4. Add these frameworks to your project: Accelerate, CoreGraphics.
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
