Pod::Spec.new do |s|
    s.name         = 'ZFPlayer'
    s.version      = '0.0.4'
    s.summary      = 'An easy way to user Player'
    s.homepage     = 'https://github.com/renzifeng/ZFPlayer'
    s.license      = 'MIT'
    s.authors      = { 'renzifeng' => 'zifeng1300@gmail.com' }
    s.platform     = :ios, '7.0'
    s.source       = { :git => 'https://github.com/renzifeng/ZFPlayer.git', :tag => s.version.to_s, :commit => '8bd2245aa7d520d8a240b6cf400a5e1d0d21f0f1'}
    s.source_files = 'ZFPlayer/*.{h,m}'
    s.resource_bundles = {
        'MyPodBundle' => ['ZFPlayer/*.{xib}']
    }
    s.resource     = 'ZFPlayer/ZFPlayer.bundle'
    s.framework    = 'UIKit','MediaPlayer'
    s.dependency 'Masonry', '~> 0.6.4'
    s.dependency 'XXNibBridge', '~> 2.2.3'
    s.requires_arc = true
end