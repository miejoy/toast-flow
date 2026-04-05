//
//  ToastManager.swift
//
//
//  Created by 黄磊 on 2023/9/18.
//

import DataFlow
import WindowFlow
import SwiftUI
import Logger

extension Store where State == ToastState {
    /// 显示 Toast 弹窗，必须在主线程调用
    ///
    /// 连续多次调用时，前一条消息会被取消，只显示最后一条。
    ///
    /// - Parameters:
    ///   - message: 要显示的消息文本，空字符串不会触发显示
    @MainActor
    public func show(message: String) {
        if message.isEmpty {
            return
        }

        // 发送显示事件
        LogInfo("Toast show: \(message)")
        Store<InnerToastState>.shared(on: self.sceneId).send(action: .displayMessage(message))
        // 调用 window，自动创建和关联
        self.showWindowIfNeed()

        // 使用 showCount 确保只处理最后一个
        var storage = self[.toastStorage] ?? ToastStorage()
        storage.showCount += 1
        self[.toastStorage] = storage
        let aShowCount = storage.showCount

        // 使用 Task 在主线程执行延迟消失逻辑
        Task { @MainActor [self] in
            try? await Task.sleep(for: .seconds(ToastState.secondOnDisplay))
            guard (self[.toastStorage]?.showCount ?? 0) == aShowCount else { return }
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                withAnimation(Animation.linear(duration: ToastState.secondOnDisappearing)) {
                    Store<InnerToastState>.shared.send(action: .needHide)
                } completion: { [self] in
                    guard (self[.toastStorage]?.showCount ?? 0) == aShowCount else {
                        LogDebug("Toast hide cancelled: new message arrived")
                        return
                    }
                    self.hideWindowIfNeed()
                }
            } else {
                withAnimation(Animation.linear(duration: ToastState.secondOnDisappearing)) {
                    Store<InnerToastState>.shared.send(action: .needHide)
                }
                try? await Task.sleep(for: .seconds(ToastState.secondOnDisappearing))
                guard (self[.toastStorage]?.showCount ?? 0) == aShowCount else {
                    LogDebug("Toast hide cancelled: new message arrived")
                    return
                }
                self.hideWindowIfNeed()
            }
        }
    }

    /// 注册自定义 Toast 视图，用于替换默认样式
    ///
    /// 调用后，所有后续显示的 Toast 将使用指定的自定义视图类型渲染。
    ///
    /// - Parameters:
    ///   - view: 遵循 `CustomToastView` 协议的自定义视图实例，仅用于推断泛型类型
    @MainActor
    public func registerToastView<T: CustomToastView>(_ view: T) {
        var storage = self[.toastStorage] ?? ToastStorage()
        storage.customToastViewMaker = { message in AnyView(T.init(message)) }
        self[.toastStorage] = storage
    }

    @MainActor
    func makeView(_ message: String) -> AnyView? {
        self[.toastStorage]?.customToastViewMaker?(message)
    }
}
