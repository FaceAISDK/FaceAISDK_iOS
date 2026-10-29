<div align="center">

<img src="./Doc/logo.png" alt="FaceAISDK logo" width="112" />

# FaceAISDK for iOS

**Offline face detection, recognition, liveness detection, and anti-spoofing for iPhone and iPad.**

[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS-111827?style=flat-square&logo=apple)](https://github.com/FaceAISDK/FaceAISDK_iOS)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-F05138?style=flat-square&logo=swift&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-15.2%2B-147EFB?style=flat-square&logo=xcode&logoColor=white)
![Runtime](https://img.shields.io/badge/runtime-fully%20offline-16A34A?style=flat-square)

**English** · [简体中文](./README_zh-CN.md)

</div>

---

## Overview

FaceAISDK is an on-device SDK that brings face enrollment, liveness detection, and face recognition to iOS and iPadOS apps. All processing happens locally, so the core features work without network access.

| | Capability | Description |
| :---: | --- | --- |
| 🔍 | Face detection | Locate and analyze faces on-device |
| 🪪 | Face recognition | Enroll and match face identities |
| 🛡️ | Liveness detection | Detect presentation attacks and spoofing |
| ✈️ | Offline runtime | Process data locally without a network connection |

### Requirements

| Item | Requirement |
| --- | --- |
| Xcode | 15.2 or later; verified up to Xcode 26.5 |
| Swift | 5.9 or later; compatible with Swift 6.3 |
| Languages | Swift and Objective-C |
| Dependency manager | CocoaPods |

## Quick Start

### 1. Add the dependency

Add `FaceAISDK_Core` to your `Podfile`. Replace the placeholder with the release tag you want to use.

```ruby
pod 'FaceAISDK_Core', :git => 'https://github.com/FaceAISDK/FaceAISDK_Core.git', :tag => '2026.*******'

# Or install a published CocoaPods version:
# pod 'FaceAISDK_Core', '2026.*******'
```

### 2. Install the SDK

```bash
pod install
```

To update only FaceAISDK:

```bash
pod update FaceAISDK_Core
```

> [!NOTE]
> The first installation of `TensorFlowLiteSwift` can take around 30 minutes, depending on your network and machine. You can use the [TensorFlow archive download](https://github.com/tensorflow/tensorflow/archive/refs/heads/master.zip) to verify that GitHub downloads are available in your network environment.

## Troubleshooting

<details>
<summary><strong>FaceAISDK_Core fails to clone</strong></summary>

This error usually indicates an unstable or restricted network connection:

```text
Updating local specs repositories
Downloading dependencies
Installing FaceAISDK_Core 2026.09.20
[!] Error installing FaceAISDK_Core
Cloning into '/var/folders/gh/p4wv4ytj4tn5xrhgq0n_jnbm0000gn/T/d20251020-8626-c57agm'...
fatal: unable to access 'https://github.com/FaceAISDK/FaceAISDK_Core.git/': Error in the HTTP2 framing layer
```

Retry from a stable network that can access GitHub.

</details>

<details>
<summary><strong>The app crashes on first launch or after an update</strong></summary>

If `TensorFlowLiteSwift` reports the following error:

```text
Thread 1: EXC BAD ACCESS (code=1, address=0x800008)
```

In Xcode, select **Product → Clean Build Folder**, then update the SDK:

```bash
pod update FaceAISDK_Core
```

</details>

<details>
<summary><strong>Git reports RPC failed, early EOF, or an unexpected disconnect</strong></summary>

Example output:

```text
[!] Error installing TensorFlowLiteSwift

Cloning into '/var/folders/ft/7cxjq5ss2094sj67mbhnzjrc0000gn/T/d20260113-17932-1xwealt'...
error: RPC failed; curl 18 transfer closed with outstanding read data remaining
error: 3926 bytes of body are still expected
fetch-pack: unexpected disconnect while reading sideband packet
fatal: early EOF
```

Check your network connection and, if necessary, increase Git's HTTP buffer size:

```bash
git config --global http.postBuffer 987654321
git config --global https.postBuffer 987654321
```

</details>

## Related Projects

| Platform | Repository |
| --- | --- |
| iOS · Swift | [FaceAISDK_iOS](https://github.com/FaceAISDK/FaceAISDK_iOS) |
| iOS · Objective-C | [ObjectC_FaceAISDK](https://github.com/FaceAISDK/ObjectC_FaceAISDK) |
| Android | [FaceAISDK_Android](https://github.com/FaceAISDK/FaceAISDK_Android) |
| Flutter | [FaceRecognition_Flutter](https://github.com/FaceAISDK/FaceRecognition_Flutter) |
| uni-app UTS | [FaceAISDK_uniapp_UTS](https://github.com/FaceAISDK/FaceAISDK_uniapp_UTS) |
| React Native | [FaceRecognition_ReactNative](https://github.com/FaceAISDK/FaceRecognition_ReactNative) |

## Preview

<p align="center">
  <img src="./Doc/FaceAISDK.png" alt="FaceAISDK preview" width="760" />
</p>

## Android Demo

Scan the QR code below to download the Android demo APK.

<p align="center">
  <img src="https://user-images.githubusercontent.com/15169396/210045090-60c073df-ddbd-4747-8e24-f0dce1eccb58.png" alt="Android demo APK QR code" width="180" />
</p>

## Contact

For integration support, email [FaceAISDK.Service@gmail.com](mailto:FaceAISDK.Service@gmail.com).

<div align="center">

Made for fast, private, on-device face recognition.

</div>
