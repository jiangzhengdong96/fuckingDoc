### Dart 基础详解

<!-- page-toc:start -->
**目录**

- [本文怎么读与适用版本](#scope)
- [从 main 开始：环境、运行与项目结构](#start)
- [类型与运算：先分清静态类型、值和转换](#types)
- [var、final、const、late：分别限制什么](#variables)
- [空安全：可空、判空与强制断言](#null-safety)
- [函数、参数与回调：看懂 Flutter 构造参数的前提](#functions)
- [集合：List、Set、Map 与数据转换](#collections)
- [控制流、枚举、Record 与模式匹配](#branches)
- [类与构造：this、命名构造、factory、const](#classes)
- [extends、implements、mixin 与依赖注入](#interfaces)
- [泛型、扩展与相等性](#generics)
- [异常处理：catch、finally、rethrow 与 assert](#errors)
- [import、库边界与 JSON](#libraries)
- [Future 与 async/await：从执行顺序理解异步](#future)
- [串行、并发等待、异常与超时](#future-concurrency)
- [事件循环与微任务：不是所有异步都开线程](#event-loop)
- [Stream：多次事件、监听与释放](#stream)
- [Isolate：CPU 工作为什么不能只加 async](#isolate)
- [综合例子：加载文章并切换收藏](#example)
- [和 Kotlin 对照时最容易误解的地方](#kotlin)
- [和 Kotlin 对照时最容易误解的地方：面试可能怎么问](#interview)
- [资料与验证范围](#sources)
<!-- page-toc:end -->


<a id="scope"></a>
###### 本文怎么读与适用版本

Dart 是语言，Flutter 是使用 Dart 构建界面的框架。可以先只写 Dart 控制台程序，弄清数据、函数和异步，再学习 Widget。本文面向有一点 Java/Kotlin 经验、但刚开始 Dart 的读者，按“解决什么问题 → 最小代码 → 执行过程 → 易错点”组织。

示例以常见 Dart 3 语法为基础，Record、模式匹配和 sealed class 等要求 Dart 3.0 或以上；本次验证环境为 **Dart SDK 3.14.0 / Windows x64**。查阅日期：2026-11-25。SDK 版本与包的语言版本不是同一件事，项目还需检查 pubspec.yaml 的 SDK 约束。本文不追求覆盖所有新语法，也不把 Dart VM 与 Web 平台实现混为一谈。

正文每个 dart 代码块都是独立示例，可分别存为 .dart 文件运行；不要把所有 main 和同名类直接拼成一个文件。错误写法放在注释或文字里。先按顺序读到 Future，再看 Stream、Isolate 和综合示例。Flutter 总体顺序见 [Flutter 学习路线](./Flutter学习路线.md)。

<a id="start"></a>
###### 从 main 开始：环境、运行与项目结构

已经安装 Flutter 时通常已经带有 Dart SDK，先确认实际命中的版本，不要仅凭安装文件夹名字判断。只学语言也可以单独安装 Dart，或在 [DartPad](https://dartpad.dev/) 运行适合浏览器的基础例子。

```powershell
dart --version
flutter --version
flutter doctor
# 将下面示例保存为 main.dart 后：
dart run main.dart
# 独立练习项目可使用：
dart create -t console dart_basics
cd dart_basics
dart analyze
dart format .
```

下面是最小程序：

```dart
void main() {
  final name = 'Dart';
  print('Hello, $name');
  print('2 + 3 = ${2 + 3}');
}
```

运行从 main 进入，依次声明变量、执行两个 print。`$name` 插入变量，`${...}` 插入表达式。语句通常以分号结束；`//` 是单行注释，`/* ... */` 是多行注释，`///` 用于文档注释。标识符和文件名推荐 lowerCamelCase、lower_case_with_underscores，类型名用 UpperCamelCase。

| 位置或工具 | 作用 |
|---|---|
| bin/ | 控制台入口，例如 main 或生成的命令行入口 |
| lib/ | 可复用的代码；Flutter 通常以 lib/main.dart 为入口 |
| test/ | 自动化测试；普通执行顺序实验可以直接用 main，不必写成测试 |
| pubspec.yaml | 包名、SDK 约束、dependencies、dev_dependencies；Flutter 还声明资源等 |
| pubspec.lock | 依赖解析结果；应用项目通常提交，便于复现 |
| dart pub get / flutter pub get | 按项目类型解析、获取依赖 |
| dart analyze | 静态检查；不等于已经执行所有路径 |
| dart format | 统一格式；不检查业务正确性 |

SDK 约束的示意：`sdk: '>=3.0.0 <4.0.0'` 表示允许的 SDK 范围；实际项目应按使用的特性和依赖确定最低版本，而不是无脑复制。依赖包版本与 SDK 版本也分别管理。包管理入口：[pubspec](https://dart.dev/tools/pub/pubspec)。

<a id="types"></a>
###### 类型与运算：先分清静态类型、值和转换

| 类型 | 表示什么 | 典型值 |
|---|---|---|
| int | 整数 | 3 |
| double | 浮点数 | 3.5 |
| num | int 和 double 的共同父类型 | 数值通用参数 |
| bool | 布尔值，只能是 true/false | true |
| String | 字符串 | 'Flutter' |
| List<T> / Set<T> / Map<K, V> | 有序序列 / 不重复元素 / 键值映射 | 见集合章节 |
| Object | 非空对象的公共超类型 | 需要后续类型判断 |
| Object? | 可接受包括 null 在内的值 | 未知来源的数据 |
| dynamic | 对该表达式放宽静态成员检查 | 边界数据；错误可能延后到运行时 |
| void | 调用者不使用返回值 | print 或普通通知函数 |
| Never | 不会正常返回 | 总是抛异常的函数 |

`var` 是类型推断，不是 dynamic：`var name = 'Dart'` 推断为 String，随后不能赋值 123。没有初始值的 `var value;` 通常得到 dynamic，入门时尽量避免。Object? 仍要求先判断才能用具体类型的方法，dynamic 则允许写出可能不存在的方法。

```dart
String describe(Object? value) {
  if (value is String) {
    return 'text length=${value.length}';
  }
  return 'not a string';
}

void main() {
  var title = 'Dart';
  title = 'Flutter';
  // title = 42; // 编译错误：String 变量不能改成 int。
  print(title);
  print(describe('abc')); // text length=3
  print(describe(null));  // not a string
  print(5 / 2);           // 2.5，/ 不是整数除法
  print(5 ~/ 2);          // 2，向零截断
  print(5 % 2);           // 1
  print(int.tryParse('bad')); // null；parse 则会抛 FormatException
  print(12.toString());
}
```

`is` 做类型检查，并可能让编译器在分支内提升变量类型；`as` 是类型转换/断言，类型不符会失败，不会像字符串解析那样把 '12' 变成 12。`if (count)` 不合法，应该明确写 `if (count > 0)`。浮点数有精度误差，金额一般使用最小货币单位的整数或明确的十进制方案。

字符串不可变；单双引号均可，三引号可写多行，`r'...'` 是原始字符串，保留反斜杠。String.length 统计 UTF-16 码元，不等于用户看到的字符数量；emoji、组合字符可能占多个码元，界面按“可见字符”截断应考虑 characters 包。

数值范围和表示在 VM、JavaScript 等目标之间有差异，不要把 Android/JVM 的所有数值假设直接搬过来。资料：[内置类型](https://dart.dev/language/built-in-types)、[运算符](https://dart.dev/language/operators)。

<a id="variables"></a>
###### var、final、const、late：分别限制什么

| 写法 | 含义 | 关键边界 |
|---|---|---|
| var name = 'A' | 推断类型，变量允许再次赋值 | 重新赋值仍必须满足类型 |
| final name = loadName() | 变量只能赋值一次，值可以在运行时产生 | 不保证对象内部不可变 |
| const count = 3 | 编译期常量，隐含 final | DateTime.now() 不是编译期常量 |
| late String name | 延迟初始化，把部分初始化检查推迟到运行时 | 未赋值就读取会失败 |
| late final name = buildName() | 首次读取时求值，且变量只能初始化一次 | 不是启动异步任务，也不是可空类型 |

```dart
String buildName() {
  print('build');
  return 'Dart';
}

void main() {
  final items = <String>['A'];
  items.add('B');             // 可以修改列表内容
  // items = ['C'];           // 不可以给 final 变量换一个列表
  print(items);              // [A, B]

  const fixed = <String>['A'];
  // fixed.add('B');          // 会失败：常量列表不可修改
  print(fixed);

  late final name = buildName();
  print('before');
  print(name);                // 首次读取，先打印 build，再打印 Dart
  print(name);                // 不会再次执行 buildName
}
```

final 限制变量绑定，const 还要求常量表达式与常量对象；const 不是“更快的 final”。const 构造函数允许生成常量实例，但非 const 调用仍可在运行时创建普通实例。Flutter 中看到 `const Text(...)` 时，先理解它在表达稳定的配置，不要解读为“这个位置永远不会参与重建”。

late 适用于初始化时机确实由程序保证的场景，不能用来消除所有空安全报错。将未知的数据写成 late，并不会让它自动准备好。资料：[变量、late、final 和 const](https://dart.dev/language/variables)。

<a id="null-safety"></a>
###### 空安全：可空、判空与强制断言

String 默认不可空，String? 才允许 null。类型后面的 `?` 与表达式后的 `!` 含义完全不同。

| 写法 | 作用 | 示例含义 |
|---|---|---|
| T? | 声明可空类型 | String? 允许 null |
| value?.member | value 非空才访问 | name?.length 可能得到 null |
| a ?? b | a 是 null 时才使用 b | null 昵称显示“游客” |
| a ??= b | a 是 null 时才赋值 | 仅补默认值 |
| value! | 断言当前值非空 | null 会在运行时失败 |
| if (value != null) | 检查并在满足条件时提升类型 | 局部变量分支内可直接使用 |

```dart
int nameLength(String? name) {
  if (name == null) return 0;
  return name.length; // 此处 name 已提升为 String
}

void greet({required String? nickname}) {
  print(nickname ?? '游客');
}

void main() {
  print(nameLength(null));     // 0
  print(nameLength('Dart'));   // 4
  greet(nickname: null);       // 游客，参数必须传，但值允许 null
  final values = <String, int>{'count': 2};
  print(values['missing'] ?? 0); // Map 查询的结果可能为空
}
```

`required` 管“必须传这个参数”，`?` 管“值是否允许 null”，二者独立。`String?` 也不代表可以省略一个 required 参数。

优先使用判空和默认值；只有确实保证非空时才用 `!`。字段、getter、被闭包修改的变量不总能像简单局部变量那样提升，可以先读取到 final 局部变量再检查；具体可提升条件与语言版本有关。`??` 只处理 null，不会把空字符串、0 或 false 当成缺省值。

资料：[空安全概览](https://dart.dev/null-safety)、[理解空安全](https://dart.dev/null-safety/understanding-null-safety)。

<a id="functions"></a>
###### 函数、参数与回调：看懂 Flutter 构造参数的前提

Dart 函数可以独立定义在文件顶层，不必放进类。返回类型写在函数名前；`=> expression` 只适合一个表达式，不是一个可以塞多条语句的代码块。

参数先看三种：必需位置参数、`[]` 中的可选位置参数、`{}` 中的命名参数。一个函数可以有必需位置参数加一组可选参数，但不能同时使用可选位置参数和命名参数。默认值必须是编译期常量。

```dart
int add(int a, int b) => a + b;

String label(String name, [String suffix = '!']) => '$name$suffix';

String greeting(String name, {String prefix = 'Hi', required int age}) {
  return '$prefix $name, age=$age';
}

typedef IntCallback = void Function(int value);

void notifyCount(int count, IntCallback onChanged) {
  onChanged(count);
}

int Function() createCounter() {
  var count = 0;
  return () => ++count; // 闭包捕获 count
}

void main() {
  print(add(2, 3));
  print(label('Dart'));
  print(greeting('Lin', age: 20, prefix: 'Hello'));
  notifyCount(3, (value) => print('count=$value'));
  final counter = createCounter();
  print(counter()); // 1
  print(counter()); // 2，同一个闭包保留同一份 count
}
```

执行 notifyCount 时，先拿到函数对象 onChanged，再用括号调用它。`onChanged: handleChanged` 是传递函数；`onChanged: handleChanged()` 是立即调用并传结果，两者不能混用。`onChanged: (value) => handleChanged(value)` 则是再包一层转发函数。

typedef 为函数类型等起别名，不会创建一个有独立运行时语义的新类。Flutter 常见 `VoidCallback` 可以理解为 `void Function()`；需要返回异步完成信号时通常使用 `Future<void> Function()`。不要把希望等待的异步回调声明成只表达同步通知的 void 回调后，又假设调用方会自动等待它。

资料：[函数与参数](https://dart.dev/language/functions)。

<a id="collections"></a>
###### 集合：List、Set、Map 与数据转换

| 类型 | 特点 | 常用操作 |
|---|---|---|
| List<T> | 有顺序，可按下标访问，可重复 | add、remove、where、map、sort |
| Set<T> | 按相等性规则去重 | add、contains、intersection |
| Map<K, V> | 按键查值，键唯一 | []、[]=、containsKey、entries |

空列表写 `<int>[]`，空集合写 `<int>{}`，空映射写 `<String, int>{}`；单写 `{}` 默认是 Map，不是 Set。

```dart
void main() {
  final ids = <int>[1, 2, 2, 3];
  print(ids.toSet()); // {1, 2, 3}
  final names = <int, String>{1: 'Dart', 2: 'Flutter'};
  print(names[9] ?? 'unknown');

  final selected = ids.where((id) => id > 1).map((id) => 'id=$id').toList();
  print(selected); // [id=2, id=2, id=3]

  final extras = <String>['B', 'C'];
  final items = <String>[
    'A',
    ...extras,
    if (ids.isNotEmpty) 'has items',
    for (final id in ids.toSet()) 'item-$id',
  ];
  print(items);

  final sorted = [...ids]..sort((a, b) => b.compareTo(a));
  print(sorted); // [3, 2, 2, 1]
  print(ids);    // [1, 2, 2, 3]，排序的是副本
}
```

`where` 过滤、`map` 转换，通常返回惰性的 Iterable；`toList()` 才把本次遍历结果物化为列表。重复遍历可能重复执行转换逻辑，因此不要轻易在 map 回调里放副作用。修改源集合后再遍历，结果也可能与首次不同。

`...items` 展开集合，`...?items` 在 items 为 null 时跳过。collection if/for 常出现在 Flutter 的 children 中，但它们本身是 Dart 语法。

`..` 是级联，连续操作同一个接收对象，并把该对象作为整段表达式的结果；sort 本身返回 void，所以不能把 sort 的返回值当成排好序的列表。级联不等于异步等待，也不改变调用顺序。

`List.unmodifiable(items)` 限制通过返回列表修改结构，但不把元素对象深度冻结。`[...items]` 同样只是浅拷贝。List 默认 `==` 通常比较对象身份，不自动逐元素比较；Set/Map 的元素与键比较依赖正确的 `==` 和 hashCode 实现。正在遍历时修改集合结构可能抛并发修改错误，即使只在一个 isolate 中也可能发生。

资料：[集合](https://dart.dev/language/collections)。

<a id="branches"></a>
###### 控制流、枚举、Record 与模式匹配

if/else、for、for-in、while、break、continue 的用途与常见语言相近。Dart 3 的 switch 可以作为表达式返回值；这里不把 Java switch 的贯穿语义照搬过来。Record 是一组固定字段的值，适合临时返回多个相关结果；命名业务对象仍可以使用 class。

```dart
enum LoadStatus { idle, loading, success, error }

String statusText(LoadStatus status) => switch (status) {
  LoadStatus.idle => '未开始',
  LoadStatus.loading => '加载中',
  LoadStatus.success => '成功',
  LoadStatus.error => '失败',
};

({String name, int count}) summary() => (name: 'favorites', count: 2);

void main() {
  for (final value in [1, 2, 3]) {
    if (value == 2) continue;
    print(value); // 1、3
  }
  print(statusText(LoadStatus.success));
  final result = summary();
  print('${result.name}: ${result.count}');
  final (:name, :count) = result; // 解构命名 Record
  print('$name/$count');

  final Object data = {'id': 7, 'title': 'Dart'};
  if (data case {'id': int id, 'title': String title}) {
    print('$id: $title');
  } else {
    print('Invalid data');
  }
}
```

模式匹配先检查形状/类型，再绑定变量；不是任何 Map 都能直接读成业务模型。上面的 Map 模式允许存在额外键，但要求指定键存在且值匹配类型。Record 的字段不能重新赋值，但字段指向的可变对象仍可能被修改；Record 不等于深度不可变对象。

Dart 3 的非空 switch 语句分支正常执行完会退出 switch，不必像 Java 那样为防贯穿在每个分支补 break；循环中的 break 则仍用于退出循环。资料：[分支](https://dart.dev/language/branches)、[Record](https://dart.dev/language/records)、[模式匹配](https://dart.dev/language/patterns)。

<a id="classes"></a>
###### 类与构造：this、命名构造、factory、const

先用 Article 表示一条文章数据。`this.id` 是把构造参数直接赋给字段的简写；花括号与 required 仍是命名参数规则。

```dart
class Article {
  final int id;
  final String title;
  final bool isFavorite;

  const Article({required this.id, required this.title, this.isFavorite = false});

  Article.empty() : id = 0, title = '', isFavorite = false;

  factory Article.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final title = json['title'];
    if (id is! int || title is! String) {
      throw const FormatException('Invalid article');
    }
    return Article(id: id, title: title);
  }

  String get displayTitle => title.isEmpty ? '未命名' : title;

  Article copyWith({bool? isFavorite}) => Article(
    id: id,
    title: title,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}

void main() {
  const original = Article(id: 1, title: 'Dart');
  final updated = original.copyWith(isFavorite: true);
  print(original.isFavorite); // false，旧对象没有被改动
  print(updated.isFavorite);  // true，新对象保存新状态
  print(Article.empty().displayTitle);
  print(Article.fromJson({'id': 2, 'title': 'Flutter'}).title);
}
```

| 语法 | 用途 | 易错点 |
|---|---|---|
| Article(...) | 普通生成式构造函数 | 不需要写 new |
| Article.empty() | 命名构造函数 | 名字只是不同创建入口，不代表单例 |
| : id = 0, ... | 初始化列表，在构造函数体前设置字段 | final 字段不能等到普通函数体里随意赋值 |
| factory Article.fromJson(...) | 创建流程可验证输入、返回缓存对象或子类 | factory 不自动变成单例，不能访问 this，也不能直接写 async 构造 |
| const Article(...) | 常量构造能力 | 全部实例字段需满足 final 等要求；实际调用是否常量还取决于调用处 |
| get displayTitle | 计算属性，访问时不带括号 | 每次访问可能重新计算，不自动缓存 |
| static | 类级成员 | 不依赖某个实例，不等于整个应用唯一一份跨 isolate 状态 |

Dart 没有 Java 那样依赖不同参数列表实现同名方法重载，常用命名参数或命名构造区分用途。普通类不会自动生成 copyWith、值相等或序列化；这里的 copyWith 是手写方法，不是语言关键字。此例字段 isFavorite 不可空，用 null 表示“不修改”可行；如果字段本身允许 null，想区分“未传”与“明确改成 null”，需要额外标记或其他 API 设计。

普通实例方法中的 this 指当前对象；构造函数不是普通异步方法。需要异步初始化时，可使用返回 Future<Article> 的静态工厂方法或仓库方法，而不是把构造函数直接标 async。

资料：[类](https://dart.dev/language/classes)、[构造函数](https://dart.dev/language/constructors)。

<a id="interfaces"></a>
###### extends、implements、mixin 与依赖注入

继承用于复用和扩展一个父类；implements 用于承诺实现接口契约；mixin 用于复用一组实例行为。这三者不是同义词。

```dart
abstract interface class ArticleRepository {
  Future<List<String>> loadTitles();
}

mixin LogSupport {
  void log(String message) => print('[repo] $message');
}

class MemoryArticleRepository with LogSupport implements ArticleRepository {
  @override
  Future<List<String>> loadTitles() async {
    log('load');
    return ['Dart', 'Flutter'];
  }
}

class ArticleService {
  final ArticleRepository repository;
  ArticleService(this.repository);

  Future<int> count() async => (await repository.loadTitles()).length;
}

Future<void> main() async {
  final service = ArticleService(MemoryArticleRepository());
  print(await service.count()); // 2
}
```

ArticleService 只依赖接口，通过构造函数拿到仓库；单元测试可传另一个实现，不需要依赖实际网络。**依赖注入表达依赖从哪里来，不自动决定实例是否单例或何时销毁。** 生命周期仍由创建和持有它的代码决定。

- `extends Parent`：继承一个父类，`super` 调用父类成员或构造函数；构造函数本身不自动继承。
- `implements Contract`：实现所需实例成员，不直接继承该接口的具体方法实现。Dart 普通类也定义隐式接口，但是否允许外部实现还受类修饰符约束。
- `with SomeMixin`：混入行为，适合可复用能力；不要为复用几个函数制造复杂继承链。
- `_name`：库私有，不是 Java 的类私有。一个 Dart 文件及其 part 通常属于同一个库；同库内其他类可能访问 `_name`。
- Dart 3 的 `interface class` 限制库外继承、允许库外实现；`final class` 限制库外继承和实现；`base` 与 `sealed` 另有继承限制。初学先理解 abstract interface class 和 sealed class 的用途，不能把 `final class` 误读成“实例字段自动不可变”。

资料：[继承](https://dart.dev/language/extend)、[mixin](https://dart.dev/language/mixins)、[类修饰符](https://dart.dev/language/class-modifiers)。

<a id="generics"></a>
###### 泛型、扩展与相等性

泛型把“具体类型”作为参数，让容器或操作保持类型安全，避免把所有内容写成 dynamic。扩展方法用于给已有类型增加调用语法，不会修改原类，也不会给实例偷偷增加存储字段。

```dart
class Box<T> {
  final T value;
  Box(this.value);
}

T firstValue<T>(List<T> items) {
  if (items.isEmpty) throw StateError('Empty list');
  return items.first;
}

extension DisplayName on String {
  String get asTitle => trim().isEmpty ? '未命名' : trim();
}

class ArticleId {
  final int value;
  const ArticleId(this.value);

  @override
  bool operator ==(Object other) => other is ArticleId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

void main() {
  print(Box<int>(7).value);
  print(firstValue<String>(['Dart', 'Flutter']));
  print('  Dart  '.asTitle);
  final ids = <ArticleId>{ArticleId(1), ArticleId(1)};
  print(ids.length); // 1，基于自定义相等性去重
}
```

`T extends Object` 可以约束类型参数为非空对象；是否需要约束由 API 需求决定。扩展方法按接收者的静态类型解析，因此不能依赖 dynamic 自动找到扩展方法。

`==` 表达相等性，`identical(a, b)` 判断对象身份；普通类默认没有 Kotlin data class 那样的自动值相等。重写 == 时要一起提供一致的 hashCode，否则 Set/Map 行为可能不符合预期。用作键的对象最好保持影响相等性与哈希的字段不变。

资料：[泛型](https://dart.dev/language/generics)、[扩展方法](https://dart.dev/language/extension-methods)、[Object 相等契约](https://api.dart.dev/dart-core/Object/operator_equals.html)。

<a id="errors"></a>
###### 异常处理：catch、finally、rethrow 与 assert

```dart
int parsePositive(String text) {
  final value = int.parse(text);
  if (value <= 0) throw ArgumentError.value(value, 'value', 'Must be positive');
  return value;
}

void main() {
  try {
    print(parsePositive('bad'));
  } on FormatException catch (error) {
    print('输入格式错误: ${error.message}');
  } catch (error, stackTrace) {
    print('其他错误: $error');
    print(stackTrace);
  } finally {
    print('本次处理结束');
  }
}
```

执行到 int.parse 抛异常后，try 中后续语句不执行，匹配的 on/catch 处理错误，最后执行 finally。`rethrow` 用在 catch 内继续向上抛原错误，并保留原始抛出信息；不要为了“稳定”把所有异常吞掉后返回空列表，这会混淆“真的没有数据”和“加载失败”。

Dart 没有 Java 的受检异常声明要求。Exception 常表示可预期失败，Error 常表示程序错误；并不意味着所有 Error 都应该被忽略。assert 是开发期检查，在生产配置可能被禁用，用户输入、网络格式和权限判断必须用正常控制流验证。

资料：[错误处理](https://dart.dev/language/error-handling)。

<a id="libraries"></a>
###### import、库边界与 JSON

`dart:` 引入 SDK 库，`package:` 引入包中的库，相对路径引入自己的文件；`as` 为库加前缀，`show`/`hide` 控制导入名称，`export` 向外暴露 API。普通业务不必为了拆文件就使用 part；part 表示共享同一库边界，常见于代码生成。

```dart
import 'dart:convert';
import 'dart:math' as math;

void main() {
  const raw = '{"id":7,"title":"Dart","favorite":true}';
  final Object? decoded = jsonDecode(raw);
  if (decoded case {'id': int id, 'title': String title, 'favorite': bool favorite}) {
    final json = jsonEncode({'id': id, 'title': title, 'favorite': favorite});
    print(json);
    print(math.max(id, 10)); // 10
  } else {
    throw const FormatException('Invalid article JSON');
  }
}
```

jsonDecode 结果需要校验：服务端可能返回 null、数组、缺失字段或错误类型。`as Map<String, dynamic>` 只做类型断言，不会自动校验每个业务字段。数字 7 和 7.0 也可能对应不同类型，需要按接口契约处理。

`jsonEncode` 能直接处理 JSON 支持的基础值、列表及字符串键映射；自定义对象需要明确序列化方式，例如 toJson。日期、枚举、金额的传输格式应由接口约定，不要只把对象 toString 当成稳定 JSON。

资料：[库与导入](https://dart.dev/language/libraries)、[dart:convert](https://api.dart.dev/dart-convert/dart-convert-library.html)。

<a id="future"></a>
###### Future 与 async/await：从执行顺序理解异步

Future<T> 表示一次未来的完成结果：成功时带 T，失败时带错误。它不是线程，也不是自动取消的 Job；Future<void> 表示只关心完成或失败、不使用业务返回值。

async 函数调用后，会执行函数体中的同步部分，遇到 await 时暂停当前函数的后续流程，让调用方继续；完成后再恢复后面的代码。await 等待流程不会占着当前 isolate 忙等，但 await 前后的 CPU 计算仍可能阻塞它。

```dart
Future<String> loadTitle() async {
  print('2 load start');
  await Future<void>.delayed(const Duration(milliseconds: 10));
  print('4 load end');
  return 'Dart';
}

Future<void> main() async {
  print('1 main start');
  final future = loadTitle();
  print('3 caller continues');
  final title = await future;
  print('5 result=$title');
}
```

这个例子的顺序是 1 → 2 → 3 → 4 → 5：调用 loadTitle 时就开始执行；并不是等 await future 时才启动。第一次 await 延时操作，让 loadTitle 暂停；main 拿到 Future，打印 3，再等待同一结果。loadTitle 返回字符串后，它对应的 Future 成功完成，main 获得 String。

**不要把 Future 等同于 Kotlin Deferred 的全部行为。** Dart 的 async/await 没有自动提供 Kotlin 结构化并发的父子取消；取消请求、页面销毁后停止处理等需要相应 API 或应用层设计。

资料：[异步语法](https://dart.dev/language/async)、[异步教程](https://dart.dev/libraries/async/async-await)。

<a id="future-concurrency"></a>
###### 串行、并发等待、异常与超时

两次独立加载可以先创建 Future，再用 Future.wait 汇合；有数据依赖时则应顺序 await。下面的示例每个加载都会先执行 start，再等待延时。

```dart
Future<String> fetch(String name) async {
  print('start $name');
  await Future<void>.delayed(const Duration(milliseconds: 10));
  return name;
}

Future<void> failLater() async {
  await Future<void>.delayed(Duration.zero);
  throw StateError('network failed');
}

Future<void> main() async {
  final first = await fetch('serial-A');
  final second = await fetch('serial-B');
  print('$first/$second');

  final values = await Future.wait<String>([
    fetch('concurrent-A'),
    fetch('concurrent-B'),
  ]);
  print(values); // 按输入顺序收集结果，不是按完成先后排序

  try {
    await failLater();
  } catch (error) {
    print('caught: $error');
  }
}
```

- **并发等待不等于 CPU 并行。** 两个 I/O 等待可能重叠，但同一个 isolate 的 Dart 代码仍依次运行。
- 串行耗时常接近等待时间之和；独立异步操作并发后常接近较长者，但还受资源竞争、调度和服务端限制影响，不能当成固定性能公式。
- Future.wait 默认等所有 Future 完成后报告错误；`eagerError: true` 可以较早报告首个错误，但不会自动取消其他操作。它也不是“收集所有错误”的默认 API。
- try 中仅调用一个返回 Future 的函数而不 await，不能指望外层同步 catch 捕获它之后的异步错误。需 await 或正确连接错误处理链。
- `future.timeout(duration)` 限制等待结果，不会自动停止底层 HTTP 请求或 CPU 任务。
- `unawaited(future)` 只是表达故意不等待，不等于捕获错误或取消操作；生产代码仍需安排错误处理。
- Future 创建方式影响何时执行：async 函数的同步前缀、`Future(() { ... })` 排队执行的回调、`Future.sync(...)` 的立即调用不能混为一谈。

资料：[Future.wait](https://api.dart.dev/dart-async/Future/wait.html)、[Future.timeout](https://api.dart.dev/dart-async/Future/timeout.html)。

<a id="event-loop"></a>
###### 事件循环与微任务：不是所有异步都开线程

每个 isolate 有自己的事件循环；在执行一个 Dart 回调时，其他回调不会抢进来同时修改它的普通变量。同步代码执行完后，微任务通常先于下一次事件任务处理；持续添加微任务可能让事件得不到机会。

```dart
import 'dart:async';

Future<void> main() async {
  print('A');
  scheduleMicrotask(() => print('C microtask'));
  final task = Future<void>(() => print('D event'));
  print('B');
  await task;
  print('E done');
}
```

本例顺序：A → B → C → D → E。不要把这个简单例子推广成“所有 then 回调永远是某一种排队方式”；Future 是否已完成、创建方式和完成链都会影响具体分析。

耗时循环即使放进 async 函数也会阻塞当前 isolate；`Future(() => heavyWork())` 只是把工作排到之后，仍不自动创建另一个 isolate。Flutter 主 isolate 被长时间占用会影响输入与绘制。

资料：[Dart 并发模型](https://dart.dev/language/concurrency)、[scheduleMicrotask](https://api.dart.dev/dart-async/scheduleMicrotask.html)。

<a id="stream"></a>
###### Stream：多次事件、监听与释放

Future 对应一次完成；Stream 对应随时间发生的多个数据事件，并可能有错误与结束事件。Stream 不自动保存“当前状态”，不能因为名称相近就当成 Kotlin StateFlow。

```dart
Stream<int> progress() async* {
  for (var value = 1; value <= 3; value++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    yield value;
  }
}

Future<void> main() async {
  await for (final value in progress()) {
    print(value); // 1、2、3
  }
  print('done');
}
```

调用 async* 函数得到流；这个生成器在被监听后才推进，yield 发出一个事件，最后函数结束则关闭流。await for 会等待流结束才执行循环后的代码；对不会结束的 UI 事件流，要考虑是否真希望一直等待。

需要回调式监听时使用 listen，保存返回的 StreamSubscription 并按生命周期取消：

```dart
import 'dart:async';

Future<void> main() async {
  final controller = StreamController<int>();
  final subscription = controller.stream.listen(
    (value) => print('event=$value'),
    onError: (Object error) => print('error=$error'),
    onDone: () => print('closed'),
  );
  controller.add(1);
  await controller.close();
  await subscription.cancel();
}
```

| 形式 | 关键语义 |
|---|---|
| 普通单订阅流 | 通常只允许监听一次；取消后也不能假设可以再次监听同一个流 |
| 广播流 | 支持多个监听者；通常不为未来订阅者重放历史事件，无监听者时发出的事件会丢失 |
| subscription.cancel() | 停止该订阅并等待相关清理；底层资源是否释放取决于生产者实现 |
| controller.close() | 生产者声明不再发新事件；不等于替所有消费者设计好生命周期 |

上例先有正常消费的监听者再 close。某些未监听或暂停的单订阅流，close 的完成可能等待监听者处理结束事件，不能机械地把 await close 当成总会立即完成的清理手段。Flutter 的 dispose 不能直接变成 async；需要在同步生命周期中发起清理，并按 API 安排异步完成和错误处理。

资料：[Stream](https://api.dart.dev/dart-async/Stream-class.html)、[StreamController](https://api.dart.dev/dart-async/StreamController-class.html)。

<a id="isolate"></a>
###### Isolate：CPU 工作为什么不能只加 async

如果任务是等接口，通常用异步 I/O；如果任务是大规模解析、计算、压缩等 CPU 工作，可考虑另一个 isolate。各 isolate 有隔离的可变状态，通过消息等机制传递数据，不能像共享内存线程那样直接修改同一个普通 List。

```dart
import 'dart:isolate';

int sumUpTo(int limit) {
  var sum = 0;
  for (var i = 1; i <= limit; i++) {
    sum += i;
  }
  return sum;
}

Future<void> main() async {
  final result = await Isolate.run(() => sumUpTo(100000));
  print(result); // 5000050000
}
```

这是原生 Dart 环境的演示，不是性能基准。小任务可能因创建 isolate 和数据传递开销反而更慢；本例只是说明执行位置与结果返回。不要在新 isolate 中直接操作 Flutter UI，也不要假设所有对象都能传送，原生资源、闭包捕获等都有约束。

Dart Web 不支持与原生相同的 dart:isolate 执行能力；Flutter 的 compute 在 Web 与原生平台行为也不同，不能写了 compute 就认为所有平台都会开后台 isolate。

资料：[Isolate](https://dart.dev/language/isolates)、[并发与平台差异](https://dart.dev/language/concurrency)、[Flutter compute](https://api.flutter.dev/flutter/foundation/compute.html)。

<a id="example"></a>
###### 综合例子：加载文章并切换收藏

这个例子把 JSON、模型、命名参数、集合、接口、依赖注入和 Future 放在同一条流程里。它只使用 Dart SDK、模拟异步等待，不发真实请求，不引入 Flutter 或数据库。完整可运行文件：[favorites_demo.dart](../../assets/flutter/dart-basics/favorites_demo.dart)。

执行入口先创建仓库，构造时校验样例 JSON 并转成模型；load 模拟异步等待后返回内存快照；切换收藏时用新 Article 替换旧对象；随后再次读取仓库并过滤收藏。对外返回不可修改列表，减少外部直接改写仓库集合的机会。

```text
main 创建 MemoryArticleRepository
  → 构造时初始化样例文章
  → await load()
  → 模拟异步等待后返回列表快照
  → 打印初始收藏数量
  → setFavorite(id: 1, value: true)
  → copyWith 创建更新后的 Article，替换仓库中的对应元素
  → await load() 读取当前内存数据
  → where 过滤收藏，map 取标题，toList 得到结果
```

在仓库根目录运行：

```powershell
dart run assets/flutter/dart-basics/favorites_demo.dart
```

本机实际输出：

```text
before=1
after=[Dart basics, Flutter widgets]
old snapshot favorite=false
handled=Article not found
```

before 中第一篇文章仍然是未收藏，因为仓库替换的是元素引用，没有原地修改旧 Article；这一点同时依赖列表快照和模型字段不可变。若把模型改成可变对象，仅复制列表就不足以隔离元素变化。

所有权要分清：同一个仓库实例存活期间保留内存收藏；重新创建仓库会回到初始数据；关闭进程也会丢失。若多个页面需要共享，应由合适的上层持有并注入同一实例；若需要重启保留，则另加持久化。这个仓库没有通知机制，修改后不会自动让 Flutter UI 重建，还需要页面状态或状态管理层。

该示例刻意使用很小的同步业务操作；真实接口还要补充请求取消、重试、过期数据、并发修改、账号切换和错误映射，不能直接当成完整生产架构。

<a id="kotlin"></a>
###### 和 Kotlin 对照时最容易误解的地方

| Kotlin 经验 | Dart 写法或概念 | 差异 |
|---|---|---|
| val / var | final / var | final 不是深度不可变；var 也不是动态类型 |
| T?、?.、?:、!! | T?、?.、??、! | 语法相似，但不能假定全部类型提升规则相同 |
| 命名参数 a = 1 | 命名参数 a: 1 | Dart 定义时用 {} 标注命名参数 |
| data class | class、Record 或代码生成 | class 不自动拥有 copyWith 与值相等 |
| Unit | void / Future<void> | 用途可对照，但 Dart void 不是可随意读取的 Unit 单例值 |
| suspend、Deferred | async/await、Future | 没有自动等价的 Job 父子取消树 |
| Flow / SharedFlow / StateFlow | Stream 与相关库 | 不能默认同样的重放、背压和当前值语义 |
| Dispatchers.Default | 按需使用 Isolate | async 不切线程；isolate 隔离可变内存 |
| object 单例 | 顶层实例、static 字段、工厂缓存等 | 不同 isolate 不共享普通全局可变实例 |
| private 成员 | _member | 默认是库级私有，不是类级私有 |

<a id="interview"></a>
###### 面试可能怎么问

当前模块还没有独立面试笔记，先将简答保留在原文，避免再建一份重复资料。

| 问法 | 简答要点 | 详解 |
|---|---|---|
| final 与 const 有什么区别？ | 单次赋值与编译期常量；final 不冻结对象内容 | [变量](#variables) |
| late 是否解决了空安全？ | 它延后检查，未初始化就读仍会失败 | [变量](#variables) |
| required String? 可以传 null 吗？ | 可以，必须传参和允许 null 是两个维度 | [空安全](#null-safety) |
| factory 是单例吗？ | 不一定，由实现决定，可创建新实例、缓存实例或返回子类 | [构造](#classes) |
| Dart 的 _field 是类私有吗？ | 库私有；同一库内其他类可访问 | [接口与边界](#interfaces) |
| async 会把 CPU 计算放到后台吗？ | 不会，仍需区分事件排队与 isolate 并行 | [事件循环](#event-loop) |
| Future.wait 中一个失败会取消其他任务吗？ | 不会自动取消；eagerError 也只影响何时报告错误 | [并发](#future-concurrency) |
| Stream 是 StateFlow 吗？ | 不是，不能默认有当前值和历史重放 | [Stream](#stream) |

<a id="sources"></a>
###### 资料与验证范围

关键结论就近链接 Dart/Flutter 官方资料。2026-11-25 已读取变量、构造、异步、并发、模式和库文档；其他链接作为专题扩展入口。基础语法示例以本机 Dart 3.14.0 检查，未将新版本页面中的所有特性都用于本文。

2026-11-25 已将正文的 18 个 dart 代码块分别提取到独立文件，全部通过 dart analyze 并运行成功；异步顺序、Stream 事件和 Isolate 结果与文中说明一致。完整 favorites_demo.dart 也通过静态分析和运行，输出见综合例子。注释中的错误示范没有解除注释运行。

这些检查只覆盖 Windows 原生 Dart 命令行示例，不代表 Flutter 页面、Web 编译或真实网络/数据库场景已验证。未执行性能基准，也未将生成内容标为已掌握。
