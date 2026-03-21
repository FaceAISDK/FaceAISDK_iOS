import SwiftUI
import PhotosUI
import FaceAISDK_Core

// 定义单侧人脸的数据模型
struct FaceSlot {
    var originalImage: UIImage?
    var croppedImage: UIImage?
    var feature: String?
    var isLoading: Bool = false
}

//其实就是为演示一个API viewModel.evaluateSimilarity(f1: f1, f2: f2)
public struct VerifyTwoFaceSimiView: View {
    // 恢复 dismiss 以支持自定义导航栏返回
    @Environment(\.dismiss) private var dismiss
    
    @State private var leftSlot = FaceSlot()
    @State private var rightSlot = FaceSlot()
    
    @StateObject private var viewModel = VerifyTwoFaceSimiModel()
    @State private var similarityResult: String = ""
    @State private var activePicker: PickerType?
    
    // CustomToastView 相关状态
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastStyle: ToastStyle = .success
    
    enum PickerType: Identifiable {
        case left, right
        var id: Int { hashValue }
    }
    
    // 干净的初始化方法
    public init() {}

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - 1. 自定义顶部导航栏 (对齐 VerifyFaceView)
                HStack {
                    Button(action: {
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
                    Text("Verify Two Face Similarity")
                        .font(.headline)
                    Spacer()
                    // 右侧占位以保持标题居中
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 30) {
                        HStack(spacing: 20) {
                            faceBox(slot: leftSlot) { activePicker = .left }
                            faceBox(slot: rightSlot) { activePicker = .right }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // MARK: - 3. 结果显示
                        if !similarityResult.isEmpty {
                            VStack(spacing: 8) {
                                Text(similarityResult)
                                    .font(.system(size: 32, weight: .heavy))
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }

                        // MARK: - 4. 操作按钮
                        Button(action: runComparison) {
                            Text("Verify Two Face Similarity")
                                .font(.headline).foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 50)
                                .background(canCompare ? Color.blue : Color.gray)
                                .cornerRadius(12)
                        }
                        .disabled(!canCompare)
                        .padding(.horizontal, 40)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.ignoresSafeArea())
            // 隐藏系统导航栏
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            
            // MARK: - 5. CustomToastView 提示层 (对齐 VerifyFaceView)
            if showToast {
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
        }
        .sheet(item: $activePicker) { type in
            ImagePicker(selectedImage: .constant(nil)) { uiImage in
                handleImageSelected(uiImage, for: type)
            }
        }
        // 监听 Model 提示状态改变，弹出 Toast
        .onChange(of: viewModel.sdkInterfaceTips.code) { code in
            if code != 0 {
                let msg = NSLocalizedString("Face_Tips_Code_\(code)", comment: "")
                toastMessage = msg
                
                // 简单约定：如果检测到人脸（Code为确认录入等）视为 success，否则视为 failure
                // 注意：如果你的 FaceTipsCode 里没有定义 CONFIRM_ADD_FACE，请替换为你业务中代表成功的 Code
                toastStyle = (code == FaceTipsCode.CONFIRM_ADD_FACE) ? .success : .failure
                
                withAnimation {
                    showToast = true
                }
                
                // 2秒后自动隐藏 Toast
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showToast = false
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showToast)
    }

    private var canCompare: Bool {
        leftSlot.feature != nil && rightSlot.feature != nil
    }

    // 处理图片选择后的初始化与直接回调闭包
    private func handleImageSelected(_ image: UIImage, for type: PickerType) {
        // 选择图片后，先重置当前 Slot 的状态
        if type == .left {
            leftSlot.originalImage = image
            leftSlot.isLoading = true
            leftSlot.feature = nil
        } else {
            rightSlot.originalImage = image
            rightSlot.isLoading = true
            rightSlot.feature = nil
        }
        
        // 调用 Model 闭包处理人脸
        viewModel.processImage(image) { croppedImage, feature in
            // 无论成功还是失败，都会走到这里，从而安全地关闭 Loading 状态
            if type == .left {
                leftSlot.isLoading = false
                leftSlot.croppedImage = croppedImage
                leftSlot.feature = feature
            } else {
                rightSlot.isLoading = false
                rightSlot.croppedImage = croppedImage
                rightSlot.feature = feature
            }
            similarityResult = "" // 有新图片时，清空之前的结果
        }
    }

    private func runComparison() {
        guard let f1 = leftSlot.feature, let f2 = rightSlot.feature else { return }
        let score = viewModel.evaluateSimilarity(f1: f1, f2: f2)
        
        
        
//        let score2 = viewModel.evaluateSimilarity(f1: "acIrOpGwtbvCUY25fld_u2ZSWzsyhN-95TLKvArPZT2He0097o3mPWh3zDvkZ7i7zoH5uzEoFj2-ZUE7N0A1PgBamjvEp685LNUku3oVBrzNKwo-UiBwvUNOsj1IWdw6fa4sPHuTWLw-wIE7S1u0PTutzz1gOgu-5_umOqmffD2XgbU9-58wPKPGmz2SS5-9x-r8PVJehzt0Ngw8Uz2JvvCALrwBbRm7BnxIO1yNnbsLaA88D2M6PWYewb1TQNI9VfPROxRLqTplEsm96783uZkWoj3iFYs71yC4PDBjHzyqZb69pYvlOjFOkLuRkQk8amiUPCVonb3ydD69tOGhPft9CDyIxty95CaWusKQtzzn-eC7SfHQu8tMCzvC2SM-AIwLvmpSgDuKpK-98p-ru-1m0rvcXOW6oB2uPS_GxD2u1lM5m4yRPb48Qrz6U4A-OLosPHUHTbu6xIA7CnTGPew2iD3hMMy9hB01Pc60wLrHfzM8OSOgO9aXIL2Rs7a9mkeAPTMlHD4urc-7wswjPOOHtrpVPxQ7HCQ2POQUILss0lC7WdHsugV_Oz16jMe6F97RuwlfF7tfwpc9yF82OxU8jDq4Fse82uAIvN5qGz6B7iW8DmMku3R60j3gCRg-iuOovt9ak7ymKUq-9WGsOmsMCzvLvG87ofxUu2cEMLwLSEK8FwR_virOpznnoWq7pYVauxgZB75Actc9jCgcu1A0wrz0IrK9lVTWOskSsLs-VTw8hdY9O33lD7yQFbg9wuI4vU74ur3owm28g87PuuVoTby-BII7H9_buielcL3iS9U8KowmPPV7d7pA2UQ87C1vvO3uobv4_wA9ty3AudbIFjw2hMW7dEEdPEeAAzpcgWi645bSO_RQ3ruEizC-jiVZO3crjjukzQq-Hp9pPC6UGrmz0JG9KHGvO6uZtzqi6ca91NUJOlnhAzcipus7-CkevXrTzb3vGLK7U52fO0CUFT1sFUc-paYIvhgnoL1RYEM8dWvkvYqBmjv5ako5", f2: "PA8IutN8WDhm-2u7k3GuOzlh5Tscyqq9brr-u288kT28YQw9QiMTPMC3zLqD2Hi6gSsMvIlIOzxilBM7pCjwPT0yLzubnqC3JGVrupYBGjvzvD4-8Oj7vK8R3D3g6P06YwHRPCOr4brs3VS7QREDPq9C8ju7GVG9iGSYOVfyKD7YIkU9PxXBOxTvYj3fiDu9q19JPg6ETTzzRJc7gclgvigDRrtsFHG6iVjDO3TMvruwMJ07EQwLOzTQCL5OqSM-fQieOzJ6Cz0LhhQ7NTEluhzIrL2SRRY7pv35vAZQ9zs5Cr08aTTqOmFyITwaSMQ7uY0zu35iGr3PeaK9GKW1O1rjSzviJES-LVmyuoAqBDkzIiu7quPqu_6eKjvXaws-eZQeviTOuLr7xCq-DIXju_la67vZExk5bvtfPqxwij1CgD07vH3GuqLnObySh3c-vGVTvTWb_7k-TuQ7rZtJPvYoqz1yfYS9vCkSPR8pvDgkTUQ8KaNWu86ojr20lZK98gvaPWHhnT10Q-67MU4cPJi5q7nfbsE7xJdZPAy8Qrun_M86qtKaumd3BT2VtVq7UeCYu8bxsbtqIwk-qQgkO0ErGTojuGa8Q9_Nux6s1z0JohO8q-jXOhaJ2D3a07k93QSDvi5kE73ZInS-_PncOkBjWbo3FRU7_-oxOofYfLv8Nz87xRDuvTp6CDuS-oE5CDW7OiVayr3I9_Q9EzUku_XFuLykl9O9jaREu76jPruq0_E7wdvROILWCbwnU0g-3LdzvQCsIDydr5G8EWFpu8avN7x22rw6noTDOeDSRj31jU89SJBHO8B1s7pE1ew7pJCiu90OAbxg11Y--T0OO29-8jvfuka7vGSKO9Sm1LnMR6w6ZqUMPDGltbvMqPK9XeQaOyUzmzv-cE2-f6ldPUqm1jijpa69l_dNO-iewDpJOEG9D-0LvCHWM7tygiA8exZwvK5u6r3fdMW6dxjCOxkKLzzNocg9eB7pvZO9vrxI2LW73ziTvcNV0bvGNw-7")
        similarityResult = String(format: "%.2f%%", score * 100)

        
        
    }

    // 复用 UI 组件 (已去除 title 传参)
    @ViewBuilder
    private func faceBox(slot: FaceSlot, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                if let displayImg = slot.croppedImage ?? slot.originalImage {
                    Image(uiImage: displayImg).resizable().scaledToFill()
                } else {
                    VStack {
                        Image(systemName: "person.crop.rectangle.badge.plus")
                            .font(.largeTitle)
                    }.foregroundColor(.gray)
                }
                
                if slot.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                        ProgressView().tint(.white)
                    }
                }
            }
            .frame(width: 150, height: 150)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            .clipped()
        }.buttonStyle(PlainButtonStyle())
    }
}
