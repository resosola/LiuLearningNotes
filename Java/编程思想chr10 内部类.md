# 编程思想第10章 内部类

* 可以将一个类的定义放在另一个类中的定义内部，这就是内部类

## 内部类的作用

* 内部类的方法可以访问该类定义所在作用域中的数据

* 内部类可以对同一包中的其他类隐藏起来。

* 内部类可以实现 java 单继承的缺陷

* 当我们想要定义一个回调函数却不想写大量代码的时候我们可以选择使用匿名内部类来实现

  

## 内部类

* 静态成员内部类【嵌套类】
  * 静态内部类和非静态内部类的差别：
    * 静态内部类可以有静态成员，而非静态内部类则不能有静态成员。
    * 静态内部类可以访问外部类的静态变量，而不可访问外部类的非静态变量；
    * 非静态内部类的非静态成员可以访问外部类的非静态变量。
    * 静态内部类的**创建不依赖于外部类**，而**非静态内部类必须依赖于外部类的创建而创建**。
* 非静态成员内部类：此**内部类对象必定会秘密地捕获一个指向那个外围类对象的引用**
* 局部内部类：
  * 也可以引用成员变量，但此成员变量必须声明为final，并内部不允许修改值，对于局部变量也是同样的。
  * 作用域局限再创建这个类的方法中
  * 不允许使用访问权限修饰符 public private protected 均不允许
* 匿名内部类：
  * 匿名内部类必须继承一个抽象类或者实现一个接口
    * 与局部内部类相同匿名内部类也可以引用局部变量。此变量也必须声明为 final。【编译器为自动地帮我们在匿名内部类中**创建了一个局部变量的备份**，final为了保持局部变量与匿名内部类中备份域保持一致。】



## 内部类可能引起的内存泄漏问题

* 只要内部类被外部类以外的变量持有，**即使没有外部类对象被引用，外部类就不会被GC回收**。我们要尤其注意内部类被外面其他类引用的情况，这点导致**外部类无法被释放**，极容易导致**内存泄漏**。



## 典型内部类

* 当生成一个内部类对象时，此对象与制造它的外围对象之间就有了一种联系，所以它能访问其外围对象的所有成员，而不需要任何特殊条件，**此外内部类还拥有其外围类所有元素的访问权。**
* 鉴于这个特性可以在多个内部类之间共享外围类元素，而多个内部类可能继承或实现同一抽象接口，对于外部客户端程序这些内部类看似游离独立，实则互相关联。
* 当某个外围类的对象创建了一个内部类对象时，此**内部类对象必定会秘密地捕获一个指向那个外围类对象的引用**，然后在你访问外围类成员时，就是用那个引用来选择外围类成员。编译器会帮你处理所有的细节，内部类的对象只能在与其外围类的**对象**相关联的情况下才能被创建（**不允许这个内部类是static类，这种就称为嵌套类**）。
* 普通内部类不能有static数据和static字段（不能有任何独立于外围类对象的成分），也不能包含嵌套类。
* 一个内部类被嵌套多少层并不重要，它能够透明地访问所有它所嵌入的外围类的所有成员。
* private内部类给类的设计者提供了一种途径，组合向上转型，可以完全阻止任何**依赖于类型**的编码，并且完全隐藏了实现的细节。【内部类一某个接口的实现一能够完全不可见，并且不可用。所得到的只是指向基类或接口的引用，能够很方便地隐藏实现细节】

```java
interface Selector {
    boolean ene();
    Object current();
    void next();
}

public class Sequence {
    private Object[] item;
    private int next = 0;
    public Sequence(int size) {
        items = new Object[size];
    }
    public void add(Object x) {
        if (next < items.length) {
            items[next++] = x;
        }
    }
    
    private class SequenceSelector implements Selector {
        private int i= 0;
        public boolean end() {
            return i == items.length;
        }
        public Object current() {
            return items[i];
        }
        public void next() {
            if (i < items.length) {
                i++;
            }
        }
    }
    
    public Selector selector() {
        return new SequenceSelector();
    }
    
    public static void main(String[] args) {
        Sequence sequence = new Sequence(10);
        for(int i = 0; i < 10; i++) {
            sequence.add(Integer.toString(i));
        }
        Selector selector = sequence.selector();
        while(!selector.end()) {
            System.out.println(selector.current() + " ");
            selector.next();
        }
    }
}

```

* 如果不是外围类内部方法创建内部类，需要使用OuterClassObject.new InnerClassName()语法。

  ```java
  public class DotNew {
      public class Inner {}
      public static void main(String[] args) {
          DotNew dn = new DotNew();
          DotNew.Inner dni = db.new Inner();
      }
  }
  
  ```

* 如果是外部程序想通过内部类对象返回外围类对象引用，可以用OuterClassName.this语法。

```java
public class DotThis {
    void f() {}
    public class Inner {
        public DotThis outer() {
            return DotThis.this；
        }
    }
    public Inner inner() {
        return new Inner();
    }
    public static void main(String[] args) {
        DotThis dt = new DotThis();
        DotThis.Inner dti = dt.inner();
        dti.outer().f();
    }
}

```



## 局部内部类

在**方法的作用域**内（而不是在其他类的作用域内）创建**一个完整的类**，这被称作局部内部类。其实就是把class定义放置在方法内部，甚至可以定义在if等作用域内。

* 在定义局部内部类地作用域之外，它是不可用的

使用局部内部类而不是匿名内部类的场景：

- 需要一个已命名的构造器，或者需要重载构造器。
- 需要不止一个该内部类的对象。



## 匿名内部类

* 类似局部内部类，但这个类没有自己的类名，直接向上转型并返回。

```java
public class Parcel7 {
    public Contens contents() {
        return new Contents() {
            private int i = 1l;
            public int value() {
                return i;
            }
        }; // Semicolon required in this case;
    }
    public static void main(String[] args) {
        Parcel7 p = new Parcel7();
        Contents c = p.contents():
    }
}

```

* 如果定义一个匿名的内部类，并且希望它**使用一个在其外部定义的对象**，那么编译器会要求其参数引用是final的。
* **局部变量的生命周期与局部内部类对象的生命周期不一致，将final局部变量复制一份，复制品直接作为局部内部类对象的数据成员，final实现了变量在内外部的统一。**

```java
public class Parcel9 {
    public Destination destination(final Stirng dest) {
        return new Destination() { //使用基类的无参构造器来创建匿名内部类
            privatr String label = dest;//使用外部参数
            public String readLabel() {
                return label;
            }
        }
    }
    public static void main(String[] args) {
        Parcel9 p = new Parcel9();
        Destination p = p.destination("Tss");
    }
}

```

* 匿名内部类中不可能有命名的显式构造器，此时只能使用实例初始化的方式来模仿，举例（当然下面这个例子还反映了匿名内部类如何参与继承）：

```java
// 基类
---------------------------------------------
abstact class Base() {
  public Base( int i ) {
    print( "Base ctor, i = " + i );
  }
  public abstract void f();
}

//主类（其中包含了继承上面Base的派生匿名内部类！）
----------------------------------------------
public class AnonymousConstructor {
  
  public static Base getBase( int i ) { // 该处参数无需final，因为并未在下面的内部类中直接使用！
    return new Base(i){ // 匿名内部类
      { // 实例初始化语法！！！
        print("Inside instance initializer");
      }
        // 实现方法 【也可重写方法】
      public void f() { 
        print( "In anonymous f()" );
      }
    }; // 分号必须！
  }

  public static void main( String[] args ) {
    Base base = getBase(47);
    base.f();
  }
}

// 输出
------------------------------------------
Base ctor, i = 47 // 先基类
Inside instance initializer // 再打印派生类
In anonymous f()

```



## 嵌套类

如果不需要内部类对象与其外围类对象之间有联系，那么可以将内部类声明为static，这被称为嵌套类。

- 要创建嵌套类的对象，并不需要其外围类的对象。
- 不能从嵌套类的对象中访问非静态的外围类对象（没有对象引用无法访问）。

正常情况下，不能在接口内部放置任何代码，但嵌套类可以作为接口的一部分，你放到接口中的任何类都自动地是public和static的，因为类是static的，只是将嵌套类置于接口的命名空间内，这并不违反接口的规则，你甚至可以在内部类中实现其外围接口。

如果你想要创建某些公共代码，使得它们可以被某个接口的所有不同实现所共用，那么使用接口内部的嵌套类会显得很方便。

```java
public interface ClassInInterface {
    void howdy();
    class Test implements ClassInInterface {
        public void howdy() {
            System.out.println("Howdy!");
        }
        public static void main(String[] args) {
            new Test().howdy();
        }
    }
}

```



## 为什么需要内部类

* 一般说来，内部类继承自某个类或实现某个接口，内部类的代码操作创建它的外围类的对象。所以可以认为内部类提供了某种进入其外围类的窗口

* 内部类可以独立地继承自一个接口或者类而无需关注其外围类的实现，这使得扩展类或者接口更加灵活，控制的粒度也可以更细！
* 注意Java中还有一个细节：虽然Java中一个接口可以继承多个接口，但是一个类是不能继承多个类的！要想完成该特性，此时除了使用内部类来“扩充多重继承机制”，你可能别无选择，举例：

```java
class D {    // 普通类
    int b = 2;
}
abstract class E { // 抽象类
    int a = 1;
    public abstract void f();
}

class Z extends D {    // 外围类显式地完成一部分继承
    E makeE() {
        return new E() { // 内部类隐式地完成一部分继承
            @Override
            public void f() {
                // 内部类与外部类链接 访问外部类成员
                System.out.println(a);  // 1
                System.out.println(b);  // 2
            }
        };
    }
}

public class InnerClassTest {
    static void takesD( D d ) { }
    static void takesE( E e ) { e.f();}
    public static void main( String[] args ) {
        Z z = new Z();
        takesD( z );
        takesE( z.makeE() );
    }
}
```
