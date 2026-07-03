<img src="https://badgen.net/badge/FaceAI%20SDK/%20%E5%BF%AB%E9%80%9F%E5%AE%9E%E7%8E%B0%E4%BA%BA%E8%84%B8%E8%AF%86%E5%88%AB%E5%8A%9F%E8%83%BD" />


## 目录导航

- [FaceAISDK 介绍](#faceaisdk-介绍)
- [集成步骤](#集成步骤)
- [其他说明](#其他说明)

---

### 快速概览

| 项目 | 说明 |
| --- | --- |
| 产品 | FaceAISDK for iPhone & iPad |
| 能力 | 人脸检测、人脸识别、活体检测、防欺诈 |
| 运行方式 | 端侧离线、本地处理 |
| 支持语言 | Swift / Objective-C |
| 推荐 Xcode | 15.2 及以上（已验证到 26.5） |

### FaceAISDK 介绍

FaceAISDK for iPhone & iPad 是一款端侧离线的人脸检测、人脸识别、活体检测与防欺诈 SDK。

FaceAISDK_iOS 支持设备端完全离线，不需要联网即可实现人脸录入、活体检测、人脸识别，集成后可以快速实现相关能力。

### 集成步骤

SDK 最低支持 Xcode 15.2（Swift 5.9），已兼容 Xcode 26.5（Swift 6.3），支持 Swift 和 Objective-C。

#### 1. 添加依赖

<details>
<summary><strong>Podfile 示例</strong></summary>

```ruby
pod 'FaceAISDK_Core', :git => 'https://github.com/FaceAISDK/FaceAISDK_Core.git', :tag => '2026.07.01'
# pod 'FaceAISDK_Core', '2026.07.01'
```

</details>

#### 2. 执行安装

建议在网络环境正常的机器上执行 CocoaPods 安装。

```bash
pod install
```

如果你只想更新人脸 SDK，也可以执行：

```bash
pod update FaceAISDK_Core
```

#### 3. 首次安装耗时提示

首次安装基础依赖 `TensorFlowLiteSwift` 预计耗时约 30 分钟，具体取决于网络环境和设备性能。

你也可以在浏览器中查看当前网络环境下 `TensorFlowLiteSwift` 的下载情况：

https://github.com/tensorflow/tensorflow/archive/refs/heads/master.zip

#### 4. 网络受限时的常见错误

网络受限时可能出现如下错误：

```text
Updating local specs repositories
Downloading dependencies
Installing FaceAISDK_Core 2026.06.25
[!] Error installing FaceAISDK_Core
Cloning into '/var/folders/gh/p4wv4ytj4tn5xrhgq0n_jnbm0000gn/T/d20251020-8626-c57agm'...
fatal: unable to access 'https://github.com/FaceAISDK/FaceAISDK_Core.git/': Error in the HTTP2 framing layer
```

#### 5. 首次运行或更新版本后闪退

如果 `TensorFlowLiteSwift` 在首次运行或更新版本后发生闪退并报错：

```text
Thread 1: EXC BAD ACCESS (code=1, address=0x800008)
```

请在 Xcode 菜单中选择 **Product** > **Clean Build Folder** / **Clean All Issues**，然后再次执行 pod 命令升级 FaceAISDK。

#### 6. Git 下载失败处理

```text
[!] Error installing TensorFlowLiteSwift

Cloning into '/var/folders/ft/7cxjq5ss2094sj67mbhnzjrc0000gn/T/d20260113-17932-1xwealt'...
error: RPC failed; curl 18 transfer closed with outstanding read data remaining
error: 3926 bytes of body are still expected
fetch-pack: unexpected disconnect while reading sideband packet
fatal: early EOF
```

请保证网络环境正常，并适当增大 Git 缓存大小：

```bash
git config --global http.postBuffer 987654321
git config --global https.postBuffer 987654321
```

### 其他说明

| 平台 | 链接 |
| --- | --- |
| iOS 纯 Swift | https://github.com/FaceAISDK/FaceAISDK_iOS |
| iOS OC 混编 | https://github.com/FaceAISDK/FaceAISDK_iOS |
| Android | https://github.com/FaceAISDK/FaceAISDK_Android |
| Flutter 插件 | https://github.com/FaceAISDK/FaceAISDK_Flutter_Plugin |
| uniApp UTS 插件 | https://github.com/FaceAISDK/FaceAISDK_uniapp_UTS |
| React Native | https://github.com/FaceAISDK/FaceAISDK_RN |

**Email：** FaceAISDK.Service@gmail.com

![FaceAISDK](/Doc/FaceAISDK.jpeg)

### Android 体验 Demo APK 下载如下

<p align="center">
<img src="https://user-images.githubusercontent.com/15169396/210045090-60c073df-ddbd-4747-8e24-f0dce1eccb58.png" width="22%" />
</p>
