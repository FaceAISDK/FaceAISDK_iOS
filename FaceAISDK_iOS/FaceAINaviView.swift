import SwiftUI
import FaceAISDK_Core
import ToastUI

/**
 * iOS  FaceAISDK 功能导航页面
 */
struct FaceAINaviView: View {
    
    @State private var navigationPath = NavigationPath()
    @State private var addFaceResult: String?
    
    //录入保存的FaceID 值。一般是你的业务体系中个人的唯一编码，比如账号 身份证
    private let faceID="yourFaceID";
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.faceMain.ignoresSafeArea()
                VStack(spacing: 20) {
                    
                    //通过SDK相机录入人脸
                    Button("Add Face By Camera") {
                        navigationPath.append(FaceAINaviDestination.AddFacePageView(faceID))
                    }
                    .font(.system(size: 20).bold())
                    .controlSize(.large)
                    .foregroundColor(Color.white)
                    .padding(.top,30)
                    
                    //通过相册录入人脸
                    Button("Add Face From Album") {
                        navigationPath.append(FaceAINaviDestination.AddFaceFromAlbum(faceID))
                    }
                    .font(.system(size: 19).bold())
                    .controlSize(.large)
                    .foregroundColor(Color.white)
                    .padding(.top,15)
                    
                    //人脸识别+活体检测
                    Button("Face Verify and Liveness Detection") {
                        navigationPath.append(FaceAINaviDestination.VerifyFacePageView(faceID))
                    }
                    .font(.system(size: 20).bold())
                    .foregroundColor(Color.white)
                    .padding(.top,22)
                    
                    //仅动作活体检测
                    Button("ONLY Motion Liveness Detection") {
                        navigationPath.append(FaceAINaviDestination.LivenessView(faceID))
                    }
                    .font(.system(size: 20).bold())
                    .foregroundColor(Color.white)
                    .padding(.top,20)
                    
                    //判断faceID对应人脸特征值是否存在
                    Button("is Face Feature Exist") {
                        //人脸特征值是一个1024长度的字符串，已经和Android 同步实现了数据互联互通
                        guard let faceFeature = UserDefaults.standard.string(forKey: faceID) else {
                            print("isFaceFeatureExist？ ： No ! ")
                            return
                        }
                        
                        print("\n😊FaceFeature: \(faceFeature)")
                    }
                    
                    .font(.system(size: 18).bold())
                    .foregroundColor(Color.white)
                    .padding(.top,33)


                    Spacer()
                    
                    Button("About us"){
                        // 记得切换成iOS 的介绍版本
                        let url = URL(string: "https://mp.weixin.qq.com/s/R43s70guLqxA6JPEdWtjcA")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if UIApplication.shared.canOpenURL(url!) {
                                UIApplication.shared.open(url!)
                            }
                        }
                    }
                    .padding(.bottom,11)
                    .foregroundColor(Color.white)
                    .font(.system(size: 16).bold())
                }
            }
            .navigationTitle("🧭 FaceAISDK")
            .navigationDestination(for: FaceAINaviDestination.self) { destination in
                switch destination {
                    
                case .AddFacePageView(let param):
                    AddFaceByCamera(faceID: param,onDismiss: { result in
                        addFaceResult = result
                        if !navigationPath.isEmpty { // 检查路径是否为空
                            navigationPath.removeLast()
                        }
                    })
                    
                case .AddFaceFromAlbum(let param):

                    AddFaceByUIImage(faceID: param,onDismiss: { result in
                        addFaceResult = result
                        if !navigationPath.isEmpty { // 检查路径是否为空
                            navigationPath.removeLast()
                        }
                    })
                
                case .VerifyFacePageView(let param):
                    //设置的相似度阈值threshold越高，对人脸角度，环境光线和摄像头宽动态要求越高
                    VerifyFaceView(faceID: param,threshold: 0.83, onDismiss: { resultCode in
                        
                        // resultCode, 参考 VerifyResultCode
                        // -2  人脸识别动作活体检测超过10秒
                        // -1  多次切换人脸或检查失败
                        // 0   默认值
                        // 1   人脸识别对比成功大于设置的threshold
                        // 2   人脸识别对比识别小于设置的threshold
                        print("VerifyResultCode ：\(resultCode)")

                        if !navigationPath.isEmpty { // 检查路径是否为空
                            navigationPath.removeLast()
                        }
                    })
                case .LivenessView(let param):
                    
                    // faceVerifyResult.code
                    // -2  人脸识别动作活体检测超过10秒
                    // -1  多次切换人脸或检查失败
                    // 0   默认值
                    // 3   动作活体检测成功
                    LivenessDetectView(faceID: param,onDismiss: { result in
                        print("Motion Liveness Result：\(result.tips) \(result.code)")
                        if !navigationPath.isEmpty { // 检查路径是否为空
                            navigationPath.removeLast()
                        }
                    })
                    
                }
            }
        }
        .onAppear {
            //和合适的场景，提前一点初始化FaceAISDK
            FaceAISDK.initSDK()
        }
    }
    
}

enum FaceAINaviDestination: Hashable {
    case AddFaceFromAlbum(String)
    case AddFacePageView(String)
    case VerifyFacePageView(String)
    case LivenessView(String)
}

//#Preview {
//    FaceAINaviView()
//}


