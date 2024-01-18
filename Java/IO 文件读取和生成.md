# IO 文件读取和生成

## IO流的分类

根据处理数据类型的不同分为：字符流和字节流

根据数据流向不同分为：输入流和输出流

### 字符流和字节流

字符流的由来： 因为数据编码的不同，而有了对字符进行高效操作的流对象。本质其实就是基于字节流读取时，去查了指定的码表。字节流和字符流的区别：

（1）读写单位不同：字节流以字节（8bit）为单位，字符流以字符为单位，根据码表映射字符，一次可能读多个字节。

（2）处理对象不同：字节流能处理所有类型的数据（如图片、avi等），而字符流只能处理字符类型的数据。

（3）字节流在操作的时候本身是不会用到缓冲区的，是文件本身的直接操作的；而字符流在操作的时候下后是会用到缓冲区的，是通过缓冲区来操作文件，我们将在下面验证这一点。

结论：优先选用字节流。首先因为硬盘上的所有文件都是以字节的形式进行传输或者保存的，包括图片等内容。但是字符只是在内存中才会形成的，所以在开发中，字节流使用广泛。

### 输入流和输出流

对输入流只能进行读操作，对输出流只能进行写操作，程序中需要根据待传输数据的不同特性而使用不同的流。

## 读写文件

如前所述，一个流被定义为一个数据序列。输入流用于从源读取数据，输出流用于向目标写数据。

下图是一个描述输入流和输出流的类层次图。

![img](https://www.runoob.com/wp-content/uploads/2013/12/iostream2xx.png)

## 1. 输入字节流InputStream

#### 定义和结构说明：

从输入字节流的继承图可以看出：

InputStream 是所有的输入字节流的父类，它是一个抽象类。

ByteArrayInputStream、StringBufferInputStream、FileInputStream 是三种基本的介质流，它们分别从Byte 数组、StringBuffer、和本地文件中读取数据。

【案例】字节流读取文件

```java
/**
 * 字节流
 *读文件
 * */
import java.io.*;
class hello{
   public static void main(String[] args) throws IOException {
       String fileName="D:"+File.separator+"hello.txt";
       File f=new File(fileName);
       InputStream in=new FileInputStream(f);
       byte[] b=new byte[1024];
       int count =0;
       int temp=0;
       while((temp=in.read())!=(-1)){
           b[count++]=(byte)temp;
       }
       in.close();
       System.out.println(new String(b));
    }
}
```

注意：当读到文件末尾的时候会返回-1.正常情况下是不会返回-1的。

read方法每次读一个字节

## 2. 输出字节流OutputStream

#### 定义和结构说明：

IO 中输出字节流的继承图可见上图，可以看出：

OutputStream 是所有的输出字节流的父类，它是一个抽象类。

ByteArrayOutputStream、FileOutputStream是两种基本的介质流，它们分别向Byte 数组、和本地文件中写入数据。

【案例】逐字节写入文件

```java
/**
 * 字节流
 * 向文件中一个字节一个字节的写入字符串
 * */
import java.io.*;
class hello{
   public static void main(String[] args) throws IOException {
       String fileName="D:"+File.separator+"hello.txt";
       File f=new File(fileName);
       OutputStream out =new FileOutputStream(f);
       String str="Hello World！！";
       byte[] b=str.getBytes();
       for (int i = 0; i < b.length; i++) {
           out.write(b[i]);
       }
       out.close();
    }
}
```

【案例】向文件中追加新内容

```java
/**
 * 字节流
 * 向文件中追加新内容：
 * */
import java.io.*;
class hello{
   public static void main(String[] args) throws IOException {
       String fileName="D:"+File.separator+"hello.txt";
       File f=new File(fileName);
       OutputStream out =new FileOutputStream(f,true);//true表示追加模式，否则为覆盖
       String str="Rollen";
       //String str="\r\nRollen"; 可以换行
       byte[] b=str.getBytes();
       for (int i = 0; i < b.length; i++) {
           out.write(b[i]);
       }
       out.close();
    }
}
```

