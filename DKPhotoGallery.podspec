Pod::Spec.new do |s|
    s.name          = "DKPhotoGallery"
    s.version       = "0.0.1"
    s.summary       = "A Photo Gallery / Browser / Viewer for iOS written in Swift 3"
    s.homepage      = "https://github.com/zhangao0086/DKPhotoGallery"
    s.license       = { :type => "MIT", :file => "LICENSE" }
    s.author        = { "Bannings" => "zhangao0086@gmail.com" }
    s.platform      = :ios, "8.0"
    s.source        = { :git => "https://github.com/zhangao0086/DKPhotoGallery.git", 
                       :tag => s.version.to_s }
    s.source_files  = "DKPhotoGallery/*.swift"
    s.resource      = "DKPhotoGallery/Resource/DKPhotoGalleryResource.bundle"

    s.frameworks    = "Foundation", "UIKit", "Photos", "WebKit", "AVFoundation", "AssetsLibrary"
    s.requires_arc  = true

    s.dependency 'SDWebImage/GIF', '4.1.0'
    s.dependency 'MBProgressHUD', '1.0.0'

    s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }

    s.subspec 'Preview' do |preview|
        preview.ios.source_files = "DKPhotoGallery/Preview/*.swift"

        preview.subspec 'AssetPreview' do |ss|
          ss.ios.source_files = "DKPhotoGallery/Preview/AssetPreview/*.swift"
        end

        preview.subspec 'LocalImagePreview' do |ss|
          ss.ios.source_files = "DKPhotoGallery/Preview/LocalImagePreview/*.swift"
        end

        preview.subspec 'RemoteImagePreview' do |ss|
          ss.ios.source_files = "DKPhotoGallery/Preview/RemoteImagePreview/*.swift"
        end

        preview.subspec 'QRCode' do |ss|
          ss.ios.source_files = "DKPhotoGallery/Preview/QRCode/*.swift"
        end

    end

    s.subspec 'Transition' do |transition|
        transition.ios.source_files = "DKPhotoGallery/Transition/*.swift"
    end

    s.subspec 'Resource' do |resource|
        resource.ios.source_files = "DKPhotoGallery/Resource/*.swift"
    end

end