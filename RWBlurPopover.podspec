Pod::Spec.new do |s|

  s.name         = "RWBlurPopover"
  s.version      = "3.1.0"
  s.summary      = "Show a UIViewController in a popover with background blurred. "

  s.description  = <<-DESC
                   Show a UIViewController in a popover with background blurred. Based on iOS7 UIKit Dynamics and custom UIViewController transitions.
                   DESC

  s.homepage     = "https://github.com/eternityz/RWBlurPopover"

  s.license      = "MIT"
  
  s.author             = { "eternityz" => "id@zhangbin.cc" }
  s.social_media_url   = "http://twitter.com/eternity1st"

  s.platform     = :ios, "7.0"

  s.ios.deployment_target = "7.0"

  s.source       = { :git => "https://github.com/eternityz/RWBlurPopover.git", :tag => "3.1.0" }

  s.source_files  = "RWBlurPopover", "RWBlurPopover/**/*.{h,m}"

  s.requires_arc = true

end
