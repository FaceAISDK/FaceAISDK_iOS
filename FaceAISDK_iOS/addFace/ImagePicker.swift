import SwiftUI
import PhotosUI
import UIKit

// Extension for UIImage providing utility functions for image processing
extension UIImage {
    
    // Scales the image to a specified size and removes complex metadata
    // 将图像缩放到指定尺寸，并剔除复杂的元数据
    public func scaledImage(with size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        

        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        
        // Core step: "Flatten" the image through encode/decode to strip metadata (like orientation flags)
        // 核心步骤：通过编码/解码将图像“拍扁”，剔除复杂元数据（如方向标识等）
        return UIGraphicsGetImageFromCurrentImageContext()?.data.flatMap(UIImage.init)
    }

    // Helper property to extract image data
    // 获取图像数据的辅助属性
    private var data: Data? {
        // Using a compression quality of 0.8 is the golden standard to balance memory usage and recognition accuracy
        // 使用 0.8 的压缩质量是平衡内存与识别精度的黄金标准
        return self.pngData() ?? self.jpegData(compressionQuality: 0.8)
    }
}

// A SwiftUI wrapper for PHPickerViewController to pick images from the photo library
// PHPickerViewController 的 SwiftUI 封装，用于从照片库中选择图像
struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    // Optional callback triggered when an image is successfully picked and processed
    // 当成功选择并处理图像时触发的可选回调
    var onImagePicked: ((UIImage) -> Void)?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        
        // Only allow image selection
        // 仅允许选择图像
        config.filter = .images
        
        // Limit selection to a single image
        // 限制最多选择 1 张图像
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates needed for this view controller lifecycle
        // 此视图控制器生命周期不需要更新
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Coordinator class to act as the PHPickerViewControllerDelegate
    // 作为 PHPickerViewControllerDelegate 的协调器类
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

            parent.dismiss()
            
            // Ensure the selected item exists and can be loaded as a UIImage
            // 确保选中的项目存在且可以作为 UIImage 加载
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            // Using [weak self] to avoid strong reference cycles during the asynchronous load
            // 使用 [weak self] 避免在异步加载过程中出现强引用循环
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self, let uiImage = image as? UIImage else { return }
                
                // Pre-processing step: Standardize the image here to avoid errors in subsequent external detectors (e.g., FaceDetector)
                // 预处理步骤：在这里进行标准化，避免后续传入外部检测器（如 FaceDetector）时报错
                
                // Scale to a base width of 1080 to maintain facial feature extraction accuracy while avoiding memory overflow.
                // Height is calculated dynamically to preserve the aspect ratio.
                // 建议缩放至 1080 基础宽度，既能保证人脸特征提取的准确性，又不会导致内存溢出。
                // 高度根据纵横比动态计算。
                let targetSize = CGSize(
                    width: 1080,
                    height: 1080 * (uiImage.size.height / uiImage.size.width)
                )
                
                if let processedImage = uiImage.scaledImage(with: targetSize) {
                    DispatchQueue.main.async {
                        self.parent.selectedImage = processedImage
                        self.parent.onImagePicked?(processedImage)
                    }
                }
            }
        }
    }
}
