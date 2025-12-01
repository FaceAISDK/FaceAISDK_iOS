import SwiftUI
import AVFoundation
import FaceAISDK_Core

// 使用 @MainActor 确保在主线程访问
@MainActor
var FaceAICameraSize: CGFloat {
    4 * min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 5
}

public struct AddFaceByCamera: View {
    let faceID: String
    let onDismiss: (String?) -> Void  //返回人脸特征值字符串，长度1024.
    
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
                .font(.system(size: 20).bold())
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .background(Color.faceMain) // 假设 Color.faceMain 已定义
                .cornerRadius(20)
            
            // 2. 核心区域：相机与确认弹窗的容器
            // 使用 ZStack 让两者重叠在同一区域
            ZStack {
                // 图层 A: 相机预览 (底层)
                FaceAICameraView(session: viewModel.captureSession, cameraSize: FaceAICameraSize)
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipShape(Circle()) // 裁剪为圆形
                    .background(Circle().fill(Color.white)) // 相机背景
                
                // 图层 B: 确认对话框 (顶层)
                if viewModel.readyConfirmFace {
                    // B1. 遮罩层：用于遮挡相机画面
                    Circle()
                        .fill(Color.white.opacity(0.95)) // 微透明或纯白，看设计需求
                        .transition(.opacity)
                    
                    // B2. 对话框实体
                    ConfirmAddFaceDialog(
                        viewModel: viewModel,
                        cameraSize: FaceAICameraSize, // 传入尺寸以适配
                        onConfirm: {
                            
                            //保存人脸特征值。人脸图如果业务有需要也可以保存，SDK不需要人脸图只需要人脸特征
                            UserDefaults.standard.set(viewModel.faceFeatureBySDKCamera, forKey: faceID)
                            let savedPath = viewModel.confirmSaveFace(fileName: faceID)

                            onDismiss(viewModel.faceFeatureBySDKCamera)
                            print("相机 FaceFeature: \(viewModel.faceFeatureBySDKCamera!)")
                        }
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity)) // 添加一点弹出动画
                }
            }
            .frame(width: FaceAICameraSize, height: FaceAICameraSize) // 强制容器尺寸一致
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.3), value: viewModel.readyConfirmFace) // 全局动画优化
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
    

        // MARK: - 确认对话框组件
        struct ConfirmAddFaceDialog: View {
            // 使用 @ObservedObject 监听 viewModel 变化，或者直接传入 let 引用（如果父视图刷新机制已覆盖）
            // 这里沿用你原来的 let 定义，因为父视图 AddFaceByCamera 已经持有 @StateObject
            let viewModel: AddFaceByCameraModel
            let cameraSize: CGFloat
            let onConfirm: () -> Void
            
            var body: some View {
                VStack(alignment: .center, spacing: 11) {
                    
                    Text("Confirm Add Face Title")
                        .font(.system(size: 19).bold())
                        .foregroundColor(.faceMain) // 确保你有定义这个颜色，否则用 .blue
                        .padding(.top, 12)
                    
                    Image(uiImage: viewModel.croppedFaceImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 142, height: 142) // 保持你原来的大小或微调
                        .clipShape(Circle()) // 圆形裁剪
                        // 如果你想要圆角矩形，就用下面这行代替上面那行：
                        // .cornerRadius(8)
                        .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 0.5)) // 边框装饰
                        .shadow(radius: 1)

                    
                    Text("Confirm Add Face Tips")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray) // 稍微浅一点的颜色
                        .font(.system(size: 16).bold())
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            viewModel.reInit()
                        }) {
                            Text("Retry")
                                .frame(maxWidth: .infinity, maxHeight: 45)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(7)
                        }
                        
                        Button(action: {
                            onConfirm()
                        }) {
                            Text("Confirm")
                                .frame(maxWidth: .infinity, maxHeight: 45)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(7)
                        }
                    }
                    .padding()
                }
                // 确保对话框在相机区域内居中
                .frame(width: cameraSize+15, height: cameraSize+9)
                .background(Color.white) // 背景透明，依靠外层的 ZStack Circle 遮挡
                .cornerRadius(9)
                .shadow(radius: 8)
            }
        }
    
    
}
