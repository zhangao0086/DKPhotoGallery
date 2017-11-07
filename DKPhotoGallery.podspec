Pod::Spec.new do |s|
    s.name          = 'DKPhotoGallery'
    s.version       = '0.0.1'
    s.summary       = 'A Photo Gallery / Browser / Viewer for iOS written in Swift 3'
    s.homepage      = 'https://github.com/zhangao0086/DKPhotoGallery'
    s.license       = { :type => 'MIT', :file => 'LICENSE' }
    s.author        = { 'Bannings' => 'zhangao0086@gmail.com' }
    s.platform      = :ios, '8.0'
    s.source        = { :git => 'https://github.com/zhangao0086/DKPhotoGallery.git', 
                       :tag => s.version.to_s }
    s.resource      = 'DKPhotoGallery/Resource/DKPhotoGalleryResource.bundle'

    s.frameworks    = 'Foundation', 'UIKit', 'Photos', 'WebKit', 'AVFoundation', 'AVKit', 'AssetsLibrary'
    s.requires_arc  = true

    s.dependency 'SDWebImage/GIF', '~> 4.0'
    s.dependency 'MBProgressHUD', '1.0.0'

    s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }

    s.subspec 'Core' do |core|
        core.dependency 'DKPhotoGallery/Model'
        core.dependency 'DKPhotoGallery/Preview'

        core.source_files  =    'DKPhotoGallery/DKPhotoGallery.swift', 
                                'DKPhotoGallery/DKPhotoGalleryContentVC.swift', 
                                'DKPhotoGallery/DKPhotoGalleryScrollView.swift',
                                'DKPhotoGallery/DKPhotoPreviewFactory.swift',
                                'DKPhotoGallery/Transition/*.swift'
    end

    s.subspec 'Model' do |model|
        model.source_files = 'DKPhotoGallery/DKPhotoGalleryItem.swift'
    end

    s.subspec 'Preview' do |preview|
        preview.dependency 'DKPhotoGallery/Model'
        preview.dependency 'DKPhotoGallery/Resource'

        preview.source_files = 'DKPhotoGallery/Preview/**/*.swift'
    end

    s.subspec 'Resource' do |resource|
        resource.source_files = 'DKPhotoGallery/Resource/*.swift'
    end

end