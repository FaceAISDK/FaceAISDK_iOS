//
//  SDKDebugApp.swift
//  SDKDebug
//
//  Created by anylife on 8/29/25.
//

import SwiftUI

@main
struct FaceAISDK_demoApp: App {
    // 状态控制：SDK 是否已准备就绪
    @State private var isEngineReady = false
    
    var body: some Scene {
        WindowGroup {
            if isEngineReady {
                // 引擎就绪后，再加载真实的导航视图
                FaceAINaviView()
            } else {
                // 极度轻量的首屏加载页，绝不阻塞主线程
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Initializing FaceAI Engine...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .task {
                    // .task 修饰符会在视图出现时自动在一个并发后台线程中执行
                    await initializeCoreEngineAsync()
                    
                    // 初始化完成后，切回主线程更新 UI 状态
                    await MainActor.run {
                        withAnimation {
                            isEngineReady = true
                        }
                    }
                }
            }
        }
    }
    
    /// 将重度的初始化逻辑封装为异步方法
    private func initializeCoreEngineAsync() async {
        // 使用 Task.detached 和 userInitiated 优先级，确保它在后台快速执行且不阻塞主线程
        await Task.detached(priority: .userInitiated) {
            // 这里替换为您真实的 SDK 需要立即马上初始化调用的，不着急的可以延后初始化
            
            // 模拟耗时操作 (测试通过后可删除)
            // try? await Task.sleep(nanoseconds: 1_000_000_000)
        }.value
    }
}
