import SwiftUI
import PhotosUI
import FaceAISDK_Core


//从相册添加人脸
public struct AddFaceByUIImage: View {

    // 状态管理
    @State private var showImagePicker = false // 控制相册弹窗
    @State private var isLoading = false
    @State private var canSave = false

    // 用于显示和处理的 Image
    @State private var selectedImage: UIImage?
    
    @StateObject private var viewModel: AddFaceByUIImageModel = AddFaceByUIImageModel()
    
    let faceID: String
    let onDismiss: (Int) -> Void
    
    //引入 dismiss 环境遍历，用于手动控制页面退出
    @Environment(\.dismiss) private var dismiss
    
    // 辅助函数
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "LivenessDetect Tips Code=\(code)"
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 20) {
                
                // MARK: - 自定义顶部栏
                HStack {
                    Button(action: {
                        onDismiss(0)  // 传递取消状态
                        dismiss()     // 触发导航栏返回（Pop）
                    }) {
                        Image(systemName: "chevron.left")
                            // iOS 15 兼容修复：fontWeight 合并在 font 中设置
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // MARK: - 主内容区域
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // 1. 状态提示
                        Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                            .font(.system(size: 16).bold())
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .foregroundColor(.white)
                            .background(Color.faceMain)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        // 2. 图片预览区
                        if let selectedImage {
                            ZStack {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 166, maxHeight: 166)
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
                            VStack(spacing: 12) {
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(.tertiary) // iOS 15+ 支持
                                
                                Text("Select from album")
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
                        
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Label("Select Image", systemImage: "photo.on.rectangle.angled")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .padding(.horizontal, 40)
                        
                        // 4. 保存按钮
                        if canSave {
                            Button(action: {
                                if let image = selectedImage {
                                    let faceFeature = viewModel.getFaceFeature(faceUIImage: image)
                                    UserDefaults.standard.set(faceFeature, forKey: faceID)
                                    //print("UIImage 特征值: \(faceFeature)")
                                    
                                    // let _ = viewModel.confirmSaveFace(fileName: faceID)
                                    onDismiss(1)  // 传递取消状态
                                    dismiss()     // 触发导航栏返回（Pop）
                                }
                            }) {
                                Text("Save Face Feature")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .padding(.horizontal, 40)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            
            .onChange(of: viewModel.croppedFaceImage) { newValue in
                withAnimation {
                    selectedImage = newValue
                    isLoading = false
                    canSave = true
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage) { uiImage in
                    // 图片选择完成后的回调
                    isLoading = true
                    canSave = false
                    // 触发 SDK 检测逻辑
                    viewModel.addFaceByUIImage(faceUIImage: uiImage)
                }
            }
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    // 回调：当用户选择照片后触发
    var onImagePicked: ((UIImage) -> Void)?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images // 只显示图片
        config.selectionLimit = 1 // 只能选一张
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { image, error in
                if let uiImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.selectedImage = uiImage
                        self.parent.onImagePicked?(uiImage)
                    }
                }
            }
        }
    }
}
