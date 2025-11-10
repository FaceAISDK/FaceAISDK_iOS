import SwiftUI
import AVFoundation
import FaceAISDK_Core


// 使用 @MainActor 确保在主线程访问
@MainActor
var FaceAICameraSize: CGFloat {
    3 * min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 4
}

/**
 *  人脸录入，摄像头采集画面需要真机调试
 *  UI 样式仅供参考，根据你的业务可自行调整
 *
 */
public struct AddFaceByCamera: View {
    //录入保存的FaceID 值。一般是你的业务体系中个人的唯一编码，比如账号 身份证
    let faceID: String
    let onDismiss: (String?) -> Void
        
    @StateObject private var viewModel: AddFaceByCameraModel = AddFaceByCameraModel()
    

    //根据提示状态码多语言展示文本
    //添加人脸状态码参考 AddFaceTipsCode
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "Add Face Tips Code=\(code)"
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
    
    
    public var body: some View {
        VStack(spacing: 22){
            Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                .font(.system(size: 20).bold())
                .padding(.horizontal,20)
                .padding(.vertical,8)
                .foregroundColor(.white)
                .background(Color.faceMain)
                .cornerRadius(20)
            
            FaceAICameraView(session: viewModel.captureSession, cameraSize: FaceAICameraSize)
                .frame(
                    width: FaceAICameraSize,
                    height:FaceAICameraSize
                )
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(Circle())
                .background(Color.white)
            
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) 
        .background(Color.white.ignoresSafeArea())
        .overlay {
            if viewModel.readyConfirmFace {
                ConfirmAddFaceDialog(
                    viewModel: viewModel,
                    onConfirm: {
                        print("confirmSaveFaceAir")

                        let facePath = viewModel.confirmSaveFaceAir(fileName: faceID)
                        onDismiss(facePath)
                        print("onDismiss")

                    }
                )
            }
        }
        .animation(.easeInOut, value: true)
        .onAppear {
            viewModel.initAddFace()
        }
        .onChange(of: viewModel.sdkInterfaceTips.code) { newValue in
            print("⚠️ 提示状态： \(viewModel.sdkInterfaceTips.message)")
        }
        .onDisappear {
            viewModel.stopAddFace()
        }

    }
    

    //确认添加人脸对话框
    struct ConfirmAddFaceDialog: View {
        let viewModel: AddFaceByCameraModel
        let onConfirm: () -> Void
        
        var body: some View {
            VStack(alignment: .center) {
                Text("Confirm Add Face Title")
                    .font(.system(size: 19).bold())
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .foregroundColor(.faceMain)
                    .padding()
                
                Image(uiImage: viewModel.canAddFace)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .cornerRadius(8)
                
                Text("Confirm Add Face Tips")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.faceMain)
                    .padding(.vertical, 3)
                    .font(.system(size: 16).bold())
                
                HStack(spacing: 16) {
                    
                    Button(action: {
                        viewModel.reInit()
                    }) {
                        Text("Retry")
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .contentShape(Rectangle()) //使整个 HStack 区域可点击
                    }
                    
                    Button(action: {
                        onConfirm()  //触发关闭弹窗和页面的操作
                    }) {
                        Text("Confirm")
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .contentShape(Rectangle()) // 使整个 HStack 区域可点击
                    }
                    

                }.padding()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: 8*FaceAICameraSize/7, minHeight: 250)
            .background(Color.white)
            .cornerRadius(9)
            .shadow(radius: 9)
        }
    }
    
}



/**
 * IDE 编辑预览
 */
//#Preview {
//    AddFaceView(faceID: <#String#>, onDismiss: <#(String) -> Void#>)
//}
