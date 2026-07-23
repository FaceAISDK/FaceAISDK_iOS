platform :ios, '15.5'

use_frameworks! 


target 'FaceAISDK_iOS' do
  # pod update FaceAISDK_Core
  pod 'FaceAISDK_Core', :git => 'https://github.com/FaceAISDK/FaceAISDK_Core.git', :tag => '2026.07.19'
#  pod 'FaceAISDK_Core', '****version****'

end





post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.5'
    end
  end

end
