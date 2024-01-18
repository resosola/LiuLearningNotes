# 编程思想chr13字符串



## 不可变String

* 字符串String对象是**不可变**的，它是由final修饰的类，其底层实现的**char数组也是final修饰的，这意味着 value 数组初始化之后就不能再引用其它数组。且没有修改char数组中的元素的方法。**

  ```java
  public final class String
      implements java.io.Serializable, Comparable<String>, CharSequence {
      /** The value is used for character storage. */
      private final char value[];
  ```

  

* String类中每一个看似会修改值的方法，其实都是创建了一个**新的String对象**，而最初的String对象一直未变。若创建的字符串没有任何引用时，GC（垃圾回收器）将对它进行回收。

```java
String str="abc";
String str="def";
```

该过程首先创建了字符串"abc"，随后创建了字符串"def"。虽然此时的引用str指向"def"，但字符串"abc"依旧存在于字符串常量池中，并没有改变。

## 不可变的好处

* **1. 可以缓存 hash 值**
  * 不可变的特性可以使得 hash 值也不可变，因此只需要进行一次计算。
* **String Pool 的需要**
  * 只有 String 是不可变的，才可能使用 String Pool。
* **线程安全**





## 重载 ”+“与StringBuilder

* 重载的意思是，一个操作符在应用于特定的类时，被赋予了特殊的意义。

* String对象具有只读特性，所以指向它的任何应用都不可能改变它的值

* 字符串+操作时编译器会自动引入StringBuilder类使用，因为它更高效。

* 当你为一个类编写toString()方法时，如果字符串操作比较简单，那就可以信赖编译器，它会为你合理构造最终的字符串结果。但是，如果你要在toString()方法中使用循环，那么最好自己创建一个StringBuilder对象，用它来构造最终的结果。
* StringBuilder是java5引入的，之前使用的是StringBuffer。后者是线程安全的，因此开销也会大些。



##  String, StringBuffer and StringBuilder

**1. 可变性**

- String 不可变
- StringBuffer 和 StringBuilder 可变

**2. 线程安全**

- String 不可变，因此是线程安全的
- StringBuilder 不是线程安全的
- StringBuffer 是线程安全的，内部使用 synchronized 进行同步



## String.intern()

* 使用 String.intern() 可以保证**相同内容的字符串变量**引用**同一的内存对象。**其返回的**可能是堆对象地址，也可能是一个字符串常量池对象地址。**

* ```java
  /**
       * Returns a canonical representation for the string object.
       * <p>
       * A pool of strings, initially empty, is maintained privately by the
       * class {@code String}.
       * <p>
       * When the intern method is invoked, if the pool already contains a
       * string equal to this {@code String} object as determined by
       * the {@link #equals(Object)} method, then the string from the pool is
       * returned. Otherwise, this {@code String} object is added to the
       * pool and a reference to this {@code String} object is returned.
       * <p>
       * It follows that for any two strings {@code s} and {@code t},
       * {@code s.intern() == t.intern()} is {@code true}
       * if and only if {@code s.equals(t)} is {@code true}.
       * <p>
       * All literal strings and string-valued constant expressions are
       * interned. String literals are defined in section 3.10.5 of the
       * <cite>The Java&trade; Language Specification</cite>.
       *
       * @return  a string that has the same contents as this string, but is
       *          guaranteed to be from a pool of unique strings.
       */
      public native String intern();
  ```

* 注释写的很详细了，如果字符串常量池中有相同的字符串则返回常量池中相同的字符串对象【引用地址】，如果不存在相同字符串，则直接将该字符串加入字符串常量池，然后返回该字符串在常量池中的引用。

  【**使用引号声明的字符串都是会直接在字符串常量池中生成**】

  注意：字符串常量池中的对象地址和Heap区域的对象地址肯定是不一样。

  ```java
  String a = new String("1");// 常量池会创建"1"对象，堆中会创建"1"对象 两者地址不同。。
  ```

  

* jdk1.7以前，字符串常量池被放在运行时常量池中，它属于永久代。

  即使内容相同，但使用字符串常量池中的对象和new出来的对象比较，肯定也是不同的，因为地址不同【常量池和堆】

  **永久代的空间有限，在大量使用字符串的场景下会导致 OutOfMemoryError 错误。**

* jdk1.7及之后，字符串常量池移动到了堆区域，字符串常量池不一定需要创建对象了，如果有一个Heap区域的对象执行intern方法，则字符串常量池中就会直接存储堆中的引用，其指向对应堆中的对象。

* https://tech.meituan.com/2014/03/06/in-depth-understanding-string-intern.html



## 无意识的递归

* 如果想打印出对象的内存地址，应该调用Object.toString()方法，所以不该使用this，而是应该调用super.toString()方法。

* 使用this时toString方法将调用this对象的toString方法进而造成递归调用，将会抛出异常。

  ```java
  class A{
      public String toString(){
      return "address is "+this;
  }
  }
  
  public static void main(String[] args){
      A a = new A();
      System.out.println(a);
  }
  ```

  

## 基于Formatter的格式化输出

使用方法

```java
Formatter formatter = new Formatter([destination]);//对应输出目的地

formatter.format(String format, Object…args);
```

* format格式如下，**%[argument_index$][flags][width][.precision]conversion**



## 正则表达式

正则表达式是一种强大而灵活的文本处理工具。使用正则表达式，我们能够以编程的方式，构造复杂的文本模式，并对输入的字符串进行搜索。注意，正则表达式中的"\"表示一个""符号。

在String类中，使用到正则表达式的方法由以下几种，

- **matchs(regex expression)**查看字符串是否匹配给定的正则表达式，例如，

```php
//正则表达式:检查一个句子或者字符串是否以大写字母开头,以句号结尾.
//^[A-Z].* 开头A-Z任意字符，^起始
//.*[\\.]$ 任意字符后有.结尾， $结尾
System.out.println(Splitting.knights.matches("^[A-Z].*[\\.]$");
```

- **replaceFirst(regex,String)**，用给定的字符串替换与给定的 [regex expression]匹配的此字符串的**第一个**子字符串。
   如：str.replaceFirst("f\w+","hi")，表示将字符串中以f开头的第一个单词，替换成hi。
- **replaceAll(regex,String)**，用给定的字符串替换与给定的 [regex expression]匹配的此字符串的**每一个**子字符串。
   如：str.replaceAll("a|o|e|i|u","_")，表示将字符串中的所有元音字母用下划线替换

**1.2**常用符号

![img](https://upload-images.jianshu.io/upload_images/21874476-fa018122ee871afc.png?imageMogr2/auto-orient/strip|imageView2/2/w/1093/format/webp)



![img](https://upload-images.jianshu.io/upload_images/21874476-232c0301eac657c2.png?imageMogr2/auto-orient/strip|imageView2/2/w/1089/format/webp)

## 扫描输入

jdk1.5加入了Scanner类，可以大大减轻扫面输入的工作负担，语法结构如下

```cpp
Scanner sc = new Scanner(System.in);
//通过控制台键入信息
```

值得注意的是，除了上述的输入方式，Scanner本身可以接受几乎所有类型的输入对象，其中就包括File对象，InputStream，String等等。

方法：

- **next()**
- **hasNext()**
- **nextLine()**
- **hasNextLine()**
- **nextInt(),nextDouble()等等**
- **hasNextInt(),hasNextDouble()等等，注意这些方法可以用来验证输入数据类型的正确性**

接下来，主要讲一讲**next和nextLine的区别**，
  next():只读取输入直到空格。它不能读两个由空格或符号隔开的单词。此外，next()在读取输入后将光标放在同一行中。(next()只读空格之前的数据,并且光标指向本行)
  nextLine():读取输入，包括单词之间的空格和除回车以外的所有符号(即。它读到行尾)。读取输入后，nextLine()将光标定位在下一行。



## 字符串常量与对象解析

```java
public class StringDemo{
 private static final String MESSAGE="taobao";
 public static void main(String [] args) {
  String a ="tao"+"bao";
  String b="tao";
  String c="bao";
  System.out.println(a==MESSAGE);
  System.out.println((b+c)==MESSAGE);
 }
}
```

对于这道题，考察的是对String类型的认识以及编译器优化。Java中String不是基本类型，但是有些时候和基本类型差不多，如String b = "tao" ; 可以对变量直接赋值，而不用 new 一个对象（当然也可以用 new）。所以String这个类型值得好好研究下。

Java中的变量和基本类型的值存放于栈内存，而new出来的对象本身存放于堆内存，指向对象的引用还是存放在栈内存。例如如下的代码：

**int** i=1;

  String s = **new** String( "Hello World" );

变量i和s以及1存放在栈内存，而s指向的对象”Hello World”存放于堆内存。

 

 

[![img](http://static.oschina.net/uploads/img/201305/28181619_ugB3.jpg)](http://static.oschina.net/uploads/img/201305/28181619_ugB3.jpg)

 

 

栈内存的一个特点是数据共享，这样设计是为了减小内存消耗，前面定义了i=1，i和1都在栈内存内，如果再定义一个j=1，此时将j放入栈内存，然后查找栈内存中是否有1，如果有则j指向1。如果再给j赋值2，则在栈内存中查找是否有2，如果没有就在栈内存中放一个2，然后j指向2。也就是如果常量在栈内存中，就将变量指向该常量，如果没有就在该栈内存增加一个该常量，并将变量指向该常量。

 

 

[![img](http://static.oschina.net/uploads/img/201305/28181619_TJmL.jpg)](http://static.oschina.net/uploads/img/201305/28181619_TJmL.jpg)

如果j++，这时指向的变量并不会改变，而是在栈内寻找新的常量（比原来的常量大1），如果栈内存有则指向它，如果没有就在栈内存中加入此常量并将j指向它。这种基本类型之间比较大小和我们逻辑上判断大小是一致的。如定义i和j是都赋值1，则i==j结果为true。==用于判断两个变量指向的地址是否一样。i==j就是判断i指向的1和j指向的1是同一个吗？当然是了。对于直接赋值的字符串常量（如String s=“Hello World”；中的Hello World）也是存放在栈内存中，而new出来的字符串对象（即String对象）是存放在堆内存中。如果定义String s=“Hello World”和String w=“Hello World”，s==w吗？肯定是true，因为他们指向的是同一个Hello World。

 

[![img](http://static.oschina.net/uploads/img/201305/28181619_E8BZ.jpg)](http://static.oschina.net/uploads/img/201305/28181619_E8BZ.jpg)

 

堆内存没有数据共享的特点，前面定义的String s = **new** String( "Hello World" );后，变量s在栈内存内，Hello World 这个String对象在堆内存内。如果定义String w = **new** String( "Hello World" );，则会在堆内存创建一个新的String对象，变量w存放在栈内存，w指向这个新的String对象。堆内存中不同对象（指同一类型的不同对象）的比较如果用==则结果肯定都是false，比如s==w？当然不等，s和w指向堆内存中不同的String对象。如果判断两个String对象相等呢？用equals方法。

 

 

[![img](http://static.oschina.net/uploads/img/201305/28181619_uF6N.jpg)](http://static.oschina.net/uploads/img/201305/28181619_uF6N.jpg)

 

说了这么多只是说了这道题的铺垫知识，还没进入主题，下面分析这道题。 MESSAGE 成员变量及其指向的字符串常量肯定都是在栈内存里的，变量 a 运算完也是指向一个字符串“ taobao ”啊？是不是同一个呢？这涉及到编译器优化问题。对于字符串常量的相加，在编译时直接将字符串合并，而不是等到运行时再合并。也就是说

String a = "tao" + "bao" ;和String a = "taobao" ;编译出的字节码是一样的。所以等到运行时，根据上面说的栈内存是数据共享原则，a和MESSAGE指向的是同一个字符串。而对于后面的(b+c)又是什么情况呢？b+c只能等到运行时才能判定是什么字符串，编译器不会优化，想想这也是有道理的，编译器怕你对b的值改变，所以编译器不会优化。运行时b+c计算出来的"taobao"和栈内存里已经有的"taobao"是一个吗？不是。b+c计算出来的"taobao"应该是放在堆内存中的String对象。这可以通过System. *out* .println( (b+c)== *MESSAGE* );的结果为false来证明这一点。如果计算出来的b+c也是在栈内存，那结果应该是true。Java对String的相加是通过StringBuffer实现的，先构造一个StringBuffer里面存放”tao”,然后调用append()方法追加”bao”，然后将值为”taobao”的StringBuffer转化成String对象。StringBuffer对象在堆内存中，那转换成的String对象理所应当的也是在堆内存中。下面改造一下这个语句System. *out* .println( (b+c).intern()== *MESSAGE* );结果是true， intern() 方***先检查 String 池 ( 或者说成栈内存 ) 中是否存在相同的字符串常量，如果有就返回。所以 intern()返回的就是*MESSAGE*指向的"taobao"。再把变量b和c的定义改一下，

**final** String b = "tao" ;

​     **final** String c = "bao" ;

​      

​    System. *out* .println( (b+c)== *MESSAGE* );

现在b和c不可能再次赋值了，所以编译器将b+c编译成了”taobao”。因此，这时的结果是true。

在字符串相加中，只要有一个是非final类型的变量，编译器就不会优化，因为这样的变量可能发生改变，所以编译器不可能将这样的变量替换成常量。例如将变量b的final去掉，结果又变成了false。这也就意味着会用到StringBuffer对象，计算的结果在堆内存中。

  如果对指向堆内存中的对象的String变量调用intern()会怎么样呢？实际上这个问题已经说过了，(b+c).intern()，b+c的结果就是在堆内存中。对于指向栈内存中字符串常量的变量调用intern()返回的还是它自己，没有多大意义。它会根据堆内存中对象的值，去查找String池中是否有相同的字符串，如果有就将变量指向这个string池中的变量。

String a = "tao"+"bao";

​    String b = new String("taobao");

   

   System.out.println(a==MESSAGE); //true

   System.out.println(b==MESSAGE); //false

   

   b = b.intern();

   System.out.println(b==MESSAGE); //true

System. *out* .println(a==a.intern()); //true



## 面试相关

* 字符串中的\0被编译为\u0000,表示一个空字符。

  ```java
  String s = "abs\0"; // 可以通过编译
  ```

  

