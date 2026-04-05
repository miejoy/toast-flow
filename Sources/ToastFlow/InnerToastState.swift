//
//  File.swift
//  
//
//  Created by 黄磊 on 2020-07-09.
//

import Foundation
import DataFlow
import ViewFlow
import SwiftUI

/// Toast 内部操作事件
public enum InnerToastAction : Action {
    /// 显示指定消息
    case displayMessage(String)
    /// 隐藏当前 Toast
    case needHide
}

/// Toast 内部状态，管理消息文本和显示状态
struct InnerToastState : FullSceneWithIdSharableState {

    typealias BindAction = InnerToastAction
    
    /// 显示状态枚举
    enum DisplayState {
        /// 正在显示
        case onDisplay
        /// 已消失
        case disappeared
    }
    
    var sceneId: SceneId
    var message : String = ""
    var displayState : DisplayState = .disappeared
    
    init(sceneId: SceneId) {
        self.sceneId = sceneId
    }
    
    @MainActor
    func makeView(_ message: String) -> AnyView? {
        Store<ToastState>.shared(on: sceneId).makeView(message)
    }
    
    static func loadReducers(on store: Store<InnerToastState>) {
        store.register { (state, action: InnerToastAction) in
            switch action {
            case .displayMessage(let message):
                state.message = message
                state.displayState = .onDisplay
            case .needHide:
                state.displayState = .disappeared
            }
        }
    }    
}
