<img src="https://badgen.net/badge/FaceAI%20SDK/%20%E5%BF%AB%E9%80%9F%E5%AE%9E%E7%8E%B0%E4%BA%BA%E8%84%B8%E8%AF%86%E5%88%AB%E5%8A%9F%E8%83%BD" />


## FaceAISDK 介绍
iPhone&iPad iOS FaceAISDK is on_device Offline Face Detection 、Recognition 、Liveness Detection Anti Spoofing SDK.  
FaceAISDK_iOS SDK是设备端可完全离线不需联网实现人脸录入、活体检测、人脸识别，集成后可快速实现相关功能。  


## 集成步骤

SDK 默认开发环境为 Xcode 15.2 (Swift 5.9)，并已验证兼容至 Xcode 26.5 (Swift 6.3)。UI 层全量采用 SwiftUI 构建；  
全面支持 iOS/iPadOS [15, 26]，还可原生运行于搭载 Apple Silicon（M系列芯片）的 Mac 设备 

  ```
    pod 'FaceAISDK_Core', :git => 'https://github.com/FaceAISDK/FaceAISDK_Core.git', :tag => '2026.04.27'
    # pod 'FaceAISDK_Core', '2026.04.27'
  ```

### 1.首次运行/更新版本发生闪退异常
  TensorFlowLiteSwift首次运行或更新版本后发生闪退并报错
  ```
    X Thread 1: EXC BAD ACCESS (code=1, address=0x800008)
  ```
  在Xcode菜单Product执行clean all Issues后
  再次执行pod命令升级FaceAISDK:  **pod update FaceAISDK_Core**

### 2. 确认电脑能科学上网翻墙后，使用Pod命令安装FaceAISDK和相关依赖库
  一般pod install 命令能完整的下载同步安装好所有依赖，也可以pod update FaceAISDK_Core仅更新人脸识别SDK
 **首次**安装基础依赖TensorFlowLiteSwift**耗时30分钟左右**（和网络环境和设备有关）

 你也可以在浏览器中看看当前网络环境下载TensorFlowLiteSwift情况：  
 https://github.com/tensorflow/tensorflow/archive/refs/heads/master.zip

 ```
 「没有翻墙的错误提示」
  Updating local specs repositories
  Downloading dependencies
  Installing FaceAISDK_Core 2026.04.26 
  [!] Error installing FaceAISDK_Core
  Cloning into '/var/folders/gh/p4wv4ytj4tn5xrhgq0n_jnbm0000gn/T/d20251020-8626-c57agm'...
  fatal: unable to access 'https://github.com/FaceAISDK/FaceAISDK_Core.git/': Error in the HTTP2 framing layer
 ```
 
### 3. 下载依赖TensorFlowLiteSwift出错了
   ```
    [!] Error installing TensorFlowLiteSwift
    
    Cloning into '/var/folders/ft/7cxjq5ss2094sj67mbhnzjrc0000gn/T/d20260113-17932-1xwealt'...
    error: RPC failed; curl 18 transfer closed with outstanding read data remaining
    error: 3926 bytes of body are still expected
    fetch-pack: unexpected disconnect while reading sideband packet
    fatal: early EOF
   ```
    保证网络环境以及增加Git缓存大小
    Bash
    git config --global http.postBuffer 998576000
    git config --global https.postBuffer 998576000

## 其他说明 
  
  **iOS纯Swift：** https://github.com/FaceAISDK/FaceAISDK_iOS  
  **iOS OC混编：** https://github.com/FaceAISDK/FaceAISDK_iOS  

  **Android：** https://github.com/FaceAISDK/FaceAISDK_Android     
  **Flutter 插件：** https://github.com/FaceAISDK/FaceAISDK_Flutter_Plugin  
  **uniApp UTS插件：** https://github.com/FaceAISDK/FaceAISDK_uniapp_UTS  
  
  Email: FaceAISDK.Service@gmail.com   
  
  ![FaceAISDK](/Doc/FaceAISDK.jpeg)  
  
## Android体验Demo APK下载如下  
  
<div align=center>
<img src="https://user-images.githubusercontent.com/15169396/210045090-60c073df-ddbd-4747-8e24-f0dce1eccb58.png" width = 22% />
</div>  

.  



