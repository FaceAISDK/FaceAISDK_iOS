<img src="https://badgen.net/badge/FaceAI%20SDK/%20%E5%BF%AB%E9%80%9F%E5%AE%9E%E7%8E%B0%E4%BA%BA%E8%84%B8%E8%AF%86%E5%88%AB%E5%8A%9F%E8%83%BD" />

[English](#english) | [中文](#中文)

## Table of Contents / 目录导航

- [English](#english)
  - [FaceAISDK Introduction](#faceaisdk-introduction)
  - [Integration Guide](#integration-guide)
  - [Quick Start](#quick-start)
  - [More Information](#more-information)
- [中文](#中文)
  - [FaceAISDK 介绍](#faceaisdk-介绍)
  - [集成步骤](#集成步骤)
  - [快速开始](#快速开始)
  - [其他说明](#其他说明)

---

## English

### FaceAISDK Introduction

FaceAISDK for iPhone & iPad is an on-device, fully offline SDK for face detection, face recognition, liveness detection, and anti-spoofing.

FaceAISDK_iOS enables face enrollment, liveness detection, and face recognition completely offline without network access, so you can quickly integrate related capabilities into your app.

### Integration Guide

Minimum supported version: Xcode 15.2 (Swift 5.9). Compatible with Xcode 26.5 (Swift 6.3). Supports both Swift and Objective-C.

> **Card 1 — Add the dependency**
>
> Add `FaceAISDK_Core` to your `Podfile`:
>
> ```ruby
> pod 'FaceAISDK_Core', :git => 'https://github.com/FaceAISDK/FaceAISDK_Core.git', :tag => '2026.07.01'
> # pod 'FaceAISDK_Core', '2026.07.01'
> ```

> **Card 2 — Install pods**
>
> Run CocoaPods installation on a machine with unrestricted network access.
>
> ```bash
> pod install
> ```
>
> You can also update only the face SDK with:
>
> ```bash
> pod update FaceAISDK_Core
> ```

> **Card 3 — Watch the first install time**
>
> The first install of the base dependency `TensorFlowLiteSwift` may take about 30 minutes, depending on network conditions and device performance.
>
> You can also check whether `TensorFlowLiteSwift` can be downloaded normally in your current network environment by opening:
>
> https://github.com/tensorflow/tensorflow/archive/refs/heads/master.zip

> **Card 4 — If a network-related error appears**
>
> Example error when network access is restricted:
>
> ```text
> Updating local specs repositories
> Downloading dependencies
> Installing FaceAISDK_Core 2026.06.25
> [!] Error installing FaceAISDK_Core
> Cloning into '/var/folders/gh/p4wv4ytj4tn5xrhgq0n_jnbm0000gn/T/d20251020-8626-c57agm'...
> fatal: unable to access 'https://github.com/FaceAISDK/FaceAISDK_Core.git/': Error in the HTTP2 framing layer
> ```

> **Card 5 — If the app crashes on first launch or after update**
>
> If `TensorFlowLiteSwift` crashes and reports an error on first launch or after an update:
>
> ```text
> Thread 1: EXC BAD ACCESS (code=1, address=0x800008)
> ```
>
> In Xcode, choose **Product** > **Clean Build Folder** / **Clean All Issues**, then run the pod command again to update FaceAISDK.

> **Card 6 — If Git transfer fails**
>
> ```text
> [!] Error installing TensorFlowLiteSwift
>
> Cloning into '/var/folders/ft/7cxjq5ss2094sj67mbhnzjrc0000gn/T/d20260113-17932-1xwealt'...
> error: RPC failed; curl 18 transfer closed with outstanding read data remaining
> error: 3926 bytes of body are still expected
> fetch-pack: unexpected disconnect while reading sideband packet
> fatal: early EOF
> ```
>
> Make sure the network environment is stable, and increase the Git buffer size:
>
> ```bash
> git config --global http.postBuffer 987654321
> git config --global https.postBuffer 987654321
> ```

### Quick Start

The SDK exposes public model classes such as `VerifyFaceModel`, `AddFaceByCameraModel`, `AddFaceByImageModel`, and `VerifyTwoFaceSimiModel`.

For live camera workflows, the SDK models conform to `AVCaptureVideoDataOutputSampleBufferDelegate`, so you can feed camera frames directly into the SDK.

#### Swift example: live verification

```swift
import UIKit
import AVFoundation
import FaceAISDK_Core

final class FaceVerifyViewController: UIViewController {
    private let verifyModel = VerifyFaceModel()
    private let cameraQueue = DispatchQueue(label: "com.faceaisdk.camera.queue")
    private let videoOutput = AVCaptureVideoDataOutput()

    func startLiveVerify() {
        // Attach the SDK model as the camera frame delegate.
        videoOutput.setSampleBufferDelegate(verifyModel, queue: cameraQueue)

        // Configure AVCaptureSession / input / output in your app as usual,
        // then start the session and let the SDK process each frame.
        // session.startRunning()
    }

    func startFaceEnrollment() {
        let addFaceModel = AddFaceByCameraModel()
        videoOutput.setSampleBufferDelegate(addFaceModel, queue: cameraQueue)
    }
}
```

#### Swift example: image enrollment

```swift
import FaceAISDK_Core

let imageModel = AddFaceByImageModel()

// Use the model in your app flow for album/image-based face enrollment.
// The SDK package exposes the model; wire it into your UI and image pipeline.
```

#### Objective-C note

If you are using Objective-C, import the generated module header and create the same models from your view controller or camera pipeline.

```objc
#import <FaceAISDK_Core/FaceAISDK_Core.h>

VerifyFaceModel *verifyModel = [[VerifyFaceModel alloc] init];
AddFaceByCameraModel *addFaceModel = [[AddFaceByCameraModel alloc] init];
```

### More Information

- **iOS Swift only:** https://github.com/FaceAISDK/FaceAISDK_iOS
- **iOS Objective-C mixed project:** https://github.com/FaceAISDK/FaceAISDK_iOS
- **Android:** https://github.com/FaceAISDK/FaceAISDK_Android
- **Flutter plugin:** https://github.com/FaceAISDK/FaceAISDK_Flutter_Plugin
- **uniApp UTS plugin:** https://github.com/FaceAISDK/FaceAISDK_uniapp_UTS
- **React Native:** https://github.com/FaceAISDK/FaceAISDK_RN

Email: FaceAISDK.Service@gmail.com

![FaceAISDK](/Doc/FaceAISDK.jpeg)

### Android Demo APK Download

<div align="center">
<img src="https://user-images.githubusercontent.com/15169396/210045090-60c073df-ddbd-4747-8e24-f0dce1eccb58.png" width="22%" />
</div>

---

## 中文

### FaceAISDK 介绍

FaceAISDK for iPhone & iPad 是一款端侧离线的人脸检测、人脸识别、活体检测与防欺诈 SDK。

FaceAISDK_iOS 支持设备端完全离线，不需要联网即可实现人脸录入、活体检测、人脸识别，集成后可以快速实现相关能力。

### 集成步骤

SDK 最低支持 Xcode 15.2（Swift 5.9），已兼容 Xcode 26.5（Swift 6.3），支持 Swift 和 Objective-C。

> **卡片 1 — 添加依赖**
>
> 在 `Podfile` 中添加 `FaceAISDK_Core`：
>
> ```ruby
> pod 'FaceAISDK_Core', :git => 'https://github.com/FaceAISDK/FaceAISDK_Core.git', :tag => '2026.07.01'
> # pod 'FaceAISDK_Core', '2026.07.01'
> ```

> **卡片 2 — 执行安装**
>
> 建议在网络环境正常的机器上执行 CocoaPods 安装。
>
> ```bash
> pod install
> ```
>
> 如果你只想更新人脸 SDK，也可以执行：
>
> ```bash
> pod update FaceAISDK_Core
> ```

> **卡片 3 — 首次安装耗时提示**
>
> 首次安装基础依赖 `TensorFlowLiteSwift` 预计耗时约 30 分钟，具体取决于网络环境和设备性能。
>
> 你也可以在浏览器中查看当前网络环境下 `TensorFlowLiteSwift` 的下载情况：
>
> https://github.com/tensorflow/tensorflow/archive/refs/heads/master.zip

> **卡片 4 — 网络受限时的常见错误**
>
> 网络受限时可能出现如下错误：
>
> ```text
> Updating local specs repositories
> Downloading dependencies
> Installing FaceAISDK_Core 2026.06.25
> [!] Error installing FaceAISDK_Core
> Cloning into '/var/folders/gh/p4wv4ytj4tn5xrhgq0n_jnbm0000gn/T/d20251020-8626-c57agm'...
> fatal: unable to access 'https://github.com/FaceAISDK/FaceAISDK_Core.git/': Error in the HTTP2 framing layer
> ```

> **卡片 5 — 首次运行或更新版本后闪退**
>
> 如果 `TensorFlowLiteSwift` 在首次运行或更新版本后发生闪退并报错：
>
> ```text
> Thread 1: EXC BAD ACCESS (code=1, address=0x800008)
> ```
>
> 请在 Xcode 菜单中选择 **Product** > **Clean Build Folder** / **Clean All Issues**，然后再次执行 pod 命令升级 FaceAISDK。

> **卡片 6 — Git 下载失败处理**
>
> ```text
> [!] Error installing TensorFlowLiteSwift
>
> Cloning into '/var/folders/ft/7cxjq5ss2094sj67mbhnzjrc0000gn/T/d20260113-17932-1xwealt'...
> error: RPC failed; curl 18 transfer closed with outstanding read data remaining
> error: 3926 bytes of body are still expected
> fetch-pack: unexpected disconnect while reading sideband packet
> fatal: early EOF
> ```
>
> 请保证网络环境正常，并适当增大 Git 缓存大小：
>
> ```bash
> git config --global http.postBuffer 987654321
> git config --global https.postBuffer 987654321
> ```

### 快速开始

SDK 对外暴露的公开模型类包括 `VerifyFaceModel`、`AddFaceByCameraModel`、`AddFaceByImageModel` 和 `VerifyTwoFaceSimiModel`。

对于摄像头实时流场景，这些模型实现了 `AVCaptureVideoDataOutputSampleBufferDelegate`，你可以把相机帧直接交给 SDK 处理。

#### Swift 示例：实时验证

```swift
import UIKit
import AVFoundation
import FaceAISDK_Core

final class FaceVerifyViewController: UIViewController {
    private let verifyModel = VerifyFaceModel()
    private let cameraQueue = DispatchQueue(label: "com.faceaisdk.camera.queue")
    private let videoOutput = AVCaptureVideoDataOutput()

    func startLiveVerify() {
        // 将 SDK 模型设置为相机帧代理。
        videoOutput.setSampleBufferDelegate(verifyModel, queue: cameraQueue)

        // 其余 AVCaptureSession / input / output 的配置按 App 自身逻辑完成。
        // 配置完成后启动 session，让 SDK 持续处理每一帧。
        // session.startRunning()
    }

    func startFaceEnrollment() {
        let addFaceModel = AddFaceByCameraModel()
        videoOutput.setSampleBufferDelegate(addFaceModel, queue: cameraQueue)
    }
}
```

#### Swift 示例：相册录入

```swift
import FaceAISDK_Core

let imageModel = AddFaceByImageModel()

// 可在 App 的相册选图流程中使用该模型完成基于图片的人脸录入。
// SDK 已提供模型对象，具体 UI 与图片管线由宿主 App 自行接入。
```

#### Objective-C 提示

如果你使用 Objective-C，可以直接导入生成的模块头，然后在控制器或相机管线中创建同样的模型对象。

```objc
#import <FaceAISDK_Core/FaceAISDK_Core.h>

VerifyFaceModel *verifyModel = [[VerifyFaceModel alloc] init];
AddFaceByCameraModel *addFaceModel = [[AddFaceByCameraModel alloc] init];
```

### 其他说明

- **iOS 纯 Swift：** https://github.com/FaceAISDK/FaceAISDK_iOS
- **iOS OC 混编：** https://github.com/FaceAISDK/FaceAISDK_iOS
- **Android：** https://github.com/FaceAISDK/FaceAISDK_Android
- **Flutter 插件：** https://github.com/FaceAISDK/FaceAISDK_Flutter_Plugin
- **uniApp UTS 插件：** https://github.com/FaceAISDK/FaceAISDK_uniapp_UTS
- **React Native：** https://github.com/FaceAISDK/FaceAISDK_RN

Email: FaceAISDK.Service@gmail.com

![FaceAISDK](/Doc/FaceAISDK.jpeg)

### Android 体验 Demo APK 下载如下

<div align="center">
<img src="https://user-images.githubusercontent.com/15169396/210045090-60c073df-ddbd-4747-8e24-f0dce1eccb58.png" width="22%" />
</div>

.
