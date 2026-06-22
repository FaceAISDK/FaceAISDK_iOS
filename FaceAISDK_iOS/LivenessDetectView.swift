import SwiftUI
import AVFoundation
import FaceAISDK_Core

/**
 * Liveness Detection (Supports motion, color flash, and silent liveness)
 * UI style is for reference only and can be adjusted according to your business needs
 * 活体检测（支持动作活体，炫彩活体，静默活体）UI 样式仅供参考，根据你的业务可自行调整
 */
struct LivenessDetectView: View {
    @StateObject private var viewModel: VerifyFaceModel = VerifyFaceModel()
    @State private var showToast = false
    @State private var showLightHighDialog = false
    @State private var isTipAppeared = false
    
    @Environment(\.dismiss) private var dismiss

    // Automatically control screen brightness
    // 自动控制屏幕亮度
    var autoControlBrightness: Bool = true
    
    // 0. No liveness detection  1. Motion only  2. Motion + Color flash  3. Color flash only
    // 0. 无需活体检测 1.仅仅动作 2.动作+炫彩 3.炫彩
    let livenessType:Int
    
    // Types of motion liveness:  1. Open mouth  2. Smile  3. Blink  4. Shake head  5. Nod
    // 动作活体种类：1. 张张嘴  2.微笑  3.眨眨眼  4.摇摇头  5.点头
    let motionLiveness:String
    
    // Timeout in seconds
    // 动作活体超时时间，秒
    let motionLivenessTimeOut:Int
    
    // Number of motion steps
    // 动作活体个数
    let motionLivenessSteps:Int
    
    // show Result Tips? For Flutter,RN,UNIApp plugin
    let showResultTips:Bool
    
    // callback status liveness score
    let onDismiss: (Int, Float) -> Void
    
    // Multi-language tips can be provided based on the Code
    // 可以根据Code进行多语言提示
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "LivenessDetect Tips Code=\(code)"
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
                        // 0 represents user cancellation 0代表用户取消
                        onDismiss(0,0.0)
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
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                    .frame(minHeight: 30)
                    .foregroundColor(.black)
                
                FaceSDKCameraView(session: viewModel.captureSession, cameraSize: FaceCameraSize)
                    .frame(width: FaceCameraSize, height: FaceCameraSize)
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.vertical, 8)
                    .clipShape(Circle())
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(viewModel.colorFlash.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)

             if showToast && showResultTips {
                
                 let isSuccess = viewModel.faceVerifyResult.liveness > 0.75
                 let toastStyle: ToastStyle = isSuccess ? .success : .failure
                 
                VStack {

                    Spacer()
                    CustomToastView(
                        message: "\(viewModel.faceVerifyResult.tips) \(viewModel.faceVerifyResult.liveness)",
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
                    // Set left and right padding for the dialog
                    // 设置弹窗左右边距
                    .padding(.horizontal, 30)
                }
                // Ensure it is on the top layer (higher than Toast)
                // 确保在最上层 (比 Toast 更高)
                .zIndex(2)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
            
        }
        .onAppear {
            if autoControlBrightness {
                ScreenBrightnessHelper.shared.maximizeBrightness()
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                isTipAppeared = true
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
                // Light is too strong 光线太强了
                withAnimation {
                    showLightHighDialog = true
                }
            }else{
                showToast = true
                
                if FaceImageManager.saveFaceImage(faceName: "Liveness", faceImage: viewModel.faceVerifyResult.faceImage){
                    //print("Base64: \(String(describing: FaceImageManger.faceImageToBase64(fileName:"Liveness")))")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
        .animation(.easeInOut(duration: 0.3), value: showToast)
    }
}
