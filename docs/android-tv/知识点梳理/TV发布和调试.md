### Android TV 发布和调试知识点清单

###### 内容概述

本文件记录 Android TV 发布和调试相关知识，包括 Manifest、启动入口、ADB 遥控器按键模拟、日志、模拟器、真机调试、发布检查、兼容性和上架注意点。

###### 使用场景

- TV 项目新建、上线前检查、真机调试、市场发布、兼容性回归时使用。
- 排查“电视桌面看不到应用”“遥控器按键和模拟器不一致”“某些盒子播放异常”等问题时使用。
- 发布规则可能会变化，涉及应用市场和 Google Play 的要求要以目标市场最新官方文档为准。

一级栏目导航：

- [Manifest 和启动入口](#manifest-和启动入口)
- [资源和图标](#资源和图标)
- [ADB 调试](#adb-调试)
- [按键模拟](#按键模拟)
- [日志和性能](#日志和性能)
- [模拟器和真机](#模拟器和真机)
- [发布检查](#发布检查)
- [兼容性记录](#兼容性记录)
- [面试可能怎么问](#面试可能怎么问)

<a id="manifest-和启动入口"></a>
###### Manifest 和启动入口

- TV 应用需要能被 TV Launcher 识别和展示。
- 常见配置包括 TV 启动 Activity、Leanback launcher category、banner 图、横屏方向、触摸屏非必需等。
- 如果应用只面向 TV，要避免声明必须依赖触摸屏特性。
- 如果应用同时支持手机和 TV，可以拆不同 flavor、不同入口 Activity 或不同导航逻辑。
- Manifest 配置要结合目标市场要求核对，不同发布渠道可能有额外审核规则。

<a id="资源和图标"></a>
###### 资源和图标

- TV 应用通常需要适合大屏显示的 banner、图标、启动图和截图。
- banner 要在电视桌面可识别，避免细字、低对比、过多信息。
- 图片资源要按 TV 分辨率准备，避免模糊或内存浪费。
- 横屏截图、功能截图、视频类应用内容展示要符合目标市场规范。
- 发布资产属于容易变化的规则，最终以应用市场最新要求为准。

<a id="adb-调试"></a>
###### ADB 调试

- TV 真机可以通过 USB 或网络 ADB 调试，网络调试常用于电视和盒子。
- 常用命令：

```powershell
adb devices
adb connect <device-ip>:5555
adb install -r app-debug.apk
adb shell am start -n package/name.ActivityName
adb logcat
```

- 网络 ADB 要确认电脑和 TV 在同一网络，设备开启开发者选项和调试权限。
- 真机调试时要记录设备品牌、型号、系统版本、分辨率、输入设备和网络环境。

<a id="按键模拟"></a>
###### 按键模拟

- ADB 可以模拟遥控器按键，用于复现焦点路径和自动化冒烟。

```powershell
adb shell input keyevent KEYCODE_DPAD_UP
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_LEFT
adb shell input keyevent KEYCODE_DPAD_RIGHT
adb shell input keyevent KEYCODE_DPAD_CENTER
adb shell input keyevent KEYCODE_BACK
adb shell input keyevent KEYCODE_MEDIA_PLAY_PAUSE
```

- 也可以使用数字 keycode，但可读性不如常量名。
- ADB 按键和真实遥控器不一定完全一致。真实遥控器可能有厂商自定义键、长按、组合键、重复事件等差异。
- 连续按键测试很重要，例如快速右移 20 次、快速上下切换栏目、打开弹窗后返回。

<a id="日志和性能"></a>
###### 日志和性能

- 焦点问题建议打印当前焦点、按键方向、页面状态、目标 item id、adapter position。
- 播放问题建议记录播放地址类型、清晰度、播放器状态、错误码、网络状态、设备信息。
- 列表性能问题建议结合 Logcat、Profiler、帧率、GC、图片加载日志定位。
- TV 端低端设备较多，内存、CPU、GPU 和解码能力都要关注。
- 可用日志示例：

```java
View focused = activity.getWindow().getDecorView().findFocus();
Log.d("TvFocus", "focused=" + focused);
```

- 不要只靠肉眼判断卡顿，至少要结合帧耗时、主线程耗时、图片加载和 GC 日志。

<a id="模拟器和真机"></a>
###### 模拟器和真机

- 模拟器适合验证基本流程、布局和部分遥控器操作。
- 真机适合验证焦点体验、性能、播放兼容、遥控器差异、厂商系统行为。
- 同一 APK 在不同电视、盒子、投影上可能表现不同，尤其是播放、焦点和系统返回。
- 项目如果面向具体厂商设备，要建立设备矩阵和问题记录。
- 低端设备回归不能省略。高性能开发机跑得流畅，不代表用户设备也能流畅。

<a id="发布检查"></a>
###### 发布检查

- 发布前建议检查：

| 检查项 | 说明 |
|---|---|
| 启动入口 | TV 桌面能看到应用并正常启动 |
| 遥控器可达 | 所有主要功能不用触摸也能操作 |
| 默认焦点 | 每个页面进入后都有合理焦点 |
| 返回路径 | 返回键行为清晰，不误退出 |
| 播放能力 | 点播、直播、暂停、恢复、错误重试正常 |
| 弱网 | 断网、慢网、网络恢复有处理 |
| 性能 | 首页、列表、播放页无明显卡顿 |
| 资源 | banner、图标、截图符合目标市场要求 |
| 兼容 | 目标设备矩阵通过基本回归 |

- Google Play 或其他应用市场的 TV 质量规范、截图、banner、权限、可操作性要求可能更新，发布前要按最新要求核对。

<a id="兼容性记录"></a>
###### 兼容性记录

- 建议为 TV 项目维护兼容性表：

| 维度 | 示例 |
|---|---|
| 设备 | 品牌、型号、盒子/电视/投影 |
| 系统 | Android 版本、厂商 ROM |
| 输入 | 遥控器型号、按键差异 |
| 屏幕 | 分辨率、缩放、裁切 |
| 播放 | 编码格式、清晰度、硬解能力 |
| 网络 | Wi-Fi、有线、弱网 |
| 问题 | 复现路径、日志、解决方案 |

- 兼容问题要沉淀到问题集或 troubleshooting 模块，避免只停留在聊天记录和临时文档里。

<a id="面试可能怎么问"></a>
###### 面试可能怎么问

- [TV 应用 Manifest 和发布要注意什么](../面试/TV开发基础面试题.md#tv-应用-manifest-和发布要注意什么)
