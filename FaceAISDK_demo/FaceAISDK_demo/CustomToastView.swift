

import Foundation
import SwiftUI

//
//  CustomToastView.swift
//  SDKDebug
//
//  Created by anylife on 2025/12/2.


// 定义 Toast 样式
enum ToastStyle {
    case success
    case failure
    var backgroundColor: Color {
        switch self {
<<<<<<< HEAD:FaceAISDK_iOS/CustomToastView.swift
        case .success: return Color.brown
=======
        case .success: return Color.faceMain
>>>>>>> b1a41a07db13c89923cf03fcf46fe08735d9eb58:FaceAISDK_demo/FaceAISDK_demo/CustomToastView.swift
        case .failure: return Color.yellow
        }
    }
}
struct CustomToastView: View {
    let message: String
    let style: ToastStyle
    // ... CustomToastView 的实现如上所示 ...
    var body: some View {
        VStack {
            HStack {
                Text(message)
                    .foregroundColor(.white)
                    .font(.system(size: 19).bold())
                    .padding(.vertical, 14)
                    .padding(.horizontal, 22)
            }
            .background(style.backgroundColor)
            .cornerRadius(25)
            .shadow(radius: 5)
        }
    }
}
