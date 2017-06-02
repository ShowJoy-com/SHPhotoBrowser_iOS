Pod::Spec.new do |s|
    s.name         = "SHPhotoBrowser"
    s.version      = "0.0.2"
    s.summary      = "SHPhotoBrowser"
    s.description  = "SHPhotoBrowser ShowJoy"
    s.homepage     = "https://github.com/ShowJoy-com/SHPhotoBrowser_iOS.git"
    s.license      = "MIT"
    s.author      = { "果冻" => "guodong@showjoy.com" }
    s.source       = { :git => "https://github.com/ShowJoy-com/SHPhotoBrowser_iOS.git", :tag => "#{s.version}"}
    s.source_files  = "SHPhotoBrowser/SHPhotoBrowser/**/*.{h,m}"
    s.requires_arc = true
    s.ios.deployment_target = '7.0'

    spec.subspec 'PINRemoteImage' do |pin|
        pin.dependency 'PINRemoteImage/iOS', '= 3.0.0-beta.9'
        pin.dependency 'PINRemoteImage/PINCache'
    end

end
