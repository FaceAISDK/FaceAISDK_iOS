
platform :ios, '15.5'


target 'FaceAISDK_iOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # pod update FaceAISDK_Core
  pod 'FaceAISDK_Core', :git => 'https://github.com/FaceAISDK/FaceAISDK_Core.git', :tag => '2026.08.01'
#  pod 'FaceAISDK_Core', '****version****'

end


#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.5'
#      if config.name == 'Debug'
#        config.build_settings['SWIFT_COMPILATION_MODE'] = 'incremental'
#        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
#        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
#      end
#    end
#  end
#
#end
