Pod::Spec.new do |s|
    s.name          = 'DKPhotoGallery'
    s.version       = '0.0.11'
    s.summary       = 'A Photo Gallery / Browser / Viewer for iOS written in Swift'
    s.homepage      = 'https://github.com/zhangao0086/DKPhotoGallery'
    s.license       = { :type => 'MIT', :file => 'LICENSE' }
    s.author        = { 'Bannings' => 'zhangao0086@gmail.com' }
    s.platform      = :ios, '8.0'
    s.source        = { :git => 'https://github.com/zhangao0086/DKPhotoGallery.git', 
                       :tag => s.version.to_s }

    s.frameworks    = 'Foundation', 'UIKit', 'Photos', 'WebKit', 'AVFoundation', 'AVKit', 'AssetsLibrary', 'MobileCoreServices'
    s.requires_arc  = true
    s.swift_version = '4.2'
    s.dependency 'SDWebImage/GIF'

    s.subspec 'Core' do |core|
        core.dependency 'DKPhotoGallery/Model'
        core.dependency 'DKPhotoGallery/Preview'

        core.source_files  =    'DKPhotoGallery/DKPhotoGallery.swift', 
                                'DKPhotoGallery/DKPhotoGalleryContentVC.swift', 
                                'DKPhotoGallery/DKPhotoGalleryScrollView.swift',
                                'DKPhotoGallery/DKPhotoPreviewFactory.swift',
                                'DKPhotoGallery/DKPhotoIncrementalIndicator.swift',
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
        resource.resource_bundle = { "DKPhotoGallery" => "DKPhotoGallery/Resource/Resources/*" }

        resource.source_files = 'DKPhotoGallery/Resource/*.swift'
    end

end
