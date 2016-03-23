Pod::Spec.new do |s|
    s.name         = "ZFPlayer"
    s.version      = "0.0.2"
    s.summary      = "An easy way to user Player"
    s.homepage     = "https://github.com/renzifeng/ZFPlayer"
    s.license      = "Apache"
    s.author       = { "renzifeng" => "459643690@qq.com" }
    s.platform     = :ios, "7.0"
    s.source       = { :git => "https://github.com/renzifeng/ZFPlayer.git", :tag => s.version }
    s.source_files  = "ZFPlayer/*.{h,m,xib}"
    s.exclude_files = "ZFPlayer/ZFPlayer.bundle"
    s.framework  = "MediaPlayer"
    s.requires_arc = true
    s.dependency "Masonry"
    s.dependency "XXNibBridge"
end
