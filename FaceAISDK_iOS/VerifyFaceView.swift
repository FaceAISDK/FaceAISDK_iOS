import SwiftUI
import FaceAISDK_Core

/**
 * 1:1 Face Verification and Liveness Detection
 * 1:1 人脸识别以及活体检测
 */
struct VerifyFaceView: View {
    @StateObject private var viewModel: VerifyFaceModel = VerifyFaceModel()
    @Environment(\.dismiss) private var dismiss
    // Prompt that the ambient light is too bright
    // 提示环境光太亮
    @State private var showLightHighDialog = false
    @State private var showToast = false
    @State private var toastViewTips: String = ""
    @State private var isTipAppeared = false
    
    
    // Automatically control screen brightness
    // 自动控制屏幕亮度
    var autoControlBrightness: Bool = true

    let faceID: String
    let threshold: Float
    
    // 0. No liveness detection 1. Motion only 2. Motion + Color flash 3. Color flash only
    // 0.无需活体检测 1.仅仅动作 2.动作+炫彩 3.炫彩
    let livenessType:Int
    
    // Types of motion liveness: 1. Open mouth 2. Smile 3. Blink 4. Shake head 5. Nod
    // 动作活体种类：1. 张张嘴  2.微笑  3.眨眨眼  4.摇摇头  5.点头
    let motionLiveness:String
    
    // Motion liveness timeout (seconds)
    // 动作活体超时（秒）
    let motionLivenessTimeOut:Int
    
    // Number of motion liveness steps
    // 动作活体步骤个数
    let motionLivenessSteps:Int
    
    // Callback status, face similarity, liveness score
    // 返回状态，人脸相似度，活体分数
    let onDismiss: (Int, Float, Float) -> Void

    // Multi-language tips
    // 多语言提示
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "VerifyFace Tips Code=\(code)"
        let tipsString = NSLocalizedString(key, value: defaultValue, comment: "")
        if code != 0 && code != 1 && code != 3 {
            TTSPlayer.shared.speak(tipsString)
        }
        return tipsString
    }
    
    var body: some View {
        ZStack {
            VStack {
                 HStack {
                    Button(action: {
                        // 0 represents user cancellation 代表用户取消
                        onDismiss(0, 0.0, 0.0)
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
                .padding(.horizontal, 2)
                .padding(.top, 10)
                
                if isTipAppeared {
                    Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                        .font(.system(size: 20).bold())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .foregroundColor(.white)
                        .background(Color.faceMain)
                        .cornerRadius(20)
                        .id(viewModel.sdkInterfaceTips.code)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.sdkInterfaceTips.code)
                }
                
                Text(localizedTip(for: viewModel.sdkInterfaceTipsExtra.code))
                    .font(.system(size: 20).bold())
                    .padding(.bottom, 6)
                    .frame(minHeight: 30)
                    .foregroundColor(.black)
                
                FaceSDKCameraView(session: viewModel.captureSession, cameraSize: FaceCameraSize)
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
            // Hide system navigation bar
            // 隐藏系统导航栏
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            
            if showToast {

                let similarity = String(format: "%.2f", viewModel.faceVerifyResult.similarity)
                // Prefer manually set toastViewTips (for handling missing feature values), otherwise use tips returned by SDK
                // 优先使用手动设置的 toastViewTips (用于处理无特征值的情况)，否则使用 SDK 返回的 tips
                let displayTips = toastViewTips.isEmpty ? viewModel.faceVerifyResult.tips : toastViewTips
                let displayMessage = (toastViewTips.isEmpty) ? "\(displayTips)" : displayTips
                
                // Calculate style: If it's a missing feature error or low similarity, it's a failure
                // 计算样式：如果是无特征值错误，或者相似度低，则为 failure
                let isSuccess = viewModel.faceVerifyResult.similarity > threshold && viewModel.faceVerifyResult.liveness>0.72
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
            
            // Custom dialog for high light levels
            // 光线过强自定义弹窗 (Dialog)
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
                                onDismiss(viewModel.faceVerifyResult.code,viewModel.faceVerifyResult.similarity,viewModel.faceVerifyResult.liveness)
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
                    .padding(.horizontal, 30)
                }
                .zIndex(2)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
         .onAppear {
             
             withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                 isTipAppeared = true
             }
             
             if autoControlBrightness {
                 ScreenBrightnessHelper.shared.maximizeBrightness()
             }
             
             withAnimation(.easeInOut(duration: 0.3)) {
                UIScreen.main.brightness = 1.0
            }
            
            // Check if there is a local feature value
            // 校验本地是否有特征值
            guard let faceFeature = UserDefaults.standard.string(forKey: faceID) else {
                toastViewTips = "No Face Feature for : \(faceID)"
                showToast = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showToast = false
                    // Callback NO_FACE_FEATURE
                    // 返回无特征值状态
                    onDismiss(6,0.0,0.0)
                    dismiss()
                }
                return
            }
             
             
             guard faceFeature.count >= 1024 else {
                 toastViewTips = "Invalid Feature length for : \(faceID)"
                 showToast = true
                 
                 DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                     showToast = false
                     onDismiss(6, 0.0, 0.0)
                     dismiss()
                 }
                 return
             }
             
             
            
            viewModel.initFaceAISDK(
                faceIDFeature: faceFeature,
                threshold: threshold,
                livenessType: livenessType,
                onlyLiveness: false,
                motionLiveness: motionLiveness,
                motionLivenessTimeOut:motionLivenessTimeOut,
                motionLivenessSteps:motionLivenessSteps
            )
        }
        .onChange(of: viewModel.faceVerifyResult.code) { newValue in
            // Clear manual tips, use SDK results
            // 清空手动的 tips，使用 SDK 的结果
            toastViewTips = ""
            
            if newValue == VerifyResultCode.COLOR_LIVENESS_LIGHT_TOO_HIGH{
                // Light is too strong
                // 光线太强了
                withAnimation {
                    showLightHighDialog = true
                }
            }else{
                showToast = true
                
                if FaceImageManager.saveFaceImage(faceName: faceID, faceImage: viewModel.faceVerifyResult.faceImage){
                    print("saveFaceImage success ")
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        showToast = false
                    }
                    onDismiss(viewModel.faceVerifyResult.code,viewModel.faceVerifyResult.similarity,viewModel.faceVerifyResult.liveness)
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
        .animation(.easeInOut(duration: 0.3), value: showToast)
    }
}
