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
                Color.faceMain.ignoresSafeArea()
                VStack(spacing: 20) {
                    
                    // Add face through the SDK camera.
                    // 通过 SDK 相机录入人脸。
                    NavigationLink(destination: AddFaceByCamera(faceID: faceID,
                                                                addFacePerformanceMode: 1,
                                                                needShowConfirmDialog: true,
                                                                onDismiss: { result, feature in
                        print("🎆 AddFace   Status: \(result), Feature: \(feature)")
                    })) {
                        Text("Add Face By Camera")
                            .font(.system(size: 20).bold())
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .padding(.top, 30)
                    
                    // Add face information from an image/album.
                    // 通过图片录入人脸信息。
                    NavigationLink(destination: AddFaceByImage(faceID: faceID, onDismiss: { result, feature in
                        print("🎆  AddFace  Status: \(result), Feature: \(feature ?? "")")
                    })) {
                        Text("Add Face From Album")
                            .font(.system(size: 19).bold())
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .padding(.top, 15)
                    
                    // Face Verification + Liveness Detection.
                    // 人脸识别 + 活体检测。
                    NavigationLink(destination: VerifyFaceView(
                        faceID: faceID,
                        // Threshold range [0.8, 0.95].
                        // 阈值范围【0.8，0.95】。
                        threshold: 0.84,
                        // 1. Motion Liveness, 2. Motion + Color, 3. Color, 4. Silent Liveness only (the first three all include silent liveness).
                        // 1.动作活体 2.动作+炫彩 3.炫彩 4.仅静默活体(前三种都会带静默)。
                        livenessType: 1,
                        // 1. Open mouth, 2. Smile, 3. Blink, 4. Shake head, 5. Nod.
                        // 1.张嘴 2.微笑 3.眨眼 4.摇头 5.点头。
                        motionLiveness: "1,2,3,4,5",
                        // Timeout: 3-22 seconds.
                        // 超时时间：3-22秒。
                        motionLivenessTimeOut: 11,
                        // Number of motion steps.
                        // 动作步骤个数。
                        motionLivenessSteps:2,
                        onDismiss: {code, similarity, liveness in
                            print("🎆 Face Verify  Status: \(code), Similarity: \(similarity), Liveness: \(liveness)")
                        }
                    )) {
                        Text("Face Verify and Liveness Detection")
                            .font(.system(size: 20).bold())
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 22)
                    
                    // ONLY Liveness Detection.
                    // 仅活体检测。
                    NavigationLink(destination: LivenessDetectView(
                        // 1. Motion Liveness, 2. Motion + Color, 3. Color, 4. Silent Liveness only (the first three all include silent liveness).
                        // 1.动作活体 2.动作+炫彩 3.炫彩 4.仅静默活体(前三种都会带静默)。
                        livenessType: 1,
                        // 1. Open mouth, 2. Smile, 3. Blink, 4. Shake head, 5. Nod.
                        // 1.张嘴 2.微笑 3.眨眼 4.摇头 5.点头。
                        motionLiveness: "1,2,3,4,5",
                        // Timeout in seconds.
                        // 超时时间(秒)。
                        motionLivenessTimeOut: 5,
                        // Number of motion steps.
                        // 动作步骤个数。
                        motionLivenessSteps:2,
                        onDismiss: { code,liveness in
                            print("🎆 Liveness Result: \(code), Liveness Score: \(liveness)")
                        }
                    )) {
                        Text("ONLY Liveness Detection")
                            .font(.system(size: 20).bold())
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 20)
                    
                    // Check if the face feature corresponding to the faceID exists.
                    // 判断 faceID 对应人脸特征值是否存在。
                    Button("is Face Feature Exist") {
                        guard let faceFeature = UserDefaults.standard.string(forKey: faceID) else {
                            print("isFaceFeatureExist？ ： No ! ")
                            return
                        }
                        print("\n😊FaceFeature: \(faceFeature)")
                    }
                    .font(.system(size: 18).bold())
                    .foregroundColor(Color.white)
                    .padding(.top, 22)
                    
                    // Verify the similarity between two faces.
                    // 验证两张人脸的相似度。
                    NavigationLink(destination: VerifyTwoFaceSimiView()) {
                        Text("Verify Two Face Similarity")
                            .font(.system(size: 19).bold())
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 20)

                    Spacer()
                    
                    // Open About Us external link.
                    // 打开关于我们的外部链接。
                    Button("About us"){
                        let url = URL(string: "https://mp.weixin.qq.com/s/R43s70guLqxA6JPEdWtjcA")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if UIApplication.shared.canOpenURL(url!) {
                                UIApplication.shared.open(url!)
                            }
                        }
                    }
                    .foregroundColor(Color.white)
                    .font(.system(size: 16).bold())
                }
                .padding(.horizontal)
            }
            .navigationTitle("🧭Face SDK API Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .ignoresSafeArea()
        .onAppear {
            // Maximize screen brightness when the view appears.
            // 视图显示时将屏幕亮度调至最大。
            ScreenBrightnessHelper.shared.maximizeBrightness()
            withAnimation(.easeInOut(duration: 0.3)) {
                UIScreen.main.brightness = 1.0
            }
        }
    }
}
