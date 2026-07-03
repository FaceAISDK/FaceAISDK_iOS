<img src="https://badgen.net/badge/FaceAI%20SDK/%20%E5%BF%AB%E9%80%9F%E5%AE%9E%E7%8E%B0%E4%BA%BA%E8%84%B8%E8%AF%86%E5%88%AB%E5%8A%9F%E8%83%BD" />

[中文](./README_zh-CN.md)

## Table of Contents 

  - [FaceAISDK Introduction](#faceaisdk-introduction)
  - [Integration Guide](#integration-guide)
  - [More Information](#more-information)

---

### At a glance

| Item | Details |
| --- | --- |
| Product | FaceAISDK for iPhone & iPad |
| Capabilities | Face detection, recognition, liveness detection, anti-spoofing |
| Runtime | Fully offline, on-device processing |
| Language support | Swift / Objective-C |
| Recommended Xcode | 15.2+ (verified up to 26.5) |

### FaceAISDK Introduction

FaceAISDK for iPhone & iPad is an on-device, fully offline SDK for face detection, face recognition, liveness detection, and anti-spoofing.

FaceAISDK_iOS enables face enrollment, liveness detection, and face recognition completely offline without network access, so you can quickly integrate related capabilities into your app.

### Integration Guide

Minimum supported version: Xcode 15.2 (Swift 5.9). Compatible with Xcode 26.5 (Swift 6.3). Supports both Swift and Objective-C.

#### 1. Add the dependency

<details>
<summary><strong>Podfile snippet</strong></summary>

```ruby
pod 'FaceAISDK_Core', :git => 'https://github.com/FaceAISDK/FaceAISDK_Core.git', :tag => '2026.07.01'
# pod 'FaceAISDK_Core', '2026.07.01'
```

</details>

#### 2. Install pods

Use CocoaPods on a machine with unrestricted network access.

```bash
pod install
```

If you only need to update the face SDK:

```bash
pod update FaceAISDK_Core
```

#### 3. Expect a longer first install

The first install of the base dependency `TensorFlowLiteSwift` may take about 30 minutes, depending on network conditions and device performance.

You can also verify whether `TensorFlowLiteSwift` is accessible in your current network environment by opening:

https://github.com/tensorflow/tensorflow/archive/refs/heads/master.zip

#### 4. Common network-related errors

Example error when network access is restricted:

```text
Updating local specs repositories
Downloading dependencies
Installing FaceAISDK_Core 2026.06.25
[!] Error installing FaceAISDK_Core
Cloning into '/var/folders/gh/p4wv4ytj4tn5xrhgq0n_jnbm0000gn/T/d20251020-8626-c57agm'...
fatal: unable to access 'https://github.com/FaceAISDK/FaceAISDK_Core.git/': Error in the HTTP2 framing layer
```

#### 5. First launch crash after update

If `TensorFlowLiteSwift` crashes and reports an error on first launch or after an update:

```text
Thread 1: EXC BAD ACCESS (code=1, address=0x800008)
```

In Xcode, choose **Product** > **Clean Build Folder** / **Clean All Issues**, then run the pod command again to update FaceAISDK.

#### 6. Git transfer failures

```text
[!] Error installing TensorFlowLiteSwift

Cloning into '/var/folders/ft/7cxjq5ss2094sj67mbhnzjrc0000gn/T/d20260113-17932-1xwealt'...
error: RPC failed; curl 18 transfer closed with outstanding read data remaining
error: 3926 bytes of body are still expected
fetch-pack: unexpected disconnect while reading sideband packet
fatal: early EOF
```

Make sure the network environment is stable, and increase the Git buffer size:

```bash
git config --global http.postBuffer 987654321
git config --global https.postBuffer 987654321
```

### More Information

| Platform | Link |
| --- | --- |
| iOS Swift only | https://github.com/FaceAISDK/FaceAISDK_iOS |
| iOS Objective-C mixed project | https://github.com/FaceAISDK/FaceAISDK_iOS |
| Android | https://github.com/FaceAISDK/FaceAISDK_Android |
| Flutter plugin | https://github.com/FaceAISDK/FaceAISDK_Flutter_Plugin |
| uniApp UTS plugin | https://github.com/FaceAISDK/FaceAISDK_uniapp_UTS |
| React Native | https://github.com/FaceAISDK/FaceAISDK_RN |

**Email:** FaceAISDK.Service@gmail.com

![FaceAISDK](/Doc/FaceAISDK.jpeg)

### Android Demo APK Download

<p align="center">
<img src="https://user-images.githubusercontent.com/15169396/210045090-60c073df-ddbd-4747-8e24-f0dce1eccb58.png" width="22%" />
</p>

---
