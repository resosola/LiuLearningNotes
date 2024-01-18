# redis设计与实现 chr04 字典

* 保存键值对的数据结构
* 哈希键的底层实现之一。
* Redis数据库使用字典作为底层实现。



## 字典实现

### 哈希表

* redis的字典**使用哈希表作为底层实现**

```c
// 哈希表
typedef struct dictht {
    dictEntry **table; // 一个数组，数组中每个元素都是指向dictEntry结构的指针
    unsigned long size; // table数组的大小
    unsigned long sizemask; // 哈希表大小掩码 值总数size-1
    unsigned long used; // 哈希表目前已有节点（键值对）的数量
} dictht;

```

### 哈希节点

```c
// 每个dictEntry都保存着一个键值对，表示哈希表节点
typedef struct dictEntry {
    void *key; // 键值对的键
    // 键值对的值，可以是指针，整形，浮点型
    union { 
        void *val;
        uint64_t u64;
        int64_t s64;
        double d;
    } v;
    struct dictEntry *next; // 哈希表节点指针，用于解决键冲突问题
} dictEntry;

```

### 字典

```c
// 字典
typedef struct dict {
    dictType *type; // 不同键值对类型对应的操作函数
    void *privdata; // 需要传递给对应函数的参数
    dictht ht[2]; // ht[0]用于存放数据，ht[1]在进行rehash时使用
    long rehashidx; /* rehashing not in progress if rehashidx == -1，目前rehash的进度 渐进式rehash时使用*/
    unsigned long iterators; /* number of iterators currently running */
} dict;

```

每个字典类型保存一簇用于操作特定类型键值对的函数

### 字典类型

```c
typedef struct dictType {
    // 计算哈希值的函数
    uint64_t (*hashFunction)(const void *key);
    // 复制键的函数
    void *(*keyDup)(void *privdata, const void *key);
    // 复制值的函数
    void *(*valDup)(void *privdata, const void *obj);
    // 对比键的函数
    int (*keyCompare)(void *privdata, const void *key1, const void *key2);  
    // 销毁键的函数
    void (*keyDestructor)(void *privdata, void *key);
    // 销毁值的函数
    void (*valDestructor)(void *privdata, void *obj);
} dictType;

```

![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/14/167ac471ba2b2b76~tplv-t2oaga2asx-watermark.awebp)



## 哈希算法

- redis使用MurmurHash2算法计算键的hash值，其具有很好的随机分布性。
- 哈希值与sizemask取与，得到哈希索引
- 哈希冲突（两个或以上数量键被分配到哈希表数组同一个索引上）：**头插方式**的链地址法解决冲突



## rehash

- 对哈希表进行扩展或收缩，以使哈希表的负载因子维持在一个合理范围之内
- 负载因子 = 保存的节点数（used）/ 哈希表大小（size）
- 扩展或收缩通过执行rehash操作来完成



### rehash步骤包括

* 为字典的ht[1]哈希表分配空间，大小取决于要执行的操作以及ht[0]当前包含的键值对数量
  - 扩展操作：ht[1]大小为第一个大于等于ht[0].used乘以2的2的n次幂。
  - 收缩操作：ht[1]大小为第一个大于等于ht[0].used的2的n次幂。
* 将保存在ht[0]的所有键值对rehash到ht[1]上面：重新计算键的哈希值和索引值
* 当所有ht[0]的键值对都迁移到ht[1]之后，释放ht[0]，将ht[1]置为ht[0],并新建一个空白hash表作为ht[1]。



### 自动扩展的条件

- 服务器没有执行BGSave命令或GBRewriteAOF命令，并且哈希表的负载因子 >= 1
- 服务器正在执行BGSave命令或GBRewriteAOF命令，并且哈希表的负载因子 >= 5
- BGSave命令或GBRewriteAOF命令时，服务器需要创建当前服务器进程的子进程，会耗费内存，**提高负载因子避免写入，节约内存**

### 自动收缩的条件

- 哈希表负载因子小于0.1时，自动收缩



## 渐进式rehash

* ht[0]数据重新索引到ht[1]不是一次性集中完成的，而是**多次渐进式完成**（**避免hash表过大时导致性能问题）**



### 渐进式rehash详细步骤

* 为ht[1]分配空间，让字典同时持有两个哈希表
* 字典中rehashidx置为0，表示开始执行rehash（默认值为-1）
* rehash期间，每次对字典执行操作时，会顺带将ht[0]哈希表在rehashidx索引上的所有键值对rehash到ht[1]
* 全部rehash完毕时，rehashidx设为-1

#### 注意点

- rehash期间，字典会同时使用两个哈希表。
- 字典的删除、查找更新等操作可能会在两个哈希表上进行，第一个表没找到，就回去第二个表查找。
- 新增加的值一律放入ht[1]，保证数据只会减少不会增加



## 应用场景

* 常用来存储一些结构化的信息，便于对对象属性进行修改。
