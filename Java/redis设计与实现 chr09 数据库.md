
# 数据库 

## 总结

服务器章节主要介绍键值对的宏观存储是怎么实现的和过期策略。通过RedisServer进行组织，用**字典存键值对**，值就是[上一章](https://zhuanlan.zhihu.com/p/140726424)所描述的那些对象，具体数据结构**按照对象的编码存储**。客户端与服务器主要通过**共享指针**的方式来共享库对象。键的过期时间是按照单独的键过期字典存储的，设置过期时间的命令**都会转换为PEXPIREAT**来实现。Redis使用**惰性删除**和**定期删除**作为移除策略。每次对键的读取都会判断是否过期，定期抽查并删除过期键。



## 服务器的数据库

* redis是内存型数据库，所有数据都放在内存中
* 保存这些数据的是redisServer这个结构体，源码中该结构体包括大概300多行的代码。具体参考server.h/redisServer
* 和数据库相关的两个属性是：
  - int类型的dbnum：表示数据库数量，默认16个，可通过配置选项设置。
  - redisDb指针类型的db：数据库对象数组

![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b228be8fb2489~tplv-t2oaga2asx-watermark.awebp)



## 数据库对象

所在文件为server.h。数据库中所有针对键值对的增删改查，都是对dict做操作

```c
typedef struct redisDb {
    dict *dict;                 /* The keyspace for this DB  */
    dict *expires;              /* Timeout of keys with a timeout set */
    dict *blocking_keys;        /* Keys with clients waiting for data (BLPOP)*/
    dict *ready_keys;           /* Blocked keys that received a PUSH */
    dict *watched_keys;         /* WATCHED keys for MULTI/EXEC CAS */
    int id;                     /* Database ID */
    long long avg_ttl;          /* Average TTL, just for stats */
} redisDb;

```

- dict：保存了该数据库中所有的键值对，键都是字符串，值可以是多种类型【键空间】
- expires：保存了该数据中所有设置了过期时间的key
- blocking_keys：保存了客户端阻塞的键
- watched_keys：保存被watch的命令
- id：保存数据库索引
- avg_ttl：键的平均过期时间。



## 客户端切换数据

* 每个客户端都有一个目标数据库。

- 客户端通过select dbnum 命令【修改目标数据库指针】切换选中的数据库。
- 客户端的信息保存在client这个数据结构中，参考server.h/client。
- client中的类型为redisDb的**db指针**指向目前所选择的数据库。



## 读写键空间时的其他操作

读写键空间时，是针对dict（键空间）做操作，但是除了完成基本的增改查找操作，**还会执行一些额外的维护操作**，包括：

* 读写键时，会根据是否命中，更新键空间命中(hit)和键空间不命中(miss)次数。

  > 相关命令：info stats keyspace_hits, info stats keyspace_misses

* 读取键后，会更新键的LRU时间【键对象的最后一次使用时间】，前面章节介绍过该字段

* **读取时，如果发现键已经过期，会先删除该键，然后才执行其他操作**

* 如果客户端使用watch监视了某个键，服务器对其修改时会**标记该键为脏**（dirty），让事务程序注意到这个键已经被修改过。

* 每修改一个键，会对**脏键计数器加1**，其会触发持久化和复制操作

* 如果开启通知功能，修改键会下发通知。

  

## 设置键过期时间

* expire key ttl：设置生存时间为ttl秒

* pexpire key ttl：设置生存时间为ttl毫秒

* expireat key timestamp：设置过期时间为timstamp的秒数时间戳

* pexpireat key timestamp：过期时间为毫秒时间戳

* persist key：解除过期时间【从过期字典中移除相应键值对】

* ttl key：获取剩余生存时间 以秒为单位

* pttl key：获取剩余生成时间 以毫秒为单位

* 设置键过期时间的命令**都是使用 pexpireat 命令**来实现的。![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/15/167b25c77c3dd2a7~tplv-t2oaga2asx-watermark.awebp)

  

## 保存过期时间

* 键的过期时间保存在redisDb结构的expires的字典中，键指向了某个键对象，值为long类型的毫秒时间戳
* 为键设置过期时间，会在过期字典中进行关联。





## 过期键删除策略

### 各种删除策略的对比

| 策略类型 | 描述                                             | 优点                             | 缺点                                                         | redis是否采用 |
| -------- | ------------------------------------------------ | -------------------------------- | ------------------------------------------------------------ | ------------- |
| 定时删除 | 通过定时器实现                                   | 保证过期键能尽快释放，对内存友好 | 对cpu不友好，删除过期键影响响应时间和吞吐量                  | 否            |
| 惰性删除 | 放任不管，查询时才去检查是否过期                 | 对cpu友好                        | 没有被访问的永远不会被释放，相当于内存泄露【无用的而垃圾数据占用了大量的内存】 | 是            |
| 定期删除 | 每隔一段时间执行删除过期键操作，并限定时长和频率 | 综合前面的优点                   | 难于确定执行时长和频率                                       | 是            |



### redis使用的过期键删除策略

redis采用了**惰性删除**和**定期删除**策略



#### 惰性删除的实现

- 由db.c中的expireIfNeeded实现
- 每次执行redis命令前都会调用该函数**对输入键做检查**
  - 如果键过期，该函数将把键从数据库中删除
  - 否则函数不做动作
- 因为每个被访问的键都可能因为过期而被删除，所以每个命令的实现函数都**必须能同时处理键存在以及键不存在的情况**。



#### 定期删除的实现

* 由redis.c/activeExpireCycle函数实现

* server.c中的serverCron函数执行**定时任务会调用它**
* 在规定的时间内，分**多次来遍历服务器中的每个数据库**，从数据库中的expires字典中**随机检查一部分键的过期时间**，并删除其中的过期键。
* 函数每次运行时，都**从一定数量的数据库中取出一定数量的键进行检查，并删除过期键**



## AOF、RDB和复制功能对过期键的处理

### 生成rdb文件

* 创建rdb文件时，会对数据库中的键进行检查，**已过期的键不会被保存**。
* 因此，包含过期键不会对新的rdb文件有影响。

### 载入rdb文件

* 主服务器模式下，会对文件中保存的键检查，过期键会被忽略。
* 从服务器模式下，无论是否过期都会被载入数据库中。

### aof文件写入

* 键过期被删除时，会追加对应删除命令到aof文件中

### aof重写

* aof重写过程中，程序会对键进行检查，过期键不会保存到aof文件中

### 复制

* 当服务器运行在复制模式下时，**从服务器的过期键删除动作由主服务器控制**。
* 从服务器只有在接到主服务器的删除命令后，才会删除过期键，否则即使从服务器上的键过期了其也不会删除，仍可被客户端访问。【主从数据一致】



## 数据库通知

* 客户端通过**订阅给定的频道或者模式**，来**获知数据库中键的变化**，以及数据库中命令的执行情况。

* 键空间通知：客户端获取数据库中的键执行了什么命令。实现代码为notify.c文件的notifyKeyspaceEvent函数

  ```bash
  subscribe __keyspace@0__:keyname ## 0号库的keyname键
  ```

  键事件通知：某个命令被什么键执行了

  ```bash
  subscribe __keyevent@0__:del ##0号库的del命令
  ```

  

