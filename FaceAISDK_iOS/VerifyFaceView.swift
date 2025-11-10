import SwiftUI
import AVFoundation
import FaceAISDK_Core
import ToastUI


/**
 * 人脸识别，摄像头采集画面需要真机调试
 * UI 样式仅供参考，根据你的业务可自行调整
 */
struct VerifyFaceView: View {
    //确保ViewModel的生命周期与视图一致，使用@StateObject持有ViewModel，视图被销毁时会一起释放
    @StateObject private var viewModel: VerifyFaceModel = VerifyFaceModel()
    @State private var showToast = false
    @Environment(\.dismiss) private var dismiss
    
    //录入保存的FaceID 值。一般是你的业务体系中个人的唯一编码，比如账号 身份证
    let faceID: String
    //人脸相似度阈值，范围0.8到0.95.
    //设置的相似度阈值越高，对人脸角度，环境光线和摄像头宽动态要求越高
    let threshold:Float
    let onDismiss: (FaceVerifyResult) -> Void
    
    
    //根据提示状态码多语言展示文本
    //添加人脸状态码参考 AddFaceTipsCode
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "VerifyFace Tips Code=\(code)"
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
    
    var body: some View {
        VStack {
            Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                .font(.system(size: 20).bold())
                .padding(.horizontal,20)
                .padding(.vertical,8)
                .foregroundColor(.white)
                .background(Color.faceMain)
                .cornerRadius(20)
            
            Text(localizedTip(for: viewModel.sdkInterfaceTipsExtra.code))
                .font(.system(size: 19).bold())
                .padding(.bottom, 6)
                .frame(minHeight: 30)
                .foregroundColor(.black)
            
            FaceAICameraView(session: viewModel.captureSession,cameraSize: FaceAICameraSize)
                .frame(
                    width: FaceAICameraSize,
                    height: FaceAICameraSize)
                .aspectRatio(1.0, contentMode: .fit)   //Enforce1:1ratio
                .clipShape(Circle())     //Clip to ensure square bounds
            
            Spacer()
        }
        
        .onAppear {
            //初始化人脸引擎,设置人脸识别的底片和比对相似度阈值（0.8到0.95）
            //设置的相似度阈值越高，对人脸角度，环境光线和摄像头宽动态要求越高
            // motionLiveness 指定活体动作的种类(至少3种)  1.张张嘴  2.微笑  3.眨眨眼  4.摇摇头  5.点头
            viewModel.initFaceAISDK(faceIDParam: faceID, threshold: 0.85, onlyLiveness: false,motionLiveness:[1,3,4,5])
        }
        
        .onChange(of: viewModel.faceVerifyResult.code) { newValue in
            showToast = true
            print("ViewModel 返回 ： \(viewModel.faceVerifyResult)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showToast = false
                onDismiss(viewModel.faceVerifyResult)  //传值给父视图
                dismiss() //关闭页面
            }
        }
        
        .toast(isPresented: $showToast) {
            let sim = String(format: "%.2f", viewModel.faceVerifyResult.similarity)
            if(viewModel.faceVerifyResult.similarity>threshold){
                ToastView("\(viewModel.faceVerifyResult.tips)  \(sim)").toastViewStyle(.success)
            }else {
                ToastView("\(viewModel.faceVerifyResult.tips)  \(sim)").toastViewStyle(.failure)
            }
        }
        
        .onDisappear{
            viewModel.stopFaceVerify() //停止
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 确保填满可用空间
        .background(Color.white.ignoresSafeArea()) // 扩展到安全区域
    }
}

