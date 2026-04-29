# Java 面向对象

## 一句话总结

Java 面向对象核心包括封装、继承、多态、抽象类、接口、重载和重写。

## 背景 / 使用场景

- 通过类组织状态和行为。
- 通过继承和接口抽象共性。
- 通过多态降低调用方和具体实现的耦合。

## 核心概念

- 封装：隐藏内部实现，对外暴露稳定接口。
- 继承：子类复用父类非私有成员。
- 多态：父类引用指向子类对象，运行期执行子类实现。
- 抽象类：提取共性模板和部分实现。
- 接口：定义行为契约。

## 关键问题

- 重载和重写有什么区别？
- 抽象类和接口怎么选择？
- 为什么构造方法不能被重写？
- static 方法能不能被重写？
- 多态的必要条件是什么？

## 示例代码

```java
class Animal {
    void speak() {
        System.out.println("animal");
    }
}

class Dog extends Animal {
    @Override
    void speak() {
        System.out.println("dog");
    }
}

Animal animal = new Dog();
animal.speak();
```

## 常见坑

- 重载只看参数列表，不靠返回值区分。
- 重写要求方法名和参数列表一致。
- 子类重写方法访问权限不能比父类更小。
- 构造方法不能被继承，所以不能被重写。
- static 方法不具备运行期多态。

## 和相关知识的区别

- 抽象类侧重代码复用和模板。
- 接口侧重行为约束和解耦。
- 继承表达 is-a，接口更适合表达 can-do。

## 实战经验

- 优先组合，谨慎继承。
- 对外暴露接口，隐藏具体实现。
- Android 中回调、监听器、Adapter、Repository 都大量使用接口和多态。

## 面试可能怎么问

- Java 面向对象三大特性是什么？
- 重载和重写区别是什么？
- 抽象类和接口区别是什么？
- 多态的实现原理是什么？
- Java 为什么不支持类多继承？

## 延伸阅读

- Encapsulation
- Inheritance
- Polymorphism
- Abstract Class
- Interface
