# 跳跃表


* 跳跃表是一种**有序数据结构**，通过在**每个节点维持多个指向其他节点的指针**，达到**快速访问节点**的目的
* 时间复杂度：最坏O(N)，平均O(logN)
* 大部分情况下，效率可与平衡树媲美，不过比平衡树实现简单
* 有序集合键【Zset】的底层实现之一



## 数据结构

```c
// 跳跃表节点
typedef struct zskiplistNode {
    sds ele; // 成员对象 需为字符串对象
    double score; // 分值，从小到大排序
    struct zskiplistNode *backward; // 后退指针，从表尾向表头遍历时使用
    struct zskiplistLevel {
        struct zskiplistNode *forward; // 前进指针
        unsigned long span; // 跨度，记录前进指针结点和当前结点之间的距离
    } level[]; // 层，是一个数组
} zskiplistNode;

// 跳跃表相关信息
typedef struct zskiplist {
    struct zskiplistNode *header, *tail; // 表头和表尾
    unsigned long length; // 跳跃表长度（包含节点的数量）
    int level; // 跳跃表内层数最大那个节点的层数（不包括表头节点层数）
} zskiplist;

```

![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/12/14/167ac8dd5c6d78ac~tplv-t2oaga2asx-watermark.awebp)

- 通过层可以用来加快访问其他节点的速度，一般，层的速度越多，访问节点的速度越快。
- 表头节点和其他节点构造是一样的，也有后退指针、分值和成员对象，但不会用到。
- level数组的大小在每次新建跳跃表的时候，随机生成，大小介于1-32之间。
- 指向NULL的所有前进指针的跨度都为0。
- 遍历操作只使用前进指针，跨度用来计算排位（rank），沿途访问的所有层跨度加起来就是节点在跳跃表的排位。
- 多个节点可以包含相同的分值，但每个节点成员对象是唯一的。
- 分值较大的成员对象排后面，分值相同的按成员对象的字典序排序。



## 使用场景

* 用于存储带有权重的元素，实现优先队列、积分排行榜等。
