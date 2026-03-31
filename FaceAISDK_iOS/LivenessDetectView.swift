import SwiftUI
import AVFoundation
import FaceAISDK_Core

/**
 * 活体检测，（iOS 已经支持动作活体，炫彩活体，静默活体也已经20260327稳定）
 * UI 样式仅供参考，根据你的业务可自行调整
 */
struct LivenessDetectView: View {
    @StateObject private var viewModel: VerifyFaceModel = VerifyFaceModel()
    @State private var showToast = false
    @State private var showLightHighDialog = false
    @Environment(\.dismiss) private var dismiss

    // 屏幕亮度控制开关，默认为 true (原生友好)
    // 如果是三方uniapp,RN,Flutter插件调用，会将其设为 false，由 Manager 在外部控制亮度
    var autoControlBrightness: Bool = true
    
    // 0.无需活体检测 1.仅仅动作 2.动作+炫彩 3.炫彩
    let livenessType:Int
    // 动作活体种类：1. 张张嘴  2.微笑  3.眨眨眼  4.摇摇头  5.点头
    let motionLiveness:String
    
    let motionLivenessTimeOut:Int //时间为秒
    let motionLivenessSteps:Int  //动作活体个数
    
    // 修改：增加 Float 参数返回活体分数
    let onDismiss: (Int, Float) -> Void
    
    // 可以根据Code进行多语言提示
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "LivenessDetect Tips Code=\(code)"
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
    
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        onDismiss(0,0.0) // 0 代表用户取消
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
                
//                Text("亮度： \(viewModel.brightnessValue)")
//                    .font(.system(size: 12).bold())
//                    .padding(.bottom, 8)
//                    .frame(minHeight: 30)
//                    .foregroundColor(.black)
                
                // 原有内容
                Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                    .font(.system(size: 20).bold())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 9)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center) // 设置多行居中对齐
                    .background(Color.faceMain)
                    .cornerRadius(20)
                
                Text(localizedTip(for: viewModel.sdkInterfaceTipsExtra.code))
                    .font(.system(size: 20).bold())
                    .multilineTextAlignment(.center) // 设置多行居中对齐
                    .padding(.bottom, 8)
                    .frame(minHeight: 30)
                    .foregroundColor(.black)
                
                FaceAICameraView(session: viewModel.captureSession, cameraSize: FaceCameraSize)
                    .frame(width: FaceCameraSize, height: FaceCameraSize)
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.vertical, 8)
                    .clipShape(Circle())
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity) //确保主视图撑满
            .background(viewModel.colorFlash.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)  

             if showToast {
                
                 let isSuccess = viewModel.faceVerifyResult.liveness > 0.8
                 let toastStyle: ToastStyle = isSuccess ? .success : .failure
                 
                VStack {
                    Spacer() // 将 Toast 推到底部
                    CustomToastView(
                        message: "\(viewModel.faceVerifyResult.tips)",
                        style: toastStyle
                    )
                     .padding(.bottom, 77)
                }
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1) // 确保在最上层
            }
            
            // 光线过强自定义弹窗 (Dialog) ---
            if showLightHighDialog {
                ZStack {
                    VStack(spacing: 22) {
                        Text(viewModel.faceVerifyResult.tips)
                            .font(.system(size: 16).bold())
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.horizontal,25)


                        if let uiImage = UIImage(named: "light_too_high") {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 120)
                                        .padding(.horizontal,1)}
                        
                        Button(action: {
                            withAnimation {
                                showLightHighDialog = false
                                onDismiss(viewModel.faceVerifyResult.code,viewModel.faceVerifyResult.liveness)
                                dismiss()
                            }
                        }) {
                            Text("Confirm")
                                .font(.system(size: 18).bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.faceMain)
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
                .zIndex(2) // 确保在最上层 (比 Toast 更高)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
            
        }
        .onAppear {
            if autoControlBrightness {
                ScreenBrightnessHelper.shared.maximizeBrightness()
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                UIScreen.main.brightness = 1.0
            }
            
            viewModel.initFaceAISDK(faceIDFeature: "", 
                                    livenessType: livenessType,
                                    onlyLiveness: true,
                                    motionLiveness: motionLiveness,
                                    motionLivenessTimeOut:motionLivenessTimeOut,
                                    motionLivenessSteps:motionLivenessSteps)
        }
        .onChange(of: viewModel.faceVerifyResult.code) { newValue in
            if newValue == VerifyResultCode.COLOR_LIVENESS_LIGHT_TOO_HIGH{
                withAnimation {  //光线太强了
                    showLightHighDialog = true
                }
            }else{
                showToast = true
                
                if FaceImageManger.saveFaceImage(faceName: "Liveness", faceImage: viewModel.faceVerifyResult.faceImage){
                    //print("Base64: \(String(describing: FaceImageManger.faceImageToBase64(fileName:"Liveness")))")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showToast = false
                    }
                    onDismiss(viewModel.faceVerifyResult.code,viewModel.faceVerifyResult.liveness)
                    dismiss()
                }
            }
        }
        .onDisappear {
            if autoControlBrightness {
                ScreenBrightnessHelper.shared.restoreBrightness()
            }
            
            viewModel.stopFaceVerify()
        }
        .animation(.easeInOut(duration: 0.3), value: showToast) // 统一控制 Toast 动画
    }
}

