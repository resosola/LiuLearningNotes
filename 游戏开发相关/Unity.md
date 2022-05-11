# Unity

* 脚本

  * fps【frame per second】：每秒执行的帧数。

  * Update()函数：**每一帧执行一次**。fps不同，1s内Update调用次数也不同。

  * Time.DeltaTime：

    * 增量时间（1帧所消耗的时间），60fps则Time.DeltaTime为1/60s。

    * **增量时间每一帧都在变动，与当前的fps有关**。

    * 因为不同fps情况下，每秒Update的执行次数不同，Update对变量的变化也会不同，故可与**Time.DeltaTime**配合，保持**1s间隔**的变化值一样，达到不同机器运行效果近似一样。【这1s内由于执行次数的不同，fps高的执行多，变量的变化更加紧**凑**，而fps低的变量变化较**分散**，但1s后两者的**最终值相同**】

      ```c#
      //【每帧执行】
      void Update() {    
           speed = speed * speedMul * Time.DeltaTime;     // 改变速度的值
      }
      ```

  * FixedUpdate()函数：**固定每0.02s执行一次**，**与fps无关**，所以不同机型运行起来没区别。

* 面板

  * Inspector：显示当前选择的游戏对象、脚本或资产【图片和各种组件等】的属性。
    * 锁定Inspector![image-20220427222937828](D:\Typora\typora-user-images\img\img\image-20220427222937828.png)
    * 图片Insepector![image-20220427224045905](D:\Typora\typora-user-images\img\img\image-20220427224045905.png)

* 主相机
* 场景
* 贴图
* 组件
  * Collider 2D：碰撞体，为了**物理碰撞的目的**而出现。
    * Circle Collider 2D：圆形碰撞区
    * Box Collider 2D：正方形和矩形碰撞。
    * Polygon Collider 2D：自由形式的碰撞区。
    * Edge Collider 2D 

* update
* 音乐：
* 脚本
  * 注意代码的编写逻辑，逻辑错误可能原本的动画替换掉
* 动画：
  * Animator：各Animation必须要能转换到其他状态，否则将一直维持同一状态，即使满足该状态的条件不再满足，因为其无法转到其他状态。
  * 可在每个动画后添加一个事件函数，该事件函数可用来进状态转换。
* 碰撞体 Collider
  * is Trigger：无需碰撞效果
* UI
  * dialog:
    * 内部加动画可有渐变效果
  * Slider:
    * 注意其他UI不要挡住进度条，否则无法拖动。
* 2D光效
  * Direnction Light：方向光
  * point Light：点光
    * Intensity：光强

  * 光效都是3d的，可调整光源位置![image-20220426154234656](D:\Typora\typora-user-images\img\img\image-20220426154234656.png)


* 父子物体：
  * 子物体的位置随父物体的位置移动
* 移动端配置
  * 所有屏幕摇动杠都是UI

