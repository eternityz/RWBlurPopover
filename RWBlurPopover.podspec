Pod::Spec.new do |s|

  s.name         = "RWBlurPopover"
  s.version      = "1.0.0"
  s.summary      = "Show a UIViewController in a popover with background blurred. "

  s.description  = <<-DESC
                   Show a UIViewController in a popover with background blurred. 
                   Support iOS 5.1+ on iPhone and iPad. Inspired by Twitter music.
                   DESC

  s.homepage     = "https://github.com/eternityz/RWBlurPopover"

  s.license      = "MIT"
  
  s.author             = { "eternityz" => "id@zhangbin.cc" }
  s.social_media_url   = "http://twitter.com/eternity1st"

  s.platform     = :ios, "5.1"

  s.ios.deployment_target = "5.1"

  s.source       = { :git => "https://github.com/eternityz/RWBlurPopover.git", :tag => "1.0.0" }

  s.source_files  = "RWBlurPopover", "RWBlurPopover/**/*.{h,m}"

  s.requires_arc = true

end
