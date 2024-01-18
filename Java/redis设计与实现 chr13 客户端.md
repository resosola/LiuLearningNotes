---
title: redis设计与实现 chr13 客户端
date: 2021-12-16 18:33:37
categories:	Redis基础
tags: Redis
---



## 总结

客户端章节主要介绍**redisClient的属性**，包括套接字描述符，输入缓冲区，时间等。然后介绍普通客户端的创建和关闭原因，是通过对应的事件处理器进行的。其他的伪客户端主要是AOF伪客户端按卸磨杀驴的套路，在载入时创建，载入结束后关闭。

## 客户端

redis服务器为每个连接的客户端建立了一个redisClient的结构，保存客户端状态信息。所有客户端的信息放在一个链表里。可通过client list命令查看

```c
struct redisServer {
    ...
    list *clients;
    ...
}

```

客户端数据结构如下：

```c
typedef struct client {
    uint64_t id;            /* Client incremental unique ID. */
    //客户端套接字描述符，伪客户端该值为-1（用于AOF还原和执行Lua脚本的命令，lua伪客户端在服务器初始化时就会创建直到服务器关闭其才会关闭）
    int fd;                 /* Client socket. */
    redisDb *db;            /* Pointer to currently SELECTed DB. */
    // 客户端名字，默认为空，可通过client setname设置
    robj *name;             /* As set by CLIENT SETNAME. */
    // 输入缓冲区，保存客户端发送的命令请求，不能超过1G
    sds querybuf;           /* Buffer we use to accumulate client queries. */
    size_t qb_pos;          /* The position we have read in querybuf. */
    sds pending_querybuf;   /* If this client is flagged as master, this buffer
                               represents the yet not applied portion of the
                               replication stream that we are receiving from
                               the master. */
    size_t querybuf_peak;   /* Recent (100ms or more) peak of querybuf size. */
    // 解析querybuf，得到参数个数
    int argc;               /* Num of arguments of current command. */
    // 解析querybuf，得到参数值
    robj **argv;            /* Arguments of current command. */
    // 根据前面的argv[0]， 找到这个命令对应的处理函数
    struct redisCommand *cmd, *lastcmd;  /* Last command executed. */
    int reqtype;            /* Request protocol type: PROTO_REQ_* */
    int multibulklen;       /* Number of multi bulk arguments left to read. */
    long bulklen;           /* Length of bulk argument in multi bulk request. */
    // 可变输出缓冲，固定buff用完时才会使用
    list *reply;            /* List of reply objects to send to the client. */
    unsigned long long reply_bytes; /* Tot bytes of objects in reply list. */
    size_t sentlen;         /* Amount of bytes already sent in the current
                               buffer or object being sent. */
    // 客户端的创建时间
    time_t ctime;           /* Client creation time. */
    // 客户端与服务器最后一次互动的时间
    time_t lastinteraction; /* Time of the last interaction, used for timeout */
    // 客户端空转时间
    time_t obuf_soft_limit_reached_time;
    // 客户端角色和状态：REDIS_MASTER, REDIS_SLAVE, REDIS_LUA_CLIENT等
    int flags;              /* Client flags: CLIENT_* macros. */
    // 客户端是否通过身份验证的标识
    int authenticated;      /* When requirepass is non-NULL. */
    int replstate;          /* Replication state if this is a slave. */
    int repl_put_online_on_ack; /* Install slave write handler on ACK. */
    int repldbfd;           /* Replication DB file descriptor. */
    off_t repldboff;        /* Replication DB file offset. */
    off_t repldbsize;       /* Replication DB file size. */
    sds replpreamble;       /* Replication DB preamble. */
    long long read_reploff; /* Read replication offset if this is a master. */
    long long reploff;      /* Applied replication offset if this is a master. */
    long long repl_ack_off; /* Replication ack offset, if this is a slave. */
    long long repl_ack_time;/* Replication ack time, if this is a slave. */
    long long psync_initial_offset; /* FULLRESYNC reply offset other slaves
                                       copying this slave output buffer
                                       should use. */
    char replid[CONFIG_RUN_ID_SIZE+1]; /* Master replication ID (if master). */
    int slave_listening_port; /* As configured with: SLAVECONF listening-port */
    char slave_ip[NET_IP_STR_LEN]; /* Optionally given by REPLCONF ip-address */
    int slave_capa;         /* Slave capabilities: SLAVE_CAPA_* bitwise OR. */
    multiState mstate;      /* MULTI/EXEC state */
    int btype;              /* Type of blocking op if CLIENT_BLOCKED. */
    blockingState bpop;     /* blocking state */
    long long woff;         /* Last write global replication offset. */
    list *watched_keys;     /* Keys WATCHED for MULTI/EXEC CAS */
    dict *pubsub_channels;  /* channels a client is interested in (SUBSCRIBE) */
    list *pubsub_patterns;  /* patterns a client is interested in (SUBSCRIBE) */
    sds peerid;             /* Cached peer ID. */
    listNode *client_list_node; /* list node in client list */

    /* Response buffer 固定输出缓冲 */
    // 记录buf数组目前使用的字节数
    int bufpos;
    // (16*1024)=16k,服务器返回给客户端的内容缓冲区。固定大小，存储一下固定返回值（如‘ok’）
    char buf[PROTO_REPLY_CHUNK_BYTES];
} client;

```

