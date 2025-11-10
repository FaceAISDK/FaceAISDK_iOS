import SwiftUI
import PhotosUI //PhotosUI 框架
import FaceAISDK_Core


public struct AddFaceByUIImage: View {

    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoading = false
    @State private var canSave = false


    // 用于存储最终加载并用于显示的 SwiftUI Image
    @State private var selectedImage: UIImage?
    
    @StateObject private var viewModel: addFaceByUIImageModel = addFaceByUIImageModel()
    
    //录入保存的FaceID 值。一般是你的业务体系中个人的唯一编码，比如账号 身份证
    let faceID: String
    let onDismiss: (String?) -> Void
    
    
    //根据提示状态码多语言展示文本
    //添加人脸状态码参考 AddFaceTipsCode
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "LivenessDetect Tips Code=\(code)"
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
    
    
    
    public var body: some View {
            VStack(spacing: 2) {
                
                Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                    .font(.system(size: 18).bold())
                    .padding(.vertical,22)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            
                
                // 用于显示选择的图片
                if let selectedImage {
                    ZStack {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 5)
                        
                        if isLoading {
                            ProgressView()
                                .scaleEffect(2.0)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(7)
                        }
                    }
                } else {
                    // 默认占位符视图
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.tertiary)
                    Text("请从相册中选择一张图片")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // 3. PhotosPicker 视图
                PhotosPicker(
                    selection: $selectedItem, // 绑定到 PhotosPickerItem
                    matching: .images,        // 只允许选择图片
                    label: {
                        Label("选择图片", systemImage: "photo.on.rectangle.angled")
                            .frame(maxWidth: 300, maxHeight: 30)
                            .font(.headline)
                    }
                )
                .padding(.top,33)
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                
                if canSave {
                    Button("保存图片"){
                        viewModel.confirmSaveFaceAir(fileName: faceID)
                        onDismiss("保存成功")
                    }
                    .padding(.top,22)
                    .frame(maxWidth: .infinity)
                    .font(.headline)
                    .tint(.green)
                    .buttonStyle(.borderedProminent)
                }


            }
            .padding()
            .onChange(of: selectedItem) { newValue in
                // 当用户选择了新的图片时，执行加载任务
                Task {
                    // 将 PhotosPickerItem 加载为 Data
                    // 我们使用 loadTransferable 来获取 Data 类型
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        // 将 Data 转换为 UIImage
                        if let uiImage = UIImage(data: data) {
                            isLoading = true
                            canSave = false
                            // 将 UIImage 转换为 SwiftUI 的 Image 并更新状态
                            selectedImage=uiImage
                            //Alpha 版本，通过传入UIImage添加人脸
                            viewModel.addFaceByUIImage(faceUIImage: uiImage)
                        }
                    }
                }
            }
            .onChange(of: viewModel.canAddFace) { newValue in
                selectedImage=newValue
                isLoading = false
                canSave = true
            }
        
    }
}

