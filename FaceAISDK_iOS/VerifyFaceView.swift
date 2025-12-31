import SwiftUI
import AVFoundation
import FaceAISDK_Core

/**
 * 1:1 人脸识别+活体检测
 */
struct VerifyFaceView: View {
    // 确保ViewModel的生命周期与视图一致
    @StateObject private var viewModel: VerifyFaceModel = VerifyFaceModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showLightHighDialog = false
    @State private var showToast = false
    @State private var toastViewTips: String = ""
    
     @State private var originalBrightness: CGFloat = UIScreen.main.brightness
    
    // 业务参数
    let faceID: String
    let threshold: Float
    let onDismiss: (Int) -> Void

    // 多语言提示
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "VerifyFace Tips Code=\(code)"
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                    .font(.system(size: 20).bold())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .background(Color.brown) // 假设 Color.brown 为 blue
                    .cornerRadius(20)
                
                Text(localizedTip(for: viewModel.sdkInterfaceTipsExtra.code))
                    .font(.system(size: 19).bold())
                    .padding(.bottom, 6)
                    .frame(minHeight: 30)
                    .foregroundColor(.black)
                
                FaceAICameraView(session: viewModel.captureSession, cameraSize: FaceCameraSize)
                    .frame(
                        width: FaceCameraSize,
                        height: FaceCameraSize
                    )
                    .padding(.vertical, 8)
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(viewModel.colorFlash.ignoresSafeArea())

            if showToast {
                // 计算显示内容
                let similarity = String(format: "%.2f", viewModel.faceVerifyResult.similarity)
                // 优先使用手动设置的 toastViewTips (用于处理无特征值的情况)，否则使用 SDK 返回的 tips
                let displayTips = toastViewTips.isEmpty ? viewModel.faceVerifyResult.tips : toastViewTips
                let displayMessage = (toastViewTips.isEmpty) ? "\(displayTips) \(similarity)" : displayTips
                
                // 计算样式：如果是无特征值错误，或者相似度低，则为 failure
                let isSuccess = viewModel.faceVerifyResult.similarity > threshold && toastViewTips.isEmpty
                let toastStyle: ToastStyle = isSuccess ? .success : .failure
                
                VStack {
                    Spacer()
                    CustomToastView(
                        message: displayMessage,
                        style: toastStyle
                    )
                    .padding(.bottom, 77)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
            
            
            // --- 顶层：光线过强自定义弹窗 (Dialog) ---
            if showLightHighDialog {
                ZStack {
                    VStack(spacing: 22) {
                        Text(viewModel.faceVerifyResult.tips)
                            .font(.system(size: 16).bold())
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.horizontal,9)
                        
                        Image("light_too_high")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                        
                        Button(action: {
                            withAnimation {
                                showLightHighDialog = false
                                onDismiss(viewModel.faceVerifyResult.code)
                                dismiss()
                            }
                        }) {
                            Text("Confirm")
                                .font(.system(size: 18).bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.brown)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.vertical, 22)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 30) // 设置弹窗左右边距
                }
                .zIndex(2)  
                .transition(.scale(scale: 0.8).combined(with: .opacity)) // 添加出现动画
            }
        }
         .onAppear {
             originalBrightness = UIScreen.main.brightness
             withAnimation(.easeInOut(duration: 0.3)) {
                UIScreen.main.brightness = 1.0
            }
            
            // 校验本地是否有特征值
            guard let faceFeature = UserDefaults.standard.string(forKey: faceID) else {
                toastViewTips = "No Face Feature for key: \(faceID)"
                showToast = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showToast = false
                    // 假设 VerifyResultCode.NO_FACE_FEATURE 是 6 (参考注释)
                    onDismiss(6)
                    dismiss()
                }
                return
            }
            
            // 初始化 SDK
            // 活体类型： //0.无需活体检测 1.仅仅动作 2.动作+炫彩 3.炫彩
            // 动作活体种类： 1. 张张嘴  2.微笑  3.眨眨眼  4.摇摇头  5.点头
            viewModel.initFaceAISDK(
                faceIDFeature: faceFeature,
                threshold: threshold,
                livenessType: 1,
                onlyLiveness: false,
                motionLiveness: "1, 3, 4, 5"
            )
        }
        .onChange(of: viewModel.faceVerifyResult.code) { newValue in
            // 清空手动的 tips，使用 SDK 的结果
            toastViewTips = ""
            
            if newValue == VerifyResultCode.COLOR_LIVENESS_LIGHT_TOO_HIGH{
                //光线太强了
                withAnimation {
                    showLightHighDialog = true
                }
            }else{
                showToast = true
                print("检测返回 ： \(viewModel.faceVerifyResult)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation {
                        showToast = false
                    }
                    onDismiss(viewModel.faceVerifyResult.code)
                    dismiss()
                }
            }
            
            
            
        }
        .onDisappear {
             withAnimation(.easeInOut(duration: 0.3)) {
                UIScreen.main.brightness = originalBrightness
            }
            
            viewModel.stopFaceVerify()
        }
        .animation(.easeInOut(duration: 0.3), value: showToast)
    }
}
// -2  人脸识别动作活体检测超过10秒
// -1  多次切换人脸或检查失败
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
