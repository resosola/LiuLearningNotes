## java基础 面试题

* 包装器缓冲池问题
  * Integer、Character、Byte、Short、Boolean、Long这些类型包装器都有对应的缓冲池【Double、Float这些浮点数类型则没】
  * 除了Boolean只有true和false缓冲外，其他包装器的缓冲值范围都为[-127,128]
  * 调用对应的valueOf()方法都会从缓冲池中找出相应的对象出来。
* Object类中的常用方法
  * equals：默认封装==，比较两变量是否引用同一对象
  * hashCode：得到散列码
  * clone：浅拷贝【对象为新对象，变量与原对象变量相同】
  * toString：默认为类名+@+散列码
  * wait：将当前线程挂起，线程会释放锁
  * notify：唤醒挂起的线程
  * notifyAll：唤醒所有挂起的线程

