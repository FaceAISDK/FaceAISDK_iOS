import SwiftUI
import FaceAISDK_Core

/**
 * 1:1 Face Verification and Liveness Detection        1:1 人脸识别以及活体检测
 */
struct VerifyFaceView: View {
    @StateObject private var viewModel: VerifyFaceModel = VerifyFaceModel()
    @Environment(\.dismiss) private var dismiss
    // Prompt that the ambient light is too bright  提示环境光太亮
    @State private var showLightHighDialog = false
    @State private var showFailureDialog = false
    @State private var showToast = false
    @State private var toastMessage: String = ""
    @State private var isTipAppeared = false
    
    // Automatically control screen brightness
    // 自动控制屏幕亮度
    var autoControlBrightness: Bool = true
    var retryTime:Int = 0; //记录失败尝试的次数 建议可以重试3-4次

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

    // Multi-language tips  多语言提示
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "VerifyFace Tips Code=\(code)"
        let tipsString = NSLocalizedString(key, value: defaultValue, comment: "")
        if code != 0 && code != 1 && code != 3 { //剔除不需要语音提示的code，否则太啰嗦
            TTSPlayer.shared.speak(tipsString)
        }
        return tipsString
    }
    
    private func showToastAndDismiss(
        message: String,
        code: Int,
        similarity: Float = 0.0,
        liveness: Float = 0.0,
        delay: Double = 1.5
    ) {
        toastMessage = message
        withAnimation {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation {
                showToast = false
            }
            onDismiss(code, similarity, liveness)
            dismiss()
        }
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
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            
            if showToast {
                // Calculate style: If it's a missing feature error or low similarity, it's a failure
                // 计算样式：如果是无特征值错误，或者相似度低，则为 failure
                let isSuccess = viewModel.faceVerifyResult.similarity > threshold && viewModel.faceVerifyResult.liveness>0.72
                let toastStyle: ToastStyle = isSuccess ? .success : .failure
                
                VStack {
                    Spacer()
                    CustomToastView(
                        message: toastMessage,
                        style: toastStyle
                    )
                    .padding(.bottom, 77)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
            
            // Custom dialog for high light levels  光线过强自定义弹窗 (Dialog)
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

            // Failure dialog when verification/liveness fails (两按钮：知道了 / 重试)
            if showFailureDialog {
                ZStack {
                    VStack(spacing: 18) {
                        Text(viewModel.faceVerifyResult.tips)
                            .font(.system(size: 18).bold())
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.vertical,18)

                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation {
                                    showFailureDialog = false
                                }
                                _ = FaceImageManager.saveFaceImage(faceName: faceID, faceImage: viewModel.faceVerifyResult.faceImage)
                                showToastAndDismiss(
                                    message: viewModel.faceVerifyResult.tips,
                                    code: viewModel.faceVerifyResult.code,
                                    similarity: viewModel.faceVerifyResult.similarity,
                                    liveness: viewModel.faceVerifyResult.liveness,
                                    delay: 1
                                )
                            }) {
                                Text("I Know")
                                    .font(.system(size: 18).bold())
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }

                            Button(action: {
                                withAnimation {
                                    showFailureDialog = false
                                    showToast = false
                                }
                                viewModel.reInit()
                            }) {
                                Text("Retry")
                                    .font(.system(size: 18).bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.faceMain)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .padding(.vertical, 18)
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
             
             withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.9)) {
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
                showToastAndDismiss(
                    message: "No Face Feature for : \(faceID)",
                    code: VerifyResultCode.NO_FACE_FEATURE
                )
                return
            }
             
             
             guard faceFeature.count >= 1024 else {
                 showToastAndDismiss(
                     message: "Invalid Feature length for : \(faceID)",
                     code: VerifyResultCode.NO_FACE_FEATURE
                 )
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
        //和Android 一样允许重试，而不是立即结束整个流程
        .onChange(of: viewModel.faceVerifyResult.code) { newValue in
            guard newValue != VerifyResultCode.DEFAULT else { return }
            
            if newValue == VerifyResultCode.COLOR_LIVENESS_LIGHT_TOO_HIGH{
                withAnimation {
                    showLightHighDialog = true // Light is too strong 光线太强了
                }
                return
            }

            // 如果是下列失败码之一，则弹出失败对话框（允许用户知道了或重试），并返回以避免继续执行默认的 toast/退出流程
            let failureCodes: [Int] = [
                VerifyResultCode.VERIFY_FAILED,
                VerifyResultCode.MOTION_LIVENESS_TIMEOUT,
                VerifyResultCode.NO_FACE_MULTI,
                VerifyResultCode.COLOR_LIVENESS_FAILED,
                VerifyResultCode.SILENT_LIVENESS_FAILED
            ]

            if failureCodes.contains(newValue) {
                withAnimation {
                    showFailureDialog = true
                }
                return
            }

            _ = FaceImageManager.saveFaceImage(faceName: faceID, faceImage: viewModel.faceVerifyResult.faceImage)
            
            showToastAndDismiss(
                message: viewModel.faceVerifyResult.tips,
                code: viewModel.faceVerifyResult.code,
                similarity: viewModel.faceVerifyResult.similarity,
                liveness: viewModel.faceVerifyResult.liveness,
                delay: 1
            )
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
