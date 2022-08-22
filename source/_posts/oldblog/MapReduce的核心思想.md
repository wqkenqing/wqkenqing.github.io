
---

title: MapReduce的核心思想
date: 2019-07-16
tags: 

---
此处简介
<!--more-->

`mapreduce在hadoop中更多的承担的是计算的角色`

## 什么是MapReduce？

mapreduce源于谷歌公司为研究大规模数据处理而研发出的一种并行计算模型和方法。
它将并行编程中的难点和有相对门槛的方法进行高度封装，而给开发者一套接口，让开发者理专注于自己的业务逻辑，即可让自己的代码运行在分布式集群中，大大降低了开发一些并发程序的门槛。从字面上就可以知道，MapReduce分为Map(映射)、Reduce(规约)

## MapReduce的核心思想

MapReduce主要是两种经典函数：

*   映射（Mapping）将一个整体按某种规则映射成N份。并对这N份进行同一种操作。
*   规约（Reducing）将N份文件，按某种策略进行合并。

## MapReduce的角色与动作

　 MapReduce包含四个组成部分，分别为**Client**、**JobTracker**、**TaskTracker**和**Task**，下面我们详细介绍这四个组成部分。

*   Client：作业提交的发起者， 每一个 Job 都会在用户端通过 Client 类将应用程序以及配置参数 Configuration 打包成 JAR 文件存储在 HDFS，并把路径提交到 JobTracker 的 master 服务，然后由 master 创建每一个 Task（即 MapTask 和 ReduceTask） 将它们分发到各个 TaskTracker 服务中去执行。
*   JobTracker：初始化作业，分配作业，与TaskTracker通信，协调整个作业 JobTracke负责资源监控和作业调度。JobTracker 监控所有TaskTracker 与job的健康状况，一旦发现失败，就将相应的任务转移到其他节点；同时，JobTracker 会跟踪任务的执行进度、资源使用量等信息，并将这些信息告诉任务调度器，而调度器会在资源出现空闲时，选择合适的任务使用这些资源。在Hadoop 中，任务调度器是一个可插拔的模块，用户可以根据自己的需要设计相应的调度器。
*   TaskTracker：TaskTracker 会周期性地通过Heartbeat 将本节点上资源的使用情况和任务的运行进度汇报给JobTracker，同时接收JobTracker 发送过来的命令并执行相应的操作（如启动新任务、杀死任务等）。TaskTracker 使用“slot”等量划分本节点上的资源量。“slot”代表计算资源（CPU、内存等）。一个Task 获取到一个slot 后才有机会运行，而Hadoop 调度器的作用就是将各个TaskTracker 上的空闲slot 分配给Task 使用。slot 分为Map slot 和Reduce slot 两种，分别供Map Task 和Reduce Task 使用。TaskTracker 通过slot 数目（可配置参数）限定Task 的并发度。
*   Task ： Task 分为Map Task 和Reduce Task 两种，均由TaskTracker 启动。HDFS 以固定大小的block 为基本单位存储数据，而对于MapReduce 而言，其处理单位是split。
*   Map Task 执行过程如下图 所示：由该图可知，Map Task 先将对应的split 迭代解析成一个个key/value 对，依次调用用户 自定义的map() 函数进行处理，最终将临时结果存放到本地磁盘上, 其中临时数据被分成若干个partition，每个partition 将被一个Reduce Task 处理。
   ![09d902f773ff4e30b1cf995705d4f03c-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/09d902f773ff4e30b1cf995705d4f03c-image.png)


    Reduce Task 执行过程下图所示。该过程分为三个阶段
    ![2f9ff84d09cf424cb8a1c4d24db637c0-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/2f9ff84d09cf424cb8a1c4d24db637c0-image.png)



**提交作业**

*   在作业提交之前，需要对作业进行配置
*   程序代码，主要是自己书写的MapReduce程序
*   输入输出路径
*   其他配置，如输出压缩等
*   配置完成后，通过JobClient来提交

**作业的初始化**

*   客户端提交完成后，JobTracker会将作业加入队列，然后进行调度，默认的调度方法是FIFO调试方式
    **任务的分配**
*   TaskTracker和JobTracker之间的通信与任务的分配是通过心跳机制完成的。
*   TaskTracker会主动向JobTracker询问是否有作业要做，如果自己能做，那么就会申请作业任务，这个任务可以使Map，也可能是Reduce任务
    **任务的执行**
*   申请到任务后，TaskTracker会做如下事情：
*   拷贝代码到本地
*   拷贝任务的信息到本地
*   启动Jvm运行任务
    **状态与任务的更新**
*   任务在运行过程中，首先会将自己的状态汇报给TaskTracker，然后由TaskTracker汇总报给JobTracker
*   任务进度是通过计数器来实现的。

**作业的完成**

*   JobTracker 是在接受到最后一个任务运行完成后，才会将任务标志为成功
*   此时会做删除中间结果等善后处理工作
  ![8fba570574f6491c96b51698743466b2-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/8fba570574f6491c96b51698743466b2-image.png)


### MapReduce任务执行流程与数据处理流程详解

`就任务流程而言，上文中有些或已经涉及，有些也介绍的比较详细了。但就整体而言，不是特别具体，或这个整体性，所以在此我们再集中总结一下，即使重复内容，就也当加深印象吧。`

#### 任务执行流程详解

1.  通过jobClient提交当mapreduce的job提交至JobTracker
    ,提交的具体信息大致会有，conf配置内容，path，相关的Map，Reduce函数等。（数据的切片会在client上完成）
2.  JobTracker中的Master服务会完成创建一个Task（MapTask与ReduceTask），并将这个任务加载至任务队列中，等待TaskTracker来获取。同进JobTracker会处于一种监听状态，监听所有TaskTracker与Job的健康情况。面对故障时，提供服务转移等。同时它还会记录任务的执行进度，资源的使用情况，提交至任务调度器，由调度器进行资源的调度。
3.  TaskTracker会主动向jobTacker去询问是否有任务，如果有，就会申请到作业，作业可以是map,也可以是reduce任务。TaskTracker获取的不仅是任务，还有相关的处理代码也会copy一份至本地，然后TaskTracker再针对所分配的split进行处理。TaskTracker还会周期性地通过HearBeat将本节点上的资源的使用情况和任务的进行进度汇报给JobTracker，同时接收JobTracker发过来的相关命令并执行，
4.  当TaskTracker中的任务完成后会上报给JobTracker,而当最后一个TaskTracker完成后，JobTracker才会将任务标志为成功，并执行一些如删除中间结果等善后工作。

* * *

`从这里我们知道了mapreduce中任务执行流程，但mapreduce作为hadoop的计算框架，它对数据的处理流程我们还没明确涉及，所以接下来我们再深入了解下具体的数据处理流程`

#### 数据处理流程详解

这里的数据处理流程，主要指的是mapreduce执行后，Task中对split的任务具体处理的这一流程，其中还包括，数据的切片，mapTask完成后将中间结果上传等动作。下面我们来具体讨论
当jobClient向JobTracker提交了任务后，数据处理流程也随之开始

*   在Client端将输入源的数据进行切片(split)，具体的切片机制参考后面
*   JobTracker中的MRAppMaster将每个Split信息计算出需要的MapTask的实例数量，然后向集群申请机器启动相应数量的mapTask进程
*   进程启动后，根据给定的数据切片范围进行数据处理，主要流程为
    a)通过inputFormat来获取RecordReader读取数据，并形成输入的KV对
    b)将输入KV对传递给用户定义的map（）方法，做逻辑处理，并map()方法的输出的kv对手机到缓存中(这里用到了缓存机制)
    简而言之map中输入时要做的事是
    1.反射构造InputFormat.
    2.反射构造InputSplit.
    3.创建RecordReader.
    4.反射创建MapperRunner

![3a461434b0604118aad45a4d38cf3649-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/3a461434b0604118aad45a4d38cf3649-image.png)


而map输出时相对复杂，主要涉及到的有Partitioner，shuffle，sort，combiner等概念，我们就来一一讨论。
在map（）方法执行后，map阶段是会有处理的数据输出，正常来说，就是每个split对应的每一行。如上图MapRunner的next为false时，对输入数据的map完成，这时对存内中这些map的数据，会对其进行sort,如果我们事先设置的有combiner那么，还会对sort完的数据执行combiner(**一个类reduce操作，不过是对本地数据的reduce，使用它的原则是combiner的输入不会影响到reduce计算的最终输入，例如：如果计算只是求总数，最大值，最小值可以使用combiner，但是做平均值计算使用combiner的话，最终的reduce计算结果就会出错。**)，然后开始map的内容spill到磁盘中，如果频繁的spill对磁盘会带来较大的损耗和效率影响。所以引入了一个写缓冲区的概念，即每一个Map Task都拥有一个“环形缓冲区”作为Mapper输出的写缓冲区。写缓冲区大小默认为100MB（通过属性io.sort.mb调整），当写缓冲区的数据量达到一定的容量限额时（默认为80%，通过属性io.sort.spill.percent调整），后台线程开始将写缓冲区的数据溢写到本地磁盘。在数据溢写的过程中，只要写缓冲区没有被写满，Mappper依然可以将数据写出到缓冲区中；否则Mapper的执行过程将被阻塞，直到溢写结束。
溢写以循环的方式进行（即写缓冲区的数据量大致限额时就会执行溢写），可以通过属性mapred.local.dir指定写出的目录。
spill结束前 溢写线程将数据最终写出到本地磁盘之前，首先根据Reducer的数目对这部分数据进行分区（即每一个分区中的数据会被传送至同一个Reducer进行处理，分区数目与Reducer数据保持一致）即 **partition**，partition是一个类inputSplit()的操作，即根据有多少个ReduceTask生成多少个partition,并通过jobTracker指定给相应的ReduceTask。
当spill完成后，本地磁盘中会有多个溢出文件存在。在MapTask结束前，这些文件会根据相应的分区进行合并，并排序，合并可能发生多次，具体由**io.sort.factor控制一次最多合并多少个文件。**

如果溢写文件个数超过3（通过属性min.num.spills.for.combine设置），会对合并且分区排序后的结果执行Combine过程（如果MapReduce有设置Combiner），而且combine过程在不影响最终结果的前提下可能会被执行多次；否则不会执行Combine过程（相对而言，Combine开销过大）。

注意：Map Task执行过程中，Combine可能出现在两个地方：写缓冲区溢写过程中、溢写文件合并过程中。

注意：Mapper的一条输出结果（由key、value表示）写出到写缓冲区之前，已经提前计算好相应的分区信息，即分区的过程在数据写入写缓冲区之前就已经完成，溢写过程实际是写缓冲区数据排序的过程（先按分区排序，如果分区相同时，再按键值排序）。

这里涉及到MapReduce的两个组件：Comparator、Partitioner。
(由于篇幅的原因，这里暂不引入对这两个组件的源码分析，和自定义方式，后面有机会则单开文章讨论)

在将map输出结果作为reducTask中的输入时，会涉及到磁盘写入，网络传输等资源的限制，所以对出于节省资源的考虑，可以在对map的输出结果进行压缩。默认情况下，压缩是不被开启的，可以通过属性**mapred.compress.map.output**、**mapred.map.output.compression.codec**进行相应设置。

当MapTask任务结束后，被指定的分区ReduceTask会立即开始执行，即开始拷贝对应MapTask分区中的输出结果。
Reduce Task的这个阶段被称为“Copy Phase”。Reduce Task拥有少量的线程用于并行地获取Map Tasks的输出结果，默认线程数为5，可以通过属性mapred.reduce.parallel.copies进行设置。
同样：如果Map Task的输出结果足够小，它会被拷贝至Reduce Task的缓冲区中；否则拷贝至磁盘。当缓冲区中的数据达到一定量（由属性mapred.job.shuffle.merge.percent、mapred.inmem.merge.threshold），这些数据将被合并且溢写到磁盘。如果Combine过程被指定，它将在合并过程被执行，用来减少需要写出到磁盘的数据量。

随着拷贝文件中磁盘上的不断积累，一个后台线程会将它们合并为更大地、有序的文件，用来节省后期的合并时间。如果Map Tasks的输出结合使用了压缩机制，则在合并的过程中需要对数据进行解压处理。

当Reduce Task的所有Map Tasks输出结果均完成拷贝，Reduce Task进入“Sort Phase”（更为合适地应该被称为“Merge Phase”，排序在Map阶段已经被执行），该阶段在保持原有顺序的情况下进行合并。这种合并是以循环方式进行的，循环次数与合并因子（io.sort.factor）有关。
sort phase 通常不是合并成一个文件，而是略过磁盘操作，直接将数据合并输入至Reduce方法中 这次合并的数据可以结合内存、磁盘两部分进行操作），即“Reduce Phase”。

通常这里还有一个“Group”的阶段，这个阶段决定着哪些键值对属于同一个键。如果没有特殊设置，只有在Map Task输出时那些键完全一样的数据属于同一个键，但这是可以被改变的。

描述至这里终于能引用mapreduce中相当重要的一个概念，即shuffle。这个词在这里该怎么定义，我暂未找到个一个比较满意的答案，但我比较喜欢有人把这个比作是搓完牌一桌子人，在下一局开始前的整个过程。
即Shuffle操作，涉及到数据的partition、sort、[combine]、spill、[comress]、[merge]、copy、[combine]、merge、group，而这些操作不但决定着程序逻辑的正确性，也决定着MapReduce的运行效率。

shuffle完后进入了ReduceTask的reduce()方法中
在Reduce Phase的过程中，它处理的是所有Map Tasks输出结果中某一个分区中的所有数据，这些数据整体表现为一个根据键有序的输入，对于每一个键都会相应地调用一次Reduce Function（同一个键对应的值可能有多个，这些值将作为Reduce Function的参数）

至此MapReduce的逻辑过程基本描述完成，虽然洋洋洒洒可能会有数千字，但本文的出发点就不是简析，而更多是自我概念原理部份的总结，所以力求整个流程完整详细。后面我配上一些网络图片，方便大家快速理解，结合文字加深印象。
![b26c54ff10ad4e2b9832a960ef4aab90-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/b26c54ff10ad4e2b9832a960ef4aab90-image.png)

![a179f15b88cc403b8bd84d7963823762-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/a179f15b88cc403b8bd84d7963823762-image.png)

![4a5b5498dd764087ade380db394e6f84-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/4a5b5498dd764087ade380db394e6f84-image.png)

![74ed215c305747a49348430782e5636a-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/74ed215c305747a49348430782e5636a-image.png)


![b55be177bd514ce79b7444c2dd3ddcfb-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/b55be177bd514ce79b7444c2dd3ddcfb-image.png)

![286bb24da172471793924b2b9b7c857c-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/286bb24da172471793924b2b9b7c857c-image.png)
![68bbc5f114f3496d886402cbb0da8fc1-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/68bbc5f114f3496d886402cbb0da8fc1-image.png)

![38d8bf9498274367b22856f62a8f7fcf-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/38d8bf9498274367b22856f62a8f7fcf-image.png)

![7b7e5da815064fdfa0d060910f8dfb9b-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/7b7e5da815064fdfa0d060910f8dfb9b-image.png)

![a4ac8a6f758b4bdfb5e1a752a02f0654-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/a4ac8a6f758b4bdfb5e1a752a02f0654-image.png)

![9e91f8a6b0ab488abbad0714487fe10f-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/9e91f8a6b0ab488abbad0714487fe10f-image.png)

![87a4d55fff15408c87f94029b8fb2aea-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/87a4d55fff15408c87f94029b8fb2aea-image.png)

![eb099e53d6fa44a5b76410040f41f3ae-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/eb099e53d6fa44a5b76410040f41f3ae-image.png)

![98aac8b77be64d53b276f7a112aba12d-image.png](http://rgr3ifyzo.sabkt.gdipper.com//file/2017/10/98aac8b77be64d53b276f7a112aba12d-image.png)



