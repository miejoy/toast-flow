//
//  Toast.swift
//  
//
//  Created by 黄磊 on 2023/9/20.
//

import Foundation
import DataFlow
import ViewFlow
import Logger

/// Toast 弹窗的命名空间，提供全局显示接口
public enum Toast {
    /// 显示指定消息的 Toast 弹窗，可在任意线程调用
    ///
    /// 内部会自动将操作调度到主线程执行。
    ///
    /// - Parameters:
    ///   - message: 要显示的消息文本，空字符串不会触发显示
    ///   - sceneId: 目标场景 ID，默认为 `.main`
    public static func show(message: String, on sceneId: SceneId = .main) {
        LogDebug("Toast.show: \(message)")
        DispatchQueue.executeOnMain {
            Store<ToastState>.shared(on: sceneId).show(message: message)
        }
    }
}
