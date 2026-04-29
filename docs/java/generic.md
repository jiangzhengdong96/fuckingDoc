# Java 泛型

## 一句话总结

Java 泛型用于在编译期约束类型，提升类型安全和代码复用能力。

## 背景 / 使用场景

- 集合中约束元素类型。
- 工具类、Repository、Adapter 等需要复用类型逻辑。
- API 返回值需要保留类型信息。

## 核心概念

- 泛型类：`class Box<T>`
- 泛型方法：`<T> T getValue()`
- 泛型接口：`interface Repository<T>`
- 上界：`<? extends T>`
- 下界：`<? super T>`
- 类型擦除：泛型主要在编译期生效，运行期类型信息会被擦除。

## 关键问题

- 泛型解决了什么问题？
- 什么是类型擦除？
- `List<Object>` 和 `List<String>` 是什么关系？
- `? extends T` 和 `? super T` 有什么区别？
- 为什么不能直接 `new T()`？

## 示例代码

```java
public class Box<T> {
    private T value;

    public void set(T value) {
        this.value = value;
    }

    public T get() {
        return value;
    }
}
```

## 常见坑

- `List<String>` 不是 `List<Object>` 的子类。
- 泛型数组创建受限制。
- 运行期不能直接判断 `obj instanceof List<String>`。
- `? extends T` 适合读取，`? super T` 适合写入。

## 和相关知识的区别

- 泛型是编译期类型约束，不等于运行期反射类型。
- 泛型和多态都能提升复用性，但泛型关注类型参数化，多态关注对象行为替换。

## 实战经验

- 集合使用时尽量明确泛型类型。
- 公共组件可以通过泛型减少重复代码。
- Android 中 Adapter、ViewModel 状态封装、网络响应包装经常会用到泛型。

## 面试可能怎么问

- Java 泛型为什么要类型擦除？
- 泛型擦除后如何保留类型？
- `extends` 和 `super` 通配符怎么选？
- 泛型方法和泛型类有什么区别？

## 延伸阅读

- Java Generics
- Type Erasure
- PECS: Producer Extends, Consumer Super
