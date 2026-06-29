import SwiftUI
import FaceAISDK_Core

/**
 * iOS FaceAISDK navigation page, UI is for reference only.
 * iOS FaceAISDK 功能导航页面，UI 仅供参考。
 */
struct FaceAINaviView: View {
    
    // The FaceID value used for saving the face feature. Usually, it's the unique identifier of a person in your business system, such as an account ID or ID card number.
    // 录入保存的 FaceID 值。一般是你的业务体系中个人的唯一编码，比如账号或身份证号。
    private let faceID = "yourFaceID";
    
    var onDismiss: (() -> Void)?

    var body: some View {
        NavigationView {
            ZStack {
                // 背景色铺满
                Color.faceMain.ignoresSafeArea()
                
                // 使用 ScrollView 适配小屏幕机型
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        
                        // --- 模块一：人脸录入 ---
                        VStack(spacing: 14) {
                            // 通过 SDK 相机录入人脸
                            NavigationLink(destination: AddFaceByCamera(
                                faceID: faceID,
                                addFacePerformanceMode: 1,
                                needShowConfirmDialog: true,
                                onDismiss: { result, feature in
                                    print("🎆 AddFace   Status: \(result), Feature: \(feature)")
                                }
                            )) {
                                MenuRowView(icon: "camera.viewfinder", title: "Add Face By Camera")
                            }
                            
                            // 通过图片录入人脸信息
                            NavigationLink(destination: AddFaceByImage(
                                faceID: faceID,
                                onDismiss: { result, feature in
                                    print("🎆  AddFace  Status: \(result), Feature: \(feature ?? "")")
                                }
                            )) {
                                MenuRowView(icon: "photo.on.rectangle.angled", title: "Add Face From Album")
                            }
                        }
                        .padding(.top, 20)
                        
                        // --- 模块二：识别与活体 ---
                        VStack(spacing: 14) {
                            // 人脸识别 + 活体检测
                            NavigationLink(destination: VerifyFaceView(
                                faceID: faceID,
                                // Threshold range [0.8, 0.9].  阈值范围【0.8，0.9】。
                                threshold: 0.83,
                                
                                // 1. Motion Liveness, 2. Motion + Color, 3. Color, 4. Silent Liveness only (the first three all include silent liveness).
                                // 1.动作活体 2.动作+炫彩 3.炫彩 4.仅静默活体(前三种都会带静默)。
                                livenessType: 1,
                                // 1. Open mouth, 2. Smile, 3. Blink, 4. Shake head, 5. Nod.
                                // 1.张嘴 2.微笑 3.眨眼 4.摇头 5.点头。
                                motionLiveness: "1,2,3,4,5",
                                // Timeout: 3-22 seconds.  超时时间：3-22秒。
                                motionLivenessTimeOut: 11,
                                // Number of motion steps.  动作步骤个数。
                                motionLivenessSteps:2,
                                
                                onDismiss: {code, similarity, liveness in
                                    print("🎆 Face Verify  Status: \(code), Similarity: \(similarity), Liveness: \(liveness)")
                                }
                            )) {
                                MenuRowView(icon: "faceid", title: "Face Verify & Liveness")
                            }
                            
                            // 仅活体检测（建议动作活体+静默组合）
                            NavigationLink(destination: LivenessDetectView(
                                // 1. Motion Liveness, 2. Motion + Color, 3. Color, 4. Silent Liveness only (the first three all include silent liveness).
                                // 1. 动作活体 2.动作+炫彩 3.炫彩 4.仅静默活体(前三种都会带静默)。
                                livenessType: 1,
                                // 1. Open mouth, 2. Smile, 3. Blink, 4. Shake head, 5. Nod.
                                // 1. 张嘴 2.微笑 3.眨眼 4.摇头 5.点头。
                                motionLiveness: "1,2,3,4,5",
                                // Timeout in seconds. 超时时间(秒)。
                                motionLivenessTimeOut: 5,
                                // Number of motion steps. 动作步骤个数。
                                motionLivenessSteps:2,
                                //show Result Tips? For Flutter,RN,UNIApp plugin
                                showResultTips: true,
                                onDismiss: { code,liveness in
                                    print("🎆 Liveness Result: \(code), Liveness Score: \(liveness)")
                                }
                            )) {
                                MenuRowView(icon: "person.crop.circle.badge.checkmark", title: "ONLY Liveness Detection")
                            }
                        }
                        .padding(.top, 8)
                        
                        // --- 模块三：功能辅助测试 ---
                        VStack(spacing: 14) {
                            // 判断 faceID 对应人脸特征值是否存在
                            Button(action: {
                                guard let faceFeature = UserDefaults.standard.string(forKey: faceID) else {
                                    print("isFaceFeatureExist？ ： No ! ")
                                    return
                                }
                                print("\n😊FaceFeature: \(faceFeature)")
                            }) {
                                MenuRowView(icon: "magnifyingglass.circle", title: "Is Face Feature Exist", showChevron: false)
                            }
                            
                            // 验证两张人脸的相似度
                            NavigationLink(destination: VerifyTwoFaceSimiView()) {
                                MenuRowView(icon: "person.2.crop.square.stack", title: "Verify Two Face Similarity")
                            }
                        }
                        .padding(.top, 8)

                        Spacer().frame(height: 30)
                        
                        // 打开关于我们的外部链接 (保持简洁风格)
                        Button(action: {
                            if let url = URL(string: "https://faceaisdk.github.io/index") {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                        }) {
                            Text("About us")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.8))
                                .underline()
                        }
                        .padding(.bottom, 40)
                        .padding(.top, 22)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 22)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            // 顶部导航栏添加关闭按钮
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        onDismiss?()
                        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            // 视图显示时将屏幕亮度调至最大
            ScreenBrightnessHelper.shared.maximizeBrightness()
            withAnimation(.easeInOut(duration: 0.3)) {
                UIScreen.main.brightness = 1.0
            }
        }
    }
}

// MARK: - 统一的菜单行组件
/// 用于美化导航列表的按钮卡片视图
struct MenuRowView: View {
    var icon: String
    
    // 将 String 改为 LocalizedStringKey，这样 SwiftUI 就会自动去 Localizable.strings 查找多语言
    var title: LocalizedStringKey
    
    var showChevron: Bool = true // 是否显示右侧的小箭头
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .light))
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 17, weight: .semibold))
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.5))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}
