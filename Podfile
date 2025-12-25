# 1. 定义公共的版本号变量，方便一处修改全域生效
$face_sdk_version = '2025.12.25'

# 2. 定义公共的FaceAISDK依赖函数
def shared_pods
  pod 'FaceAISDK_Core', $face_sdk_version
end

# 微信最新版本支持iOS 15+ ，后期SDK也将跟随支持。 and https://iosref.com/ios-usage
platform :ios, '16.0'
use_frameworks!

workspace 'FaceAISDK_iOS.xcworkspace'

target 'FaceAISDK_demo' do
  project 'FaceAISDK_demo/FaceAISDK_demo.xcodeproj'

  # 1. 命令 pod update FaceAISDK_Core 安装更新FaceAISDK依赖,请指定版本。
  # 不同开发设备和网络环境，首次集成到主项目依赖同步耗时20-30分钟不等
  # 调用FaceAISDK公共依赖
    shared_pods
end








post_install do |installer|
    installer.pods_project.targets.each do |target|
      # 启用库演进支持
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
end



#----------   以下是打包XCFrameWork 制作插件用,SDK接入方不用关心    --------------
# CD 到Product 目录然后命令
# xcodebuild -create-xcframework -framework Release-iphoneos/FaceAISDK_Lib.framework -output FaceAISDK_Lib.xcframework
target 'FaceAISDK_Lib' do
  project 'FaceAISDK_Lib/FaceAISDK_Lib.xcodeproj'
  # 调用公共依赖
  shared_pods
end
