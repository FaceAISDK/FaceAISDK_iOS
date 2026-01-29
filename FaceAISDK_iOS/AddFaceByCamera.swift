import SwiftUI
import AVFoundation
import FaceAISDK_Core

// 使用 @MainActor 确保在主线程访问
@MainActor
var FaceCameraSize: CGFloat {
    // 保持相机区域为屏幕宽度或高度的 70%，确保是正方形
    7 * min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 10
}

public struct AddFaceByCamera: View {
    let faceID: String
    let onDismiss: (Int) -> Void //0 用户取消， 1 添加成功
    
    // 屏幕亮度控制开关，默认为 true (原生友好)
    // 如果是三方uniapp,RN,Flutter插件调用，会将其设为 false，由 Manager 在外部控制亮度
    var autoControlBrightness: Bool = true
    
    //引入 dismiss 环境遍历，用于手动控制页面退出
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: AddFaceByCameraModel = AddFaceByCameraModel()
    
    // 辅助函数：获取本地化提示
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "Add Face Tips Code=\(code)"
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // 自定义顶部栏 (关闭按钮)
                HStack {
                    Button(action: {
                        onDismiss(0)  // 传递取消状态
                        dismiss()     // 触发导航栏返回（Pop）
                    }) {
                        Image(systemName: "chevron.left") // 系统图标 "xmark" 或 "chevron.left"
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black) // 图标颜色
                            .padding(10)
                            .background(Color.gray.opacity(0.1)) // 浅灰色圆形背景
                            .clipShape(Circle())
                    }
                    Spacer() // 将按钮推到左边
                }
                .padding(.horizontal, 2)
                .padding(.top, 10) // 顶部留白
                
                // 1. 顶部提示区域
                Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                    .font(.system(size: 19).bold())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .background(Color.brown)
                    .cornerRadius(20)
                
                // 2. 核心区域：相机与确认弹窗的容器
                ZStack {
                    // 图层 A: 相机预览 (底层)
                    FaceAICameraView(session: viewModel.captureSession, cameraSize: FaceCameraSize)
                        .aspectRatio(1.0, contentMode: .fit)
                        .clipShape(Circle()) // 裁剪为圆形
                        .background(Circle().fill(Color.white)) // 相机背景
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    
                    // 图层 B: 确认对话框 (顶层)
                    if viewModel.readyConfirmFace {
                        // 黑色半透明遮罩
                        Color.black.opacity(0.3)
                            .clipShape(Circle())
                        
                        ConfirmAddFaceDialog(
                            viewModel: viewModel,
                            cameraSize: FaceCameraSize,
                            onConfirm: {
//                                print("FaceFeature: \(String(describing: viewModel.faceFeatureBySDKCamera))")
                                // 保存人脸特征值
                                UserDefaults.standard.set(viewModel.faceFeatureBySDKCamera, forKey: faceID)
                                
                                // 报错人脸图（可选操作，非SDK运行必须）
                                if FaceImageManger.saveFaceImage(faceName: faceID, faceImage: viewModel.croppedFaceImage){
                                    print("Base64: \(String(describing: FaceImageManger.faceImageToBase64(fileName:faceID)))")
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    onDismiss(1)  // 传递取消状态
                                    dismiss()     // 触发导航栏返回（Pop）
                                }
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: FaceCameraSize, height: FaceCameraSize)
                .animation(.easeInOut(duration: 0.25), value: viewModel.readyConfirmFace)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.ignoresSafeArea())
            // 隐藏系统导航栏和返回按钮
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true) //兼容iOS 15 及以下
            
            // 生命周期事件
            .onAppear {
                // 【新增】如果是自动模式（原生），则在此处调亮
                if autoControlBrightness {
                    ScreenBrightnessHelper.shared.maximizeBrightness()
                }
                
                viewModel.initAddFace()
            }
            .onChange(of: viewModel.sdkInterfaceTips.code) { newValue in
                print("🔔 AddFaceBySDKCamera： \(viewModel.sdkInterfaceTips.message)")
            }
            .onDisappear {
                // 【新增】如果是自动模式（原生），则在此处恢复
                if autoControlBrightness {
                    ScreenBrightnessHelper.shared.restoreBrightness()
                }
                
                viewModel.stopAddFace()
            }
        }
    }
}

//ConfirmAddFaceDialog 保持不变
struct ConfirmAddFaceDialog: View {
    let viewModel: AddFaceByCameraModel
    let cameraSize: CGFloat
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            
            Text("Confirm Add Face")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.brown)
                .padding(.top, 16)

            Image(uiImage: viewModel.croppedFaceImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

            Text("Ensure face is clear")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 按钮组
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.reInit()
                }) {
                    Text("Retry")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.gray.opacity(0.6))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    onConfirm()
                }) {
                    Text("Confirm")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(width: cameraSize * 1.11)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
