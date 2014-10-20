RWBlurPopover
=============

Show a UIViewController in a popover with background blurred. Introduced in [China Air Quality Index](http://air.fresh-ideas.cc).

<p align="center">
    <a href="http://zhangbin.cc/temp/RWBlurPopover3/demo.mp4"><img src="https://raw.github.com/eternityz/RWBlurPopover/master/demo.gif" /></a>
</p>

[Demo Video](http://zhangbin.cc/temp/RWBlurPopover3/demo.mp4)

iOS 7.0+ is required. "Throwing away to dismiss" gesture is inspired by [Tweetbot](http://tapbots.com/software/tweetbot/).

NOTE: Release 3.0.0 of RWBlurPopover is incompatible with previous releases.

Installation
----

- Add a pod description into your `podfile`:

            pod 'RWBlurPopover', '~> 3.0.0'

OR

- Clone this repo, drop `.h` and `.m` files from `RWBlurPopover` into your project.

Useage
----
- Include RWBlurPopover whenever you need it with `#import <RWBlurPopover/RWBlurPopover.h>`.

- Present a UIViewController inside a popover with background blurred:

```objective-c
[RWBlurPopover showContentViewController:contentViewController insideViewController:presentingViewController];

```

- Dismiss the view controller presented by RWBlurPopover:

```objective-c
[contentViewController dismissViewControllerAnimated:YES completion:nil];
```

License
----
MIT License
