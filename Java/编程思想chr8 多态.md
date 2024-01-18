# 《 Java 编程思想》CH08 多态

https://juejin.cn/post/6871890430284267534

https://juejin.cn/post/6844904067622240269

https://blog.csdn.net/weixin_41066529/article/details/89674359

## 多态

多态分为编译时多态和运行时多态:

* 编译时多态主要指方法的重载。根据实际参数的数据类型、个数和次序，Java在编译时能够确定执行重载方法中的哪一个。
* 运行时多态指程序中定义的对象引用所指向的具体类型在运行期间才确定

* 在面向对象的程序设计语言中，多态是继数据抽象和继承之后的第三种基本特征。

* 多态通过分离做什么和怎么做，从另一个角度将接口和实现分离开来。

* “封装”通过合并特征和行为来创建新的数据类型。“实现隐藏”则通过将细节“私有化”把接口和实现分离开来，而多态的作用则是消除类型之间的**耦合关系**。

  

## 再论向上转型 & 转机



* 对象既可以作为它自己本身的类型使用，也可以作为它的基类使用，而这种把某个对象的引用视为其基类的引用的做法被称为“向上转型”
  * 从导出类向上转型到基类可能会”缩小“接口，但不会比基类的全部接口更窄
* 将一个方法调用同一个方法主体关联起来被称为绑定。
  - 若在程序执行前进行绑定（如果有的话，由编译器和链接器实现），叫做**前期绑定**。[static方法]
  - 若在运行时根据对象的类型进行绑定，则叫做**后期绑定**，也叫做**动态绑定**或**运行时绑定**。【Java 就是根据它自己的后期绑定机制，以便在运行时能够判断对象的类型，从而调用正确的方法】

- Java 中除了 static 方法和 final 方法（private 方法属于 final 方法）外，其他所有方法都是后期绑定的。

  - static方法是与类，而并非与单个的对象相关联的【**那就是如果某个方法是静态的，那么它的行为就不具有多态性。**】

    ```java
    class StaticSuper {
    
        public static void staticTest() {
            System.out.println("StaticSuper staticTest()");
        }
    
    }
    
    class StaticSon extends StaticSuper{
    
        public static void staticTest() {
            System.out.println("StaticSon staticTest()");
        }
    
    }
    
    class StaticTest {
        public static void main(String[] args) {
            StaticSuper sup = new StaticSon();
            sup.staticTest();
        }
    }
    /* OUTPUT
    StaticSuper staticTest()
    */
    
    ```

    

  - final方法不会被重写无需动态绑定，编译器会为其调用生成更有效的方法

- Java 用动态绑定实现了多态后，我们可以只编写与基类相关的代码，而这些代码可以对所有该基类的导出类正确运行。

- 在一个设计良好的 OOP 程序中，大多数或所有方法都只与基类接口通信。这样的程序是可扩展的，因为可以从通用的基类继承出新的数据类型，从而新添加一些功能。

- 多态是一项让程序员“将改变的事物与未变的事物分离开来”的重要技术

- **由于 final 方法是无法覆盖的，所以 private 也是无法覆盖的**，因此没办法进行动态绑定。即只有非 private 方法可以覆盖，但是“覆盖”private 方法编译器不会报错【重写的方法头上可以标注`@Override`注解，如果不是重写的方法，标注`@Override`注解就会报错】，但运行结果往往与预期不符：

  所以在导出类中，对于基类中的private方法，最好采用不同的名字。

```java
package com.company.ch08;

public class PrivateOverride {
    private void func() {
        System.out.println("private func()");
    }

    public static void main(String[] args) {
        PrivateOverride privateOverride = new Derived();
        privateOverride.func();
    }
}

class Derived extends PrivateOverride {
    public void func() { // 这里其实没有覆盖。
        System.out.println("Derived func()");
    }
}
// private func()
```

* 只有普通的方法调用可以是多态的。**域是没有多态的，直接访问某个域，这个访问就将在编译期进行解析。**
  * 通常会将域设置成private，因此不能直接访问他们。
  * 通常不会将基类中的域和导出类中的域赋予相同的名字，这种做法容易令人混淆

```java
class Super{
    public int field = 0;
    public int getField(){
        return field;
    }
}
class Sub extends Super{
    public int field = 1;
    public int getField() { return field;}
    public int getSuperField() {return super.field;}
}
public class FieldAccess {
    public static void main(String[] args) {
        Super sup = new Sub();
        System.out.println(sup.field); //0
        System.out.println(sup.getField()); //1
    }
}
```



## 构造器和多态



**构造器不具有多态性**，它们实际上是 static 方法，只不过该 static 是隐式声明的。



### 构造器的调用顺序



- 基类的构造器总是在导出类的构造过程中调用，而且按照继承层次逐渐向上链接，以使每个基类的构造器都能得到调用。【确保对象被正确地构造。】
- 在导出类的构造器主体中，如果没有明确指定调用某个基类构造器，它会默默地调用默认构造器。如果不存在默认构造器，编译器就会出错（如果某个类没有任何构造器，则编译器会给他添加一个默认构造器）

构造器的调用顺序：

1. 调用基类构造器。【反复递归，首先构造层次结构的根，然后是下一层导出类，直到最底层的导出类】
2. 按照声明顺序调用成员的初始化方法。
3. 调用导出类的构造器的主体。

【保证在构造器内部，确保所有要使用的成员已经构建完毕】



### 继承与清理



Java 中通常不需要考虑清理的问题，垃圾回收机制会解决大部分问题，但是如果真的需要进行清理操作时，我们需要手动调用某个特定的函数进行清理操作。因为继承的原因，我们在覆盖基类的清理函数时，需要调用基类版本的清理函数。通常在导出类清理函数的末尾。同时如果成员对象也有需要清理的话，也需要在清理函数中调用该成员的清理函数。调用的原则就是：**清理的顺序应该与初始化的顺序相反**。【**对于字段，则意味着与声明的顺序相反（后定义的可能依赖先定义的，所以先清理后定义的**】



### 构造器内部的多态方法的行为：

如果在一个构造器的内部调用正在构造的对象的某个动态绑定方法，会发生什么？

```java
package com.company.ch08;

class Glyph {
    void draw() {
        System.out.println("Glyph.draw()");
    }
    Glyph() {
        System.out.println("Glyph() before draw()");
        draw();
        System.out.println("Glyph() after draw()");
    }
}

class RoundGlyph extends Glyph {
    private int radius = 1;
    RoundGlyph(int r) {
        radius = r;
        System.out.println("RoundGlyph.RoundGlyph(), radius = " + radius);
    }

    @Override
    void draw() {
        System.out.println("RoundGlyph.draw(), radius = " + radius);
    }
}

public class PolyConstructors {
    public static void main(String[] args) {
        new RoundGlyph(5);
    }
}
// Glyph() before draw()
// RoundGlyph.draw(), radius = 0
// Glyph() after draw()
// RoundGlyph.RoundGlyph(), radius = 5
```

从上面的输出可以看出，在基类中调用动态方法，的确会调用到对应导出类的方法，**但是导出类的域却未完成初始化。**【整个对象只是部分形成】

### 初始化实例的过程：

1. 在其他任何事物发生之前，将分配给对象的存储空间初始化成二进制的零
2. 调用基类构造器
3. 按声明顺序调用成员的初始化方法
4. 调用导出类的构造器方法。

编写构造器有一条准则：用尽可能简单的方法使对象进入正常状态，如果可以的话，避免调用其他方法。

在构造器内唯一能够安全调用的那些方法是基类中 final 方法（private 方法属于 final 方法），这些方法不会被覆盖。



**初始化过程：** 

**1.** **初始化父类中的静态成员变量和静态代码块** **；** 

**2.** **初始化子类中的静态成员变量和静态代码块** **；** 

**3.初始化父类的普通成员变量和代码块，再执行父类的构造方法；**

**4.初始化子类的普通成员变量和代码块，再执行子类的构造方法；** 



## 协变返回类型

Java SE5 中添加了协变返回类型，它表示**在导出类中的被覆盖方法可以返回基类方法的返回类型的某种导出类型。**

```java
package com.company.ch08;

class Grain {
    @Override
    public String toString() {
        return "Grain";
    }
}

class Wheat extends Grain {
    @Override
    public String toString() {
        return "Wheat";
    }
}

class Mill {
    Grain process() {
        return new Grain();
    }
}

class WheatMill extends Mill {
    @Override
    Wheat process() { // 关键在这里，原本返回类型应该是 Grain，而这里使用了 Grain 的导出类 Wheat
        return new Wheat();
    }
}

public class CovariantReturn {
    public static void main(String[] args) {
        Mill mill = new Mill();
        Grain grain = mill.process();
        System.out.println("grain = " + grain);
        mill = new WheatMill();
        grain = mill.process();
        System.out.println("grain = " + grain);
    }
}
// grain = Grain
// grain = Wheat
```



## 用继承进行设计

我们应该首先选择“组合”，尤其是不能十分确定应该使用哪种方法时。组合不会强制我们的程序谁叫进入继承的层次结构。而且，组合更加灵活，他可以动态选择类型。相反，继承在编译时就需要知道确切类型

```java
package com.company.ch08;

class Actor {
    public void act() {}
}

class HappyActor extends Actor {
    @Override
    public void act() {
        System.out.println("HappyActor");
    }
}

class SadActor extends Actor {
    @Override
    public void act() {
        System.out.println("SadActor");
    }
}

class Stage {
    private Actor actor = new HappyActor();
    public void change() {
        actor = new SadActor();
    }
    public void performPlay() {
        actor.act();
    }
}

public class Transmogrify {
    public static void main(String[] args) {
        Stage stage = new Stage();
        stage.performPlay();
        stage.change();
        stage.performPlay();
    }
}
// HappyActor
// SadActor
```

我们通过在运行时将引用与不同的对象重新绑定起来，可以让我们在运行期间获得动态灵活性（也称为“状态模式”）。【于此相反，我们**不能在运行期间决定继承不同的对象，因为它要求在编译期间完全确定下来**】

通用准则：**继承表示行为间的差异，字段表示状态上的变化**。



### 纯继承与扩展

- is-a 关系（纯继承）：只覆盖在基类中已有的方法，不对其进行扩展
  - 导出类和基类有完全相同的接口。
  - 只需要从导出类向上转型，永远不需要知道正在处理的对象的确切类型
- is-like-a 关系：对基类进行了扩展
  - **导出类接口中扩展部分不能被基类访问。【一旦向上转型，就不能调用那些新方法】**



### 向下转型与运行时类型识别

* 向上转型会丢失具体的类型信息，可以通过向下类型获取类型信息【用于向上转型后访问扩展接口】
  * 向上转型是安全的，基类不会具有大于导出类的接口
  * 必须保证向下转型的正确性，因为导出类可能具有大于基类的接口且（有多种确切的类型）

* 在 Java 中，**所有转型都会得到检查。即使我们只是进行一次普通的加括弧形式的类型转换，在进入运行期时仍然会对其进行检查**，如果不是我们想要转换的类型，那么会返回一个 ClassCastException。
  * 这种在运行期间对类型进行检查的行为称为**“运行时类型识别”(RTTI)**
  * RTTI的内容不仅仅包括转型处理。它还提供一种方法，使你可以在试图向下转型之前，查看你所要处理的类型。





## **为什么要用多态呢？**

原因：我们知道，封装可以隐藏实现细节，使得代码模块化；继承可以扩展已存在的代码模块（类）；它们的目的都是为了——代码重用。而多态除了代码的复用性外，还可以解决项目中紧偶合的问题,提高程序的可扩展性.。耦合度讲的是模块模块之间，代码代码之间的关联度，通过对系统的分析把他分解成一个一个子模块，子模块提供稳定的接口，达到降低系统耦合度的的目的，模块模块之间尽量使用模块接口访问，而不是随意引用其他模块的成员变量。

 

## 多态有什么好处？

有两个好处：

1. 应用程序不必为每一个派生类编写功能调用，只需要对抽象基类进行处理即可。大大提高程序的可复用性。//继承 
2. 派生类的功能可以被基类的方法或引用变量所调用，这叫向后兼容，可以提高可扩充性和可维护性。 //多态的真正作用，

 

## 多态在什么地方用？

* 可以用在方法的参数中和方法的返回类型中。
