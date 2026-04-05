//
//  ToastView.swift
//  
//
//  Created by 黄磊 on 2020-07-09.
//

import SwiftUI
import DataFlow
import ViewFlow
import WindowFlow

/// 自定义 Toast 视图协议
///
/// 遵循此协议可替换默认 Toast 样式。通过 `Store<ToastState>.registerToastView(_:)` 注册。
public protocol CustomToastView: View {
    /// 使用消息文本初始化视图
    ///
    /// - Parameters:
    ///   - message: 要展示的消息文本
    init(_ message: String)
}

/// 默认的 Toast 视图，内部使用
struct ToastView: View {

    @SharedState private var toastState: InnerToastState

    var body: some View {
        if let view = toastState.makeView(toastState.message) {
            view
        } else {
            Text(toastState.message)
                .font(.footnote)
                .foregroundColor(.toastTextColor)
                .lineLimit(2)
                .padding(10)
                .background(Color.toastBgColor)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 5))
                .opacity(toastState.displayState == .onDisplay ? 1 : 0)
        }
    }
}

extension Color {
    /// 根据当前 UI 风格返回对应颜色：浅色模式返回 `light`，深色模式返回 `dark`
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        #if os(macOS)
        return Color(NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? NSColor(dark) : NSColor(light)
        })
        #else
        return Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
        #endif
    }

    static let toastTextColor: Color = adaptiveColor(light: .white, dark: .black)
    static let toastBgColor: Color = adaptiveColor(light: .black.opacity(0.6), dark: .white.opacity(0.6))
}
