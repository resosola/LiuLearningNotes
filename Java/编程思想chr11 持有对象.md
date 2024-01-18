# 编程思想 ch11 持有对象

* 有数组尺寸固定这一限制
* 写程序时并不知道将需要多少对象
  * java实用类库提供了容器类来解决问题
    * 其基本类型是List、Set、Queue和Map，这些对象类型也称为集合类



## 泛型和类型安全的容器

* 没有使用泛型的容器保存的Object，存储元素的时候我们需向上转型，取出元素则需向下转型

  ```java
  ArrayList apples = new ArrayList();//不指定泛型 保存的是Object
  ```

* 通过使用泛型，可以在**编译期**防止将错误类型的对象放置到容器中

  ```java
  ArrayList<Apple> apples = new ArrayList<>();
  ```

  * 泛型让容器知道它保存的是什么类型，因此它会在调用get()时替你执行转型
  * 向上转型也可以像作用于其他类型一样作用于泛型（子类也可以放入容器）



## 基本概念

java容器类类库的用途是“保存对象”，并将其划分为两个不同的概念

* Collection：一个独立元素的序列，这些元素都将服从一条或多条规则。【List必须按照插入的顺序保存要素，而Set不能有重复元素。Queue按照队列规则来确定对象的产生顺序（通常与它们被插入的顺序相同）】
* Map：一组成对的“键值对”对象，允许使用键来查找值。映射表允许我们使用另一对象来查找某个对象，也被称为关联数组。
* Collection接口概括了序列的概念，



## 添加一组元素

* Arrays和Collections类中有很多实用方法，可以在一个Collection中添加一组元素

  * Arrays.asList()方法接受一个数组或是一个用逗号分割的元素列表(使用可变参数)，并将其转换为一个List对象。

    * 其底层表示的是数组，因此不能调整尺寸。

    * 其会对元素类型做出最合理的解释(最近的相同基类)

      ```java
      class Snow{}
      class Powder extends Snow{}
      class Light extends Powder{}
      class Heavy extends Powder{}
      class Crusty extends Snow{}
      class Slush extends Snow{}
      //Arrays的asList方法返回的是List<Powder> 将编译不通过
      List<Snow> snow3 = Arrays.asList(new Light(),new Heavy());
      ```

    * 也可以告诉它实际的目标类型(显式类型参数说明)

      ```java
      //指明泛型方法的类型
      List<Snow> snow4 = Arrays.<Snow>asList(new Light().new Heavy());
      ```

  * Collections.addAll()方法接受一个Collection对象，以及一个数组或是一个用逗号分隔的列表，将元素添加到Collection中（首选）

    * 该方法从第一个参数collection中了解了目标类型是什么

* Collection构造器直接传入Collection对象，将会创建一个引用了Collection对象中所有元素的Collection(即创建一个副本)

  ```java
  List<Integer> list1 = new ArrayList<>(Arrays.asList(ia));
  ```

  



## 容器的打印

* 默认的打印行为（使用容器提供的toString()方法）即可生成可读性很好的结果。



## List

* List表示顺序容器，即元素存放的数据与放进去的顺序相同。

* List接口在Collection的基础上添加了大量的方法，使得可以在List的中间插入和移除元素。
* ArrayList：擅长于随机访问元素，但是在中间插入和移除元素时较慢，允许放入`null`元素，底层通过**数组实现**。除该类未实现同步外，其余跟*Vector*大致相同。
* LinkedList：同时实现了*List*接口和*Deque*接口，也就是说它既可以看作一个顺序容器，又可以看作一个队列(*Queue*)，同时又可以看作一个栈(*Stack*)。底层基于双向链表实现，中间进行插入和删除操作代价较低，提供了优化的顺序访问。LinkedList在随机访问方面相对较慢。
* List是一种可修改的序列，允许自我调整尺寸，添加元素、移除元素
* indexOf()、remove()、contains()都会用到equals()方法
* 主要都是一些api讲解 详情看书



## 迭代器

* 迭代器是一个对象，它的工作是遍历并选择序列中的对象，而客户端程序员不必知道或关心该序列底层的结构。且Java的Iterator只能单向移动。
* 迭代器将遍历序列的操作与序列底层的结构分离，统一了对容器的访问方式。

### ListIterator

* ListIterator是一个更加强大的Iterator的子类型，它只能用于各种List类的访问，且可以双向移动。



## LinkedList

* LinkedList在中间插入和删除元素时比ArrayList更高效，但在随机访问操作方面要逊色一些
* LinkedList还添加了可以使其用作栈、队列或双端队列的方法



## Stack

* 栈 通常是指后进先出的容器，LinkedList具有能够直接实现栈的所有功能的方法，因此可将LinkedList作为栈使用



## Set

* Set不保存重复的元素，通常会选择一个HashSet的实现，它专门对快速查找进行了优化
* Set具有与Collection完全一样的接口
* Set是基于对象的值来确定归属性的
* HashSet使用了散列。HashSet所维护的顺序与TreeSet或LinkedHashSet都不同，因为他们的实现具有不同的元素存储方式。
  * TreeSet将元素存储在红-黑树数据结构中
  * HashSet使用的是散列函数
  * LinkedHashList因为查询速度的原因也使用了散列



## Map

* Map具有将对象映射到其他对象的能力
* Map可以返回它的键的Set，它的值的Collection，或者它的键值对的Set



## Queue

*  LinkedList提供了方法以支持队列的行为，并且它实现了Queue接口
* Queue接口窄化了对LinkedList的方法的访问权限，以使得只有恰当的方法才可以使用



### PriorityQueue

* 队列规则是指在给定一组队列中的元素的情况下，确定下一个弹出队列的元素的规则。先进先出声明的是下一个元素应该是等待时间最长的元素
* 优先级队列声明下一个弹出的元素具有最高优先级（默认排序将使用对象在队列中的自然顺序，但是可以提供自己的Comparator来修改这个顺序）
  * 优先级队列算法通常会在插入时排序（维护一个堆）



## Collection和Iterator

* Collection是描述所有**序列**容器的共性的根接口
* 实现Collection就意味着需要提供iterator()方法



## Foreach与迭代器

* foreach语法主要用于数组，也可以应用于任何Collection对象

  ```java
  for(String s:cs){
      ...
  }
  ```

* **之所以能够工作，是因为java5引入了Iterable的接口，其包含一个产生Iterator的iterator()方法，并且Iterable接口被foreach用来在序列中移动。【其next和hasNext方法将被调用】**

