import SwiftUI
import FaceAISDK_Core

/**
 * iOS  FaceAISDK 功能导航页面，UI 仅供参考
 *
 */
struct FaceAINaviView: View {
    // 1. 【新增】定义一个闭包属性，用来接收外部传入的关闭逻辑
    var onDismiss: (() -> Void)?
    @State private var navigationPath = NavigationPath()
    
    //录入保存的FaceID 值。一般是你的业务体系中个人的唯一编码，比如账号 身份证
    private let faceID="yourFaceID";
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.brown.ignoresSafeArea()
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
                        navigationPath.append(FaceAINaviDestination.VerifyFacePageView(faceID,0.85,1,"1,2,3,4,5"))
                    }
                    .font(.system(size: 20).bold())
                    .foregroundColor(Color.white)
                    .padding(.top,22)
                    
                    //仅动作活体检测
                    Button("ONLY Liveness Detection") {
                        navigationPath.append(FaceAINaviDestination.LivenessView(2,"1,2,3,4,5"))
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
                    .foregroundColor(Color.white)
                    .font(.system(size: 16).bold())
                }
            }
            .navigationTitle("🧭 FaceAISDK")
            .navigationDestination(for: FaceAINaviDestination.self) { destination in
                switch destination {
                    
                case .AddFacePageView(let param):
                    AddFaceByCamera(faceID: param,onDismiss: { result in
                        // result //0 用户取消， 1 添加成功
                        if !navigationPath.isEmpty { // 检查路径是否为空
                            navigationPath.removeLast()
                        }
                    })
                    
                case .AddFaceFromAlbum(let param):

                    AddFaceByUIImage(faceID: param,onDismiss: { result in
                        // result //0 用户取消， 1 添加成功
                        if !navigationPath.isEmpty { // 检查路径是否为空
                            navigationPath.removeLast()
                        }
                    })
                
                case .VerifyFacePageView(let faceID,let threshold,let livenessType,let motionLiveness):
                    //设置的相似度阈值threshold越高，对人脸角度，环境光线和摄像头宽动态要求越高
                    VerifyFaceView(faceID: faceID,threshold: 0.85,
                                   livenessType: livenessType,
                                   motionLiveness:motionLiveness,onDismiss: { resultCode in
                        
                        // resultCode, 参考 VerifyResultCode
                        // 0   默认值
                        // 1   人脸识别对比成功大于设置的threshold
                        // 2   人脸识别对比识别小于设置的threshold
                        // 3   动作活体检测成功
                        // 4   动作活体超时
                        // 5   多次没有检测到人脸
                        // 6   没有对应的人脸特征值
                        // 7   炫彩活体成功
                        // 8   炫彩活体失败
                        // 9   炫彩活体失败，光线亮度过高
                        // 10  所有的活体检测完成(包括动作和炫彩)
                        print("VerifyResultCode ：\(resultCode)")

                        if !navigationPath.isEmpty { // 检查路径是否为空
                            navigationPath.removeLast()
                        }
                    })

                case .LivenessView(let livenessType,let motionLiveness):
                    // Code 含义同上
                    LivenessDetectView(livenessType: livenessType,
                                       motionLiveness:motionLiveness,
                                       onDismiss: { resultCode in
                        print("Motion Liveness Result \(resultCode)")
                        if !navigationPath.isEmpty { // 检查路径是否为空
                            navigationPath.removeLast()
                        }
                    })
                    
                }
            }
        }
        .onAppear {
            //在合适的场景，提前一点初始化FaceAISDK
            FaceAISDK.initSDK()
        }
        // 3. 【核心修复】将 ignore 加在 NavigationStack 整体上
        // 这样整个导航栈（包括导航栏区域）都会延伸到屏幕边缘
        .ignoresSafeArea()
    }
    
}

enum FaceAINaviDestination: Hashable {
    case AddFaceFromAlbum(String)
    case AddFacePageView(String)
    case VerifyFacePageView(String,Float,Int,String)
    case LivenessView(Int,String)
}



//#Preview {
//    FaceAINaviView()
//}


