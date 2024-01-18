# 编程思想 chr12 通过异常处理错误

## 基本概念

* Java使用异常来提供一致性的错误报告模型；且可集中错误处理；且任务代码与异常代码分割开来，易于理解和维护
* 虽然异常处理理论有**终止模型**、**恢复模型**两种，但恢复模型很难优雅地做到，∴并不实用，实际中大家都是转向使用终止模型代码
* 一个异常抛出后发生的两件事：① 使用new在堆上创建异常对象；② 异常处理机制开始接管流程（当前的执行流程被终止）
  * 异常对象创建后，会从当前环境中弹出对其的引用
  * 异常处理程序的任务是将程序从错误状态中恢复，以使程序能要么换一种方式运行，要么继续运行下去。
* 标准异常类均有两个ctor：① default ctor； ② 带字符串参数的ctor
  * 错误信息可以保存在异常对象内部或者用异常类的名称来暗示。
* Throwable是异常类型的根类
* catch异常时，try中抛出的是子类异常，但catch的是基类异常也是OK，但若catch子类异常和基类异常的子句同时存在时，应将基类catch子句放在后面避免“屏蔽”现象发生
* 异常情形是指阻止当前方法或作用域继续执行的问题。对于异常情形，所能做的就是从当前环境跳出，并且把问题提交给上一级环境。这就是抛出异常所发生的事情。
* 异常最重要的方面之一就是如果发生问题，它们将不允许程序沿着其正常的路径继续执行走下去。
  * 异常也允许我们强制程序停止运行，并告诉我们出现了什么问题，或者强制程序处理问题，并回到稳定状态。
* 各位置抛出异常，程序执行流程：**1.若catch(){}块中，如果有throw 语句，则，try{}catch(){} finally{}块之外的代码不执行；否则，执行。 2.try{}中有异常，则try块异常下面代码不执行。 3.finally{}中代码必执行。**

* try的三种形式
  * try-catch
  * try-finally
  * try-catcah-finally
  * catch可以省略，但**catch和finally语句不能同时省略！**



## 抛出异常 + 捕获异常

* 如果在方法内部出现了异常，这个方法将在抛出异常的过程中结束。要是不希望方法就此结束，可以在方法内设置一个try块来捕获异常。【**try块作用域后的语句即使在抛出异常后任会执行**】
* 抛出异常得到处理的地点就是异常处理程序，而且针对每种要捕获的异常，得准备相应的处理程序，其以catch关键字表示。

- 抛出异常（throw）：

```java
if( t==null )
  throw new NullPointerException(); // 异常对象用new创建于堆上
```

- 捕获异常（try+catch）：

```java
try {
  ...
} catch( Type1 id1 ) {
  // 处理Type1类型的异常代码
} catch( Type2 id2 ) {
  // 处理Type2类型的异常代码
}
```

1. 虽然上面的id1和id2在处理异常代码中可能用不到，但不能少，必须定义
2. 异常发生时，异常机制搜寻参数与异常类型相匹配的第一个catch子句并进入



## 创建自定义异常

* 可以自己定义异常类来表示程序中可能会遇到的特定问题
* 定义异常类，必须从已有的异常类继承，最好是选择意思相近的异常类继承。
* 对于异常来说，最重要的部分是类名。

创建**不带参数**ctor的自定义异常类：

```java
// 自定义异常类（default ctor）
class SimpleException extends Exception {}
------------------------------------------------------------

// 客户端代码
public class UseException {
  public void fun throws SimpleException {
    System.out.println( "Throw SimpleExcetion from fun" );
    throw new SimpleException();
  }

  public static void main( String[] args ) {
    UseException user = new UseException();
    try {
      user.fun(); 
    } catch( SimpleException e ) {
      System.out.println("Caught it !");
    }
  }
}
------------------------------------------------------------
// 输出
Throw SimpleExcetion from fun
Caught it !

```

创建**带参数**ctor的自定义异常类

```java
// 自定义异常类（有参ctor）
class MyException extends  Exception {
  public MyException() { }
  public MyException( String msg ) { super(msg); }
}
------------------------------------------------------------

// 客户端代码
public class UseException {
  
  pubilc static void f() throws MyException {
    System.out.println( "Throwing MyException from f()" )
    throw new MyException();
  }
  public static void g() throws MyException {
    System.out.println( "Throwing MyException from g()" )
    throw new MyException("Originated in g()");
  }

  publib static void main( String[] args ) {
    try {
      f();
    } catch( MyException e ) {
      e.printStackTrace( System.out );
    }

    try {
      g();
    } catch( MyException e ) {
      e.printStackTrace( System.out );
    }
  }

}
------------------------------------------------------------

// 输出
Throwing MyException from f()
MyException
      at ...
      at ...
Throwing MyException from g()
MyException: Originated in g() // 此即创建异常类型时传入的String参数
      at ...
      at ...

```

* Throwable类声明的printStackTrace(PrintWriter writer)方法将打印“**从方法调用处直到异常抛出处”的方法调用序列**到对应输出流中。

  默认版本e.printStackTrace();则信息将被输出到标准错误流。



## 异常说明

* 如果方法中产生了异常却没有处理，编译器会发现这个问题并提醒你，要么处理这个异常，要么就在异常说明中表明此方法将产生异常。

* **异常说明形式**：表示**这个方法可能抛出的异常**。

  ```java
  void f() throws TooBig,TooSmall,DivZero{//...
  ```

* 异常说明告诉了调用此方法的程序员其**可能抛出的异常。**



## 捕获所有异常

* 可以只写一个异常处理程序来捕获所有类型的异常

```java
try {
  ...
} catch( Exception e ) { // 填写异常的基类，该catch子句一般置于末尾
  ...
}

```

* **这将捕获所有异常，所以最好把它放在处理程序列表的末尾，以防它抢在其他处理程序之前先把异常捕获了。**
  * 因为Exception是与编程有关的所有异常类的基类。

Exception类型所持有的方法：

- String getMessage()
- String getLocalizedMessage()

------

- String toString()

------

- void printStackTrace()
- void printStackTrace( PrintStream )
- void printStackTrace( javo.io.PrintWriter )

注意：从下往上每个方法都比前一个提供了更多的异常信息！



## 栈轨迹

printStackTrace()方法所提供的**栈轨迹信息**可以通过getStackTrace()方法来Get，举例：

* 该方法将返回一个由栈轨迹中的元素构成的数组。

```java
try {
  throw new Exception();
} catch( Exception e ) {
  for( StackTraceElement ste : e.getStackTrace() )
    System.out.println( ste.getMethodName() );
}

```

这里使用getMethodName()方法来给出异常栈轨迹所经过的方法名！



## 重抛异常

* **重抛异常会把异常抛给上一级环境中的异常处理程序，同一个try块的后续catch子句将被忽略。**

```java
try {
  ...
} catch( Exception e ) {
  throw e;   // 重新抛出一个异常！
}

```

**若只是简单地将异常重新抛出，则而后用printStackTrace()显示的将是原异常抛出点的调用栈信息，而非重新抛出点的信息，欲更正该信息，可以使用fillInStackTrace()方法：**

* fillInStackTrace()方法将返回一个Throwable对象，它是通过**把当前调用栈信息填入原来那个异常对象而建立的。**

```java
try {
  ...
} catch( Exception e ) {
  throw (Exception)e.fillInStackTrace(); // 该行就成了异常的新发生地！
}

```



## 异常链

* 异常链：在捕获一个异常后抛出另一个异常，并希望将原始的异常信息保存下来！

解决办法：

1. 在异常的ctor中加入cause参数,cause即原始异常
2. 使用initCause()方法

注意：Throwable子类中，仅三种基本的异常类提供了待cause参数的ctor（Error、Exception、RuntimeException），其余情况只能靠initCause()方法，举例：

```java
class DynamicFieldsException extends Exception { }

public Object setField( String id, Object value ) throws DynamicFieldsException {

  if( value == null ) {
    DynamicFieldsException dfe = new DynamicFieldsException();
    dfe.initCause( new NullPointerException() ); 
    throw dfe;
  }

  Object result = null;
  try {
    result = getField(id);
  } catch( NoSuchFieldException e ) {
    throw new RuntimeException( e );
  }

}

```



## Java标准异常

![Java标准异常类体系](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/7/22/164c0fceb5a8199f~tplv-t2oaga2asx-watermark.awebp)

* 看这个图需要明确：程序员一般关心Exception基类型的异常

* 由图中可知，Error、RuntimeException都叫做“Unchecked Exception”，即**不检查异常**，程序员也**无需写异常处理的代码，这种异常属于错误，将被自动捕获，不用亲自动手。**

  * Error用来表示**编译时和系统错误，一般用户无法处理也无需处理。**

  * 也无需在方法声明中写异常说明

    ```java
    public static void f(){
        throw new RuntimeException();
    }
    ```

* 若诸如RuntimeException这种Unchecked异常没有被捕获而直达main()，则程序在退出前将自动调用异常的printStackTrace()方法

* 只能在代码中忽略RuntimeException【及其子类】类型的异常，**其他类型异常的处理都是由编译器强制实施的**。究其原因，RuntimeException代表的是**编程错误。**

* **非运行时异常（编译异常）【**可查的异常（checked exceptions）**】** 包括：**RuntimeException以外的异常**，类型上都属于Exception类及其子类。从程序语法角度讲是**必须进行处理的异常**，如果不处理，程序就不能编译通过。如IOException、SQLException等以及用户自定义的Exception异常，**一般情况下不自定义检查异常**

  

## 使用finally进行清理

* 异常处理机制会在跳到更高一层的异常处理程序之前，执行finally子句。【无论是否抛异常都会执行】

```java
try {
  ...
} catch(...) {
  ...
} finally { // finally子句总是会被执行！！！
  ...
}

```

使用时机：

- 当需要把内存之外的资源（如：文件句柄、网络连接、某个外部世界的开关）恢复到初始状态时！

```java
try {
  ...
} catch(...) {
  ...
} finally { // finally子句总是会被执行！！！
  sw.off(); // 最后总是需要关掉某个开关！
}

```

- 在return中使用finally

```java
public static void func( int i ) {
  
  try {
    if( i==1 )
      return;
    if( i==2 )
      return;
  } finally {
    print( "Performing cleanup!" ); // 即使上面有很多return，但该句肯定被执行
      //若finally 中有return 则return会被覆盖
  }

}

```



### 异常丢失

finally存在的缺憾：两种情况下的finally使用会导致**异常丢失**！

* 前一个异常还未处理就抛出下一个异常

```java
// 异常类
class VeryImportantException extends Exception {
  poublic String toString() {
    return "A verfy important exception!";
  }
}

class HoHumException extends Exception {
  public String toString() {
    return "A trivial exception!";
  }
}
------------------------------------------------------------------
// 使用异常的客户端
public class LostMessage {
  void f() throws VeryImportantException {
    throw new VeryImportantException();
  }

  void dispose() throws HoHumException {
    throw new HoHumException();
  }

  public static void main( String[] args ) {
    try {
      LostMessage lm = new LostMessage();
      try {
        lm.f();
      } finally {
        lm.dispose(); // 最后只会该异常生效，lm.f()抛出的异常丢了！
      }
    } catch( Exception e ) {
      System.out.println(e);
    }
  }
}
-----------------------------------------------------------------
// 输出
A trivial exception!

```

- finally子句中的return

```java
public static void main( String[] args ) {
  try {
    throw new RuntimeException();
  } finally {
    return; // 这将会掩盖所有的异常抛出
  }
}

```



## 继承基类、实现接口时的异常限制

```java
// 异常类
class A extends Exception { }
class A1 extends A { }
class A2 extends A { }
class A1_1 extends A1 { }

class B extends Exception { }
class B1 extends B { }
-------------------------------------------------
// 用了异常类的基类
abstract class Base {
  public Base() throws A { }
  public void event() throws A { }                   // (1)
  public abstract void atBat throws A1, A2;
  public void walk() { }
}
-------------------------------------------------
// 用了异常类的接口
interface Interf {
  public void event() throws B1;
  public void rainHard() throws B1;
}
-------------------------------------------------
// 继承基类并实现接口的客户端类
public class Ext extends Base implements Interf {

  public Ext() throws B1, A { }            // (2)
  public Ext( String s ) throws A1, A {}   // (2)
  public void walk() throws A1_1 { }       // (3) 编译错误！
  public void rainHard() throws B1 {}      // (4)
  public void event() { }                  // (5)
  public void atBat() throws A1_1 { }      // (6)

  public static void main( String[] args ) {
  
    try {
      Ext ext = new Ext();
      ext.atBat();
    } catch( A1_1 e ) {
      ...
    } catch( B1 e ) {
      ...
    } catch( A e ) {
      ...
    }

    try {
      Base base = new Ext();
      ext.atBat();
    } catch( A2 e ) { // 这里的catch必须按照Base中函数的异常抛出来写
      ...
    } catch( A1 e ) {
      ...
    } catch( B1 e ) {
      ...
    } catch( A ) {
      ...
    }
    
  }
}


```

上面的例子可以总结如下：【注意对应数字标号】

- (1) 基类的构造器或者方法声明了抛出异常，但实际上没有抛出，这里相当于为继承类写了一个异常抛出规范，子类实现时安装这个规范来抛异常
- (2) 从这两个ctor看出：异常限制对ctor不生效，子类ctor可以抛出任何异常而不管基类ctor所抛出的异常，但是子类ctor的异常说明必须包含基类ctor的异常说明
- (3) 基类函数没抛异常，派生类重写时不能瞎抛！
- (4) 完全遵守基类的抛出，正常情况
- (5) 基类函数抛了异常，派生类重写时不抛也是OK的
- (6) 派生类重写基类函数时抛的异常可以是基类函数抛出异常的子类型



## 构造器中异常如何书写

对于在构造阶段可能会抛出异常并要求清理的类，安**全的方式是使用嵌套的try子句：即在创建需要清理的对象之后，立即进入一个try-finally块，举例：**

特别需要注意的是下面的例子里**在ctor中对文件句柄的close**应放置的合理位置！

```java
// 需要清理的对象类
class InputFile {
  private BufferedReader in;
  
  InputFile( String fname ) throws Exception {  // 构造函数！
    try {
      in = new BufferedReader( new FileReader(fname) );
      // 这里放置可能抛出异常的其他代码
    } catch( FileNotFoundException e ) { // 若上面的FileReader异常，将会抛FileNotFoundException，走到这里，该分支无需in.close()的
      System.out.println( "Could not open " + fname );
      throw e;
    } catch( Exception e ) {
      // 走到这里其实说明in对象已经构建成功，这里是必须in.close()的
      try {
        in.close();   // 注意此处关闭动作单独用try进行保障
      } catch( IOException e2 ) {
        System.out.println("in.close() unsuccessful");
      }
      throw e;
    } finally {
      // 注意in.close() 不要在此处关闭，因为try中假如BufferedReader构造失败，此时in对象未生成成功，是无需close()一说的！
    }
  }

  String getLine() {
    String s;
    try {
      s = in.readLine();
    } catch( IOException e ) {
      System.out.println( "readLine() unsuccessful!" );
      s = "failed";
    }
    return s;
  }

  void cleanup() {  // 提供手动的关闭文件句柄的操作函数
    try {
      in.close();
    } catch( IOException e ) {
      System.out.println( "in.close() failed !" );
    }
  }

}
----------------------------------------------------
// 客户端代码
public class Cleanup {

  public static void main( String[] args ) {
    
    try {
      InputFile in = new InputFile( "Cleanup.java" );
      try { // 上面InputFile构造完成以后立即进入该try-finally子句！
        String s = "";
        int i = 1;
        while( (s = in.getLine()) != null )
          System.out.println(""+ i++ + ": " + s);
      } catch( Exception e ) {
        e.printStackTrace( System.out );
      } finally {  // 该finally一定确保in能正常cleanup()！
        in.cleanup();
      } 
    } catch( Exception e ) {
      System.out.println( "InputFile ctor failed!" );
    }

  } // end main()
}


```



## 其他资料

try  return  finally  的详细解释文档:

https://www.nowcoder.com/test/question/done?tid=48397747&qid=4344#referAnchor
