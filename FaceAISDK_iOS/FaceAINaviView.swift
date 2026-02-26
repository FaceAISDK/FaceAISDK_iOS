import SwiftUI
import FaceAISDK_Core

/**
 * iOS  FaceAISDK 功能导航页面，UI 仅供参考
 *
 */
struct FaceAINaviView: View {
    //定义一个闭包属性，用来接收外部传入的关闭逻辑
    var onDismiss: (() -> Void)?
    @State private var addFaceResult: Int?
    
    //录入保存的FaceID 值。一般是你的业务体系中个人的唯一编码，比如账号 身份证
    private let faceID = "yourFaceID";
    
    var body: some View {
        // 1. 使用 NavigationView(兼容 iOS 15)
        NavigationView {
            ZStack {
                Color.faceMain.ignoresSafeArea()
                VStack(spacing: 20) {
                    
                    //通过SDK相机录入人脸
                    NavigationLink(destination: AddFaceByCamera(faceID: faceID, onDismiss: { result in
                        addFaceResult = result
                    })) {
                        Text("Add Face By Camera")
                            .font(.system(size: 20).bold())
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)  
                    }
                    .controlSize(.large) // iOS 15+ 支持
                    .padding(.top, 30)
                    
                    //通过相册录入人脸
                    NavigationLink(destination: AddFaceByUIImage(faceID: faceID, onDismiss: { result in
                        addFaceResult = result
                    })) {
                        Text("Add Face From Album")
                            .font(.system(size: 19).bold())
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .padding(.top, 15)
                    
                    //人脸识别+活体检测
                    NavigationLink(destination: VerifyFaceView(
                        faceID: faceID,
                        threshold: 0.85,
                        livenessType: 1, // 1.仅仅动作 2.动作+炫彩 3.炫彩
                        motionLiveness: "1,2,3,4,5", //1. 张张嘴  2.微笑  3.眨眨眼  4.摇摇头  5.点头
                        motionLivenessTimeOut: 11, //超时时间3-22秒
                        motionLivenessSteps:2,     //动作步骤个数
                        onDismiss: { resultCode in
                            print("VerifyResultCode ：\(resultCode)")
                        }
                    )) {
                        Text("Face Verify and Liveness Detection")
                            .font(.system(size: 20).bold())
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 22)
                    
                    //仅动作活体检测
                    NavigationLink(destination: LivenessDetectView(
                        livenessType: 2,
                        motionLiveness: "1,2,3,4,5", // 1.仅仅动作 2.动作+炫彩 3.炫彩
                        motionLivenessTimeOut: 5,
                        motionLivenessSteps:2,
                        onDismiss: { resultCode in
                            print("Motion Liveness Result \(resultCode)")
                        }
                    )) {
                        Text("ONLY Liveness Detection")
                            .font(.system(size: 20).bold())
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 20)
                    
                    // 判断faceID对应人脸特征值是否存在
                    Button("is Face Feature Exist") {
                        guard let faceFeature = UserDefaults.standard.string(forKey: faceID) else {
                            print("isFaceFeatureExist？ ： No ! ")
                            return
                        }
                        print("\n😊FaceFeature: \(faceFeature)")
                    }
                    .font(.system(size: 18).bold())
                    .foregroundColor(Color.white)
                    .padding(.top, 33)

                    Spacer()
                    
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
                .padding(.horizontal) // 添加一点水平间距防止贴边
            }
            .navigationTitle("🧭 FaceAISDK")
            .navigationBarTitleDisplayMode(.inline) // 可选：iOS 15 风格
        }
        .navigationViewStyle(.stack) // 3. 强制使用堆栈导航风格
        .ignoresSafeArea()
    }
}

