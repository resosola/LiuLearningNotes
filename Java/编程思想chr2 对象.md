# 编程思想2 对象

## 2.1-2.2 用引用操纵对象

* Java中一切都被视为对象，尽管一切都是对象，但操作的标识符实际上是对象的一个引用（Reference），引用用于与对象关联（也不一定需要有对象关联);

  ```java
  String s ;//创建一个String类型的引用
  s = new String("abc") ; //将该引用与对象关联
  String a = new String("asd");//创建一个引用的同时进行初始化
  ```

* new关键字表示通用的创建类型的方式

* Java 的参数是以值传递的形式传入方法中，而不是引用传递。**存储的是对象的地址。**



### 2.2.1 对象存储的地方

**五个存储数据的不同地方**

* 寄存器
  * 最快的存储区，位于处理器内部，不能直接控制
* 堆栈
  * 位于通用RAM（随机访问存储器）中，某些java数据存储于堆栈中（特别是对象引用），但java对象并不存储于其中
* 堆
  * 一种通用的内存池（也位于RAM区），用于存放所有的Java对象，new操作时会自动在堆里进存储分配。
* 常量存储
  * 常量值通常直接存放在程序代码内部
* 非RAM存储

### 2.2.2 特例：基本类型

* 某些小的、简单的变量无需存储在堆中，也无需创建引用，它们需要特殊对待，它们的类型**为基本类型，这些变量直接存储值，并置于堆栈中，这样更加高效**

* 所有基本数值类型都有正负号，所以不要去寻找无符号的数值类型。

* **String不是基本类型**

  * String内部是用char[]数组实现的，不过结尾不用\0。

* [Java](http://lib.csdn.net/base/javase)中的char是Unicode编码。Unicode编码占两个字节，就是16位，足够存储一个汉字。

  * ```java
    int a ='2';//这里的字符为ASCII码 50
    ```

  * 一个简便的记忆法：0：48  A:65  a:97，数字连起来是486597

* boolean类型**所占存储空间的大小没有明确指定**，仅定义为能过获取字面值ture和false

* **基本类型具有的包装器类**，使得可以在**堆中创建一个对象，用来表示对应的基本类型。**

* 在java里面 float类型数据类型初始化时必须使用后缀f  因为**java默认浮点型是double**  用后缀f表示为float类型； 

  ```java
  // float f = 0.0; // complie error
  float f = 0.0f;
  ```

* 

变量名称 字节 位数

byte 1 8

short 2 16

int 4 32

long 8 64

float 4 32

double 8 64

char 2 16

boolean 1 8

解释一下boolean占多大的空间，JVM规范给出的是4个字节也就是单个boolean当做int处理，boolean数组1个字节的定义，具体还要看虚拟机实现是否按照规范来，1个字节、4个字节都是有可能的。其实这就是运算效率与存储空间之间的博弈





#### 高精度数字

* 两个用于**高精度计算**的类：BigInteger和BigDecimal，大体属于包装器类，但没有对应的基本类型

* 这两个类所包含的方法，提供的操作与对基本类型所能执行的操作类似，也就是，能作用于int和float上的操作，也同样能作用于BigInteger和BigDecimal，只不过必须以**调用方法的方式**进行。

* BigInteger支持**任意精度的整数**，在运算中可以准确表示任何大小的整数值，而不会丢失任何信息。

* BigDecimal支持**任何精度的定点数**，常用于精确的货币计算。

* 基本使用

  ```java
   //将十进制字符串表示的整数形式转换为 BigInteger，该类同样是不可变的 可以对超过Integer范围内的数据进行运算。
          BigInteger bi1 = new BigInteger("1000");
          BigInteger bi2 = new BigInteger("3");
          System.out.println(bi1.add(bi2));
          System.out.println(bi1.subtract(bi2));
          System.out.println(bi1.multiply(bi2));
          System.out.println(bi1.divide(bi2));
          System.out.println(bi1.remainder(bi2));
          //1003
          //997
          //3000
          //333
          //1
  
  
          //BigDecimal表示不可变的、任意精度的有符号十进制数，可以解决浮点型数据运算数据丢失问题。
          BigDecimal bd1 = new BigDecimal("0.08");
          BigDecimal bd2 = new BigDecimal("0.022");
          System.out.println(bd1.add(bd2));
          System.out.println(bd1.subtract(bd2));
          System.out.println(bd1.multiply(bd2));
          //精确运算 可能出现无限循环小数 可以设置保留几位小数 和摄入模式
          //这里为保留7位小数，并向远离0的方向舍入
          System.out.println(bd1.divide(bd2, 7, BigDecimal.ROUND_UP));
  ```

### 2.2.3 Java中的数组

* java确保数组会被初始化，而且不能在它的范围之外被访问。

* 当创建一个数组对象时，实际上就是创建了一个引用数组，并且每个引用都会自动被初始化为一个特定值（null);

  ```java
  Stuend[] s = new Student[19];//创建数组对象 每个引用被初始化为null
  ```

* 基本数据类型数组的初始化为值全部置0



## 2.4 类

### 字段和方法

字段：也叫数据成员，如果是对某个对象的引用，必须**初始化该引用**，以便与某个实际对象关联，默认会初始化为null，如果是**基本数据类型，**即使没有初始化，java也会给予一个**默认值。**（上面确保初始化的方法并不适用于局部变量）

方法：也叫成员函数，方法的基本组成部分包括：（名称、参数列表、返回值和方法体），方法名和参数列表（合起来称为**方法签名**）**唯一地标识某个方法**。



## 2.6.3 static关键字

* 当一段代码被声明为static时，就意味着这个域或方法**不会被包含它的那个类的任何对象实例关联在一起**。其只有一份存储空间

* static声明后即可通过对象调用，也可通过类名直接调用。

* 而非static域或方法必须与某一特定对象关联

* 构造器也是static方法，尽管static关键字并没有显示地写出来。

* **一般方法是可以访问静态方法的，但是静态方法必须访问静态的。**

* **static方法无法被子类重写**，**重写是对于对象而言的**，static并不与某个对象关联。【java中除了static方法和final方法（private方法属于final方法）外，都是后期绑定】

* 在java中静态方法中不能使用非静态方法和非静态变量。但非静态方法中可以使用静态变量

* Test test=null;**这里也会加载静态方法，所以test数据中包含Test类的静态初始化数据,但是test并不能调用该类的非静态数据**

  ```java
  链接：https://www.nowcoder.com/questionTerminal/733630b017f74bf3bcf54dc8a82dc3cf
  来源：牛客网
  
  class Test {
      public static void hello() {
          System.out.println("hello");
      }
  }
  public class MyApplication {
      public static void main(String[] args) {
          // TODO Auto-generated method stub
          Test test=null;
          test.hello();
      }
  }
  ```

* 通过类名调用静态数据成员时需确保有相应的访问权限【private、public、default、protected】

* 非静态内部类无法申明静态变量，静态内部类内部才可以申明静态成员，因为**内部类其实就是类变量**，非静态内部类实现依赖于外部类，相当于外部类的一个非静态属性，所以其初始化依赖于外部类的实例化。



## 包装器

* 编译器会**在缓冲池范围内的基本类型** **自动装箱**过程调用 valueOf() 方法

* 基本类型对应的缓冲池如下:
  - boolean values true and false
  - all byte values 【一个字节表示即 -128 and 127】
  - short values between -128 and 127
  - int values between -128 and 127
  - char in the range \u0000 to \u007F 【即整型0 and 127】
  - 在使用这些基本类型对应的包装类型时，就可以直接使用缓冲池中的对象。



## Integer相关

* 不变类,底层封装不变的int

  ```java
   private final int value;
  ```

* 使用Integer a = 1;或Integer a = Integer.valueOf(1); **在值介于-128至127直接时，作为基本类型。**

  使用Integer a = new Integer(1); 时，无论值是多少，都作为对象。

* 只有**运算操作符，才会自动拆封箱** 其他操作符并不会





## 面试相关

### 数据赋值

* float基本类型赋值必须在数据尾部加'F'或'f'，因为小数默认为double，从**大类型到小类型必须强转**。【**Java 不能隐式执行向下转型，因为这会使得精度降低。】**

```JAVA
float f = 45.0;// 错误
float f1 = (float)45.0; 或 float f2 = 45.0f;
```

* char类型可以用\u+Unicode编码来表示一个字符，数字是十六进制的。

```java
char s = '\u0639';
```

* 可以把**任何一种数据类型的变量赋给Object类型的变量**，因为java所有类默认继承Object，基本数据类型赋值给Object会先装箱，装箱之后就是Object的子类了；

```java
Object s = 1; // 会自动装箱【Integer.valueOf(1)】
```

* 自动装箱的约束

  * 自动装箱规则: **Double Integer Long Float只接受自己基础类型的数据**(double int long float) 
  * **Character Short Byte 都可以接受char int short byte四种基础数据类型直接封装**

  ```java
  Integer i=100;//没有问题
  Integer i2=100.0;//报红杠，因为默认是double
  Integer i3=(byte)100;//报红杠
  
  Short s = (byte) 100;//没有问题，是不是很神奇？说明上面的规律对Short不适用
  
  Double d=100; //报红杠
  Double d=100.0;//没有问题
  Double d=100.0f;//报红杠
  
  double d=100;//没有问题，100是int类型，自动转换为double.
  Double d=Double.valueOf("100"); //正确
  Double d=Double.valueOf(100);//正确
  Double d=new Double(100);//正确
  ```

* **整数数值表达式默认为int类型**，如果**表达式中有其他类型则整体类型为最大的类型【数值当成int】**

  ```java
  int a = 1+3;  // 表达式结果为int类型
  ```

  * 溢出问题：表达式中有变量时可能会产生溢出问题【二分时】

    ```java
    int middle = (left+right)/2 ; // left+right 的结果可能溢出
    // 正确写法
    int middle = left + (right-left)/2;
    int middle = ((right - left) >>> 1) + left;
    ```



### 隐式类型转换

* 对于**byte、char、short类型**直接赋值操作，**赋予int类型的值不超过这些类型的取值范围，那系统就会自动进行数据类型转换了；**

  ```java
  byte a = 100; // 等价于 byte a = (byte)100;
  ```

  **不过当赋予的值超过了byte类型的取值范围，那就要手动进行数据类型转换了，不然系统程序就报错了；**

  ```java
  byte b = 128; // 异常
  ```



* 复合表达式的非fianl变量的类型会自动提升，关于类型的自动提升，注意下面的规则。

  ①所有的byte,short,char型的值将被提升为int型；

  ②如果有一个操作数是long型，计算结果是long型；

  ③如果有一个操作数是float型，计算结果是float型；

  ④如果有一个操作数是double型，计算结果是double型；

  而声明为final的变量会被JVM优化，以下第3行相当于 b6 = 10

  常量：编译时常量  final int a = 3*2;【编译时确定】、运行时常量 final int b = new Random(100);

  ```java
  byte b1=1,b2=2,b3,b6; 
  final byte b4=4,b5=6; 
  b6=b4+b5; 
  b3=(b1+b2); // 需要手动转化 因为 (b1+b2)为int类型
  System.out.println(b3+b6);
  ```

  



* **复合赋值操作符如 +=、-=、*=、/= 具有隐式类型转换。**

  ```java
  short s1 = 1;
  // s1 = s1 + 1; // 这就不能通过编译因为(s1+1)表达式的计算结果为int类型，需要向下转型
  s1 += 1;
  
  ```

  上面的语句相当于将 s1 + 1 的计算结果进行了**向下转型**:

  ```java
  s1 = (short) (s1 + 1);
  
  ```

  官方的解析：A compound assignment expression of the form `E1 op= E2` is equivalent to `E1 = (T) ((E1) op (E2))`, where T is the type of `E1`, except that `E1` is evaluated only once.



### 标识符相关

* Java中标识符有**字母、数字、美元符号$、下划线4**种，**不能以数字开头**，不能用保留字和关键字





### Object对象

* equals()：对任何不是 null 的对象 x 调用 x.equals(null) 结果都为 false
*  hashCode()：等价的两个对象散列值一定相同，但是散列值相同的两个对象不一定等价。
* clone()：浅拷贝方式![img](https://upload-images.jianshu.io/upload_images/15856169-88bd5975eafaa488.png?imageMogr2/auto-orient/strip|imageView2/2/w/600/format/webp)

​		浅拷贝：拷贝对象和原始对象的**引用类型**成员变量为同一个对象。

​		深拷贝：拷贝对象和原始对象的**引用类型**成员变量不同对象。

