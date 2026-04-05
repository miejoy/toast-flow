# ToastFlow

ToastFlow 是基于 [WindowFlow](https://github.com/miejoy/window-flow) 的轻量级 SwiftUI Toast 弹窗组件，通过独立 Window 实现状态驱动的弹窗管理。支持全局调用、多场景隔离、自定义样式和自动消失动画。

[![Swift](https://github.com/miejoy/toast-flow/actions/workflows/test.yml/badge.svg)](https://github.com/miejoy/toast-flow/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/miejoy/toast-flow/branch/main/graph/badge.svg)](https://codecov.io/gh/miejoy/toast-flow)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/swift-6.2-brightgreen.svg)](https://swift.org)

## 依赖

- iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+
- Xcode 26.0+
- Swift 6.2+

## 简介

ToastFlow 基于独立 Window 展示 Toast 弹窗，无需挂载到任何视图上，框架会自动创建和管理 Window 生命周期。该模块包含以下核心功能：

- **全局调用**：通过 `Toast.show(message:)` 一行代码即可显示弹窗，支持任意线程调用
- **多场景支持**：基于 `SceneId` 隔离，支持多窗口场景独立显示
- **自动管理**：弹窗自动显示、定时消失，无需手动管理生命周期
- **自定义样式**：通过 `CustomToastView` 协议注册自定义 Toast 视图
- **可配置时长**：通过 `AutoConfig` 配置显示时长和消失动画时长

## 安装

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

在项目中的 Package.swift 文件添加如下依赖：

```swift
dependencies: [
    .package(url: "https://github.com/miejoy/toast-flow.git", branch: "main"),
]
```

## 使用

### 基础用法

通过 `Toast.show(message:)` 全局显示 Toast 弹窗，可在任意线程调用：

```swift
import ToastFlow

// 显示一条 Toast 消息（默认主场景）
Toast.show(message: "操作成功")

// 指定场景显示
Toast.show(message: "操作成功", on: mySceneId)
```

### 自定义 Toast 视图

实现 `CustomToastView` 协议，创建自定义 Toast 样式，并通过 `Store<ToastState>.registerToastView(_:)` 注册：

```swift
import SwiftUI
import ToastFlow

struct MyToastView: CustomToastView {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(message)
                .font(.body)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}

// 注册自定义视图（在 App 启动时）
Store<ToastState>.shared(on: .main).registerToastView(MyToastView(""))
```

### 通过环境变量使用

在 SwiftUI 视图中通过 `@Environment` 获取当前场景的 Toast 管理器：

```swift
import SwiftUI
import ToastFlow

struct ContentView: View {
    @Environment(\.toastManager) var toastManager

    var body: some View {
        Button("显示提示") {
            toastManager.show(message: "来自环境变量的 Toast")
        }
    }
}
```

### 配置显示时长

通过 `AutoConfig` 在 Bundle 配置文件中调整 Toast 时长：

```swift
// 在 Bundle 的配置文件中设置（单位：秒）
// ToastSecondOnDisplay: 3.0      （默认 2.5 秒）
// ToastSecondOnDisappearing: 1.0  （默认 0.5 秒）
```

也可通过 `ConfigKey` 在代码中读取：

```swift
import ToastFlow

let displayTime = Config.value(for: .toastSecondOnDisplay, 2.5)
let fadeTime = Config.value(for: .toastSecondOnDisappearing, 0.5)
```

## 作者

黄磊, raymond0huang@gmail.com

## License

ToastFlow is available under the MIT license. See the LICENSE file for more info.
