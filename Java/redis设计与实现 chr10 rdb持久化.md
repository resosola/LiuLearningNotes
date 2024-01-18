---
title: redis设计与实现 chr10 rdb持久化
date: 2021-12-16 18:33:37
categories:	Redis基础
tags: Redis
---





# 总结

RDB持久化章节主要介绍持久化机制和发生时机，BGSAVE指令对其他指令的**排斥性**，RDB文件结构。RDB文件载入时，主服务器会**检查键是否过期**。RDB的实现分为SAVE和BGSAVE，**SAVE会阻塞**，BGSAVE是通过**fork子进程**来写RDB文件的方式，来记录Redis的数据库快照。BGSAVE随着serverCron函数的执行，每次都会判断是否有必要执行。

# RDB持久化

- redis是**内存**数据库，为了避免服务器进程异常推出导致**数据丢失**，redis提供了RDB**持久化**功能
- 持久化后的RDB文件是一个经过**压缩**的**二进制**文件，通过该文件可以还原生成rdb文件时的**数据库状态**。



## RDB文件的创建与载入

生成rdb文件的两个命令如下，实现函数为rdb.c文件的rdbSave函数：

- SAVE：**阻塞redis服务器进程，直到RDB创建完成。阻塞期间不能处理其他请求**
- BGSAVE：**派生出子进程，子进程负责创建RDB文件，父进程继续处理命令请求**
  - BGSAVE命令执行期间，SAVE、BGSAVE、BGREWRITEAOF三个命令都会被拒绝。
- 两命令会以**不同方式调用rdbSave函数**。

RDB文件的载入是在**服务器启动时自动执行**的，实现函数为rdb.c文件的rdbload函数。**只要启动时检测到RDB文件的存在，载入期间服务器一直处于阻塞状态。**

* 因为aof文件更新频率比rdb文件高，所以如果开启了aof持久化功能，服务器会优先使用aof文件来还原数据库状态。
* 只有再aof持久化功能关闭时，服务器才会使用rdb文件。



## 自动间隔保存

* redis允许用户通过**设置服务器配置的save选项**，让服务器**每隔一段时间**（100ms）检查执行BGSAVE命令的条件是否满足，如果满足则执行（serverCron函数）

### 设置保存条件

```c
// 任意一个配置满足即执行
save 900 1 // 900s内，对服务器进行至少1次修改
save 300 10 // 300s内，对服务器至少修改10次
```

### dirty计数器和lastsave属性

```c
// 服务器全局变量，前面介绍过
struct redisServer {
    ...
     /* RDB persistence */
    // 上一次执行save或bgsave后，对数据库进行了多少次修改
    long long dirty;                /* Changes to DB from the last save */
    long long dirty_before_bgsave;  /* Used to restore dirty on failed BGSAVE */
    pid_t rdb_child_pid;            /* PID of RDB saving child */ 
    // 保存条件
    struct saveparam *saveparams;   /* Save points array for RDB */
    int saveparamslen;              /* Number of saving points */
    char *rdb_filename;             /* Name of RDB file */
    int rdb_compression;            /* Use compression in RDB? */
    int rdb_checksum;               /* Use RDB checksum? */
    // 上一次成功执行save或bgsave的unix时间戳
    time_t lastsave;                /* Unix time of last successful save */
    time_t lastbgsave_try;          /* Unix time of last attempted bgsave */
    time_t rdb_save_time_last;      /* Time used by last RDB save run. */
    time_t rdb_save_time_start;     /* Current RDB save start time. */
    int rdb_bgsave_scheduled;       /* BGSAVE when possible if true. */
    int rdb_child_type;             /* Type of save by active child. */
    int lastbgsave_status;          /* C_OK or C_ERR */
    int stop_writes_on_bgsave_err;  /* Don't allow writes if can't BGSAVE */
    int rdb_pipe_write_result_to_parent; /* RDB pipes used to return the state */
    int rdb_pipe_read_result_from_child; /* of each slave in diskless SYNC. */
    ...
};
// 具体每一个参数对应的变量
struct saveparam {
    time_t seconds;
    int changes;
};

```



## **RDB 的优点**

- 适合大规模的数据恢复场景，如备份，全量复制等

## **RDB缺点**

- 没办法做到实时持久化/秒级持久化。
- 新老版本存在RDB格式兼容问题



## RDB文件结构

* 对于不同类型的键值对，RDB文件会使用不同的方式来保存它们。
* 具体结构看书。。
