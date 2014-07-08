RWBlurPopover
=============

Show a UIViewController in a popover with background blurred. Introduced in [China Air Quality Index](http://air.fresh-ideas.cc).

[Demo Video](http://zhangbin.cc/temp/RWBlurPopover2/demo.mp4)

Click on the images above to view demo videos.

iOS 7.0+ is required. "Throwing away to dismiss" gesture is inspired by [Tweetbot](http://tapbots.com/software/tweetbot/).

NOTE: Release 2.0.0 of RWBlurPopover is incompatible with previous releases.

Installation
----

- Add a pod description into your `podfile`:

            pod 'RWBlurPopover', '~> 2.0.0'

OR

- Clone this repo, drop `.h` and `.m` files from `RWBlurPopover` into your project.

Useage
----
- Include RWBlurPopover whenever you need it with `#import <RWBlurPopover/RWBlurPopover.h>`.

- Present a UIViewController inside a popover with background blurred:

```objective-c
UIViewController *popoverContentViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
RWBlurPopover *popover = [[RWBlurPopover alloc] initWithContentViewController:vc];
[parentViewController presentViewController:popover animated:YES completion:nil];
```

- Dismiss the view controller presented by RWBlurPopover:

```objective-c
[popoverContentViewController dismissViewControllerAnimated:YES completion:nil];
```

License
----
MIT License
