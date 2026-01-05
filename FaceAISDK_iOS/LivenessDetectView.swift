import SwiftUI
import AVFoundation
import FaceAISDK_Core

/**
 * 动作活体检测，（iOS 目前仅支持动作活体，炫彩活体）
 * UI 样式仅供参考，根据你的业务可自行调整
 */
struct LivenessDetectView: View {
    @StateObject private var viewModel: VerifyFaceModel = VerifyFaceModel()
    @State private var showToast = false
    @State private var showLightHighDialog = false
    @Environment(\.dismiss) private var dismiss
    @State private var originalBrightness: CGFloat = UIScreen.main.brightness
    
    //0.无需活体检测 1.仅仅动作 2.动作+炫彩 3.炫彩
    let livenessType:Int
    //动作活体种类：1. 张张嘴  2.微笑  3.眨眨眼  4.摇摇头  5.点头
    let motionLiveness:String
    
    let onDismiss: (Int) -> Void
    
    // ... localizedTip 函数保持不变 ...
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "LivenessDetect Tips Code=\(code)"
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
    

    
    var body: some View {
        ZStack {
            // --- 底层：主内容 ---
            VStack {
                // MARK: - [新增] 自定义顶部栏 (关闭按钮)
                HStack {
                    Button(action: {
                        // 0 代表用户取消
                        onDismiss(0)
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
                
                // 原有内容
                Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                    .font(.system(size: 20).bold())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 9)
                    .foregroundColor(.white)
                    .background(Color.brown) //假设 Color.brown 为 blue
                    .cornerRadius(20)
                
                Text(localizedTip(for: viewModel.sdkInterfaceTipsExtra.code))
                    .font(.system(size: 19).bold())
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
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 确保主视图撑满
            .background(viewModel.colorFlash.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)

             if showToast {
                VStack {
                    Spacer() // 将 Toast 推到底部
                    CustomToastView(
                        message: "\(viewModel.faceVerifyResult.tips)",
                        style: .success
                    )
                     .padding(.bottom, 77)
                }
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1) // 确保在最上层
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
                .zIndex(2) // 确保在最上层 (比 Toast 更高)
                .transition(.scale(scale: 0.8).combined(with: .opacity)) // 添加出现动画
            }
            
        }
        .onAppear {
             originalBrightness = UIScreen.main.brightness
             withAnimation(.easeInOut(duration: 0.3)) {
                UIScreen.main.brightness = 1.0
            }
            
            viewModel.initFaceAISDK(faceIDFeature: "", livenessType: livenessType, onlyLiveness: true, motionLiveness: motionLiveness)
        }
        .onChange(of: viewModel.faceVerifyResult.code) { newValue in
            if newValue == VerifyResultCode.COLOR_LIVENESS_LIGHT_TOO_HIGH{
                //光线太强了，弹出一个提示Dialog, 上面显示文字viewModel.Result.msg
                withAnimation {
                    showLightHighDialog = true
                }
            }else{
                showToast = true
                print("动作活体检测返回 ： \(viewModel.faceVerifyResult)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
        .animation(.easeInOut(duration: 0.3), value: showToast) // 统一控制 Toast 动画
    }
}
// 添加这个空类，专门用来定位 Bundle
private class BundleFinder {}
