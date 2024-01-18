## 第4章　锁的优化及注意事项 138

### 4.1　有助于提高“锁”性能的几点建议 139 面试点 锁优化

* 锁的竞争必然会导致程序的整体性能下降。



#### 4.1.1　减小锁持有时间 139

* 单个线程对锁的持有时间与系统性能有着直接的关系。如果线程持有锁的时间很长，那么锁的竞争程度也就越激烈。
* 应该尽可能地减少对某个锁的占用时间，以减少线程间互斥的可能。
* 一种较为优化的解决方案是**，只在必要时进行同步**【同步范围尽量小】，这样就能明显减少线程持有锁的时间，提高系统的吞吐量。

- JDK1.7源代码：[Pattern](https://hub.fastgit.org/guanpengchn/JDK/blob/master/JDK1.7/src/java/util/regex/Pattern.java)



#### 4.1.2　减小锁粒度 140

* 所谓减小锁粒度，就是指**缩小锁定对象的范围**，从而减小锁冲突的可能性，进而提高系统的并发能力。

- 对整个HashMap加锁粒度过大，对于ConcurrentHashMap内部细分若干个HashMap，称之为段，被分成16个段
- 现根据hashcode得到应该存放到哪个段中，然后对该段加锁
- ConcurrentHashMap.size()获取全局信息时将对所有段进行加锁，消耗资源比较多。
- 只有在类似于size()获取全局信息的方法调用并不频繁时，这种减小锁粒度的方法才能真正意义上提高系统吞吐量。
- JDK8中改变了实现方式，使用CAS来做实现，区别可见[文章](https://blog.csdn.net/Gavin__Zhou/article/details/76792071)



#### 4.1.3　读写分离锁来替换独占锁 142

* 读写锁通过对**系统功能点的分割**来提高系统的性能。
* 在读多写少的场合，使用读写锁可以有效提升系统的并发能力。

- [ReadWriteLock](https://hub.fastgit.org/guanpengchn/java-concurrent-programming/blob/master/src/main/java/ch3/s1/ReadWriteLockDemo.java)



#### 4.1.4　锁分离 142

* 通过不同操作分离出不同的锁，实现不同操作的分离，使不同操作成为可并发的操作。

- 在LinkedBlockingQueue中，take和put函数分别作用于队列的前端和尾端，不冲突，如果使用独占锁就无法并发，所以实现中使用了两把锁
- JDK1.7源代码：[LinkedBlockingQueue](https://hub.fastgit.org/guanpengchn/JDK/blob/master/JDK1.7/src/java/util/concurrent/LinkedBlockingQueue.java)



#### 4.1.5　锁粗化 144

- 虚拟机在遇到一连串连续地对**同一锁**不断进行请求和释放的操作时，便会把所有的锁操作整合成对锁的一次请求，从而减少对锁的请求同步次数，这个操作叫做锁的粗化。【对同一锁不停地进行请求、同步和释放，其本身也会消耗系统宝贵地资源，反而不利于性能的优化。】
- 在循环内使用锁往往可以考虑优化成在循环外
- 锁粗化的思想和减少锁持有时间是相反的，但在不同场合，它们的效果并不相同，所以应根据实际情况进行权衡。





### 4.2　Java虚拟机对锁优化所做的努力 146 面试点

* jdk内部也想尽方法提高并发时的系统吞吐量。

* **重量级锁是悲观锁的一种，自旋锁、轻量级锁与偏向锁属于乐观锁**
* java中的悲观锁就是Synchronized
* java中的乐观锁基本都是通过CAS操作实现的，CAS是一种更新的原子操作，比较当前值跟传入值是否一样，一样则更新，否则失败。

#### 重量级锁Synchronized





#### 4.2.1　锁偏向 146

* 针对加锁操作的优化手段。

- 如果一个线程获得了锁，就进入了偏向模式，之后该线程再去连续申请就无须做其他操作【节省了大量有关锁申请的操作，提高了程序的性能】
- 适合几乎没有锁竞争的场合。
- 但是如果不同线程来回切换，效果反而差，不如不开启锁偏向
- Java虚拟机参数：-XX:+IseBiasedLocking



#### 4.2.2　轻量级锁 146

* 偏向锁失败，虚拟机会使用称为轻量级锁的优化手段。

- 偏向锁升级为轻量级锁，轻量级锁，升级为重量级锁
- 这里书中写的比较简略，可以看文章[java 中的锁 -- 偏向锁、轻量级锁、自旋锁、重量级锁](https://blog.csdn.net/zqz_zqz/article/details/70233767)



#### 4.2.3　自旋锁 146

* 锁膨胀后，虚拟机为避免线程真实地在操作系统层面挂起，所做的努力--自旋锁。

- 虚拟机假设当前线程还可以获得锁，不马上挂起线程，让当前线程做几个空循环，如果能获得就进入临界区【这样就**避免用户线程和内核的切换的消耗**。即避免了线程阻塞所带来的代价】，如果不行则挂起

**优缺点**

* 能尽可能的减少线程的阻塞，对于锁竞争不激烈，且占用锁时间非常短的代码来说性能能大幅提升。因为自旋的消耗会小于线程阻塞挂起再唤醒的操作的消耗，这些操作会导致线程发生两次上下文切换！
* 但是如果锁的竞争激烈，或者持有锁的线程需要长时间占用锁执行同步块，这时候就不适合使用自旋锁了，因为自旋锁在获取锁前一直都是占用cpu做无用功，占着XX不XX，同时有大量线程在竞争一个锁，会导致获取锁的时间很长，线程自旋的消耗大于线程阻塞挂起操作的消耗，其它需要cup的线程又不能获取到cpu，造成cpu的浪费。所以这种情况下我们要关闭自旋锁；



**自旋锁时间阈值**

* 如果自旋执行时间太长，会有大量的线程处于自旋状态占用CPU资源，进而会影响整体系统的性能。因此自旋的周期选的额外重要！

* JVM对于自旋周期的选择，jdk1.5这个限度是一定的写死的，在1.6引入了适应性自旋锁，适应性自旋锁意味着自旋的时间不在是固定的了，而是由前一次在同一个锁上的自旋时间以及锁的拥有者的状态来决定，基本认为一个线程上下文切换的时间是最佳的一个时间，同时JVM还针对当前CPU的负荷情况做了较多的优化

  * 如果平均负载小于CPUs则一直自旋

    如果有超过(CPUs/2)个线程正在自旋，则后来线程直接阻塞

    如果正在自旋的线程发现Owner发生了变化则延迟自旋时间（自旋计数）或进入阻塞

    如果CPU处于节电模式则停止自旋

    自旋时间的最坏情况是CPU的存储延迟（CPU A存储了一个数据，到CPU B得知这个数据直接的时间差）

    自旋时会适当放弃线程优先级之间的差异

**自旋锁的开启**

JDK1.6中-XX:+UseSpinning开启；
-XX:PreBlockSpin=10 为自旋次数；
JDK1.7后，去掉此参数，由jvm控制；



#### 4.2.4　锁消除 146

- 在编译过程中，去掉**不可能存在共享资源竞争**的锁，比如局部变量，可以节省毫无意义的请求锁时间。
- 锁消除的一项关键技术叫做逃逸分析【观察某个变量是否会逃出一个作用域，如果逃出了，则其可能被其他线程访问，如果这样，虚拟机就不能消除对该变量的锁操作】
- 逃逸分析必须在-server模式下，虚拟机参数：-XX:+DoEscapeAnalysis打开逃逸分析，-XX:+EliminateLocks打开锁消除



### 4.3　人手一支笔：ThreadLocal 147 工具常用

#### 4.3.1　ThreadLocal的简单使用 148

- 这个demo测试没有ThreadLocal，仅仅是对象在run内部new出来也行呀，不是很懂
- [ThreadLocalDemo](https://hub.fastgit.org/guanpengchn/java-concurrent-programming/blob/master/src/main/java/ch4/s3/ThreadLocalDemo.java)

#### 4.3.2　ThreadLocal的实现原理 149

- ThreadLocalMap我在jdk1.8下运行不出效果来，作者在书中也提到了，二者实现方式不同
- [ThreadLocalDemo_Gc](https://hub.fastgit.org/guanpengchn/java-concurrent-programming/blob/master/src/main/java/ch4/s3/ThreadLocalDemo_Gc.java)
- WeakHashMap和HashMap的区别可以见该[文章](http://mzlly999.iteye.com/blog/1126049)和代码[WeakVsHashMap](https://hub.fastgit.org/guanpengchn/java-concurrent-programming/blob/master/src/main/java/ch4/s3/WeakVsHashMap.java)
- 理解弱引用和强引用概念，可参考[Java 7之基础 - 强引用、弱引用、软引用、虚引用](https://blog.csdn.net/mazhimazh/article/details/19752475)

#### 4.3.3　对性能有何帮助 155

- 见下面demo可得ThreadLocal的效率还是很高的
- [ThreadLocalPerformance](https://hub.fastgit.org/guanpengchn/java-concurrent-programming/blob/master/src/main/java/ch4/s3/ThreadLocalPerformance.java)

### 4.4　无锁 157

- 无锁策略使用一种叫做比较交换的技术（CAS Compare And Swap）

#### 4.4.1　与众不同的并发策略：比较交换（CAS） 158 重要

- 天生免疫死锁，没有锁竞争和线程切换的开销
- CAS(V,E,N)，V表示要更新的变量，E表示预期值，N表示新值，当V=E时，才会将V值设为N，如果不相等则该线程被告知失败，可以再次尝试
- 硬件层面现代处理器已经支持原子化的CAS指令

#### 4.4.2　无锁的线程安全整数：AtomicInteger 159

- atomic包中实现了直接使用CAS的线程安全类型
- [AtomicIntegerDemo](https://hub.fastgit.org/guanpengchn/java-concurrent-programming/blob/master/src/main/java/ch4/s4/AtomicIntegerDemo.java)

#### 4.4.3　Java中的指针：Unsafe类 161

- native方法是不用java实现的
- [compareAndSet](https://hub.fastgit.org/guanpengchn/JDK/blob/master/JDK1.7/src/java/util/concurrent/atomic/AtomicInteger.java#L134-L136)
- Unsafe类在rt.jar中，jdk无法找到
- JDK开发人员并不希望大家使用Unsafe类，下面的代码，会检查调用getUnsafe函数的类，如果这个类的ClassLoader不为空，直接抛出异常拒绝工作，这使得自己的程序无法直接调用Unsafe类

```
public static Unsafe getUnsafe() {
    Class cc = Reflection.getCallerClass();
    if (cc.getClassLoader() != null)
        throw new SecurityException("Unsafe");
    return theUnsafe;
}
```

- 注意：根据Java类加载器的原理，应用程序的类由App Loader加载，而系统核心的类，如rt.jar中的由Bootstrap类加载器加载。Bootstrap加载器没有java对象的对象，因此试图获得该加载器会返回null，所以当一个类的类加载器为null时，说明是由Bootstrap加载的，这个类也极可能是rt.jar中的类

#### 4.4.4　无锁的对象引用：AtomicReference 162

- AtomicInteger是对整数的封装，AtomicReference是对对象的封装
- 运行下面demo可以见到错误，进行了多次充值，原因是状态可能不同，但是值却可能相同，所以不应该用值来判断状态
- [AtomicReferenceDemo](https://hub.fastgit.org/guanpengchn/java-concurrent-programming/blob/master/src/main/java/ch4/s4/AtomicReferenceDemo.java)

#### 4.4.5　带有时间戳的对象引用：AtomicStampedReference 165

- 对象值和时间戳必须都一样才能修改成功，所以只会充值一次
- [AtomicStampedReferenceDemo](https://hub.fastgit.org/guanpengchn/java-concurrent-programming/blob/master/src/main/java/ch4/s4/AtomicStampedReferenceDemo.java)

#### 4.4.6　数组也能无锁：AtomicIntegerArray 168

- [AtomicIntegerArrayDemo](https://hub.fastgit.org/guanpengchn/java-concurrent-programming/blob/master/src/main/java/ch4/s4/AtomicIntegerArrayDemo.java)

#### 4.4.7　让普通变量也享受原子操作：AtomicIntegerFieldUpdater 169

- 可以包装普通变量，让其也具有原子操作
- [AtomicIntegerFieldUpdaterDemo](https://hub.fastgit.org/guanpengchn/java-concurrent-programming/blob/master/src/main/java/ch4/s4/AtomicIntegerFieldUpdaterDemo.java)
- 变量必须可见，不能为private
- 为确保变量被正确读取，需要有volatile
- CAS通过偏移量赋值，不支持static（Unsafe, objectFieldOffset不支持静态变量）

#### 4.4.8　挑战无锁算法：无锁的Vector实现 171 了解

- N_BUCKET为30，相当于有30个数组，第一个数组大小FIRST_BUCKET_SIZE为8，但是Vector之后会不断翻倍，第二个数组就是16个，最终能2^33左右
- 这段比较复杂，多看

#### 4.4.9　让线程之间互相帮助：细看SynchronousQueue的实现 176

### 4.5　有关死锁的问题 179

- [DeadLock](https://hub.fastgit.org/guanpengchn/java-concurrent-programming/blob/master/src/main/java/ch4/s5/DeadLock.java)

### 4.6　参考文献 183
