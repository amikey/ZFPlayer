Pod::Spec.new do |s|
    s.name         = 'ZFPlayer'
    s.version      = '0.0.8'
    s.summary      = 'An easy way to user Player'
    s.homepage     = 'https://github.com/renzifeng/ZFPlayer'
    s.license      = 'MIT'
    s.authors      = { 'renzifeng' => 'zifeng1300@gmail.com' }
    s.platform     = :ios, '7.0'
    s.source       = { :git => 'https://github.com/renzifeng/ZFPlayer.git', :tag => s.version.to_s, :commit => 'b33d719a1ed8273bbcfb8ac1dc96af6de4c490de'}
    s.source_files = 'ZFPlayer/*.{h,m}'
    s.resource     = 'ZFPlayer/ZFPlayer.bundle'
    s.framework    = 'UIKit','MediaPlayer'
    s.dependency 'Masonry'
    s.requires_arc = true
end