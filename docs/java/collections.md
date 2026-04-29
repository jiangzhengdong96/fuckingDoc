# Java 集合

## 一句话总结

Java 集合是用于组织和操作一组对象的标准 API，核心分为 `Collection` 和 `Map` 两条体系。

## 背景 / 使用场景

- 需要存储多个对象时使用集合。
- 需要按顺序访问时常用 `List`。
- 需要去重时常用 `Set`。
- 需要键值映射时常用 `Map`。
- 需要队列或优先级处理时常用 `Queue`。

## 核心概念

| 类型 | 常见实现 | 特点 |
|---|---|---|
| `List` | `ArrayList`、`LinkedList` | 有序、可重复 |
| `Set` | `HashSet`、`LinkedHashSet`、`TreeSet` | 不重复 |
| `Map` | `HashMap`、`LinkedHashMap`、`TreeMap`、`ConcurrentHashMap` | key-value |
| `Queue` | `ArrayDeque`、`PriorityQueue` | 队列或优先级队列 |

## 关键问题

- `ArrayList` 和 `LinkedList` 的区别是什么？
- `HashMap` 的底层结构是什么？
- `HashSet` 如何保证元素不重复？
- `HashMap` 为什么需要重写 `equals` 和 `hashCode`？
- `ConcurrentHashMap` 和 `HashMap` 的区别是什么？

## 示例代码

```java
List<String> list = new ArrayList<>();
list.add("Android");
list.add("Java");

Map<String, Integer> map = new HashMap<>();
map.put("Java", 1);
map.put("Kotlin", 2);
```

## 常见坑

- 遍历集合时直接删除元素容易触发 `ConcurrentModificationException`。
- 自定义对象作为 `HashMap` key 时，需要同时重写 `equals` 和 `hashCode`。
- `HashMap` 不是线程安全的，多线程写入要考虑 `ConcurrentHashMap`。
- `ArrayList` 适合随机访问，频繁头部插入删除不适合。

## 和相关知识的区别

- 数组长度固定，集合长度可动态变化。
- `Collection` 关注单值集合，`Map` 关注键值映射。
- `HashMap` 关注快速查询，`TreeMap` 关注 key 的排序。

## 实战经验

- 默认优先考虑 `ArrayList` 和 `HashMap`。
- 需要保持插入顺序时考虑 `LinkedHashMap`。
- 需要线程安全读写时优先考虑 `ConcurrentHashMap`。
- 需要不可变集合时，优先使用只读包装或不可变创建方式。

## 面试可能怎么问

- `HashMap` 的 put 流程是什么？
- `HashMap` 扩容机制是什么？
- `ArrayList` 扩容机制是什么？
- `HashMap` 和 `Hashtable` 有什么区别？
- `ConcurrentHashMap` 为什么线程安全？

## 延伸阅读

- `java.util.Collection`
- `java.util.Map`
- `java.util.HashMap`
- `java.util.concurrent.ConcurrentHashMap`
