import SwiftUI
import FaceAISDK_Core
import ToastUI



enum FaceAINaviDestination: Hashable {
    case AddFaceFromAlbum(String)
    case AddFacePageView(String)
    case VerifyFacePageView(String)
    case LivenessView(String)
}

//#Preview {
//    FaceAINaviView()
//}


