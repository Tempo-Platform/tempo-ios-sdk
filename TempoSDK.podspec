#
# Run `pod lib lint TempoSDK.podspec' to validate the spec after any changes
#
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'TempoSDK'
  spec.version          = '1.5.2-rc.0'
  spec.swift_version    = '5.6.1'
  spec.author           = { 'Tempo Engineering' => 'development@tempoplatform.com' }
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage         = 'https://github.com/Tempo-Platform/tempo-ios-sdk'
  spec.readme           = 'https://github.com/Tempo-Platform/tempo-ios-sdk/blob/main/README.md'
  spec.source           = { :git => 'https://github.com/Tempo-Platform/tempo-ios-sdk.git', :tag => spec.version.to_s }
  spec.summary          = 'Tempo SDK to show payable ads'

  spec.ios.deployment_target = '11.0'

  spec.source_files  = 'TempoSDK/**/*.{h,m,swift}'
  spec.resource_bundles = {
      'TempoSDK' => ['TempoSDK/Resources/**/*']
    }
  
  spec.tvos.pod_target_xcconfig  = { 'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64', }
  spec.tvos.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64' }
  spec.pod_target_xcconfig       = { 'PRODUCT_BUNDLE_IDENTIFIER': 'com.tempoplatform.sdk' }
end
