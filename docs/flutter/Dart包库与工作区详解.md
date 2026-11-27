### Dart 包、库与工作区详解

<!-- page-toc:start -->
**目录**

- [先分清 package、library、workspace](#concepts)
- [创建哪一种项目：console、package、Flutter 应用和插件](#create)
- [package 目录与对外入口](#layout)
- [library、import、export：需要手动声明库吗](#library)
- [part 与 part of：同一个库拆成多个文件](#part)
- [dependencies、dev_dependencies 与依赖来源](#dependencies)
- [一个完整工作区：共享包加命令行调用方](#workspace)
- [workspace 解决什么，不解决什么](#resolution)
- [接到 Flutter 项目时怎么用](#flutter)
- [本地开发与发布不是一回事](#publish)
- [常见问题与简答](#faq)
- [验证与资料范围](#verification)
<!-- page-toc:end -->


<a id="concepts"></a>
###### 先分清 package、library、workspace

本文回答三个问题：代码怎样拆文件并隐藏实现、怎样提供给其他项目使用、多个包怎样放在一个仓库共同开发。先会 [Dart 基础语法](./Dart基础详解.md)，再看这里；不需要先创建 Flutter 页面。

| 概念 | 管理什么 | 如何辨认 | 不代表什么 |
|---|---|---|---|
| package（包） | 名称、版本、依赖、SDK 约束等 | 包根目录有 pubspec.yaml | 不一定已发布，不一定第三方，不一定只有库代码 |
| library（库） | 导入、导出、命名空间与 `_` 私有边界 | 通常一个 Dart 文件是一个库；加上其 part 文件仍是一个库 | 一个 package 不等于一个 library |
| Pub workspace（工作区） | 多个 package 的共同依赖解析 | 根 pubspec 的 workspace + 成员的 resolution: workspace | 不会自动合并库或让所有成员互相依赖 |
| monorepo（单仓库多项目） | Git 中的组织方式 | 同一个仓库内多个项目/包 | 不自动等于已配置 Pub workspace |

Flutter 应用本身也是 package；一个工具包、业务包或命令行程序也都是 package。workspace 中的成员仍是 package。不能按“稳定三方库用 package、变化业务用 workspace”分类：它们是不同层级，业务 package 也可在 workspace 中开发。

版本：Pub workspace 从 **Dart 3.6** 起支持，成员包 SDK 约束下限需至少 3.6；本文用显式成员路径，不依赖较新版本的通配符或嵌套工作区功能。验证 SDK：Dart 3.14.0，日期：2026-11-27。资料：[官方工作区说明](https://dart.dev/tools/pub/workspaces)。

<a id="create"></a>
###### 创建哪一种项目：console、package、Flutter 应用和插件

以下命令用于分别新建不同项目，不要求全部执行：

```powershell
# 终端程序，有 main 入口，可以开发正式工具，不只是练习。
dart create -t console article_cli

# 可供其他 Dart 程序引用的共享包。
dart create -t package article_core

# Flutter 图形界面应用，默认入口 lib/main.dart。
flutter create article_app

# 使用 Flutter API 的共享包，例如公共 Widget。
flutter create --template=package article_ui

# 需要 Android/iOS 等平台实现的插件。
flutter create --template=plugin --platforms=android,ios article_platform
```

普通 library 不需要 main；调用方导入后调用它的类和函数。console 模板通常把入口放在 bin；Flutter 应用通常在 lib/main.dart。这里的 bin 是项目目录，不是 SDK 安装目录里的 bin。

纯 Dart 包尽量不依赖 Flutter，这样控制台、服务端和 Flutter 都可能复用；但是否能在 Web 使用仍取决于是否引入 dart:io 等平台相关 API。Flutter package 用于依赖 Flutter 的组件，plugin 通常还包含平台能力实现，不必为所有组件包创建插件。

<a id="layout"></a>
###### package 目录与对外入口

一个共享包可按下面组织：

```text
article_core/
├── pubspec.yaml
├── lib/
│   ├── article_core.dart       # 对外入口，集中 export
│   └── src/
│       └── article.dart        # 实现文件
├── example/                   # 使用示例
├── test/                      # 测试
├── README.md
├── CHANGELOG.md
└── LICENSE
```

lib/article_core.dart 可以只写：

```dart
export 'src/article.dart' show Article;
```

lib/src/article.dart：

```dart
class Article {
  final String title;
  const Article(this.title);
  String get label => _normalize(title);
}

String _normalize(String value) => value.trim();
```

调用方写：

```dart
import 'package:article_core/article_core.dart';

void main() {
  print(const Article('  Dart  ').label); // Dart
}
```

这里 `package:article_core/` 按 pubspec 的 name 解析，后面的 article_core.dart 相对于该包的 lib 目录，不要再写一层 lib。目录名可以与 name 不同，但建议一致以降低混淆。

`lib/src` 是内部实现的组织约定和分析规则关注点，**不是语言级访问权限**。别人直接导入 src 中的公开声明在技术上可能可行，但不应依赖这种不稳定内部 API。真正的库私有由 `_normalize` 的下划线实现；export 不会把这个私有名字变成公有。

资料：[创建共享包](https://dart.dev/tools/pub/create-packages)、[包布局](https://dart.dev/tools/pub/package-layout)。

<a id="library"></a>
###### library、import、export：需要手动声明库吗

每个 Dart 文件（及其 part）已经是库，**普通文件不必额外写 library 声明才能被 import**。`library;` 主要可承载库级文档与注解，不是把整个 package 合成一个库的开关。

| 指令 | 作用 | 关键边界 |
|---|---|---|
| import 'a.dart'; | 当前库使用 a 的公开 API | 不自动转发给导入当前库的人 |
| export 'a.dart'; | 把 a 的公开 API 转发给调用方 | 不自动让当前库的代码能使用 a 的名字，自己用时仍需 import |
| import ... as core; | 用前缀避免名称冲突 | 调用 core.Article(...) |
| show Article | 只引入/导出指定公开名字 | 不是重新定义类，也不能开放私有名字 |
| hide SomeType | 排除指定名字 | 不改变源库本身 |
| library; | 库级声明，可附文档和注解 | 不必为每个文件添加 |

两个文件都在 lib/src 或同一个 package 中，也通常是**不同库**。因此 Dart 基础里的 interface/base 限制，不是只在不同 package 之间才生效：同包的两个独立文件也可能触发“库外”限制。

同包 lib 内部之间通常用相对 import；从 bin/test 引入自己 lib 中的代码，或引用其他包时，用 package: URI。不要用 `../../other_package/lib/...` 穿越包边界来绕过依赖声明。

资料：[库与导入](https://dart.dev/language/libraries)。

<a id="part"></a>
###### part 与 part of：同一个库拆成多个文件

普通拆文件优先用 import/export。只有明确需要同库私有访问、或者代码生成工具要求时，再考虑 part。

counter.dart：

```dart
part 'counter_part.dart';

int _count = 0;

void main() {
  increase();
  print(_count); // 1
}
```

counter_part.dart：

```dart
part of 'counter.dart';

void increase() {
  _count++; // 与宿主属于同一个库，所以可以访问
}
```

运行宿主 `dart run counter.dart`，不是单独运行 part 文件。part 不是普通独立库，通常不应再被调用方直接 import；依赖导入也放在宿主库中管理。若把第二个文件改成普通独立库，仅仅用 import 就不能访问第一个文件的 `_count`。

不要为了让所有文件都能互访私有字段，把整个业务 package 全部接成 part；这会放大耦合。代码生成中的 `part 'model.g.dart';` 属于另一常见用途，生成文件不要手动维护。

<a id="dependencies"></a>
###### dependencies、dev_dependencies 与依赖来源

pubspec 是 YAML，使用空格缩进；下例每一段都必须放到实际包的 pubspec 中，不能写在 Dart 文件里。

| 配置 | 用途 | 例子 |
|---|---|---|
| dependencies | lib 或 bin 等正常使用路径需要的包 | HTTP、模型共享包 |
| dev_dependencies | 当前包开发、测试、检查等工具 | test、lints、build_runner |
| dependency_overrides | 临时覆盖依赖解析以调试/排障 | 暂时替换一个传递依赖 |

一个包被别人依赖时，它的 dev_dependencies 不会作为该包的普通传递依赖带给使用者；workspace 的共同解析则会考虑各成员的开发依赖。把 lib 中实际 import 的包写成 dev_dependency，不能因为自己机器上能跑就认为配置正确。

常见来源对照（示意，按项目选其一）：

```yaml
# pub.dev 托管包，版本范围不是 SDK 版本。
dependencies:
  http: ^1.0.0
```

```yaml
# 本地路径：相对于当前这份 pubspec.yaml 所在目录。
dependencies:
  article_core:
    path: ../article_core
```

```yaml
# Git 来源：实际使用时替换为自己的 URL，并固定合适的 tag/commit。
dependencies:
  article_core:
    git:
      url: https://github.com/example/article_core.git
      ref: v1.0.0
```

Git 片段只是配置形状，不表示该示例仓库真实存在或已验证。path 适合联调，但目录移动后必须重审相对路径；只引用本地包并不要求一定建立 workspace。

正常使用的外部包都应显式声明为自己的依赖，即使它恰好已经是其他包的传递依赖。overrides 会改变当前解析，但不是修改库对外兼容承诺的替代方案，也不应随意用它掩盖版本不兼容。

`^1.2.3` 常表示 `>=1.2.3 <2.0.0`；0.x 的上界规则更收紧，例如 `^0.2.3` 对应 `<0.3.0`。修改 pubspec 后执行 pub get；pub upgrade 才用于主动尝试更新到约束允许的新版本，仍应检查 lockfile 差异。资料：[依赖配置](https://dart.dev/tools/pub/dependencies)。

<a id="workspace"></a>
###### 一个完整工作区：共享包加命令行调用方

先用纯 Dart 演示，避免把环境问题和 Flutter UI 混在一起。可运行源码位于 [workspace_demo](../../assets/flutter/workspace_demo/pubspec.yaml)。文件关系如下：

```text
workspace_demo/
├── pubspec.yaml
├── packages/
│   └── article_core/
│       ├── pubspec.yaml
│       └── lib/
│           ├── article_core.dart
│           └── src/article.dart
└── apps/
    └── article_cli/
        ├── pubspec.yaml
        └── bin/main.dart
```

根 pubspec.yaml：

```yaml
name: article_workspace
publish_to: none
environment:
  sdk: ^3.6.0
workspace:
  - packages/article_core
  - apps/article_cli
```

packages/article_core/pubspec.yaml：

```yaml
name: article_core
version: 1.0.0
publish_to: none
environment:
  sdk: ^3.6.0
resolution: workspace
```

apps/article_cli/pubspec.yaml：

```yaml
name: article_cli
version: 1.0.0
publish_to: none
environment:
  sdk: ^3.6.0
resolution: workspace
dependencies:
  article_core: ^1.0.0
```

共享包的 Dart 代码就是前面目录章节中的 Article 和 export；调用方的 bin/main.dart 则是前面的 import 与 main。三个 YAML 文件各有职责：

1. 根 workspace 列出**成员路径**，不是包名列表，也不是 import 列表。
2. 成员 resolution: workspace 表示参加共同解析。
3. 调用方 dependencies 声明自己实际依赖 article_core；同属 workspace 仍需显式写依赖。
4. pub 将 article_core 解析到工作区本地同名包；成员的 version 仍必须满足调用方约束。不是因为本地就可以忽略版本。
5. 根目录的共享 package_config 把包名映射到位置；编译器再据此解释 package: URI。

在知识库根目录执行：

```powershell
cd assets/flutter/workspace_demo
dart pub get
dart pub workspace list
dart analyze
cd apps/article_cli
dart run bin/main.dart
```

运行打印 `Dart`。示例没有第三方依赖；联网受限时可尝试 `dart pub get --offline`，但真实项目依赖不在本地缓存时不能靠 offline 自动获得它们。

<a id="resolution"></a>
###### workspace 解决什么，不解决什么

共同解析会生成根目录的 `pubspec.lock` 与 `.dart_tool/package_config.json`；成员之间使用同一套解析版本。它不会把所有包的 Dart 文件变成同一个 library，不会开放私有成员，也不会自动创建单例或运行所有应用。

| 问题 | 结果与处理 |
|---|---|
| 两个成员要求同一包的不兼容版本 | 共同解析失败，需要调整兼容范围；不是每个成员各装一个版本 |
| 只有 resolution，没有被根 workspace 收录 | 配置不完整；检查根路径和成员声明 |
| 根与成员之间夹着未加入工作区的 pubspec | 可能遮蔽解析配置而失败；梳理包层级 |
| 成员遗留独立 lock/config | pub get 迁移时会清理遮蔽根解析的这些文件；先查看 Git 差异 |
| 想新增一个成员 | 创建包、声明成员路径和 resolution，再给实际使用者加 dependency，重新 pub get |
| 包名重复 | 不能靠不同文件夹名区分，使用唯一 name |
| 只改 Dart 方法实现 | 通常无需重新 pub get；运行或按框架支持进行热重载即可 |
| 改包名、依赖、成员路径 | 重新 pub get，并修复引用 |

`.dart_tool/` 是生成物，不提交。应用或应用型工作区通常提交根 lockfile 以保持依赖可复现；共享库自身的发布约束由 pubspec 表达，消费方不会直接使用你的开发 lockfile。本文演示作为应用型工作区保存根 lockfile，成员不再各维护一份。

Pub workspace 与 IDE 的“打开工作区”不是一回事。VS Code 多根工作区只决定编辑器如何打开目录，不会替你完成 Pub 共同依赖解析。Melos 等工具可用于批量脚本和版本管理，但不是使用原生 Pub workspace 的必需条件。

<a id="flutter"></a>
###### 接到 Flutter 项目时怎么用

已有 Flutter 项目时，不需要先创建一个额外 console 程序才能用共享包。只需选择包位置，在 Flutter 应用 pubspec 的 dependencies 中声明，然后在 lib 中 import。

两种常见方式：

- **先做简单本地依赖：** 应用通过 path 引入旁边的 article_core；各包仍可独立解析，适合小规模联调。
- **多个包共同开发：** 使用根目录协调 apps/article_app 与 packages/article_core。Flutter 应用也声明 resolution: workspace，并保留原有 Flutter SDK、flutter 配置及依赖。

包含 Flutter SDK 依赖时，使用 Flutter 配套工具执行依赖获取和检查，例如在应用目录执行 `flutter pub get`、`flutter analyze`、`flutter run`；纯 Dart 示例的验证不能证明 Flutter 插件或平台构建也成功。

如果共享包只是模型、接口和纯 Dart 逻辑，优先保持不依赖 Flutter；如果需要 Widget，就使用 Flutter package；若需要 Android/iOS 原生实现，再考虑 plugin。

<a id="publish"></a>
###### 本地开发与发布不是一回事

包不发布也可以通过 path、Git 或 workspace 使用。`publish_to: none` 明确禁止误发布此包，不会禁止本地依赖。真正准备发布到 pub.dev 时，需要许可证、说明、版本、可被消费者解析的依赖和发布前检查；`dart pub publish --dry-run` 只检查，正式 publish 才是外部发布行为。

在 workspace 内成功，不能证明成员单独发布后也能用。发布时调用方通常会按原来源解析依赖；如果 article_core 只存在本地，其他人就拿不到。应把待发布包复制到隔离目录、去除工作区专用解析设置后，验证真实依赖约束与入口；不要直接破坏当前工作区来试验。

本任务没有执行发布。资料：[发布包](https://dart.dev/tools/pub/publishing)。

<a id="faq"></a>
###### 常见问题与简答

| 问题 | 答案 |
|---|---|
| package 是不是只适合第三方稳定库？ | 不是，应用、自研业务包、工具都可以是 package |
| 必须写 library 才能 import 吗？ | 不必，普通 Dart 文件本来就是库 |
| export 会共享 `_` 私有成员吗？ | 不会；part 才把文件组织进同一个库 |
| lib/src 是否绝对无法访问？ | 不是硬访问控制，外部不应依赖它；下划线才表达库私有 |
| workspace 根目录一定是主应用吗？ | 不一定，可只是协调多个成员的 package |
| workspace 成员自动互相依赖吗？ | 不会，使用者仍需声明 dependencies |
| 本地成员版本不符合约束能忽略吗？ | 不能，仍需满足版本约束 |
| 应用已存在，还要 dart create console 吗？ | 不需要，在应用 lib 中使用依赖即可 |

<a id="verification"></a>
###### 验证与资料范围

2026-11-27 已阅读官方工作区、共享包创建及库文档。本文语法例子包含分文件和多包配置，按其标注位置组合使用，不应把所有代码块拼成一个 main.dart。

本次已在随文纯 Dart 工作区执行 dart pub get --offline、dart pub workspace list、dart analyze，并从调用方入口运行成功输出 Dart。根目录生成共享 lockfile 与 package_config，成员正确列出。part 的两文件例子另在临时目录通过静态分析并运行输出 1。最初在知识库根目录执行命令因没有 pubspec 而失败，切到示例工作区完成解析后检查通过；这也说明命令必须在正确项目上下文运行。未验证 Flutter UI、平台插件、发布到 pub.dev 或 Git 依赖示意仓库。

关联阅读：[Dart 基础详解](./Dart基础详解.md)、[Flutter 学习路线](./Flutter学习路线.md)。
