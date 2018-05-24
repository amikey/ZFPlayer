#
# Be sure to run `pod lib lint ZFPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZFPlayer'
  s.version          = '3.0.0'
  s.summary          = 'A good player made by renzifeng'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  support the vertical, horizontal screen(lock screen direction). Support adjust volume, brigtness and video progress
  DESC

  s.homepage         = 'https://github.com/renzifeng/ZFPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'renzifeng' => 'zifeng1300@gmail.com' }
  s.source           = { :git => 'https://github.com/renzifeng/ZFPlayer.git', :tag => s.version.to_s }
  s.social_media_url = 'http://weibo.com/zifeng1300'

  s.ios.deployment_target = '7.0'

  s.source_files = 'ZFPlayer/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZFPlayer' => ['ZFPlayer/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MediaPlayer', 'AVFoundation'
  s.requires_arc = true
end
