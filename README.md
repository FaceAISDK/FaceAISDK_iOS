<img src="https://badgen.net/badge/FaceAI%20SDK/%20%E5%BF%AB%E9%80%9F%E5%AE%9E%E7%8E%B0%E4%BA%BA%E8%84%B8%E8%AF%86%E5%88%AB%E5%8A%9F%E8%83%BD" />


<div align=center>
<img src="https://github.com/user-attachments/assets/b1e0a9c4-8b43-4eb8-bf7a-7632901cfb2c" width = 15% />
</div>


## FaceAISDK 介绍
iPhone&iPad iOS FaceAISDK is on_device Offline Face Detection 、Recognition 、Liveness Detection Anti Spoofing SDK.  
FaceAISDK_iOS SDK是设备端可完全离线不需联网实现人脸录入、动作活体检测、人脸识别，集成后可快速实现相关功能。  


  ![FaceAISDK](/Doc/SDK_WORK_FLOW.jpg)  


## 更新说明 V2025.12.31
- 新加炫彩活体检测beat
- 优化UI交互细节和多语言
- 提高不同设备相机的兼容性

[更多历史版本介绍见](/Doc/历史版本SDK更新记录.md)  

## 集成步骤

SDK默认的开发环境为Xcode 15.2 ,Swift 5.9；UI全部使用SwiftUI实现，支持iOS[16,26]

**集成运行本SDK 示范工程，你的电脑需要能科学上网翻墙同步依赖，因为部分资源托管在GitHub，否则无法编译成功**


### 1. 确认电脑能科学上网翻墙后，使用Pod命令安装FaceAISDK和相关依赖库
一般pod install 命令能完整的下载同步安装好所有依赖，也可以pod update FaceAISDK_Core仅更新人脸识别SDK
**首次**安装基础依赖TensorFlowLiteSwift**耗时30分钟左右**（和网络环境和设备有关），建议此时去喝杯水活动一下颈椎😭

你也可以在浏览器中看看当前网络环境下载TensorFlowLiteSwift情况：  
https://github.com/tensorflow/tensorflow/archive/refs/heads/master.zip

```
「没有翻墙的错误提示」
Updating local specs repositories
Downloading dependencies
Installing FaceAISDK_Core 2025.10.17 

[!] Error installing FaceAISDK_Core
[!] /usr/bin/git clone https://github.com/FaceAISDK/FaceAISDK_Core.git /var/folders/gh/p4wv4ytj4tn5xrhgq0n_jnbm0000gn/T/d20251020-8626-c57agm --template= --single-branch --depth 1 --branch 2025.10.17

Cloning into '/var/folders/gh/p4wv4ytj4tn5xrhgq0n_jnbm0000gn/T/d20251020-8626-c57agm'...
fatal: unable to access 'https://github.com/FaceAISDK/FaceAISDK_Core.git/': Error in the HTTP2 framing layer
```
 **经过漫长的等待，编译完成后 就可以在体验效果了**


## 其他说明 
  
  微信：FaceAISDK  
  Email: FaceAISDK.Service@gmail.com   
  iOS SDK： https://github.com/FaceAISDK/FaceAISDK_iOS  
  Android： https://github.com/FaceAISDK/FaceAISDK_Android     
  **其他实现**  
  **React native** https://github.com/zkteco-home/react-native-face-ai  
  **uniApp UTS插件：**  https://github.com/FaceAISDK/FaceAISDK_uniapp_UTS  
  
  ![FaceAISDK](/Doc/FaceAISDK.png)  
  
## Android体验Demo APK下载如下  
  
<div align=center>
<img src="https://user-images.githubusercontent.com/15169396/210045090-60c073df-ddbd-4747-8e24-f0dce1eccb58.png" width = 22% />
</div>  

.  



