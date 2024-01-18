# redis设计与实现 chr03 链表

* Redis构建了自己的链表实现
* 链表结点结构有前置、后置结点、以及结点值
* redis使用list结构来持有链表，其有表头指针head、表尾指针tail，以及链表长度计数器len、和一些用于实现多态链表的类型特定函数

```c
typedef struct listNode { // 双向链表
    struct listNode *prev; // 前置节点
    struct listNode *next; // 后置节点
    void *value;//节点值
} listNode;

typedef struct list {
    listNode *head; // 表头节点
    listNode *tail; // 表尾节点
    void *(*dup)(void *ptr); // 节点值复制函数
    void (*free)(void *ptr); // 节点值释放函数
    int (*match)(void *ptr, void *key); // 节点值对比函数
    unsigned long len; // 节点数量
} list;

```



## redis的链表特性

* **双端**，可以获取某个节点前置节点和后置节点,复杂度为O(1)
* 无环
* 带表头指针和表尾指针，
* 带链表长度计数器
* 多态：使用void*保存节点值，可保存不同类型的值

![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/14/167abee9fcb2654c~tplv-t2oaga2asx-watermark.awebp)



## 应用场景

* 消息封装进链表做消息队列。
* 利用list结构实现最新消息排行。
