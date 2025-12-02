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
        case .success: return Color.green
        case .failure: return Color.red
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
                    .font(.subheadline.bold())
                    .padding(.vertical, 12)
                    .padding(.horizontal, 22)
            }
            .background(style.backgroundColor)
            .cornerRadius(25)
            .shadow(radius: 5)
        }
    }
}
