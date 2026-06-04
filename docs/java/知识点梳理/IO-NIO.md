### Java IO / NIO 知识点清单

###### 内容概述

本文件记录 Java IO / NIO 的基础知识点，包括 IO 流分类、常用流、缓冲流、字符编码、资源关闭、File / Path / Files、RandomAccessFile，以及 BIO / NIO / AIO 等概念入口。

###### 使用场景

- Android 中读取 assets、raw、缓存文件、下载文件时会用到 IO 基础。
- 文件复制、日志落盘、图片/音视频缓存等场景需要区分字节流和字符流。
- 处理文本文件、配置文件、接口返回落盘时要关注字符编码和资源关闭。
- 大文件读写、断点续传或性能优化时，需要了解缓冲流、`RandomAccessFile`、`FileChannel` 和零拷贝等概念。

一级栏目导航：

- [IO 基础分类](#io-基础分类)
- [常用 IO 流](#常用-io-流)
- [缓冲流和资源关闭](#缓冲流和资源关闭)
- [字符编码和转换流](#字符编码和转换流)
- [文件 API](#文件-api)
- [BIO / NIO / AIO](#bio--nio--aio)
- [常见问题和易错点](#常见问题和易错点)
- [面试可能怎么问](#面试可能怎么问)

<a id="io-基础分类"></a>
###### IO 基础分类

- 输入流是从数据源读取数据，相当于读。
- 输出流是向目标位置写出数据，相当于写。
- 字节流按 `byte` 处理数据，适合所有类型文件，比如图片、视频、音频、压缩包、文本文件。
- 字符流按 `char` 处理数据，适合文本文件，本质上是字节流加字符编码转换。
- 字符流读取中文不乱码的前提是编码匹配；如果文件编码和读取编码不一致，字符流同样会乱码。
- 二进制文件不要用字符流处理，否则可能因为编码转换导致文件损坏。
- 按数据单位划分：字节流、字符流。
- 按流向划分：输入流、输出流。
- 按功能划分：节点流、处理流。
- 节点流直接连接数据源，比如文件、内存数组、管道。
- 处理流包装其他流，提供缓冲、对象序列化、数据类型读写、打印输出等增强能力。

<a id="常用-io-流"></a>
###### 常用 IO 流

| 类型 | 输入流 | 输出流 | 说明 |
| --- | --- | --- | --- |
| 文件字节流 | `FileInputStream` | `FileOutputStream` | 读写文件字节，适合二进制文件，也可以处理文本但要手动处理编码 |
| 字节数组流 | `ByteArrayInputStream` | `ByteArrayOutputStream` | 在内存字节数组中读写数据，常用于临时缓存、测试、网络数据转换 |
| 缓冲字节流 | `BufferedInputStream` | `BufferedOutputStream` | 包装字节流，减少底层读写次数 |
| 对象流 | `ObjectInputStream` | `ObjectOutputStream` | 对对象进行序列化和反序列化，相关细节见 [序列化.md](./序列化.md) |
| 基本数据流 | `DataInputStream` | `DataOutputStream` | 按 Java 基本类型读写数据，比如 `int`、`long`、`double` |
| 管道流 | `PipedInputStream` | `PipedOutputStream` | 线程之间通过管道传输字节数据 |

- `RandomAccessFile` 是独立的随机访问文件类，不属于 `InputStream` / `OutputStream` / `Reader` / `Writer` 四大流体系。
- `RandomAccessFile` 同时支持读和写，可以通过 `seek(long position)` 移动文件指针到指定位置。
- `RandomAccessFile` 按字节操作，适合固定格式文件、断点续传、修改文件中间某段内容等场景。
- `RandomAccessFile` 实现了 `DataInput`、`DataOutput`、`Closeable`，也可以通过 `getChannel()` 获取 `FileChannel`。
- `InputStream` 是字节输入流的抽象父类。
- `OutputStream` 是字节输出流的抽象父类。
- `Reader` 是字符输入流的抽象父类。
- `Writer` 是字符输出流的抽象父类。
- `FileReader` / `FileWriter` 是文件字符流，适合简单文本读写，但默认编码依赖运行环境。
- `BufferedReader` / `BufferedWriter` 是缓冲字符流，`BufferedReader` 常用 `readLine()` 按行读取。
- `InputStreamReader` / `OutputStreamWriter` 是字节流和字符流之间的转换桥梁，可以指定字符编码。
- `PrintWriter` 适合便捷文本输出，可以配合 `OutputStreamWriter` 指定编码。
- `StringReader` / `StringWriter` 用于字符串内容读写。
- `StringBufferInputStream` 已废弃，不建议继续使用；字符串读取优先考虑 `StringReader`，字符串转字节流优先考虑 `ByteArrayInputStream`。

常见创建方式：

```java
InputStream input = new FileInputStream("C:/java/hello.txt");
OutputStream output = new FileOutputStream("C:/java/hello.txt");

File file = new File("C:/java/hello.txt");
InputStream inputByFile = new FileInputStream(file);
OutputStream outputByFile = new FileOutputStream(file);
```

字节数组流构造方式：

```java
byte[] data = "hello".getBytes(StandardCharsets.UTF_8);

ByteArrayInputStream input = new ByteArrayInputStream(data);
ByteArrayInputStream rangeInput = new ByteArrayInputStream(data, 0, data.length);

ByteArrayOutputStream output = new ByteArrayOutputStream();
ByteArrayOutputStream sizedOutput = new ByteArrayOutputStream(1024);
```

<a id="缓冲流和资源关闭"></a>
###### 缓冲流和资源关闭

- 不带缓冲的流如果频繁单字节读写，会频繁访问底层资源，效率较低。
- 带缓冲的流会先把数据读到内存缓冲区，或先写到内存缓冲区，减少底层系统调用和实际读写次数。
- 缓冲流不能单独直接操作文件，通常需要包装基础流。
- `BufferedInputStream` / `BufferedOutputStream` 包装字节流。
- `BufferedReader` / `BufferedWriter` 包装字符流。
- 输出缓冲流写入后建议 `flush()` 或 `close()`，避免数据还停留在缓冲区。
- `close()` 会触发资源关闭，通常也会刷新输出缓冲区。
- 输入流没有 `flush()` 概念。
- 推荐使用 `try-with-resources` 自动关闭流，避免文件句柄泄漏。
- 读写大文件时优先使用缓冲区批量读写，不要只用 `read()` 单字节循环。

示例：

```java
try (
    BufferedInputStream input = new BufferedInputStream(new FileInputStream("source.dat"));
    BufferedOutputStream output = new BufferedOutputStream(new FileOutputStream("target.dat"))
) {
    byte[] buffer = new byte[8192];
    int len;
    while ((len = input.read(buffer)) != -1) {
        output.write(buffer, 0, len);
    }
}
```

控制台输入：

```java
BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
String line = reader.readLine();
```

<a id="字符编码和转换流"></a>
###### 字符编码和转换流

- 文本文件读写要明确字符编码，常见编码有 `UTF-8`、`GBK`、`ISO-8859-1`。
- 中文乱码通常是写入编码和读取编码不一致导致的。
- 字节流读取文本后，需要按正确编码转换成字符串。
- 字符流内部会做字节到字符、字符到字节的编码转换。
- `InputStreamReader` 可以把字节输入流转换成字符输入流。
- `OutputStreamWriter` 可以把字符输出流转换成字节输出流。
- 建议优先显式指定 `StandardCharsets.UTF_8`。
- `FileReader` / `FileWriter` 在部分 Java 版本中使用系统默认编码，跨系统时不够稳定。

示例：

```java
try (
    BufferedReader reader = new BufferedReader(
        new InputStreamReader(new FileInputStream("test.txt"), StandardCharsets.UTF_8)
    )
) {
    String line;
    while ((line = reader.readLine()) != null) {
        System.out.println(line);
    }
}
```

<a id="文件-api"></a>
###### 文件 API

- `File` 表示文件或目录路径，不代表文件内容本身。
- `File` 常用能力：判断是否存在、是否文件、是否目录、创建文件、创建目录、删除、重命名、列出目录内容。
- Windows 路径字符串中的反斜杠需要转义，比如 `"C:\\java\\hello.txt"`。
- Java 中也可以使用 `/` 表示路径分隔，Windows 通常也能识别，比如 `"C:/java/hello.txt"`。
- `Path` 是 NIO 中更现代的路径抽象。
- `Paths.get()` 可以创建路径对象；Java 11+ 也可以使用 `Path.of()`。
- `Files` 是 NIO 提供的文件工具类，常用于复制、移动、删除、读取、写入、遍历目录。
- `Files.copy()` 可以复制文件。
- `Files.readAllBytes()` 适合小文件，不适合一次性读取大文件；Java 11+ 可以使用 `Files.readString()` 读取文本小文件。
- `Files.newBufferedReader()` / `Files.newBufferedWriter()` 适合指定编码读写文本。
- `Files.walk()` 返回流式结果，使用后也需要关闭。
- `RandomAccessFile` 更偏底层文件读写工具，可以指定 `"r"`、`"rw"` 等模式打开文件，并通过文件指针控制读写位置。

<a id="bio--nio--aio"></a>
###### BIO / NIO / AIO

- Android 普通业务开发里很少直接手写 BIO / NIO / AIO 网络模型，更多是使用 `InputStream` / `OutputStream`、`File` / `Files`、`ContentResolver`、OkHttp 等上层 API。
- BIO 是同步阻塞 IO，调用读写方法时当前线程会等待结果，适合普通文件读写和简单通信。
- NIO 是面向缓冲区和通道的 IO，既包含 `Path` / `Files` / `FileChannel` 这类文件 API，也支持非阻塞网络模型。
- AIO 是异步 IO，提交读写任务后通过回调或 `Future` 获取完成结果，Android 日常开发中很少直接使用。
- 面试或源码阅读中知道三者差别即可：BIO 阻塞当前线程，NIO 可以配合 Selector 管理多个通道事件，AIO 由系统异步通知完成结果。
- 简单文件读写不需要强行使用 NIO，普通 IO 加缓冲流通常更直观。
- `Channel` 表示 NIO 的数据通道，用于连接文件、Socket 等数据源和缓冲区。
- `Buffer` 表示 NIO 的数据缓冲区，`Channel` 读写通常先经过 `Buffer`。
- `Selector` 用于监听多个非阻塞 `Channel` 的事件，主要见于服务端高并发网络模型，Android 日常很少直接使用。
- `FileChannel` 是 NIO 的文件通道，可以配合 `ByteBuffer` 读写文件。
- `ByteBuffer` 是最常见的字节缓冲区，用来保存准备读写的字节数据。
- `transferTo()` / `transferFrom()` 可以在通道之间传输数据，和零拷贝概念相关，了解即可。
- `MappedByteBuffer` 可以把文件映射到内存，适合大文件随机访问，Android 日常业务中不常直接使用。

<a id="常见问题和易错点"></a>
###### 常见问题和易错点

- IO 流会占用系统资源，尤其是文件句柄，必须关闭。
- `try-with-resources` 是关闭 IO 资源的首选写法。
- 追加写入时，`FileOutputStream` 或 `FileWriter` 构造方法的第二个参数传 `true`。
- 默认写入是覆盖原文件内容。
- 文本读写优先明确编码，不要依赖系统默认编码。
- 字节流不是不能读文本，而是读完后需要按正确编码转换。
- 字符流只能可靠处理文本，不适合图片、视频、压缩包等二进制文件。
- `available()` 不能当作完整文件长度使用，它只表示当前不阻塞可读取的字节数估计值。
- `skip()` 不保证一次跳过指定长度，必要时需要循环处理。
- `read(byte[])` 返回 `-1` 表示读取结束，返回值才是本次实际读取长度。
- `Reader.read(char[])` 同样要使用返回值判断实际读取字符数。
- `PrintWriter` 的部分写入方法不会直接抛出 `IOException`，需要关注 `checkError()`。
- 对象序列化要关注 `serialVersionUID`、`transient`、兼容性和安全风险。
- 大文件不要轻易使用 `Files.readAllBytes()` 一次性加载进内存。
- `Files.walk()`、`Stream<Path>` 这类返回流的 API 也需要关闭。
- Android 开发中，如果涉及 assets、raw、外部存储、ContentResolver，要结合 Android 存储模型理解，不要只按普通 Java 文件路径处理。

<a id="面试可能怎么问"></a>
###### 面试可能怎么问

- 输入流和输出流有什么区别？
- 字节流和字符流有什么区别？
- 为什么字符流读取中文不一定就不会乱码？
- 字节流能不能处理文本文件？
- 为什么图片、视频不能用字符流复制？
- 常见的字节输入流和字节输出流有哪些？
- 缓冲流为什么能提升性能？
- `flush()` 和 `close()` 有什么区别？
- 什么是 `try-with-resources`？
- `FileReader` / `FileWriter` 有什么编码问题？
- `InputStreamReader` / `OutputStreamWriter` 的作用是什么？
- `File`、`Path`、`Files` 有什么区别？
- `RandomAccessFile` 是什么类型？和普通 IO 流有什么区别？
- BIO、NIO、AIO 有什么区别？
- NIO 一定比 BIO 快吗？
- `Channel`、`Buffer`、`Selector` 大概分别是什么？
- Android 开发中为什么通常不直接手写 NIO 网络模型？
