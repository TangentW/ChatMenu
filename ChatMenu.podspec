#
#  Be sure to run `pod spec lint ChatMenu.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "ChatMenu"
  s.version      = "1.0.4"
  s.summary      = "A menu display on chat bubble view just like iMessage."
  s.homepage     = "https://github.com/TangentW/ChatMenu"
  s.license      = "MIT"
  s.author             = { "Tangent" => "805063400@qq.com" }
  s.platform     = :ios
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/TangentW/ChatMenu.git", :tag => "1.0.4" }
  s.source_files  = "ChatMenu/ChatMenu/*.swift"
  s.resources = "ChatMenu/ChatMenu/*.xcassets"
  s.framework  = "UIKit"
end
