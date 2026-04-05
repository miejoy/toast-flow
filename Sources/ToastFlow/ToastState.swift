//
//  File.swift
//  
//
//  Created by 黄磊 on 2023/9/17.
//

import DataFlow
import ViewFlow
import WindowFlow
import AutoConfig
import SwiftUI

extension ConfigKey where Value == Double {
    /// Toast 显示时长配置键，默认值为 2.5 秒
    public static let toastSecondOnDisplay = ConfigKey<Double>("ToastSecondOnDisplay")
    /// Toast 消失动画时长配置键，默认值为 0.5 秒
    public static let toastSecondOnDisappearing = ConfigKey<Double>("ToastSecondOnDisappearing")
}

/// Toast 弹窗的状态，负责管理 Toast 窗口的创建和配置
///
/// 遵循 `WindowOperableState` 协议，可自动管理浮层窗口的生命周期。
/// 通过 `Store<ToastState>.registerToastView(_:)` 可注册自定义样式。
public struct ToastState: WindowOperableState {
    /// Toast 显示时长（秒），可通过 `ConfigKey.toastSecondOnDisplay` 配置
    static let secondOnDisplay = TimeInterval(Config.value(for: .toastSecondOnDisplay, 2.5))
    /// Toast 消失动画时长（秒），可通过 `ConfigKey.toastSecondOnDisappearing` 配置
    static let secondOnDisappearing = TimeInterval(Config.value(for: .toastSecondOnDisappearing, 0.5))

    /// 关联的场景 ID
    public var sceneId: SceneId

    /// 初始化 ToastState
    ///
    /// - Parameters:
    ///   - sceneId: 关联的场景 ID
    public init(sceneId: SceneId) {
        self.sceneId = sceneId
    }

    /// Toast 窗口的唯一标识，使用 `ToastView` 类型作为标识
    public var windowId: ObjectIdentifier {
        ObjectIdentifier(ToastView.self)
    }

    /// Toast 窗口层级，位于状态栏之上
    public var windowLevel: AppWindowLevel {
        .statusBar + 1
    }

    /// 创建并返回 Toast 视图
    ///
    /// - Returns: 包装为 `AnyView` 的 Toast 视图
    @MainActor
    public func makeView() -> AnyView {
        AnyView(ToastView())
    }

    /// 配置 Toast 专属窗口的外观属性
    ///
    /// - Parameters:
    ///   - window: 需要配置的 AppWindow 实例
    @MainActor
    public func modify(_ window: AppWindow) {
        window.backgroundColor = .clear
        #if os(iOS) || os(tvOS)
        window.isUserInteractionEnabled = false
        window.isOpaque = false
        window.rootViewController?.view.backgroundColor = .clear
        #endif
    }
}

// MARK: - ToastStorage

/// Toast 在 Store 中的缓存数据
struct ToastStorage {
    /// 当前显示计数，用于判断是否为最新一条消息
    var showCount: Int = 0
    /// 自定义 Toast 视图构建器
    var customToastViewMaker: ((String) -> AnyView)? = nil
}

extension StateOnStoreStorageKey where Value == ToastStorage, State == ToastState {
    /// ToastStorage 对应的 Store 缓存 Key
    static let toastStorage: Self = .init("toastStorage")
}
