---
title: jvm chr06 类文件结构
date: 2021-12-22 18:33:37
categories:	jvm基础
tags: jvm
---

## Class类文件的结构

在 Java 中，**JVM 可以理解的代码就叫做`字节码`**（即扩展名为 `.class` 的文件），它不面向任何特定的处理器，只面向虚拟机。Java 语言通过字节码的方式，在一定程度上解决了传统解释型语言执行效率低的问题，同时又保留了解释型语言可移植的特点。所以 Java 程序运行时比较高效，而且，**由于字节码并不针对一种特定的机器**，因此，Java 程序无须重新编译便可在多种不同操作系统的计算机上运行。

**可以说`.class`文件是不同的语言在 Java 虚拟机之间的重要桥梁，同时也是支持 Java 跨平台很重要的一个原因。**

* Class文件是一组**以8个字节为基础单位的二进制流**，**各个数据项目严格按照顺序紧凑地排列在文件之中。**
* Class文件格式采用一种类似于C语言结构体的伪结构来存储数据，这种伪结构**只有两种数据类型**：“无符号数”和“表”。
  * 无符号数：属于基本的数据类型，以u1、u2、u4、u8来分别代表1个字节、2个字节、4个字节和8个字节的无符号数，无符号数可以用来描述数字、索引引用、数量值或者按照UTF-8编码构成字符串值。
  * 表**是由多个无符号数或者其他表作为数据项构成的复合数据类型**，为了便于区分，所有表的命名都习惯性地以"_info"结尾。
  * 无论是无符号数还是表，**当需要描述同一类型但数量不定的多个数据时，经常会使用一个前置的容量计数器加若干个连续的数据项的形式**，这时候称**这一系列连续的某一类型的数据为某一类型的“集合”。**

据 Java 虚拟机规范，类文件由单个 ClassFile 结构组成：

```java
ClassFile {
    u4             magic; //Class 文件的标志
    u2             minor_version;//Class 的小版本号
    u2             major_version;//Class 的大版本号
    u2             constant_pool_count;//常量池的数量
    cp_info        constant_pool[constant_pool_count-1];//常量池
    u2             access_flags;//Class 的访问标记
    u2             this_class;//当前类
    u2             super_class;//父类
    u2             interfaces_count;//接口
    u2             interfaces[interfaces_count];//一个类可以实现多个接口
    u2             fields_count;//Class 文件的字段数量
    field_info     fields[fields_count];//一个类会可以有个字段
    u2             methods_count;//Class 文件的方法数量
    method_info    methods[methods_count];//一个类可以有个多个方法
    u2             attributes_count;//此类的属性表中的属性数
    attribute_info attributes[attributes_count];//属性表集合
}

```

**Class文件字节码结构组织示意图** （之前在网上保存的，非常不错，原出处不明）：

![类文件字节码结构组织示意图](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2019/12/21/16f275b0754ae35b~tplv-t2oaga2asx-watermark.awebp)



### 魔数

```java
    u4             magic; //Class 文件的标志
```

每个 Class 文件的头四个字节称为魔数（Magic Number）

它的唯一**作用**:**确定这个文件是否为一个能被虚拟机接收的 Class 文件**。【**标志文件类型**】

* 使用魔数而不是扩展名来进行识别主要是**基于安全考虑**，因为文件扩展名可以随意改动。
* Class文件的魔数取得很有”浪漫气息“，值为0xCAFEBABE。



### Class 文件版本

```java
    u2             minor_version;//Class 的小版本号
    u2             major_version;//Class 的大版本号
```

紧接着魔数的四个字节存储的是 Class 文件的版本号：第五和第六是**次版本号**，第七和第八是**主版本号**。

* **作用：标志jdk版本号，用于jdk兼容性的问题。**

**高版本的 Java 虚拟机可以执行低版本编译器生成的 Class 文件，但是低版本的 Java 虚拟机不能执行高版本编译器生成的 Class 文件。**所以，我们在实际开发的时候要确保开发的的 JDK 版本和生产环境的 JDK 版本保持一致。



### 常量池

```java
    u2             constant_pool_count;//常量池的数量
    cp_info        constant_pool[constant_pool_count-1];//常量池
```

* 紧接着主次版本号之后的是常量池，常量池的数量是 constant_pool_count-1（**常量池计数器是从1开始计数的，将第0项常量空出来是有特殊考虑的，索引值为0代表“不引用任何一个常量池项”**）。

  举例： 匿名内部类本身没有类名称， 进行名称引用时会将index指向0； **Object类的文件结构的父类索引指向0**  

* 常量池可以比喻为Class文件里的资源仓库，它是**Class文件结构中与其他项目关联最多的数据**

* 常量池主要存放两大常量：**字面量和符号引用**。字面量比较接近于 Java 语言层面的的常量概念，如文本字符串、声明为 final 的常量值等。而符号引用则属于编译原理方面的概念。包括下面三类常量：
  * 类和接口的全限定名
  * 字段的名称和描述符
  * 方法的名称和描述符

* 虚拟机加载Class文件的时候进行**动态连接**,即**在Class文件中不会保存各个方法,字段最终在内存中的布局信息**,这些字段,方法的符号引用**不经过虚拟机在运行期转换的话是无法得到真正的内存入口地址.**

* 当虚拟机做类加载时,将会从常量池获得对应的符号引用,再**在类创建时或运行时解析翻译到具体的内存地址之中.**

* 常量池中每一项常量都是一个表，这14种表有一个共同的特点：**开始的第一位是一个 u1 类型的标志位 -tag 来标识常量的类型，代表当前这个常量属于哪种常量类型．**

| 类型                             | 标志（tag） | 描述                   |
| -------------------------------- | ----------- | ---------------------- |
| CONSTANT_utf8_info               | 1           | UTF-8编码的字符串      |
| CONSTANT_Integer_info            | 3           | 整形字面量             |
| CONSTANT_Float_info              | 4           | 浮点型字面量           |
| CONSTANT_Long_info               | ５          | 长整型字面量           |
| CONSTANT_Double_info             | ６          | 双精度浮点型字面量     |
| CONSTANT_Class_info              | ７          | 类或接口的符号引用     |
| CONSTANT_String_info             | ８          | 字符串类型字面量       |
| CONSTANT_Fieldref_info           | ９          | 字段的符号引用         |
| CONSTANT_Methodref_info          | 10          | 类中方法的符号引用     |
| CONSTANT_InterfaceMethodref_info | 11          | 接口中方法的符号引用   |
| CONSTANT_NameAndType_info        | 12          | 字段或方法的符号引用   |
| CONSTANT_MothodType_info         | 16          | 标志方法类型           |
| CONSTANT_MethodHandle_info       | 15          | 表示方法句柄           |
| CONSTANT_InvokeDynamic_info      | 18          | 表示一个动态方法调用点 |

* 这14中常量类型**各自有着完全独立的数据结构**,**两两之间并没有什么共性和联系.**
* `.class` 文件可以通过`javap -v class类名` 指令来看一下其常量池中的信息(`javap -v class类名-> temp.txt` ：将结果输出到 temp.txt 文件)。

* CONSTANT_utf8_info存储字符串数据，最大长度为64KB，故方法名最大长度为64KB。
* 





### 访问标志

在常量池结束之后，紧接着的两个字节代表访问标志，

作用：这个标志用于**识别一些类或者接口层次的访问信息**。

包括：这个 Class 是类还是接口，是否为 public 或者 abstract 类型，如果是类的话是否声明为 final 等等。

类访问和属性修饰符:

![类访问和属性修饰符](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2019/12/21/16f275b0a0651cc4~tplv-t2oaga2asx-watermark.awebp)

我们定义了一个 Employee 类

```java
package top.snailclimb.bean;
public class Employee {
   ...
}
```

通过`javap -v class类名` 指令来看一下类的访问标志。



![查看类的访问标志](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2019/12/21/16f275b0c3221bb1~tplv-t2oaga2asx-watermark.awebp)



### 当前类索引,父类索引与接口索引集合

```java
u2             this_class;//当前类索引
u2             super_class;//父类索引
u2             interfaces_count;//接口计数器
u2             interfaces[interfaces_count];//一个类可以实现多个接口
```

作用：**类索引用于确定这个类的全限定名，父类索引用于确定这个类的父类的全限定名，由于 Java 语言的单继承，所以父类索引只有一个，除了 `java.lang.Object` 之外，所有的 java 类都有父类，因此除了 `java.lang.Object` 外，所有 Java 类的父类索引都不为 0。**

**具体寻址**：**索引指向常量池的CONSTANT_UTF8_INFO中。【先指向CONSTANT_CLASS_INFO】**

**接口索引集合用来描述这个类实现了那些接口，这些被实现的接口将按`implents`(如果这个类本身是接口的话则是`extends`) 后的接口顺序从左到右排列在接口索引集合中。**

* 如果该类没有实现任何接口,则接口计数器值为0,后面接口的索引表不再占用任何字节.
* 具体寻址：同类索引寻址相同，不过是先找CONTANT_INTEFACES_INFO。



### 字段表集合

```java
u2             fields_count;//Class 文件的字段的个数
field_info     fields[fields_count];//一个类会可以有个多个字段
```

作用：字段表（field info）用于**描述接口或类中声明的变量**。**字段包括类级变量以及实例变量**，但**不包括在方法内部声明的局部变量。**

* **access_flags:**  字段的作用域（`public` ,`private`,`protected`修饰符），是实例变量还是类变量（`static`修饰符）,可否被序列化（transient 修饰符）,可变性（final）,可见性（volatile 修饰符，是否强制从主内存读写）。
* **name_index:** 对常量池的引用，表示的字段的名称；
* **descriptor_index:** 对常量池的引用，表示字段和方法的描述符；
* **attributes_count:** 一个字段还会拥有一些额外的属性，attributes_count 存放属性的个数；
* **attributes[attributes_count]:** 存放具体属性具体内容。
  * 对于static final 修饰的常量值。
  * **属性表可以中有常量值属性，即字段表中的某个字段后面跟着的属性表记录了该字段的常量值。**【这样在类加载之前改常量就可以使用了】



  上述这些信息中，各个修饰符都是布尔值，要么有某个修饰符，要么没有，很适合使用标志位来表示。**而字段叫什么名字、字段被定义为什么数据类型这些都是无法固定的，只能引用常量池中常量来描述。**

* 描述符:用来描述字段的**数据类型**,方法的参数列表 (包括数量,类型以及顺序)和返回值
* 全限定名:把类全名的"."替换成"/"而已,如"org/fenixsorf/clazz/TestClass";  ";"用于表示全限定名的结束.[详情看书]

**字段的 access_flags 的取值:**



![字段的access_flags的取值](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2019/12/21/16f275b10cc05ebb~tplv-t2oaga2asx-watermark.awebp)



### 方法表集合

```java
    u2             methods_count;//Class 文件的方法的数量
    method_info    methods[methods_count];//一个类可以有个多个方法
```

**作用：记录类的声明的方法信息。**

methods_count 表示方法的数量，而 method_info 表示的方法表。

Class 文件存储格式**中对方法的描述与对字段的描述几乎采用了完全一致的方式。**方法表的结构如同字段表一样，依次包括了访问标志、名称索引、描述符索引、属性表集合几项。

**method_info(方法表的) 结构:**



![方法表的结构](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2019/12/21/16f275b1353a9700~tplv-t2oaga2asx-watermark.awebp)



**方法表的 access_flag 取值：**

![方法表的 access_flag 取值](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2019/12/21/16f275b15980fce7~tplv-t2oaga2asx-watermark.awebp)



注意：因为`volatile`修饰符和`transient`修饰符不可以修饰方法，所以方法表的访问标志中没有这两个对应的标志，但是增加了`synchronized`、`native`、`abstract`等关键字修饰方法，所以也就多了这些关键字对应的标志。

* **方法表中的属性表中的Code属性中记录着方法代码编译成的字节码指令和其长度、操作数栈的最大深度，局部变量表的需要最大空间。**



### 属性表集合

```java
   u2             attributes_count;//此类的属性表中的属性数
   attribute_info attributes[attributes_count];//属性表集合
```

**在 Class 文件，字段表，方法表中都可以携带自己的属性表集合，以用于描述某些场景专有的信息。**与 Class 文件中其它的数据项目要求的顺序、长度和内容不同，**属性表集合的限制稍微宽松一些，不再要求各个属性表具有严格的顺序，并且只要不与已有的属性名重复**，任何人实现的编译器都可以向属性表中写 入自己定义的属性信息，Java 虚拟机运行时会忽略掉它不认识的属性。

* **属性表可以中有常量值属性，即字段表中的某个字段后面跟着的属性表记录了该字段的常量值。**
