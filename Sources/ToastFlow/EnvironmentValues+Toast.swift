//
//  File.swift
//  
//
//  Created by 黄磊 on 2023/9/18.
//

import SwiftUI
import DataFlow
import ViewFlow

extension EnvironmentValues {
    /// Toast 管理器，用于在 SwiftUI 视图中获取当前场景的 Toast 存储器
    ///
    /// 默认返回当前场景关联的 `Store<ToastState>`，也可通过 `.environment(\.toastManager, ...)` 注入自定义实例。
    public var toastManager: Store<ToastState> {
        get { self[ToastManagerEnvironmentKey.self] ?? Store<ToastState>.shared(on: sceneId) }
        set { self[ToastManagerEnvironmentKey.self] = newValue }
    }
}


/// Toast 管理器对应的环境值 Key
struct ToastManagerEnvironmentKey: EnvironmentKey {
    static let defaultValue: Store<ToastState>? = nil
}
