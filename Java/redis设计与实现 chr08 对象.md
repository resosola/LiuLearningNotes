# 对象 



## 概述

- redis并没有直接使用前面的数据结构来实现键值对的数据库，而是基于数据结构创建了一个对象系统，每种对象都用到前面至少一种数据结构
- 每个对象都由一个redisObject结构来表示。【字符串对象、列表对象、哈希对象、集合对象和有序集合对象】

```c
//server.h
typedef struct redisObject {
   unsigned type:4; //类型
   unsigned encoding:4; // 编码
   // 对象最后一个被命令程序访问的时间
   unsigned lru:LRU_BITS; /* LRU time (relative to global lru_clock) or
                           * LFU data (least significant 8 bits frequency
                           * and most significant 16 bits access time). */
   int refcount; // 引用计数
   void *ptr; // 指向底层的数据结构指针
} robj;

```



### 使用对象的好处

- 在执行命令之前，根据对象类型判断一个对象是否可以执行给定的命令
- 针对不同使用场景，为对象设置多种不同的数据结构实现，从而优化对象在不同场景下的使用效率
- 实现了基于引用计数的内存回收机制，不再使用的对象，内存会自动释放
- 引用计数实现对象共享机制，多个数据库键共享同一个对象以节约内存
- 对象带有访问时间记录信息，用于计算空转时间，可用于删除空转时间较长的哪些键。



### redis中的对象

- 字符串对象
- 列表对象
- 哈希对象
- 集合对象
- 有序结合对象



## 对象的类型与编码

* 数据库中的键和值都是对象
* 键总是字符串对象，值对象可以为以下中的一种

### 对象的类型

| 对象         | 对象type属性 | type命令的输出 |
| ------------ | ------------ | -------------- |
| 字符串对象   | REDIS_STRING | string         |
| 列表对象     | REDIS_LIST   | list           |
| 哈希对象     | REDIS_HASH   | hash           |
| 集合对象     | REDIS_SET    | set            |
| 有序集合对象 | REDIS_ZSET   | zset           |



### 对象的编码

- **编码**决定了ptr指向的**数据结构的类型**，表明使用什么数据结构作为底层实现
- type + encoding 表明了使用哪种数据结构 实现了type对象。
- 每种类型对象至少使用两种不同的编码。【使用XX数据结构实现的XX对象】
- 通过编码，redis可以根据不同场景设定不同编码，极大**提高灵活性和效率**

| 编码常量                  | 对应的数据结构             | OBJECT ENCODING命令输出 |
| ------------------------- | -------------------------- | ----------------------- |
| REDIS_ENCODING_INT        | long类型的整数             | “int”                   |
| REDIS_ENCODING_EMBSTR     | embstr编码的简单动态字符串 | “embstr”                |
| REDIS_ENCODING_RAW        | 简单动态字符串             | “raw”                   |
| REDIS_ENCODING_HT         | 字典                       | “hashtable”             |
| REDIS_ENCODING_LINKEDLIST | 双端链表                   | “linkedlist”            |
| REDIS_ENCODING_ZIPLIST    | 压缩列表                   | “ziplist”               |
| REDIS_ENCODING_INTSET     | 整数集合                   | “intset”                |
| REDIS_ENCODING_SKIPLIST   | 跳跃表和字典               | “skiplist”              |



## 字符串对象

- 字符串对象的编码可以是

  - int： 保存整数值时且该整数值可用long类型表示。

    ![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b15616ddb9ce3~tplv-t2oaga2asx-watermark.awebp)

  - raw：字符串值且长度大于39字节【**两次内存分配**，redisObject和sdshdr】

    ![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b156e779c0e4a~tplv-t2oaga2asx-watermark.awebp)

  - embstr： 字符串值且长度小于等于39字节

    embstr是保存短字符串的一种优化编码方式。通过**一次内存分**配来分配一块连续的空间。

    ![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b1579b6f8ddcb~tplv-t2oaga2asx-watermark.awebp)

- 浮点数在redis中也是作为字符串值保存，保存时转为字符串值，涉及计算时，先转回浮点数，算完后再转换成字符串值进行保存。

| 字符串对象内容 | 长度           | 编码类型 |
| -------------- | -------------- | -------- |
| 整数值         | -              | int      |
| 字符串值       | 小于等于32字节 | embstr   |
| 字符串值       | 大于32字节     | raw      |

embstr编码是专门用于保存短字符串的一种优化编码方式。这种编码和raw编码一样，都使用redisObject结构和sdshdr结构来表示对象。区别在于：

- raw编码调用两次内存分配函数来分别创建redisObject和sdrhdr结构
- embstr则调用一次内存分配函数来创建一块连续空间，里面包括redisObject和sdrhdr
- embstr编码的好处：
  - 内存分配次数降低
  - 释放对象时，只需调用一次内存释放函数
  - 对象数据都**保存在一块连续的内存**里，更好地利用缓存带来的优势。



### 编码转换

int编码和embstr编码的对象满足条件时会自动转换为raw编码的字符串对象

- int编码对象，执行命令导致对象不再是整数时，会转换为raw对象【如append操作】
- embstr编码字符串对象没有相应修改函数，是只读编码。涉及修改时，会转换为raw对象再修改。

### 字符串命令

redis中所有键都是字符串对象，所以所有对于键的命令都是针对字符串键来构建的

- set
- get
- append
- incrbyfloat
- incrby
- decrby
- strlen
- strrange
- getrange



## 列表对象

* 列表对象的编码可以是

* ziplist：**每个压缩列表节点都存了一个列表元素**

  ![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b1586d405e8c1~tplv-t2oaga2asx-watermark.awebp)

* linkedlist：**每个链表节点都保存一个字符串对象**，每个字符串对象保存了一个列表元素。【字符串对象是Redis五种类型的对象中唯一一种会被其他四种对象嵌套的对象。】

  ![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b15907ad10305~tplv-t2oaga2asx-watermark.awebp)



### 编码转换

使用ziplist编码的两个条件如下，不满足的都用linkedlist编码（这两个条件可以在配置文件中修改）:

- 保存的所有字符串元素的长度都小于64字节
- 列表的元素数量小于512个

### 列表命令

- lpush
- rpush
- lpop
- rpop
- lindex
- llen
- linsert
- lrem
- ltrim
- lset



## 哈希对象

哈希对象的编码可以是

- ziplist：

  ![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b1bf5d2e45469~tplv-t2oaga2asx-watermark.awebp)

- hashtable：字典作为底层实现

  ![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b1c05675034a3~tplv-t2oaga2asx-watermark.awebp)

### 编码转换

- 使用ziplist需要满足两个条件，不满足则都使用hashtable（这两个条件可以在配置文件中修改）
  - 所有键值对的键和值的字符串长度都小于64字节
  - 键值对数量小于512个

### 哈希命令

- hset
- hget
- hexists
- hdel
- hlen
- hgetall



## 集合对象

集合对象的编码可以是：

- intset：所有元素保存在整数集合里

  ![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b1c7c861215e8~tplv-t2oaga2asx-watermark.awebp)

- hashtale：字典的每个键都是字符串对象，字典的值为null。

  ![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b1c81ff7bbdaf~tplv-t2oaga2asx-watermark.awebp)

### 编码转换

集合使用intset需要满足两个条件，不满足时使用hashtable（参数可通过配置文件修改）

- 保存的所有元素都是整数值
- 元素数量不超过512个

### 集合命令

- sadd
- scard
- sismember
- smembers
- srandmember
- spop
- srem




## 有序集合对象

有序集合的编码可以是

- ziplist：每个元素使用两个紧挨在一起的节点表示，第一个表示成员，第二个表示分值。分值小的靠近表头，分值大的靠近表尾

  ![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b1d0b6c46fa95~tplv-t2oaga2asx-watermark.awebp)

- skiplist：使用zset作为底层实现，zset结构同时包含了字典和跳跃表，分别用于根据key查找score和分值排序或范围查询

- 为了让有序集合的**查找和范围型操作都尽可能快地执行**，同时使用字典和跳跃表来实现有序集合对象。

```c
// 两种数据结构通过指针共享元素成员和分值，不会浪费内存
typedef struct zset {
    zskplist *zsl; //跳跃表，方便zrank，zrange
    dict *dict; //字典，方便zscore
}zset;
复制代码
```



![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b1db35769bf51~tplv-t2oaga2asx-watermark.awebp)



### 编码转换

当满足以下两个条件时，使用ziplist编码，否则使用skiplist（可通过配置文件修改）

- 保存的元素数量少于128个
- 成员长度小于64字节

### 有序集合命令

- zadd
- zcard
- zcount
- zrange
- zrevrange
- zrem
- zscore



## 类型检查和命令多态

redis的命令可以分为两大类：

- 可以对任意类型的键执行，基于类型的多态【一个命令可以同时用于处理多种不同类型的键即不同的值对象】，如
  - del
  - expire
  - rename
  - type
  - object
- 只能对特定类型的键执行，**基于编码的多态**【一个命令可以同时用于处理多种不同的编码】，比如前面各种对象的命令。通过redisObject的type属性实现类型检查【判断是否可执行此命令】，且还需要根据键的值对象所使用的编码来选择正确的命令函数实现【选择正确的命令实现】。



## 内存回收

* redis通过对象的refcount属性记录对象的引用计数信息，适当的时候**自动释放对象进行内存回收。**



## 对象共享

* **对象的引用计数属性还带有对象共享的作用。**

* redis中，让多个键共享同一个值对象需要执行以下两个步骤：

  * 将数据库键的值指向一个现有的值对象。
  * 将被共享的值对象的引用计数增一。

* 数据库中包含同样数值的对象，键的值指向同一个对象，以**节约内存**。

* redis在初始化时，创建一万个字符串对象，包含从0-9999的所有**整数值**，当需要用到这些值时，服务器会共享这些对象，而不是新建对象

* 数量可通过配置文件修改。

* 目前不共享包含字符串的对象，因为要比对对象是否相同本身就会造成性能问题。

* Redis**只对包含整数值的字符串对象进行共享。**

  

## 对象空转时长

- 空转时长=现在时间-redisObject.lru，**lru记录对象最后一次被访问的时间**
  - 计算空转时长的命令：OBJECT IDLETIME，其不会更新lru
- 当redis配置了最大内存（maxmemory）时，回收算法为volatile-lru或allkeys-lru且内存超过该值时，**空转时长高的会优先被释放以回收内存**

