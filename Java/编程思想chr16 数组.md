# 编程思想chr16 数组

## 数组为什么特殊

* 数组与其他种类的容器之间的区别有三个方面：效率，类型，保存基本数据类型的能力。
* 效率：数组是一种效率最高的存储和随机访问对象引用序列的方式。
* 类型：在泛型之前，其他容器在处理对象时，都将对象视为Object类处理，数组的优点是，你可以创建一个拥有某种数据类型的数组，这样可以防止你在编译期插入的错误数据类型和获取不当类型。
* 保存基本数据类型的能力：数据可以持有基本类型，但是泛型之前的容器不能。
* 有了泛型之后，容器看起来能够持有基本数据类型，且编译器可以对容器持有的对象进行类型检查，此时数组仅存的优点就是效率。



## 数组是第一级对象

* 数组也是一个对象，和其他普通对象一样在堆中创建， int[ ] arr arr是数组的引用。

* 可以隐式创建数组对象，也可以new显式创建数组对象

  ```java
      int[] ints = {1 ,8 ,9}; //聚集初始化 只能在定义处进行
      /*动态聚集初始化，任意位置创建并初始化，
       * 有时候传一个数组类型参数时代码更简单*/
      int[] iArr = new int[]{2 , 5 , -12 , 20};
      int[] arr = new int[3];//只定义了大小
  ```

* 对象数组中数组存的是对象的引用，基本类型数组直接存值

  * 数组如果没有显式初始化，则对象数组所有引用会自动初始化为null，基本类型则为默认值【数值型为0，字符型为(char)O，布尔型为false】

* length表示数组大小，不表示数组内具体存有多少个元素。



## 返回一个数组

* 返回一个数组与返回任何其他对象没有什么区别



## 多维数组

* Java没有多维数组，任何多维数组都可以看成一维数组内引用一维数组
* 初始化多维数组时可以先只初始化最左边的维数，此时该数组的每个元素都相当于一个数组引用变量，这些数组元素还需要进一步初始化
* int a = new int[2] [3] [5] ; 直接定义大小，这样的数组是个规则的多维数组
* 逐步定义大小如下

```java
 		int[][][] a = new int[2][][];
        System.out.println("a.length="+a.length); //a中只有2个元素a[0],a[1]它们是一个二维数组的引用
        a[0]=new int[3][];
        a[1]=new int[3][];
        System.out.println("a[1].length="+a[1].length);//a[1]中3个元素a[1][0],a[1][1],a[1][2]他们是一维数组的引用
        a[0][1] =  new int[5];
        System.out.println("a[0][1].length="+a[0][1].length);// a[0][1] 中有5个元素a[0][1][0]-a[0][1][4]
        System.out.println(Arrays.deepToString(a));
        /*  a.length=2
            a[1].length=3
            a[0][1].length=5
            [[null, [0, 0, 0, 0, 0], null], [null, null, null]]
```

* 逐步定义大小可以定义出不规则多维数组，如

```java
 a[0]=new int[3][];
 a[1]=new int[2][];
```

- 打印多维数组Arrays.deepToString();
- 数据存在[5]这个数组中，其他[2]和[3]都存的引用。



## 数组与泛型

* 不能实例化具有参数类型的数组【擦除会移除参数类型信息，而数组必须知道他们所持有的确切类型，以强制保证类型的安全】
* 可以参数化数组本身的类型【使用参数化方法相比使用参数化类更加方便】
* 可以创建范型数组的引用【即能创建泛型数组的引用，却不能创建实际的持有泛型的数组对象，且编译器可对泛型数组的引用的对象进行编译器类型检查】
* 可以把普通数组转型成范型数组【创建泛型数组引用后可以创建非泛型数组对象将其转型】

```java
	public static void main(String[] args){
    	A<String>[] arr1 = new A<String>[10]; // 1 error
    	A<String>[] arr2 ; // 3 创建泛型数组引用
    	A<String>[] arr2 = (A<String>[]) new A[10]; // (4)
	}

// 2
class A<T>{
    T[] func(){
        
    }
    // 泛型方法
    public static <A> A[] f(A[] arg) {return arg;}
}
```

* 泛型在类或方法的边界处很有效，**而在类或方法的内部，擦除通常会使泛型变得不适用。**例如：你不能创建泛型数组

```java
public class ArrayOfGenericType<T>{
    T[] array;
    
    @SuppressWarnings("unchecked")
    public ArrayOfGenericType(int size){
        // array = new T[size]; // illegal
        array = (T[])new Object[size]; // unchecked warning
    }
    
    // Illegal
    public <U> U[] makeArray(){ return new U[10];}
}
```



## Arrays类的功能

1. `Arrays.fill()`：把全部或部分数组填充为某一个**固定值**

2. `Arrays.equals()`和`Arrays.deepEquals()`：比较数组是否相等。数组相等的条件是数组长度相等，而且对应位置的元素也相等。【调用元素的equals方法进行比较】

3. `Arrays.copy()`：底层调用的是`System.arraycopy`，用于复制数组，效率比for循环快的多。如果复制的内容是对象，那么只是复制了对象的引用（浅复制）。

4. `Arrays.binarySearch()`：对**已排序**的数组进行二分查找，如果数组未排序可能会无限循环。如果使用Comparator排序了某个对象数组，则使用二分查找时必须提供同样的Comparator【利用重载版本】

5. `Arrays.sort()`：对数组中元素进行排序，只要数组中的元素实现了Comparable接口，或者提供一个Comparator。字符串的排序按照字典序进行排序，可以使用`String.CASE_INSENSITIVE_ORDER`来忽略大小写。`Collections.reverseOrder()`方法产生的Comparator可以反转自然的排列顺序。

   Java排序算法针对排序的特殊类型进行了优化，**对基本类型设计快速排序，对对象设计归并排序**

6. `Arrays.asList()`：接受任意的序列或数组作为其参数，并将其转变为List容器

```java
public class Main {
    public static void main(String[] args) {
        Item[] arr = {new Item(3), new Item(5), new Item(4)};
        System.out.println(Arrays.toString(arr)); // [3, 5, 4]
        Arrays.sort(arr);
        System.out.println(Arrays.toString(arr)); // [3, 4, 5]
        Arrays.sort(arr, new Comparator<Item>() {
            public int compare(Item o1, Item o2) {
                return o1.value == o2.value ? 0 : (o1.value > o2.value ? -1 : 1);
            }
        });
        System.out.println(Arrays.toString(arr)); // [5, 4, 3]
    }
}

class Item implements Comparable<Item> {
    public int value;

    public Item(int value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return value + "";
    }

    public int compareTo(Item o) {
        return value == o.value ? 0 : (value > o.value ? 1 : -1);
    }
}
```



## 面试相关

### new方式创建数组细节

* 说数组命名时**名称与[]可以随意排列**，但声明的二维数组中**第一个中括号中必须要有值**，它代表的是在该二维数组中有多少个一维数组。

* 使用过程需要注意,**直接赋值会产生空指针异常**。java.lang.NullPointerException

  ```java
  		float [][]f = new float[6][];
  		f[0][1] = 1.0f;// java.lang.NullPointerException
  		System.out.println(f[0][1]);
  ```

  **若要访问，需要创建数组，并指向该地址。**

```java
		float [][]f = new float[6][];
		f[0] = new float[5];
		f[0][1] = 1.0f;
		System.out.println(f[0][1]);
```
