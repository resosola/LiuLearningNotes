# 编程思想04控制执行流程

## **条件语句**

* if,if-else,switch-case语句
* 所有条件语句都利用条件表达式的真或假来决定执行路径
* java不允许我们将一个数字作为布尔值用！

## 迭代

* while、do-while、for用来控制循环 称为迭代语句，语句会重复执行，直到起控制作用的布尔表达式得到假的结果为止
* 无穷循环有两种形式,编译器将他们看成同一回事
  * for(;;)
  * while(true)

### for

* 结构

  for(initialization;Boolean-expression;step)

  statement

* 执行顺序

  * 第一次迭代之前进行初始化，随后进行条件测试，每一次迭代时，进行某种形式的“步进”；

* 初始化表达式、布尔表达式、步进运算都可以为空。每次迭代前都会测试布尔表达式，若获得的结果为false，就会执行for语句后面的代码
* 初始化语句定义的变量的作用域就是for控制的表达式的范围内

### 逗号操作符

* 逗号分隔符用来分隔函数的不同参数
* java里唯一用到逗号操作符的地方就是for循环的控制表达式。在控制表达式的初始化和步进控制部分，可以使用一系列由逗号分隔的语句；而且那些语句均会独立执行。
* 通过使用逗号操作符，**可以在for语句内定义多个变量，但是它们必须具有相同的类型。**

## Foreach

* 一种更加简洁的for语法用于数组和容器
* 不必创建int变量去对由访问项构成的序列进行计数，foreach将自动创建每一项,用于按顺序选取数组或容器中的每一个元素，常用于**无需索引**进行元素访问。
* foreach还可以作用于任何Itereable对象

## return

* 如果返回void的方法中没有return语句，那么该方法的结尾处会有一个隐式的return，因此方法中并非总是必须要有一个return语句

## switch

https://juejin.cn/post/6844903991390765069#heading-2

* 格式

  swith(integral-selector){

  case integral-value1 : statement; break;

  case integral-value2 : statement; break;

  default : statement;

  }

* integral-selector(整数选择因子)是一个能够产生**整数值**的表达式，byte,shor,char,int【事实上仅对`int`数据有效。因为对 `byte`，`char`或或`short`值的操作在内部被提升为`int`】

* （String、enum可以和switch协调工作）

  * `String`类型是通过获取`String`的hashCode来进行选择的，也就是本质上还是int.
  * 枚举支持`switch`更加简单，直接通过枚举的顺序即可作为相关`case`

* switch 不支持 long，是因为 switch 的设计初衷是**对那些只有少数的几个值进行等值判断，如果值过于复杂，那么还是用 if 比较合适。**

* swithc将这个表达式结果与每个 integral-value(整数值)相比较，如果相符就执行对应的语句。若没有发现相符的，就执行defalut语句。

* break语句会使执行流程跳转至switch主体的末尾

* 若省略break，会继续执行后面的case语句，直到遇到一个break为止。

