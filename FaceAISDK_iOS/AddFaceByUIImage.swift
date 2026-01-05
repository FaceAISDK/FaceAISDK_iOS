import SwiftUI
import PhotosUI // PhotosUI 框架
import FaceAISDK_Core

public struct AddFaceByUIImage: View {

    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoading = false
    @State private var canSave = false

    // 用于存储最终加载并用于显示的 SwiftUI Image
    @State private var selectedImage: UIImage?
    
    @StateObject private var viewModel: addFaceByUIImageModel = addFaceByUIImageModel()
    
    // 录入保存的FaceID 值。一般是你的业务体系中个人的唯一编码，比如账号 身份证
    let faceID: String
    let onDismiss: (Int) -> Void  // 0 用户取消， 1 添加成功
    
    // 根据提示状态码多语言展示文本
    // 添加人脸状态码参考 AddFaceTipsCode
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "LivenessDetect Tips Code=\(code)"
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
    
    public var body: some View {
        // 使用 ZStack 以便扩展未来的悬浮层 (如 Toast)
        ZStack {
            VStack(spacing: 20) {
                
                // 自定义顶部栏 (关闭按钮)
                HStack {
                    Button(action: {
                        // 0 代表用户取消
                        onDismiss(0)
                    }) {
                        Image(systemName: "chevron.left") // 保持统一风格
                            .fontWeight(.semibold)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10) // 顶部留白
                
                // MARK: - 主内容区域
                ScrollView { // 使用 ScrollView 以防内容在小屏幕上溢出
                    VStack(spacing: 25) {
                        
                        // 1. 状态提示文字
                        Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                            .font(.system(size: 16).bold()) // 统一字体大小
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .foregroundColor(.white)
                            .background(Color.brown)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        // 2. 图片展示区域
                        if let selectedImage {
                            ZStack {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 166, maxHeight: 166) // 稍微调大一点
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(radius: 8)
                                
                                if isLoading {
                                    ZStack {
                                        Color.black.opacity(0.4)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                        ProgressView()
                                            .scaleEffect(1.5)
                                            .tint(.white)
                                    }
                                    .frame(maxWidth: 166, maxHeight: 166)
                                }
                            }
                        } else {
                            // 默认占位符视图
                            VStack(spacing: 12) {
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(.tertiary)
                                
                                Text("请从相册中选择一张图片")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 166, height: 166)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                        }
                        
                        // 3. PhotosPicker 按钮
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            label: {
                                Label("选择图片", systemImage: "photo.on.rectangle.angled")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                            }
                        )
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .padding(.horizontal, 40)
                        
                        // 4. 保存按钮 (条件显示)
                        if canSave {
                            Button(action: {
                                // 保存逻辑
                                if let image = selectedImage {
                                    let faceFeature = viewModel.getFaceFeature(faceUIImage: image)
                                    UserDefaults.standard.set(faceFeature, forKey: faceID)
                                    print("UIImage 特征值: \(faceFeature)")
                                    
//                                    let _ = viewModel.confirmSaveFace(fileName: faceID)
                                    onDismiss(1)
                                }
                            }) {
                                Text("保存人脸数据")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .padding(.horizontal, 40)
                            .transition(.opacity.combined(with: .move(edge: .bottom))) // 添加动画
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color.white.ignoresSafeArea())
            // 隐藏系统导航栏
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            
            // 监听图片选择
            .onChange(of: selectedItem) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        
                        await MainActor.run {
                            isLoading = true
                            canSave = false
                            selectedImage = uiImage
                            // 开始检测
                            viewModel.addFaceByUIImage(faceUIImage: uiImage)
                        }
                    }
                }
            }
            // 监听检测结果 (裁剪后的图片)
            .onChange(of: viewModel.croppedFaceImage) { newValue in
                withAnimation {
                    selectedImage = newValue
                    isLoading = false
                    canSave = true
                }
            }
        }
    }
}
