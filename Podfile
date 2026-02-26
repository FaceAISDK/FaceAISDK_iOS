
# Uncomment the next line to define a global platform for your project
platform :ios, '15.5'

# 怎么清除缓存？
# 1. pod cache clean --all
# 2. pod deintegrate

target 'FaceAISDK_iOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  
  # 1. 命令 pod update FaceAISDK_Core 安装更新FaceAISDK依赖,请指定版本。
  # 不同开发设备和网络环境，首次集成到主项目依赖同步耗时20-30分钟不等
#  pod 'FaceAISDK_Core', '2026.01.22'

  pod 'FaceAISDK_Core', :git => 'https://github.com/FaceAISDK/FaceAISDK_Core.git', :tag => '2026.01.22'

end
