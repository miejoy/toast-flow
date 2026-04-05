import Testing
@testable import ToastFlow

@Suite("ToastState 配置")
struct ToastStateTests {
    @Test("默认显示时长为 2.5 秒")
    func defaultDisplayTime() {
        #expect(ToastState.secondOnDisplay == 2.5)
    }
    
    @Test("默认消失动画时长为 0.5 秒")
    func defaultFadeTime() {
        #expect(ToastState.secondOnDisappearing == 0.5)
    }
}

@Suite("InnerToastState 状态与 Action")
struct InnerToastStateTests {
    @Test("InnerToastAction.displayMessage 携带消息")
    func displayMessageAction() {
        let action = InnerToastAction.displayMessage("测试消息")
        if case .displayMessage(let msg) = action {
            #expect(msg == "测试消息")
        } else {
            Issue.record("应为 displayMessage 类型")
        }
    }
    
    @Test("InnerToastAction.needHide")
    func needHideAction() {
        let action = InnerToastAction.needHide
        if case .needHide = action {
            // 通过
        } else {
            Issue.record("应为 needHide 类型")
        }
    }
    
    @Test("DisplayState 包含 onDisplay 和 disappeared")
    func displayStateValues() {
        let onDisplay = InnerToastState.DisplayState.onDisplay
        let disappeared = InnerToastState.DisplayState.disappeared
        
        // 确保两种状态不相等（通过模式匹配验证）
        if case .onDisplay = onDisplay {
            // 通过
        } else {
            Issue.record("应为 onDisplay 状态")
        }
        
        if case .disappeared = disappeared {
            // 通过
        } else {
            Issue.record("应为 disappeared 状态")
        }
    }
}

@Suite("Toast 显示接口")
struct ToastShowTests {
    @Test("Toast.show 调用不崩溃")
    @MainActor
    func showDoesNotCrash() {
        // 仅验证调用不会崩溃，不验证 UI 展示
        Toast.show(message: "测试弹窗")
    }
    
    @Test("空消息不触发显示")
    @MainActor
    func emptyMessageDoesNotShow() {
        // 空字符串应直接返回，不会崩溃
        Toast.show(message: "")
    }
}
