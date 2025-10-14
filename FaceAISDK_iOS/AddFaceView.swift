import SwiftUI
import AVFoundation
import FaceAISDK_Core

let cameraSize: CGFloat = 320 //  相机的尺寸


/**
 *  人脸录入，摄像头采集画面需要真机调试
 *  UI 样式仅供参考，根据你的业务可自行调整
 *
 */
public struct AddFaceView: View {
    //录入保存的FaceID 值。一般是你的业务体系中个人的唯一编码，比如账号 身份证
    let faceID: String
    let onDismiss: (String?) -> Void
        
    @StateObject private var viewModel: AddFaceModel = AddFaceModel()
    
    public var body: some View {
        VStack {
            Text(viewModel.addFaceTips)
                .font(.system(size: 22).bold())
                .padding(.bottom, 5)
                .foregroundColor(.black)
            
            Text(viewModel.addFaceTipsExtra)
                .font(.system(size: 19).bold())
                .padding(.bottom, 6)
                .frame(minHeight: 30)
                .foregroundColor(.black)
            
            FaceAICameraView(session: viewModel.captureSession, cameraSize: cameraSize)
                .frame(
                    width: min(UIScreen.main.bounds.width, cameraSize),
                    height: min(UIScreen.main.bounds.width, cameraSize)
                )
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(Circle())
                .background(Color.white)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 确保填满可用空间
        .background(Color.white.ignoresSafeArea()) // 扩展到安全区域
        .overlay {
            if viewModel.readyConfirmFace {
                PopupConfirmView(
                    viewModel: viewModel,
                    onConfirm: {
                        let facePath = viewModel.confirmSaveFaceAir(fileName: faceID)
                        onDismiss(facePath)
                    }
                )
            }
        }
        .animation(.easeInOut, value: true)
        .onAppear {
            viewModel.initAddFace()
        }
        .onDisappear {
            viewModel.stopAddFace()
        }
    }
    
    
    
    struct PopupConfirmView: View {
        let viewModel: AddFaceModel
        let onConfirm: () -> Void
        
        var body: some View {
            VStack(alignment: .center) {
                Text("人脸录入确认")
                    .font(.system(size: 19).bold())
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .foregroundColor(.faceMain)
                    .padding()
                
                Image(uiImage: viewModel.canAddFace)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .cornerRadius(8)
                
                Text("请录入无遮挡正脸清晰图")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.faceMain)
                    .padding(.vertical, 3)
                    .font(.system(size: 15).bold())
                
                HStack(spacing: 10) {
                    Button("重试") {
                        viewModel.reInit()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    
                    Button("确认") {
                        onConfirm()  //触发关闭弹窗和页面的操作
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }.padding()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: UIScreen.main.bounds.width-50, minHeight: 250)
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
