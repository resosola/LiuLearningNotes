# RPC项目问题

简易RPC框架

项目描述：项目主要分为服务注册、服务发现、网络通信三大模块，服务注册模块是基于 Nacos 作为服务的注册中心，而服务发现模块则也是从Nacos中获取服务对应的地址并提供多种负载均衡算法，网络传输模块的实现基于Java原生Socket和Netty的版本，并自定义应用层协议且提供多种序列化机制。

特性：

- 通过基于NIO的Netty进行网络传输，解决了传统BIO
- 通过Netty的责任链封装编码器、解码器、数据处理器，对数据的编码、解码、处理进行分离处理。
- 实现了四种序列化算法，Json 方式、Kryo 算法【默认】、Hessian 算法与 Google Protobuf 方式。
- 使用 Nacos 作为服务注册中心，从注册中心获取服务地址时提供多种负载均衡算法，客户端通过从注册中心获取服务地址与服务端进行通信。
- 接口抽象良好，模块耦合度低，网络传输、序列化器、负载均衡算法可配置
- 通过自定义的通信协议，实现所用序列化算法的获取、判断是否支持此协议包等
- 通过本地服务表获取对应服务执行。
- 服务端接收到请求后通过反射调用执行相应方法
- 通过JDK动态代理实现调用服务在客户端无感。
- 为避免服务的手动注册，实现基于注解和反射的服务自动注册功能。
- 通过为虚拟机关闭时注册钩子函数，实现服务端退出时将注册中心对应服务注销。
- 通过Netty实现应用层自定义心跳机制来避免资源浪费。
- 通过定时任务实现客户端连接失败重试机制



* 大头是序列化和netty，还有一些分布式的内容
  * 需要系统学习netty【reactor】
  * netty线程模型，序列化相关，微分布式相关
* 了解基本的rpc原理
* 序列化：
  * 几种序列化方式的原理和比较

```
+---------------+---------------+-----------------+-------------+
|  Magic Number |  Package Type | Serializer Type | Data Length |
|    4 bytes    |    4 bytes    |     4 bytes     |   4 bytes   |
+---------------+---------------+-----------------+-------------+
|                          Data Bytes                           |
|                   Length: ${Data Length}                      |
+---------------------------------------------------------------+
```

## RPC的提出

* https://mp.weixin.qq.com/s/R8UJFu_aKjOhjKdvbhy1AQ



## 调用如何在客户端无感（动态代理）

* 基于jdk动态代理实现对应服务的代理对象，当调用代理对象的方法时，代理对象将**相关信息【方法、参数等】组装并发送到服务端进行远程调用**，并由**代理接收调用结果并返回。**

## 代理

### 静态代理

#### 定义

* 在程序运行前，**代理类文件已经存在**了，访问对象通过**访问代理类来间接访问目标对象**。

#### 具体实现

* 目标对象和代理类**实现同一接口或继承同一抽象类**，代理类持有目标对象的引用，访问对象实现父类的接口中有对目标对象的访问，**访问对象通过访问代理类与目标对象的同名接口即可间接实现访问目标对象**。

**代码：**

```java
public interface Subject {
    public void sout();
}

public class RealSubject implements Subject{
    @Override
    public void sout() {
        System.out.println("real----");
    }
}
public class Proxy implements Subject {
    RealSubject realSubject = new RealSubject();
    @Override
    public void sout() {
        System.out.println("代理调用");
        realSubject.sout();
    }
}

```



### 动态代理

#### 和静态代理的区别

* 动态代理与静态代理相比较，最大的好处是接口中**声明的所有方法都被转移到调用处理器一个集中的方法中处理**（InvocationHandler.invoke）。这样，在接口方法数量比较多的时候，我们可以进行灵活处理，而**不需要像静态代理那样对每一个方法进行中转。**

* 如果接口增加一个方法，**静态代理模式除了所有实现类需要实现这个方法外，所有代理类也需要实现此方法。增加了代码维护的复杂度。而动态代理不会出现该问题。**

#### 定义

* 在程序运行时，代理类**由反射机制动态创建而成**



#### JDK动态代理

##### 具体实现

* 1、编写接口和需要被代理的类
* 2、编写代理工厂，需要实现 `InvocationHandler` 接口，重写 `invoke()` 方法；代理工厂同样持有目标对象的引用。
* 3、使用`Proxy.newProxyInstance(ClassLoader loader, Class<?>[] interfaces, InvocationHandler h)`**动态创建代理类对象，通过代理类对象调用业务方法。**

**代码：**

```java
interface Subject {
    public void sout();
}

class RealSubject implements Subject {
    @Override
    public void sout() {
        System.out.println("real----");
    }
}
class ProxyObjectFactory implements InvocationHandler {
    // 被代理对象
    private Subject subject;

    public ProxyObjectFactory(Subject subject){
        this.subject = subject;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("目标对象执行后");
        Object result = method.invoke(subject, args);
        System.out.println("目标对象执行后");
        return result;
    }
}

public class Test01 {
    public static void main(String[] args) {
        RealSubject subject1 = new RealSubject();
        ProxyObjectFactory proxyObjectFactory = new ProxyObjectFactory(subject1);
        // 生成代理对象
        Subject newProxyInstance = (Subject) Proxy.newProxyInstance(proxyObjectFactory.getClass().getClassLoader(), subject1.getClass().getInterfaces(), proxyObjectFactory);
        newProxyInstance.sout();
    }
}


输出：
目标对象执行后
real----
目标对象执行后
```

##### 细节

* 注意： JDK Proxy **只能代理实现接口的类**（即使是extends继承类也是不可以代理的）。



#### CGLB代理

* Cglib 是**针对类**来实现代理的，他的原理是**对指定的目标类生成一个子类，并覆盖其中方法实现增强**，但因为采用的是继承，所以**不能对 final 修饰的类进行代理。**
* CGLIB 底层是通过 asm 字节码框架**实时生成类的字节码**，达到**动态创建类的目的**，效率较 JDK 动态代理低。**Spring 中的 AOP 就是基于动态代理的**，如果被代理类实现了某个接口，Spring 会采用 JDK 动态代理，否则会采用 CGLIB。

##### 具体实现

* 代理工厂需实现MethodInterceptor接口并实现intercept代理方法，且持有对目标对象的引用，获取代理对象的方法需用到Enhancer类

**代码：**

```java
class RealSubject {
    public void sout(){
        System.out.println("real");
    }
}
class ProxyFactory implements MethodInterceptor {
    private RealSubject realSubject = new RealSubject();
    public RealSubject getProxyObject(){
        //创建Enhancer对象
        Enhancer enhancer = new Enhancer();
        //设置父类的字节码对象
        enhancer.setSuperclass(realSubject.getClass());
        //设置回调函数
        enhancer.setCallback(this);
        //创建代理对象 即父类对象的子类
        RealSubject o = (RealSubject) enhancer.create();
        return o;
    }
    //代理方法。
    @Override
    public Object intercept(Object o, Method method, Object[] args, MethodProxy methodProxy) throws Throwable {
        System.out.println("cglib");
        Object result = methodProxy.invokeSuper(o, args);
        return result;
    }
}

public class Test02 {
    public static void main(String[] args) {
        //创建代理工厂
        ProxyFactory proxyFactory = new ProxyFactory();
        //获取代理对象
        RealSubject proxyObject = proxyFactory.getProxyObject();
        //执行所代理的功能
        proxyObject.sout();
    }
}

```





## 序列化

* 全局上理解：https://tech.meituan.com/2015/02/26/serialization-vs-deserialization.html
* 大牛博客：https://cloud.tencent.com/developer/article/1443596

### 定义

* 序列化：通过某种协议将**存储于内存中的对象**转换成可以用于**持久化存储或者通信的形式**即字节序列的过程。【按照某种格式】
* 反序列化：就是将这种被持久化存储或者通信的数据通过**对应解析算法还原成对象**的过程，它是序列化的逆向操作。
* 对象序列化成的字节序列会包含对象的类型信息、对象的数据等，说白了就是包含了**描述这个对象的所有信息**，能根据这些信息“复刻”出一个和原来一模一样的对象。



### 为什么需要序列化

1. **数据持久化**：对象是存储在JVM中的堆区的，但是如果JVM停止运行了，对象也不存在了。**序列化可以将对象转化成字节序列，可以写进硬盘文件中实现持久化**。在新开启的JVM中可以读取字节序列进行反序列化成对象。
2. **网络传输**：通过序列化以字节流的形式使对象在网络中进行传递和接收；



**直接传输对象为什么不行**

* 对象存在于内存中，可以在同一进程中进行传输，但不能跨内存传输，因为不同机器的内存结构可能不同，且对应对象所在的内存数据也可能不同。



### java序列化

* 对于要序列化对象的类要去实现Serializable接口或者Externalizable接口
* 实现序列化接口只是表示该类能够被序列化/反序列化，我们还需要借助I/O操作的ObjectInputStream和ObjectOutputStream对对象进行序列化和反序列化。

#### 实现Serializable接口

* ```java
  package com.liu.test;
  
  import lombok.Data;
  import lombok.ToString;
  
  import java.io.*;
  import java.util.Date;
  
  /**
   * @className: TextSerialize
   * @description: TODO 类描述
   * @author: liu
   * @date: 2022/2/22
   **/
  @Data
  @ToString
  public class TextSerialize implements Serializable {
      private Integer id;
  
      private String name;
  
      private Date date;
  
      // 不会默认序列化的字段，如果需要需进行手动序列化
      private transient Object[] arr;
  
      public TextSerialize(){
          this.arr = new Object[100];
          /*
          给前面30个元素进行初始化
           */
          for (int i = 0; i < 30; i++) {
              this.arr[i] = i;
          }
      }
  
      public static void main(String[] args) {
  //        serialize();
          unSerialize();
      }
      //-------------------------- 自定义序列化反序列化 arr 元素 ------------------
  
      /**
       * Save the state of the <tt>ArrayList</tt> instance to a stream (that
       * is, serialize it).
       *
       * @serialData The length of the array backing the <tt>ArrayList</tt>
       * instance is emitted (int), followed by all of its elements
       * (each an <tt>Object</tt>) in the proper order.
       */
      private void writeObject(java.io.ObjectOutputStream s)
              throws java.io.IOException {
          //执行 JVM 默认的序列化操作
          s.defaultWriteObject();
  
  
          //手动序列化 arr  前面30个元素
          for (int i = 0; i < 30; i++) {
              s.writeObject(arr[i]);
          }
      }
  
      /**
       * Reconstitute the <tt>ArrayList</tt> instance from a stream (that is,
       * deserialize it).
       */
      private void readObject(java.io.ObjectInputStream s)
              throws java.io.IOException, ClassNotFoundException {
  
          s.defaultReadObject();
          arr = new Object[30];
  
          // Read in all elements in the proper order.
          for (int i = 0; i < 30; i++) {
              arr[i] = s.readObject();
          }
      }
  
  
      public static void serialize(){
          TextSerialize textSerialize = new TextSerialize();
          textSerialize.setDate(new Date());
          textSerialize.setId(1);
          textSerialize.setName("zll1");
  
          try {
              //使用ObjectOutputStream序列化testBean对象并将其序列化成的字节序列写入test.txt文件
              FileOutputStream fileOutputStream = new FileOutputStream("D:\\test.txt");
              ObjectOutputStream outputStream = new ObjectOutputStream(fileOutputStream);
              outputStream.writeObject(textSerialize);
          } catch (IOException e) {
              e.printStackTrace();
          }
      }
  
      public static void unSerialize(){
          try {
              FileInputStream inputStream = new FileInputStream("D:\\test.txt");
              ObjectInputStream objectInputStream = new ObjectInputStream(inputStream);
              TextSerialize o = (TextSerialize)objectInputStream.readObject();
              System.out.println(o);
          } catch (IOException | ClassNotFoundException e) {
              e.printStackTrace();
          }
      }
  }
  
  ```

##### 细节

* 一个对象要进行序列化，如果**该对象成员变量是引用类型的，那这个引用类型也一定要是可序列化的**，否则会报错
* 同一个对象多次序列化成字节序列，这多个字节序列反序列化成的对象还是一个（使用==判断为true）（因为**所有序列化保存的对象都会生成一个序列化编号，当再次序列化时回去检查此对象是否已经序列化了，如果是，那序列化只会输出上个序列化的编号**）
* 如果序列化一个可变对象，**序列化之后，修改对象属性值，再次序列化，只会保存上次序列化的编号**（这是个坑注意下）
* 对于**不想被默认序列化的字段可以再字段类型之前加上transient关键字修饰**（反序列化时会被赋予默认值）【可以通过私有的writeObject和readObject方法进行自定义序列化】
* 序列化保存的是对象的状态，静态变量属于类的状态，因此 **序列化并不保存静态变量。**
* 序列化是以正向递归的形式进行的，**如果父类实现了序列化那么其子类都将被序列化；子类实现了序列化而父类没实现序列化，那么只有子类的属性会进行序列化，而父类的属性是不会进行序列化的。【父类需要无参构造器】**



##### 序列化原理

https://juejin.cn/post/6854573214077550600

* 序列化字节意义：https://www.cnblogs.com/liango/p/7142204.html

* 先判断对象是否实现 Serializable 接口，如果没有则抛出NotSerializableException【writeObject0】

* 然后先将 TC_OBJECT 这一个对象标志位写入到流中，标识着当前开始写一个的数据是一个对象，然后写入对应类描述信息，接着将从父类到子类的实例数据开始写入到流中。【writeOrdinaryObject】

* 在此期间会检查序列化对象中是否实现了 writeObject 这个方法，如果实现了，就通过反射调用该方法。没实现，就进行默认序列化。【还是通过反射来检查是否实现该方法】

  【writeSerialData】

* 写入实例数据时【defaultWriteFields】

  * 先通过反射调用对象的getter方法获取对象的基本类型属性的值，然后将其写入流中。
  * 然后再通过反射获取对象的非基本类型属性的值，然后将其写入流中【会进行递归写入】





#### 实现Externalizable接口

* ```java
  package com.liu.test;
  
  import lombok.Data;
  
  import java.io.*;
  import java.util.Date;
  
  /**
   * @className: TextExternalize
   * @description: TODO 类描述
   * @author: liu
   * @date: 2022/2/22
   **/
  @Data
  public class TextExternalize implements Externalizable {
      private static final long serialVersionUID = 1961048824439494236L;
      private Integer id;
  
      private String name;
  
      private Date date;
  
      /**
       * 自定义序列化字段
       * @param out
       * @throws IOException
       */
      @Override
      public void writeExternal(ObjectOutput out) throws IOException {
          out.writeInt(id);
          out.writeObject(name);
          out.writeObject(date);
      }
  
      /**
       * 自定义反序列化字段
       * @param in
       * @throws IOException
       * @throws ClassNotFoundException
       */
      @Override
      public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException {
          this.id = in.readInt();
          this.name = (String)in.readObject();
          this.date = (Date)in.readObject();
      }
  
      public static void main(String[] args) {
          serialize();
          unSerialize();
      }
  
      public static void serialize(){
          TextExternalize textSerialize = new TextExternalize();
          textSerialize.setDate(new Date());
          textSerialize.setId(1);
          textSerialize.setName("zll1");
  
          try {
              //使用ObjectOutputStream序列化testBean对象并将其序列化成的字节序列写入text.txt文件
              FileOutputStream fileOutputStream = new FileOutputStream("D:\\text.txt");
              ObjectOutputStream outputStream = new ObjectOutputStream(fileOutputStream);
              outputStream.writeObject(textSerialize);
          } catch (IOException e) {
              e.printStackTrace();
          }
      }
  
      public static void unSerialize(){
          try {
              FileInputStream inputStream = new FileInputStream("D:\\text.txt");
              ObjectInputStream objectInputStream = new ObjectInputStream(inputStream);
              TextExternalize o = (TextExternalize)objectInputStream.readObject();
              System.out.println(o);
          } catch (IOException | ClassNotFoundException e) {
              e.printStackTrace();
          }
      }
  }
  
  ```



##### 细节

* 序列化对象要提供无参构造
* 如果序列化时一个字段没有序列化，那反序列化是要注意别给未序列化的字段反序列化了



#### Serializable和Externalizable的区别

* 1、Serializable序列化时不会调用默认的构造器，而Externalizable序列化时会调用默认构造器的！

* 2、Serializable：一个对象想要被序列化，它的类就要实现 此接口，这个对象的所有属性都可以被序列化和反序列化来保存、传递。 

   Externalizable：自定义序列化可以控制序列化的过程和决定哪些属性不被序列化。

* 3、使用Externalizable时，必须按照写入时的确切顺序读取所有字段状态。否则会产生异

#### serialVersionUID的作用

* 序列化的过程：在进行序列化时，会把当前类的serialVersionUID写入到字节序列中。在**反序列化时会将字节流中的serialVersionUID同本地对象中的serialVersionUID进行对比**，一样的话进行反序列化，不一致则失败报错（报InvalidCastException异常）

* serialVersionUID的生成有三种方式（private static final long serialVersionUID= XXXL ）：
  * 显式声明：默认的1L
  * 显式声明：根据包名、类名、继承关系、非私有的方法和属性以及参数、返回值等诸多因素计算出的64位的hash值
  * 隐式声明：未显式的声明serialVersionUID时java序列化机制会根据Class自动生成一个serialVersionUID（最好不要这样，因为**如果Class发生变化，自动生成的serialVersionUID可能会随之发生变化，导致匹配不上**）【**只要序列化版本一样，对象新增属性并不会影响反序列化对象。**】

* 建议使用idea快捷键进行显示声明。



#### java序列化的缺点

* 不能跨平台使用、字节数较大







### JSON序列化

#### 定义

* 序列化：将对象数据先转为对应json字符串格式【序列化格式】，然后转为字节序列写入流中
* 反序列化：将对应的json字符串还原为对应的对象。



#### 缺点

* JSON 进行序列化的**额外空间开销比较大**，对于大数据量服务这意味着需要巨大的内存和磁盘开销； 
* JSON **没有类型**，但像 Java 这种强类型语言，需要通过反射统一解决，所以性能不会太好（比如反序列化时先反序列化为String类，要自己通过反射还原）。



### Kryo序列化

https://github.com/EsotericSoftware/kryo#quickstart

中文：https://blog.csdn.net/fanjunjaden/article/details/72823866

* Kryo是一种快速高效的Java对象图（Object graph）序列化框架。 该项目的目标**是速度、效率和易于使用的API**。 当对象需要持久化时，无论是用于文件、数据库还是通过网络，该项目都很有用。
* Kryo还可以执行自动深层浅层的复制/克隆。这是从对象直接复制到对象，而不是object -> bytes -> object。
* 进出 Kryo 的数据是通过 Input 和 Output 类完成的。**这些类不是线程安全**的。

#### Output

* Output 类是一个 OutputStream，它将数据写入字节数组缓冲区。如果需要一个字节数组，可以获得并直接使用这个缓冲区。
* 当Output作为一个 OutputStream，那么当缓冲区满时，它将把字节刷新到流中。而其作为装饰器时，Output 可以自动增加缓冲区。
* Output有许多方法可以有效地将基本数据类型和字符串写入字节。它提供了类似于 DataOutputStream、 BufferedOutputStream、 FilterOutputStream 和 ByteArrayOutputStream 的功能
* Output缓冲写入 OutputStream 时的字节，因此写入完成后必须调用 flush 或 close，以便将缓冲的字节写入 OutputStream。如果 Output 没有提供 OutputStream，则不需要调用刷新或关闭。与许多流不同，可以通过设置位置或设置新的字节数组或流重用 Output 实例。
* 对应无参构造函数创建一个未初始化的 Output。必须调用 Output setBuffer 才能使用 Output。



#### Input

* Input 类是从字节数组缓冲区读取数据的 InputStream。如果需要从字节数组中读取数据，可以直接设置这个缓冲区。如果给 Input 一个 InputStream，那么缓冲区中的数据读完后，它将从流中填充缓冲区，然后再读取。
* Input 有许多方法可以有效地从字节读取原语和字符串。它提供了类似于 DataInputStream、 BufferedInputStream、 FilterInputStream 和 ByteArrayInputStream 的功能。
* 如果调用 Input close，则关闭 Input 的 InputStream (如果有的话)。如果不从 InputStream 读取，那么就没有必要调用 close。与许多流不同，可以通过设置位置和限制，或者设置新的字节数组或 InputStream 重用 Input 实例。
* 无参构造函数创建一个未初始化的输入。在使用输入之前必须调用输入 setBuffer。

#### 特性

##### 可变长度编码【压缩算法】

* Kryo提供了**读写可变长度 int (varint)和 long (varlong)值**的方法。
* 这是通过使用**每个字节的第8位**来指示**后面是否有更多的字节**，这意味着 varint 使用1-5个字节，varlong 使用1-9个字节。使用可变长度编码耗时更长，但使序列化的数据小得多。
* Input和Output提供了读取和写入固定大小或可变长度值的方法。![image-20220224120341678](https://gitee.com/LiuDeLmmg/img/raw/master/img/image-20220224120341678.png)



##### 分块编码

* 缓冲写入需要知道数据和数据的长度，常规缓冲写入是先将数据写入缓冲中，然后得出数据长度，再将数据长度、数据分别写入流中。

  这可能会需要一个不合理的大型缓冲区。

* 分块编码通过使用一个小的缓冲区解决了这个问题。当缓冲区满时，写入它的长度、然后写入数据到流中。这是一个数据块。缓冲区被清除，然后继续，直到没有更多的数据可以写入。长度为零的块表示块的结束。

* Kryo 提供用于分块编码的类。OutputChunked 用于写入分块数据。它扩展了 Output，以及所有方便的数据写入方法。当 OutputChunked 缓冲区满了时，它将块刷新到另一个 OutputStream。endChunk 方法用于标记一组块的结束。

* 要读取分块数据，可以使用 InputChunked。它扩展了 Input，以及所有方便的读取数据的方法。读取时，当数据到达一组块的末尾时，InputChunked 将显示为到达数据的末尾。Nextchunk 方法前进到下一组块，即使并非所有数据都已从当前的块集中读取。【需和OutputChunked约定缓冲区的大小】



#### 读写对象

* 三套方法读写对象

* ```java
  If the concrete class of the object is not known and the object could be null:
  
  kryo.writeClassAndObject(output, object);
  
  Object object = kryo.readClassAndObject(input);
  if (object instanceof SomeClass) {
     // ...
  }
  
  If the class is known and the object could be null:
  
  kryo.writeObjectOrNull(output, object);
  
  SomeClass object = kryo.readObjectOrNull(input, SomeClass.class);
  
  If the class is known and the object cannot be null:
  
  kryo.writeObject(output, object);
  
  SomeClass object = kryo.readObject(input, SomeClass.class);
  
  ```



##### 往返

* 写入对象到Output的字节缓冲区，然后再从Output的字节缓冲区读取到Input中

* ```java
  Kryo kryo = new Kryo();
  
  // Register all classes to be serialized.
  kryo.register(SomeClass.class);
  
  SomeClass object1 = new SomeClass();
  
  // 缓冲区大小1024，最大上限【-1】
  Output output = new Output(1024, -1);
  kryo.writeObject(output, object1);
  
  Input input = new Input(output.getBuffer(), 0, output.position());
  SomeClass object2 = kryo.readObject(input, SomeClass.class);
  ```



##### 深拷贝和浅拷贝

* Kryo 支持使用从一个对象到另一个对象的直接赋值来制作对象的深层和浅层副本。这比序列化为字节并返回到对象更有效。

* ```java
  Kryo kryo = new Kryo();
  SomeClass object = ...
  SomeClass copy1 = kryo.copy(object);
  SomeClass copy2 = kryo.copyShallow(object);
  ```

* 如果启动了引用，Kryo 将自动处理对同一对象和循环引用的多个引用。



#### 注册

* 当 Kryo 去写一个对象的实例时，首先它可能需要写一些东西来标识对象的类。默认情况下，Kryo 将读取或写入的所有类都必须事先注册。注册提供了一个 int 类 ID、用于类的序列化器和用于创建类实例的对象实例化器。

* ```java
  Kryo kryo = new Kryo();
  kryo.register(SomeClass.class);
  Output output = ...
  SomeClass object = ...
  kryo.writeObject(output, object);
  ```

* 在反序列化期间，注册的类必须具有与序列化期间完全相同的 id。注册时，将为类分配下一个可用的最低整数 ID，这意味着**注册的顺序非常重要**。可以选择显式指定类 ID，以使顺序不重要:

  ```java
  Kryo kryo = new Kryo();
  kryo.register(SomeClass.class, 9);
  kryo.register(AnotherClass.class, 10);
  kryo.register(YetAnotherClass.class, 11);
  ```

  类 id-1和-2是保留的。类 id 0-8默认用于基本类型和 String，但是这些类 id 可以重用。这些 id 被写成正优化的 varint，所以当它们是小的正整数时效率最高。负数 id 不能有效地序列化。

#### 原理

https://cloud.tencent.com/developer/article/1443590

* 先序列化类型【即Class对象】，如果内存中的对象图已有相应的类型对象，则只是写入对应类型的id值，否则将写入id和全路径类名，然后获取类型对应的序列器。【writeClass】
* 使用该序列化器，然后对该类型一个字段一个字段的序列化，当然其序列化也是，先类型再值的模式，递归进行，最终完成。期间同样会判断是否判断实例对象是否序列化过。【writeReferenceOrNull，write】
* 其引入了**对象图的概念来消除循环依懒的序列化**，已序列化的对象，在循环引用时，只是用一个int类型即id来表示该对象值。



#### **Kryo与java 序列化的区别**

* kryo的设计目的是指**对象值的序列化**，关注的是有效数据的传输，**减少需要序列化的元数据信息。**
* Kryo对Class的序列化**只序列化Class的全路径名**，在反序列化时根据Class通过类加载进行加载，大大**减少了序列化后的文件大小**，能极大提高性能。
* Kryo的核心设计理念就是**尽最大可能减少序列化后的文件大小**，其举措1就是通过对long,int等数据类型，采用**变长字节存储来代替java中使用固定字节(4,8)字节的模式**，因为在软件开发中，对象的这些值基本上都是小值，能节省很多空间，第二个举措是使用了类似缓存的机制，在一次序列化对象中，在整个递归序列化期间，**相同的对象，只会序列化一次，后续的用一个局部int值来代替。**



#### 优点

* kryo 速度较快，序列化后体积较小

#### 缺点

* 跨语言支持较复杂



### Hessian 序列化

#### 定义

* Hessian 是一个动态类型的二进制序列化和 Web 服务协议，用于面向对象的传输。

* Hessian采用的是二进制协议，它的序列化和反序列化也是非常高效。**速度较慢，序列化后的体积较大。**

* 由于Hessian设计之初就考虑到**跨语言的需求**因此在兼容性方面也更胜一筹。

* 使用固定长度存储int和long。 

  将所有类字段信息都放入序列化字节数组中，直接利用字节数组进行反序列化，不需要其他参与，因为存的东西多处理速度就会慢点。 

  把复杂对象的所有属性存储在一个Map中进行序列化。所以在父类、子类存在同名成员变量的情况下，Hessian序列化时，先序列化子类，然后序列化父类，因此反序列化结果会导致子类同名成员变量被父类的值覆盖 

  需要实现Serializable接口 

  兼容字段增、减，序列化和反序列化 

  必须拥有无参构造函数 

  Java 里面一些常见对象的类型不支持，比如：  

  - Linked 系列，LinkedHashMap、LinkedHashSet 等； 
  - Locale 类，可以通过扩展 ContextSerializerFactory 类修复； 
  - Byte/Short 反序列化的时候变成 Integer。



对应序列化格式：http://hessian.caucho.com/doc/hessian-serialization.html#anchor19



### protoStuff

#### 定义

* 基于protobuf发展而来的，相对于protobuf提供了更多的功能和更简易的用法。
* 序列化后体积相比 JSON、Hessian 小很多
* IDL 能清晰地描述语义，所以足以帮助并保证应用程序之间的类型不会丢失，无需类似XML 解析器；
* 序列化反序列化速度很快，不会记录对象类型所以也无需反射而是直接赋值；
* 打包生成二进制流
* 预编译过程不是必须的



#### 底层实现

protostuff和protobuf的关系

* protostuff是基于protobuf实现的，它在几乎不损耗性能的情况下做到了不用我们写.proto文件来实现序列化，是为了简化protobuf对java对象的序列化和反序列化而提出来的，主要是封装对象的schema来避免写proto协议文件的。序列化原理与protobuf原理基本一致。

protobuf原理

* 需先编写一个proto协议文件，**协议文件**中定义了**要序列化和反序列的对象**，然后静态编译成一个外部类，通过这个外部类就可以对定义的对象进行序列化和反序列化了。
* 序列化过程：
  * 根据定义的消息类型【协议文件中定义的对象】进行编码
    * 转换为一系列tag-value结构的二进制，tag=(key << 3) | wire_type【key为字段设置的字段号】，write_type根据字段的定义类型有不同的值：![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2019/11/30/16eba9390b1dc57c~tplv-t2oaga2asx-zoom-in-crop-mark:1304:0:0:0.awebp)
    * value的生成：会针对**字段不同的数据类型做不同的压缩编码**
      * 可变长编码：核心是用字节的最高位作为标志，标志下一个字节是否读取，这样的字节序列来表示某个值，节省字节占用空间。【对应字段类型有：int32、uint32】
      * 负数可变长编码：针对负数，先将负数映射为正数，然后再用进行可变长编码。【对应字段类型有：sin32】
      * 固定字节数类型：值的固定字节序列，无压缩。【fixed32】
      * string类型：固定格式：value = length + content【length采用可变长编码】【string】

协议文件格式：

* ```txt
  syntax="proto3";  #序列化协议版本
  // option java_outer_classname = "ProtoBufAnimal"
  message Animal { #消息类型 类比要序列化和反序列化的对象
  	int32 age = 1; #int32:字段类型 age:字段名 1:字段号
  	string name = 2;
  }
  #可以定义多个消息类型 同时可以嵌套
  ```

* 协议文件作用，静态编译协议文件后，可以得到一个输出器，使用这个输出器，我们就可以序列化和反序列相应结构的对象。

Protobuf优缺点：

* 优点：
  * 序列化出的字节序列占用空间小：各种压缩方式。
  * 快：序列化和反序列基本都是位运算实现。【CPU资源消耗小】
  * 安全：protobuf编码时并没有将字段名写入，只写入字段号，更加安全。
  * 向后兼容：解码时遇到无法解析的字段会自动跳过，不影响其他字段的解析，故新版本编码产生的字节序列还是能被旧版本解析。
  * 跨语言：只要协议文件定义相同，编码的字节序列都是相同的，解码可根据不同语言解析出相应对象。
* 缺点：
  * 定义协议的文件过大。
  * 可读性差：二进制流。

应用场景：

* 对消息大小较敏感【网络带宽】的场景

参考：

https://juejin.cn/post/6844904007811465229



### 各序列化框架比较

* ![image-20220224203443237](https://gitee.com/LiuDeLmmg/img/raw/master/img/image-20220224203443237.png)





## Netty

### 简单介绍一下 Netty

* Netty是一个异步事件【使用 Threads（多线程）处理 I/O 事件，通过Future取得异步结果】驱动的网络应用程序框架，用于快速开发可维护的**高性能**协议服务器和客户端。[Netty]() 基于 NIO 的，封装了 JDK 的 NIO，让我们使用起来更加方法灵活。

  特点和优势：

  - 使用简单：封装了 NIO 的很多细节，使用更简单。 
  - 功能强大：预置了多种编解码功能，支持多种主流协议。 
  - 定制能力强：可以通过 ChannelHandler 对通信框架进行灵活地扩展。 
  - 性能高：通过与其他业界主流的 NIO 框架对比，[Netty]() 的综合性能最优。



### 为什么Netty性能高

* IO 线程模型：同步非阻塞，用最少的资源做更多的事。 
* 内存零拷贝：**尽量减少不必要的内存拷贝**，实现了更高效率的传输。 
* 内存池设计：申请的内存可以重用，主要指直接内存。内部实现是用一颗二叉查找树管理内存分配情况。 
* 串行化处理读写：避免使用锁带来的性能开销。 
* 高性能序列化协议：支持 protobuf 等高性能序列化协议。



### Netty中的ByteBuffer

* Netty 根据 **reference-counting(引用计数)**来确定何时可以释放 ByteBuf 或 ByteBufHolder 和其他相关资源，从而可以利用池和其他技巧来提高性能和降低内存的消耗。
* Netty 缓冲 API 提供了几个优势：
  - 可以自定义缓冲类型
  - 通过一个内置的复合缓冲类型实现零拷贝
  - 扩展性好，比如 StringBuilder
  - 不需要调用 flip() 来切换读/写模式
  - 读取和写入索引分开
  - 方法链
  - 引用计数
  - Pooling(池)
* ByteBuf中有两个索引：一个用来读，一个用来写。这两个索引达到了便于操作的目的。我们可以按顺序的读取数据，也可以通过调整读取数据的索引或者直接将读取位置索引作为参数传递给get方法来重复读取数据。
* ByteBuf.discardReadBytes() 可以用来**清空 ByteBuf 中已读取的数据**，从而使 ByteBuf 有多余的空间容纳新的数据，但是discardReadBytes() 可能会涉及内存复制，因为它需要**移动 ByteBuf 中可读的字节到开始位置**，这样的操作会影响性能，一般在需要马上释放内存的时候使用收益会比较大。

#### ByteBuf 的工作原理

* 写入数据到 ByteBuf 后，writerIndex（写入索引）增加写入的字节数。读取字节后，readerIndex（读取索引）也增加读取出的字节数。你可以读取字节，直到写入索引和读取索引处在相同的位置。此时ByteBuf不可读，所以下一次读操作将会抛出 IndexOutOfBoundsException，就像读取数组时越位一样。
* 调用 ByteBuf 的以 "read" 或 "write" 开头的任何方法都将自动增加相应的索引。另一方面，"set" 、 "get"操作字节将不会移动索引位置，它们只会在指定的相对位置上操作字节。
* 可以给ByteBuf指定一个最大容量值，这个值限制着ByteBuf的容量。任何尝试将写入超过这个值的数据的行为都将导致抛出异常。ByteBuf 的默认最大容量限制是 Integer.MAX_VALUE。
* ByteBuf 类似于一个字节数组，最大的区别是读和写的索引可以用来控制对缓冲区数据的访问。



#### ByteBuf 使用模式

##### HEAP BUFFER(堆缓冲区)

* 最常用的模式是 ByteBuf 将**数据存储在 JVM 的堆空间**，这是通过**将数据存储在数组的实现**。堆缓冲区可以**快速分配，当不使用时也可以快速释放**。它还提供了直接访问数组的方法，通过 ByteBuf.array() 来获取 byte[]数据。 这种方法，正如清单5.1中所示的那样，是非常适合用来处理遗留数据的。

* ```java
  ByteBuf heapBuf = ...;
  if (heapBuf.hasArray()) {                //1
      byte[] array = heapBuf.array();        //2
      int offset = heapBuf.arrayOffset() + heapBuf.readerIndex();                //3
      int length = heapBuf.readableBytes();//4
      handleArray(array, offset, length); //5
  }
  ```

* **访问非堆缓冲区 ByteBuf 的数组会导致UnsupportedOperationException**， 可以使用 ByteBuf.hasArray()来检查是否支持访问数组。

* 这个用法与 JDK 的 ByteBuffer 类似



##### DIRECT BUFFER(直接缓冲区)

* 在 JDK1.4 中被引入 NIO 的ByteBuffer 类允许 JVM 通过本地方法调用分配内存，其目的是

  - 通过**免去中间交换的内存拷贝, 提升IO处理速度;** **直接缓冲区的内容可以驻留在垃圾回收扫描的堆区以外。**
  - DirectBuffer 在 -XX:MaxDirectMemorySize=xxM大小限制下, 使用 Heap 之外的内存, GC对此”无能为力”,也就意味着**规避了在高负载下频繁的GC过程对应用线程的中断影响**【直接内存足够大】

* 但是直接缓冲区的缺点是**在内存空间的分配和释放上比堆缓冲区更复杂**，另外一个缺点是如果要将数据传递给遗留代码处理，因为**数据不是在堆上，你可能不得不作出一个副本【拷贝到数组】**

* ```java
  ByteBuf directBuf = ...
  if (!directBuf.hasArray()) {            //1
      int length = directBuf.readableBytes();//2
      byte[] array = new byte[length];    //3
      directBuf.getBytes(directBuf.readerIndex(), array);        //4    
      handleArray(array, 0, length);  //5
  }
  ```

* 



##### COMPOSITE BUFFER(复合缓冲区)

* 最后一种模式是复合缓冲区，我们可以创建多个不同的 ByteBuf，然后提供一个**这些 ByteBuf 组合的视图**。**复合缓冲区就像一个列表，我们可以动态的添加和删除其中的 ByteBuf**，JDK 的 ByteBuffer 没有这样的功能。

  Netty 提供了 ByteBuf 的子类 CompositeByteBuf 类来处理复合缓冲区，CompositeByteBuf 只是一个视图。

* *CompositeByteBuf.hasArray() 总是返回 false，因为它可能既包含堆缓冲区，也包含直接缓冲区*![image-20220226152058368](https://gitee.com/LiuDeLmmg/img/raw/master/img/image-20220226152058368.png)



* ```java
  CompositeByteBuf messageBuf = ...;
  ByteBuf headerBuf = ...; // 可以支持或直接
  ByteBuf bodyBuf = ...; // 可以支持或直接
  messageBuf.addComponents(headerBuf, bodyBuf);
  // ....
  messageBuf.removeComponent(0); // 移除头ByteBuf    //2
  
  for (int i = 0; i < messageBuf.numComponents(); i++) {                        //3
      System.out.println(messageBuf.component(i).toString());
  }
  
  CompositeByteBuf compBuf = ...;
  int length = compBuf.readableBytes();    //1
  byte[] array = new byte[length];        //2
  compBuf.getBytes(compBuf.readerIndex(), array);    //3
  handleArray(array, 0, length);    //4
  ```





#### ByteBuf 分配

* 为了**减少分配和释放内存**的开销，Netty 通过支持**池类** ByteBufAllocator，可用于分配的任何 ByteBuf 我们已经描述过的类型的实例。是否使用池是由应用程序决定的。![image-20220226154232747](https://gitee.com/LiuDeLmmg/img/raw/master/img/image-20220226154232747.png)

* 得到一个 ByteBufAllocator 的引用很简单。你**可以得到从 Channel （在理论上，每 Channel 可具有不同的 ByteBufAllocator ），或通过绑定到的 ChannelHandler 的 ChannelHandlerContext 得到它**，用它实现了你数据处理逻辑。

  ```java
  Channel channel = ...;
  ByteBufAllocator allocator = channel.alloc(); //1
  ....
  ChannelHandlerContext ctx = ...;
  ByteBufAllocator allocator2 = ctx.alloc(); //2
  ...
  ```

* Netty 提供了两种 ByteBufAllocator 的实现，一种是 PooledByteBufAllocator,**用ByteBuf 实例池改进性能以及内存使用降到最低**，此实现使用一个“[jemalloc](http://people.freebsd.org/~jasone/jemalloc/bsdcan2006/jemalloc.pdf)”内存分配。其他的实现不池化 ByteBuf 情况下，每次返回一个新的实例。

  **Netty 默认使用 PooledByteBufAllocator，我们可以通过 ChannelConfig 或通过引导设置一个不同的实现来改变。**



#### 引用计数器

* 在Netty 4中为 ByteBuf 和 ByteBufHolder（两者都实现了 ReferenceCounted 接口）**引入了引用计数器。**
* 引用计数器本身并不复杂；它能够**在特定的对象上跟踪引用的数目**，实现了ReferenceCounted 的类的实例会通常开始于一个活动的引用计数器为 1。而如果对象活动的引用计数器大于0，就会被保证不被释放。**当数量引用减少到0，将释放该实例**。需要注意的是“释放”的语义是特定于具体的实现。最起码，一个对象，它已被释放应不再可用。



### Netty中的ChannelHandler 家族

#### Channel 生命周期

* ![image-20220226160749527](https://gitee.com/LiuDeLmmg/img/raw/master/img/image-20220226160749527.png)![image-20220226160925395](https://gitee.com/LiuDeLmmg/img/raw/master/img/image-20220226160925395.png)





#### ChannelHandler 生命周期

* ![image-20220226160953505](https://gitee.com/LiuDeLmmg/img/raw/master/img/image-20220226160953505.png)



#### ChannelHandler 子接口

Netty 提供2个重要的 ChannelHandler 子接口：

- ChannelInboundHandler - 处理进站数据和所有状态更改事件
- ChannelOutboundHandler - 处理出站数据，允许拦截各种操作

* *ChannelHandler 适配器*

*Netty 提供了一个简单的 ChannelHandler 框架实现，给所有声明方法签名。这个类 ChannelHandlerAdapter 的方法,主要推送事件 到 pipeline 下个 ChannelHandler 直到 pipeline 的结束。这个类 也作为 ChannelInboundHandlerAdapter 和ChannelOutboundHandlerAdapter 的基础。**所有三个适配器类的目的是作为自己的实现的起点;您可以扩展它们,覆盖你需要自定义的方法。***



##### ChannelInboundHandler

* ChannelInboundHandler 的生命周期方法在下表中，**当接收到数据或者与之关联的 Channel 状态改变时调用。**


Table 6.3 ChannelInboundHandler methods

|           类型            |                             描述                             |
| :-----------------------: | :----------------------------------------------------------: |
|     channelRegistered     | Invoked when a Channel is registered to its EventLoop and is able to handle I/O. |
|    channelUnregistered    | Invoked when a Channel is deregistered from its EventLoop and cannot handle any I/O. |
|       channelActive       | Invoked when a Channel is active; the Channel is connected/bound and ready. |
|      channelInactive      | Invoked when a Channel leaves active state and is no longer connected to its remote peer. |
|    channelReadComplete    | Invoked when a read operation on the Channel has completed.  |
|        channelRead        |          Invoked if data are read from the Channel.          |
| channelWritabilityChanged | Invoked when the writability state of the Channel changes. The user can ensure writes are not done too fast (with risk of an OutOfMemoryError) or can resume writes when the Channel becomes writable again.Channel.isWritable() can be used to detect the actual writability of the channel. The threshold for writability can be set via Channel.config().setWriteHighWaterMark() and Channel.config().setWriteLowWaterMark(). |
|  userEventTriggered(...)  | Invoked when a user calls Channel.fireUserEventTriggered(...) to pass a pojo through the ChannelPipeline. This can be used to pass user specific events through the ChannelPipeline and so allow handling those events. |



##### ChannelOutboundHandler

* ChannelOutboundHandler 提供了出站操作时调用的方法。这些方法会被 Channel, ChannelPipeline, 和 ChannelHandlerContext 调用。![image-20220226161544683](https://gitee.com/LiuDeLmmg/img/raw/master/img/image-20220226161544683.png)



### ChannelPipeline

* **ChannelPipeline** 是一系列的ChannelHandler 实例的容器，流经一个 Channel 的**入站和出站事件**可以被ChannelPipeline 拦截，ChannelPipeline能够让用户自己对入站/出站事件的处理逻辑，以及pipeline里的各个Handler之间的交互进行定义。

* 每当一个新的Channel被创建了，**都会建立一个新的 ChannelPipeline，并且这个新的 ChannelPipeline 还会绑定到Channel上。**这个关联是永久性的；Channel 既不能附上另一个 ChannelPipeline 也不能分离当前这个。这些都由Netty负责完成,，而无需开发人员的特别处理。

* **根据事件的起源**,一个事件将由 ChannelInboundHandler 或 ChannelOutboundHandler 处理。随后它将调用 ChannelHandlerContext 实现转发到**下一个相同**的超类型的处理程序。

* ![image-20220226162908164](https://gitee.com/LiuDeLmmg/img/raw/master/img/image-20220226162908164.png)

  默认左边为入站口，右边为出站口。【即in的处理顺序与加入顺序相同，而out相反】

* 随着管道传播事件,它**决定下个 ChannelHandler 是否是相匹配的方向运动的类型**。如果没有,ChannelPipeline 跳过 ChannelHandler 并继续下一个合适的方向。记住,一个处理程序可能同时实现ChannelInboundHandler 和 ChannelOutboundHandler 接口。

* 可以修改 ChannelPipeline 通过动态添加和删除 ChannelHandler

* ChannelPipeline 有着丰富的API调用动作来回应入站和出站事件。



### 接口ChannelHandlerContext

* 下图展示了 ChannelPipeline, Channel, ChannelHandler 和 ChannelHandlerContext 的关系

  ![Figure%206](https://atts.w3cschool.cn/attachments/image/20170808/1502159866928817.jpg)

* ChannelHandlerContext 中包含了有许多方法，其中一些方法也出现在 Channel 和ChannelPipeline 本身。如果您通过Channel 或ChannelPipeline 的实例来调用这些方法，他们就会**在整个 pipeline中传播** 。相比之下，一样的方法在 ChannelHandlerContext 的实例上调用， 就只会**从当前的 ChannelHandler 开始并传播到相关管道中的下一个有处理事件能力的 ChannelHandler 。**
* 然在 Channel 或者 ChannelPipeline 上调用write() 都会把事件在整个管道传播,但是**在 ChannelHandler 级别上，从一个处理程序转到下一个却要通过在 ChannelHandlerContext 调用方法实现。**
* ![Figure%206](https://atts.w3cschool.cn/attachments/image/20170808/1502159893150498.jpg)
  1. 事件传递给 ChannelPipeline 的第一个 ChannelHandler
  2. ChannelHandler 通过关联的 ChannelHandlerContext 传递事件给 ChannelPipeline 中的 下一个
  3. ChannelHandler 通过关联的 ChannelHandlerContext 传递事件给 ChannelPipeline 中的 下一个
* 想要实现**从一个特定的 ChannelHandler 开始处理，**你必须引用与 此ChannelHandler的前一个ChannelHandler 关联的 ChannelHandlerContext 。这个ChannelHandlerContext 将会调用与自身关联的 ChannelHandler 的下一个ChannelHandler 。





### 说下 [Netty]() 零拷贝

https://cloud.tencent.com/developer/article/1488088

[Netty]() 的零拷贝主要包含三个方面：

- [Netty]() 的接收和发送 ByteBuffer 采用 DIRECT BUFFERS，使用**堆外直接内存进行 Socket 读写**，**不需要进行字节缓冲区的二次拷贝**。如果使用传统的堆内存（HEAP BUFFERS）进行 Socket 读写，JVM 会**将堆内存 Buffer 拷贝一份到直接内存中，然后才写入 Socket 中【这里说的是write时，直接内存相当于内核缓冲】**。相比于堆外直接内存，消息在发送过程中多了一次缓冲区的内存拷贝。 
- [Netty]() 提供了组合 Buffer 对象，可以**聚合多个 ByteBuffer 对象**，用户可以像操作一个 Buffer 那样方便的对组合 Buffer 进行操作，**避免了传统通过内存拷贝的方式将几个小 Buffer 合并成一个大的 Buffer。** 
- [Netty]() 的文件传输采用了 transferTo 方法，它可以**直接将文件缓冲区的数据发送到目标 Channel**，避免了传统通过循环 write 方式导致的内存拷贝问题。【实现了数据直接从内核的读缓冲区传输到套接字缓冲区，避免了用户态(User-space) 与内核态(Kernel-space) 之间的数据拷贝。】





### Netty的IO模型

* 基于NIO实现的网络框架，它们底层的IO模型通常是基于Reactor模型来实现的。Reactor模型又可以分为三种：**单线程模型、多线程模型、主从多线程模型。**

#### Reactor单线程模型

* Reactor单线程模型中，**只有一个线程。这个线程既负责客户端的接入，还负责数据的读写、编解码、业务逻辑处理**等工作。
* 一个NIO 线程同时处理成百上千的链路，性能上无法支撑，速度慢，若线程进入死循环，整个程序不可用，对于高负载、大并发的应用场景不合适。![图片](https://mmbiz.qpic.cn/mmbiz_png/K5cqia0uV8GwA3ia2bN6H0WzsVxWOx6f7JwuUHOwv8ndX8ibNQqVvoREempOnuIiaMyhO8icmqJBZnBlmictm5yxApIg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



#### Reactor多线程模型

* 在Reactor多线程模型中，由**一个NIO线程【Acceptor】来负责客户端的接入，连接创建完成后，再由一组线程来处理数据的读写、编解码、业务处理等操作。**
* 线程组可以采用Java中的线程池，它有一个任务队列和多个NIO线程，因此一个NIO线程可以同时处理多个连接，但是**一个连接只属于一个NIO线程**，这是为了**防止发生并发操作问题。**
* 但在并发百万客户端连接或需要安全认证时，**一个Acceptor 线程可能会存在性能不足问题。![图片](https://mmbiz.qpic.cn/mmbiz_png/K5cqia0uV8GwA3ia2bN6H0WzsVxWOx6f7J47oicXqEeKRLlMP4daUhibELEfSSfMmYQQkWvHd5rfxYNTzibIBT6pWDg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)**



#### Reactor主从多线程模型

* Reactor主从多线程模型则解决了多线程模型的缺点，主从多线程模型中**由一组NIO线程来负责处理新连接的接入，另外一组NIO线程来处理IO读写、编解码、业务逻辑处理等操作。因此它是两个线程池**，负责新连接接入的线程池称之为主线程池，负责数据读写、编解码操作的线程池称之为从线程池。
* 当一个客户端来连接服务端时，主线程池会从线程池中选择出一个NIO线程，来充当Acceptor的角色，负责新连接的接入。当连接创建完成后，会将这个新连接绑定到从线程池的一个NIO线程上，后续则由这个NIO线程来进行数据的读写、编解码等操作。



#### Netty对Reactor三种线程模型的支持

![image-20220224221548999](https://gitee.com/LiuDeLmmg/img/raw/master/img/image-20220224221548999.png)

todo https://blog.csdn.net/qq_38685503/article/details/114168722

### 全过程图解

* https://blog.csdn.net/qq_38685503/article/details/114168722

![img](https://img-blog.csdnimg.cn/20210227123754270.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4Njg1NTAz,size_16,color_FFFFFF,t_70)



### 简述AIO、BIO、NIO的具体使用、区别及原理

* BIO：BIO是阻塞IO，一个连接一个线程，**客户端有连接请求时服务器端就需要启动一个线程进行处理。线程开销大。**【不可以读取就开始工作】

* 伪异步IO：将请求连接放入线程池，一对多，但线程还是很宝贵的资源。

* NIO：通常称它为同步非阻塞IO。一个请求一个线程，但**客户端发送的请求事件都会注册到多路复用器上，多路复用器轮询到连接有I/O请求时才启动一个线程进行处理。**【可以读取时才开始工作但不能异步读完】

  javaNIO写法复杂，且还存在空轮询的BUG。

* AIO：异步非阻塞IO一个有效请求一个线程，**客户端的I/O请求都是由OS先完成了再通知服务器应用去启动线程进行处理。**【可以异步读完】



### Netty对于TCP粘包、半包问题的解决

#### 粘包半包引起的根本原因

* 对于 TCP 协议而言，它传输数据是基于**字节流传输**的。应用层在传输数据时，实际上会先将数据写入到 TCP 套接字的缓冲区，**当缓冲区被写满后，数据才会被写出去，这就可能造成粘包、半包的问题。**
* 多个数据包相互之间是没有边界的，而且在 TCP 的协议头中，没有一个单独的字段来表示数据包的长度，这样在接收方的应用层，从**字节流中读取到数据后，是没办法将两个数据包区分开的。**



#### 粘包半包

* 粘包：两个**独立完整数据包粘合**，接收方无法区分。

  ![图片](https://mmbiz.qpic.cn/mmbiz_png/K5cqia0uV8Gzf0EH8MzDDfG0wQosNsjxOTh5H3bb6gXibq8h75pUjic57JIv5hcuZVGpGrYLd4hAZDu1UBeQ4uTow/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

* 半包：**独立完整的数据包被拆分发送**，接收方**无法送到一个完整的数据包**

  ![图片](https://mmbiz.qpic.cn/mmbiz_png/K5cqia0uV8Gzf0EH8MzDDfG0wQosNsjxOuHKZlrtbJ5C7p9IaxaUN4xQtiaaia6hTGrFtCgEF0AHk5O3sySicfoQrw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



#### 产生粘包、半包的原因

- 粘包原因

- 1. 接收方**读取套接字缓冲区的数据不够及时**。

- 2. 发送方每次写入的数据小于套接字缓冲区大小；

* 半包原因

* 1. 发送的数据大于协议的 MSS 或者 MTU，必须拆包。（MSS 是 TCP 层的最大分段大小，TCP 层发送给 IP 层的数据不能超过该值；MTU 是最大传输单元，是物理层提供给上层一次最大传输数据的大小，用来限制 IP 层的数据传输大小）。

* 2. 发送方写入的数据大于套接字缓冲区的大小；

* 归根结底，产生粘包、半包的**根本原因是因为 TCP 是基于字节流来传输数据的，数据包相互之间没有边界，导致接收方无法准确的分辨出每一个单独的数据包。**



#### netty 如何解决粘包半包问题

* netty 中通过提供**一系列的编解码器**来解决 TCP 的粘包、半包问题。
* 编解码器就是通过将从 TCP 套接字中读取的字节流通过一定的规则，将其进行编码或者解码，**编码成二进制字节流或者解析出一个个完整的数据包。**在 netty 中提供了很多通用的编解码器，对于解码器而言，它们均继承自抽象类**ByteToMessageDecoder**；对于编码器而言，它们均继承与抽象类**MessageToByteEncoder**。
* 解决方式：可以使用Netty自带的解码器，或者自己根据自定义协议编写解码逻辑。
* Netty 自带的拆包器【解码器】：
  * 固定长度的拆包器 FixedLengthFrameDecoder
  * 行拆包器 LineBasedFrameDecoder
  * 分隔符拆包器 DelimiterBasedFrameDecoder
  * 基于长度域拆包器 LengthFieldBasedFrameDecoder
* 解码器的原理：
  * 通过**字节缓冲累计器**不断**接收发送过来的字节**。【从TCP缓冲区读取】
  * 同时**每次累加完新接收的数据后，就尝试解码**，如果字节流不能解码，则接着累加新数据，能解码，则将解码出的对象将入到集合中，然后将对象传递给后边的处理器处理。



### Netty组件

* Channel：[Netty](https://www.nowcoder.com/jump/super-jump/word?word=Netty) 网络操作抽象类，它除了包括基本的 I/O 操作，如 bind、connect、read、write 等。

* EventLoopGroup：事件轮询组，它里面包含了一组线程，这些线程后续用来执行客户端的接入、IO数据读写等任务。
* EventLoop：用于处理 Channel 的 I/O 操作，用来处理连接的生命周期中所发生的事情。
* ChannelFuture：Netty 框架中所有的 I/O 操作都为异步的，因此我们需要 ChannelFuture 的 addListener()注册一个 ChannelFutureListener 监听事件，当操作执行成功或者失败时，监听就会自动触发返回结果。
* ChannelHandler：充当了**所有处理入站和出站数据的逻辑容器**。ChannelHandler 主要用来处理各种事件，这里的事件很广泛，比如可以是连接、数据接收、异常、数据转换等。 
* ChannelPipeline：为 ChannelHandler 链提供了容器，当 channel 创建时，就会被自动分配到它专属的 ChannelPipeline，这个关联是永久性的。



### 服务端Channel初始化过程：

https://mp.weixin.qq.com/s?__biz=MzI4Mjg2NjUzNw==&mid=2247483908&idx=1&sn=dc6df8114dd3481958c675417a088449&scene=21#wechat_redirect

* serverBootstrap.channel(NioServerSocketChannel.class)方法，该

  方法会创建一个ReflectiveChannelFactory，其用于后续反射创建channel。

* ServerBootstrap的bind()方法，其会初始化服务端的channel，注册channel到selector上，然后绑定端口，启动服务端。

* 构造channel是由ReflectiveChannelFactory通过NioServerSocketChannel的无参构造器进行，其会初始化channel的id、NioMessageUnsafe对象、Pipeline。

* 构造完channel后，ServerBootstrap会为Channel设置`options、attr`等属性，还会往该channel的Pipeline中添加一个处理器，该处理器负责添加自定义的NettyServerHandler和开启线程任务添加ServerBootstrapAcceptor【负责所有新连接的接入】到管道中。当后面channel注册到Selector上后，该处理器会被调用，然后该处理器将从管道中移除。



### 服务端Channel注册过程

https://mp.weixin.qq.com/s?__biz=MzI4Mjg2NjUzNw==&mid=2247483924&idx=1&sn=b37fc390716fedb1729e8f97ad1c1114&scene=21#wechat_redirect

* bind()方法将会给Channel绑定eventLoop，所有的操作均由这个线程来执行。
* 然后由这个线程来进行注册，注册过程中，其会将服务端Channel注册到了多路复用器Selector上，同时还会回调之前初始化时添加的处理器的`handlerAdded()`方法。
* 再然后该线程会调用之前初始化添加的处理器的channelRegistered()方法，其会调用initChannel(channel)方法，进行添加我们为服务端设置的handler和ServerBootstrapAcceptor，方法执行完后，该处理器会从管道中移除。



### 服务端Channel端口绑定过程以及如何将服务端Channel 感兴趣的事件设置为 **OP_ACCEPT**

https://mp.weixin.qq.com/s/p3ZouaQ_x6NgyVMWw4tJ0g

* 如果initAndRegister() 方法已经完全执行完，则进行端口绑定，否则将添加一个监听器监听是否执行完，监听到执行完后，将进行端口绑定。
* 其会通过 NioEventLoop 线程来异步进行端口绑定，最终将由NioMessageUnsafe 类的 bind()方法进行绑定。
* 一旦绑定完成后，将在 pipeline 中从head节点开始传播执行 handler 的 chanelActive()方法。
* 然后将从pipeline中从尾到头开始传播，一次调用pipeline中的handler的read()方法，最终在head节点通过或运算进行连接事件注册，这样服务端 channel 感兴趣的事件就是 **OP_ACCEPT** 事件。





## 负载均衡定义

* 将负载（请求任务）均衡到各个运行同一服务的机器上。

## 负载均衡了解哪些

* RandomLoadBalance:随机负载均衡。随机的选择一个。【Dubbo的**默认**负载均衡策略，Dubbo的随机负载均衡策略不会让每个服务被选到的概率一样，而是**对每个服务设置权重，权重高的被选到的概率高**，权重一般根据某个机器性能设置】

  好处：实现简单，水平扩展方便

* RoundRobinLoadBalance:轮询负载均衡。依次调用所有服务提供者。【Dubbo的轮询负载均衡策略也有权重的概念，具体实现：轮询指针对权重和取余，指向某部分权重对应的服务】

  缺点：某台机器处理得很慢，后续轮询到该台机器的请求都会滞留。

* LeastActiveLoadBalance:最少活跃调用数。通过为每个机器设置活跃调用数即正在请求数，让活跃调用数更少的优先被调用，活跃调用数相同的随机调用。

  好处：使处理慢的机器收到更少请求

* 一致性Hash算法：添加删除机器前后映射关系一致，当然，**不是严格一致**。实现的关键是**环形Hash空间**。将数据和机器都hash到环上，数据映射**到顺时针离自己最近的机器中。**这样无论是新增主机还是删除主机,**被影响的都是离那台主机最近的那些节点,其他节点映射关系没有影响。**

  好处：相同请求参数的访问，发送到同一个Provider，Provider可以对数据进行缓存，减少访问数据库或分布式缓存的次数。**减少对数据库，缓存等中间件的依赖和访问次数**，同时减少了网络IO操作，**提高系统性能。**

  数据的哈希参数一般是方法参数，节点的哈希主要是IP地址，实际上是**逻辑上的环形Hash空间**，通过维护一个TreeMap实现，key为Provider的Hash值，value为Provider，当方法参数的hash值映射到具体的key时，则使用该Provider，否则，则找到对应最小上界的key所对应的节点的Provider，如果不存在，则使用最小key的节点的Provider。

  保证平衡性：存在虚拟节点的概念。

  

## 负载均衡作用

* 根据集群中每个节点的负载情况将用户请求转发到合适的节点上, 以**避免单点压力过大**的问题

* 负载均衡可实现**集群** **高可用**及**伸缩性**

  ​		高可用：**某个节点故障**时，负载均衡器会**将用户请求转发到其他节点**,从而保证所有服务持续可用.

  ​		伸缩性：根据**系统整体负载情况，可以很容易地添加或移除节点。**



## 负载均衡如何保证健壮性

* **心跳机制**检测是否存在宕机节点。



## RPC和HTTP

* rpc是**远端过程调用**，其调用协议通常包含**传输协议和序列化协议。**

### 对比

* 传输协议：
  * RPC：基于HTTP协议，TCP协议
  * HTTP：就是基于HTTP协议
* 传输效率：
  * RPC：
    * 使用自定义的应用层协议，请求报文体积一般更小
    * 使用HTTP2协议，也可以很好的减少报文体积，提高效率。
  * HTTP：
    * 基于HTTP1.1协议，请求中可能会包含很多无用的内容。
    * 

