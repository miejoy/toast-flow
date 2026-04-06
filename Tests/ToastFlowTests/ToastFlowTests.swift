import Testing
import SwiftUI
import DataFlow
import ViewFlow
@testable import ToastFlow

// MARK: - ToastState 配置

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

    @Test("windowId 与 ToastView 类型一致")
    func windowId() {
        let state = ToastState(sceneId: .main)
        #expect(state.windowId == ObjectIdentifier(ToastView.self))
    }

    @Test("windowLevel 高于 statusBar")
    func windowLevel() {
        let state = ToastState(sceneId: .main)
        #expect(state.windowLevel > .statusBar)
    }

    @Test("sceneId 与初始化参数一致")
    func sceneId() {
        let state = ToastState(sceneId: .main)
        #expect(state.sceneId == .main)
    }
}

// MARK: - InnerToastState 状态与 Action

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
        } else {
            Issue.record("应为 needHide 类型")
        }
    }

    @Test("DisplayState 包含 onDisplay 和 disappeared")
    func displayStateValues() {
        if case .onDisplay = InnerToastState.DisplayState.onDisplay {
        } else {
            Issue.record("应为 onDisplay 状态")
        }
        if case .disappeared = InnerToastState.DisplayState.disappeared {
        } else {
            Issue.record("应为 disappeared 状态")
        }
    }

    @Test("初始状态消息为空、displayState 为 disappeared")
    func initialState() {
        let state = InnerToastState(sceneId: .main)
        #expect(state.message == "")
        if case .disappeared = state.displayState {
        } else {
            Issue.record("初始 displayState 应为 disappeared")
        }
    }

    @Test("reducer 处理 displayMessage 后更新消息和状态")
    @MainActor
    func reducerDisplayMessage() {
        let store = Store<InnerToastState>.shared(on: .main)
        store.send(action: InnerToastAction.displayMessage("hello"))
        #expect(store.state.message == "hello")
        if case .onDisplay = store.state.displayState {
        } else {
            Issue.record("displayState 应为 onDisplay")
        }
    }

    @Test("reducer 处理 needHide 后 displayState 变为 disappeared")
    @MainActor
    func reducerNeedHide() {
        let store = Store<InnerToastState>.shared(on: .main)
        store.send(action: InnerToastAction.displayMessage("hello"))
        store.send(action: InnerToastAction.needHide)
        if case .disappeared = store.state.displayState {
        } else {
            Issue.record("displayState 应为 disappeared")
        }
    }
}

// MARK: - ToastStorage

@Suite("ToastStorage")
struct ToastStorageTests {

    @Test("默认 showCount 为 0")
    func defaultShowCount() {
        let storage = ToastStorage()
        #expect(storage.showCount == 0)
    }

    @Test("默认 customToastViewMaker 为 nil")
    func defaultCustomMaker() {
        let storage = ToastStorage()
        #expect(storage.customToastViewMaker == nil)
    }
}

// MARK: - ToastManager

@Suite("ToastManager", .serialized)
struct ToastManagerTests {

    @Test("空消息不更新 showCount")
    @MainActor
    func emptyMessageNotIncreaseShowCount() {
        let store = Store<ToastState>.shared(on: .main)
        let beforeCount = store[.toastStorage]?.showCount ?? 0
        store.show(message: "")
        let afterCount = store[.toastStorage]?.showCount ?? 0
        #expect(beforeCount == afterCount)
    }

    @Test("非空消息增加 showCount")
    @MainActor
    func nonEmptyMessageIncreasesShowCount() {
        let store = Store<ToastState>.shared(on: .main)
        let beforeCount = store[.toastStorage]?.showCount ?? 0
        store.show(message: "test")
        let afterCount = store[.toastStorage]?.showCount ?? 0
        #expect(afterCount == beforeCount + 1)
    }

    @Test("连续两次 show，showCount 累加")
    @MainActor
    func consecutiveShowsIncrementCount() {
        let store = Store<ToastState>.shared(on: .main)
        let beforeCount = store[.toastStorage]?.showCount ?? 0
        store.show(message: "first")
        store.show(message: "second")
        let afterCount = store[.toastStorage]?.showCount ?? 0
        #expect(afterCount == beforeCount + 2)
    }

    @Test("registerToastView 注册自定义视图后 customToastViewMaker 不为 nil")
    @MainActor
    func registerCustomToastView() {
        struct MyToast: CustomToastView {
            let message: String
            init(_ message: String) { self.message = message }
            var body: some View {
                Text(message)
            }
        }
        let store = Store<ToastState>.shared(on: .main)
        store.registerToastView(MyToast(""))
        #expect(store[.toastStorage]?.customToastViewMaker != nil)
    }
}

// MARK: - Toast 显示接口

@Suite("Toast 显示接口")
struct ToastShowTests {

    @Test("Toast.show 调用不崩溃")
    @MainActor
    func showDoesNotCrash() {
        Toast.show(message: "测试弹窗")
    }

    @Test("空消息不触发显示")
    @MainActor
    func emptyMessageDoesNotShow() {
        Toast.show(message: "")
    }
}
