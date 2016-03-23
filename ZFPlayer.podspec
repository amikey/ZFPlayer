Pod::Spec.new do |s|
    s.name         = "ZFPlayer"
    s.version      = "0.0.1"
    s.summary      = "An easy way to user Player"
    s.homepage     = "https://github.com/renzifeng/ZFPlayer"
    s.license      = "Apache"
    s.author       = { "renzifeng" => "459643690@qq.com" }
    s.platform     = :ios, "6.0"
    s.source       = { :git => "https://github.com/renzifeng/ZFPlayer.git", :tag => "0.0.1" }
    s.source_files  = "ZFPlayer/*.{h,m}"
    s.exclude_files = "ZFPlayer/ZFPlayer.bundle"
    s.framework  = "MediaPlayer"
    s.requires_arc = true
    s.dependency "Masonry"
    s.dependency "XXNibBridge"
end
