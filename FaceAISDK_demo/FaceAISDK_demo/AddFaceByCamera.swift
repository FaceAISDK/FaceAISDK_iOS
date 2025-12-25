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
    let onDismiss: (String?) -> Void
    
    @StateObject private var viewModel: AddFaceByCameraModel = AddFaceByCameraModel()
    
    // 辅助函数：获取本地化提示
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "Add Face Tips Code=\(code)"
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
    
    public var body: some View {
        VStack(spacing: 22) {
            // 1. 顶部提示区域
            Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                .font(.system(size: 19).bold())
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .background(Color.faceMain)
                .cornerRadius(20)
            
            // 2. 核心区域：相机与确认弹窗的容器
            // 使用 ZStack 让两者重叠在同一区域
            ZStack {
                // 图层 A: 相机预览 (底层)
                FaceAICameraView(session: viewModel.captureSession, cameraSize: FaceCameraSize)
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipShape(Circle()) // 裁剪为圆形
                    .background(Circle().fill(Color.white)) // 相机背景
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                
                // 图层 B: 确认对话框 (顶层)
                if viewModel.readyConfirmFace {
                    // 黑色半透明遮罩，突出 Dialog
                    Color.black.opacity(0.3)
                        .clipShape(Circle())
                    
                    ConfirmAddFaceDialog(
                        viewModel: viewModel,
                        cameraSize: FaceCameraSize,
                        onConfirm: {
                            // 保存人脸特征值
                            UserDefaults.standard.set(viewModel.faceFeatureBySDKCamera, forKey: faceID)
                            print("FaceFeature: \(String(describing: viewModel.faceFeatureBySDKCamera))")

                            // 人脸图保存逻辑
                            let _ = viewModel.confirmSaveFace(fileName: faceID)

                            onDismiss(viewModel.faceFeatureBySDKCamera)
                        }
                    )
                    // 增加淡入动画
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: FaceCameraSize, height: FaceCameraSize) // 强制容器尺寸一致
            .animation(.easeInOut(duration: 0.25), value: viewModel.readyConfirmFace)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            viewModel.initAddFace()
        }
        .onChange(of: viewModel.sdkInterfaceTips.code) { newValue in
            print("🔔 AddFaceBySDKCamera： \(viewModel.sdkInterfaceTips.message)")
        }
        .onDisappear {
            viewModel.stopAddFace()
        }
    }
}



// MARK: - 确认对话框组件
struct ConfirmAddFaceDialog: View {
    // 使用 @ObservedObject 监听变化，或者让父视图传递（这里沿用你的 let，因为父视图是 StateObject）
    let viewModel: AddFaceByCameraModel
    let cameraSize: CGFloat
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            
            Text("Confirm Add Face")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.faceMain)
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
                        .background(Color.gray.opacity(0.15))
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
                        .background(Color.faceMain)
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



