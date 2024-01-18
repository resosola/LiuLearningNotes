# 编程思想chr14类型信息



## 为什么需要 RTTI

**一句话：因为我们确实需要在运行时获取类型信息。**

* RTTI，是 Run-Time Type Information 的缩写。为什么需要？因为在使用继承的时候，免不了将**类进行向上转型**，在转型后，我们就**不知道具体的类型**了。使用 RTTI 的作用就是，帮助我们**获取这个具体的类型**。
* 所有的类型转换都是在运行时进行正确性检查的。【即在运行时，识别一个对象的类型】

## 获取RTTI的途径

* 对象的Class对象，获取对象对应类的相关信息
* instanceof方法，检验对象是否从属于某个类。

##  Class对象

* 每个类都有一个 Class 对象，这个 Class 对象用于保存**这个类相关的信息**。其可表示类型信息在运行时是如何表示的。
* Class对象仅**在需要的时候才被加载**，static初始化是在类加载时进行的。



### 获取 Class 对象的方法

* 有三种。Class 类中的 ForName，类的 .class 字段(对于基本类型的包装类还有 TYPE 字段)，对象的 getClass 方法。【BTW，Boolean.class 不等于 Boolean.TYPE，boolean.class 才等于 Boolean.Type。】

* 使用 .class 类字面常量的时候，**初始化被推迟到了对静态方法或者非常数静态域（非 final 的静态变量【常数静态域在编译期即可读取】）进行首次引用时才进行。**其他的获取方法都会初始化。

  * 相比于ForName，.class类字面常量生成的class对象可以让编译器知道类引用的具体类型信息。

    ```java
         try {
                Class<? extends Pet> pet = (Class<? extends Pet>) Class.forName("Pet"); // 需要强转类型【编译器不知道类引用的具体类型信息】
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
    Class<? extends Pet> pet = Pet.class; // 编译器通过类引用的具体类型信息进行检查
    Class<? extends Pet> pet = Apple.class; // 无法通过编译
    ```

* Class的newInstance()方法可用来创建对象，且**必须带有默认构造器**。【返回Object，如有泛型约束则返回对应的类型】

  

### 泛化的 Class 引用

* 向Class引用添加泛型语法的原因**仅仅是为了提供编译期类型检查。**

* 允许对Class引用所指向的Class对象的类型进行限定，即可用泛型语法。

  ```java
  Class<Integer> intClass = int.class;
  //intClass  = double.class; // Illegal
  Class class1 = int.class; // 普通的类引用可以指向任何其他的Class对象
  ```

* 也可使用通配符【？表示任何事物】让Class引用泛化。

  ```java
  Class<?> intClass = int.class;
  //Class<?>等价Class 但优于平凡的Class
  ```

  * Class<?>的**好处就是它表示你并非是碰巧或者由于疏忽，而使用了一个非具体的类引用，你就是选择的非具体的版本。**
    * 其其newInstance()方法将返回对应限制的类型
  * 可以将类引用限定为某种类型、或该类型的任何子类，将通配符与extends结合

  ```java
  Class<? extends Father> extendClass = Son.class;
  ```

  ​		**其newInstance()方法将返回Father类型**

  * 可以将类引用限定为某种类型、或该类型的任何超类

  ```java
  Class<? super Son> superClass = Father.class;
  ```

  ​		**其newInstance()方法将返回Object类型**【因为无法知道是哪个超类】

  

### 新的转型语法

```java
Building b = new House();
Class<House> houseType = House.class;
House h = houseType.cast(b); // 新转型语法
h = (House)b; // 旧的转型语法
```

* cast()方法接受参数对象，并将其转型为Class引用的类型
* 新的转型语法对于无法使用普通转型的情况显得非常有用。



## **类型转换前先做检查**

* 迄今为止，已知的RTTI形式包括：1，传统的类型转换，2，代表对象类型的Class对象。

* 第三种形式 instanceof。返回一个布尔值，告诉我们**对象是否从属于某个类**

* instanceof有比较严格的限制：只可将其与命名类型进行比较，而不能与Class对象作比较。

* Class.isInstance方法也提供了动态测试对象的途径，其参数接受一个对象，与instance等价

* 如果使用 `equals` 和 `==` 来直接比较类的对象的时候，这和 instanceof 是有区别的。instanceof 保存了类的概念，但是 Class 对象的比较是没有类的概念的。我们有 `apple.getClass() != Food.class`，但是如果使用 instanceof 我们是可以得到 apple 确实是 food 的实例(instance)。

  

## **注册工厂**

* 使用工厂方法设计模式，将**对象的创建工作**交给**类自己去完成**。工厂方法可以**被多态地调用**，从而**创建恰当类型的对象**。



## **反射：运行时的类信息**

* 定义：使用 Class【在java.lang中】 和 java.lang.reflect 类库，可以**动态地获取类的信息以及动态调用对象方法**的机制称为java的反射机制，这个类库有 Field、Method、Constructor 类。
* 在需要使用类内部的属性、方法、构造器的时候，查查 Class 的文档，看看它提供的方法是否可以获取到想要的信息。



### 功能

* 在运行时判断任意一个对象所属的类；
* 在运行时构造任意一个类的对象；
* 在运行时判断任意一个类所具有的成员变量和方法；
* 在运行时调用任意一个对象的方法；
* 生成动态代理



### **反射机制作用**

* 动态**加载类**、动态**获取类的信息**（属性、方法、构造器）；
* **动态构造对象**；
* 动态**调用类和对象的任意方法、构造器**；
* 动态**调用和处理属性**；

* **获取泛型信息**（新增类型：ParameterizedType,GenericArrayType等）；

* **处理注解**（反射API:getAnnotationsdeng等）。



### 反射的性能问题

* 反射调用过程中会产生**大量的临时对象**，这些对象会占用内存，可能会**导致频繁 gc**，从而影响性能。
* 反射调用方法时会从方法数组中遍历查找，并且会检查**可见性等操作会耗时。**
* 反射一般会涉及**自动装箱/拆箱和类型转换**，都会带来一定的资源开销。
* void setAccessible(boolean flag):是否启用访问安全检查的开关，true屏蔽Java语言的访问检查，使得对象的私有属性也可以被查询和设置。**禁止安全检查，可以提高反射的运行速度。**
* 可以考虑使用：cglib/javaassist操作来提高性能。



## 动态代理

* 动态的实现一个接口，形成一个新的类，用这个类创建对象，调用对象方法。



### 使用方法

有点类似 AOP 的一个东西。书中进行讲了个用法的例子。

1. 我们需要实现一个 `InvocationHandler`，覆盖其中的 `invoke` 方法。当对象被调用的时候，就会进入这个方法
2. 创建被代理类的对象。
3. 使用 Proxy 的静态方法 newProxyInstance。传入需要的三个参数：classLoader, Class 数组, Handler。

```java
interface Interface {
    void doSomething();
    void somethingElse(String arg);
}


class RealObject implements Interface {

    public void doSomething() {
        System.out.println("do something");
    }

    public void somethingElse(String arg) {
        System.out.println("do something else: " + arg);
    }
}


class DynamicProxyHandler implements InvocationHandler {
    private Object proxied; //被代理类的对象

    public DynamicProxyHandler(Object proxied) {
        this.proxied = proxied;
    }

    public Object invoke(Object object, Method method, Object[] args) throws Throwable {
        if (method.getName() == "doSomething") {
            return null;
        }
        System.out.println("proxy...");
        return method.invoke(proxied, args); // invoke方法将请求转发给被代理对象
    }
}

public class SimpleDynamicProxy {
    public static void consumer(Interface iface) {
        iface.doSomething();
        iface.somethingElse("simple");
    }

    public static void main(String[] args) {
        RealObject real = new RealObject();
        consumer(real);

        Object proxy = Proxy.newProxyInstance(
                Interface.class.getClassLoader(), //从已被加载的对象中获取其类加载器
                new Class[] {Interface.class},  // 代理实现的接口列表
                new DynamicProxyHandler(real)
        );
        consumer((Interface) proxy); //对接口的调用被重定向为对代理的调用
    }
}
```



### 原理

也许你会好奇，当我们调用代理的方法的时候，我是怎么进入到 `invoke` 中的呢？

这涉及动态代理的实现原理。如果进入到 `Proxy.newProxyInstance` 去看一眼，不断地跟踪下去，就会发现，这个动态代理的类，是生成的！网上的一些讲解，都会**先产生一个字节码**，然后进行一下反编译，具体可以参考[1]

![img](https://img2020.cnblogs.com/blog/1616773/202012/1616773-20201202205323771-1005712528.png)



## 空对象

* 使用 null 可能带来一些不便，我们可以使用一个空对象来代替它，这样我们就可以避免了每次都去检查 null。

* 在很多地方，我们还是需要检查是否空对象，引入了空对象还是有一些好处的，比如 toString 方法就不需要检查了。
* **通常空对象都是单例。**

* 实现方法是，搞一个 Null 接口，然后实现一个静态内部类，用这个静态内部类创建一个空对象的单例模式。下面做出了简化。当需要搞一个空对象，使用 `Person.NULL`；当需要检查是否空对象，使用 `instanceof Null`。【由于使用单例，可以使用equals甚至==来与Person.NULL比较】
* 这一节讲的具有一定的启发性，但是在实际开发中，究竟该如何正确使用呢？这还需要多多实践看看。

```java
interface Null {}

class Person {
    public Person() {}
    private static class NullPerson extends Person implements Null {}
    public static final Person NULL = new NullPerson();
}

```



## 接口和类型信息

* interface关键字的一种重要目标就是**允许程序员隔离构件，进而降低耦合性。**
* 这一节，概括起来那就是，反射牛逼，任你怎么封装继承，都阻止不了反射获取内部信息。
* 对了，使用私有成员的时候，记得调用 `setAccessible(true)`，这样就可以获取类内部的任何信息啦。



## **总结**

* 面向对象编程语言的目的是让我们在凡是可以使用的地方都使用多态机制，只在必须的时候使用RTTI。



## 面试相关

* **Filed、Method Constructor分别分别用与描述类的与、方法和构造器。 在Java.lang.reflet包中而Class而是在Java.lang中**

