---

title: Hadoop总结(第一版---HDFS篇)
date: 2019-07-16
tags: 

---
此处简介
<!--more-->

# Hadoop总结(第一版---HDFS篇)
```接触hadoop生态也有大半年了，一直碎片化的查阅，学习了一些博客和书籍。随着使用的深入，对一些常用的模块有较熟练的使用，也有写过一些日常小结，但对hadoop本身背后的原理没有系统性的学习，回顾来看，就提升曲线来说，现在亟需总结这环节，这也是本文的由来```
## 什么是hadoop？
>hadoop是稳定的，高容错的，可大规模布署的分布式文件，存储，并行编程框架。
```本文默认是已经有hadoop使用经验,所以暂不涉及具体的hadoop生态的各组件的部署和调优细节，后续单开文章来总结。但在具体讲解时会涉及说参数配置会对相关组件参生影响```
具体而言，hadoop核心组件内容有：**hdfs**、**mapredcue**。所以接下来的总结主要针对这两在核心组件展开
## HDFS篇
### 什么是HDFS？
**分布式文件系统**：分布式文件系统是一种允许文件通过网络在多台主机上分享的 文件的系统，可让多机器上的多用户分享文件和存储空间
HDFS:（Hadoop Distribute File System）即hadoop分布式文件系统  主要用于适合运行在通用硬件上的分布式文件系统，特点是高度容错，适合布署在廉价服务器上，具有高吞吐量的数据访问等特点  1\. 保存多个副本，且提供容错机制，副本丢失或宕机自动恢复。默认存3份。  2\. 运行在廉价的机器上。  3\. 适合大数据的处理。多大？多小？HDFS默认会将文件分割成block，64M为1个block。然后将block按键值对存储在HDFS上，并将键值对的映射存到内存中。如果小文件太多，那内存的负担会很重。  4\. 适用于一次写入、多次查询的情况  5\. 不支持并发写情况，小文件不合适。因为小文件也占用一个块，小文件越多（1000个1k文件）块越 多，NameNode压力越大。
``hdfs得部署在linux系统上``
### HDFS的具体内容
文件、节点、数据块 HDFS主要是是围绕着这三个关键词设计的.
#### **数据块**
* Block：在HDFS中，每个文件都是采用的分块的方式存储，每个block放在不同的dataNode节点上，每个block的标识是一个三元组(block id , numBytes,generationStamp),block id 具有唯一性，具体分配是由namenode节点设置，然后在datanode上建立对应的Block文件，同时建立对应的block meta文件(问题是block meta文件存放位，block size可以通过配置文件设置，所以修改block size会对以前持续化的数据有何影响?）
* Packet:是HDFS文件在DFSClient与DataNode之间通信的过程中文件的形式(一般一个Block对应多个Packet)
* Chunk:是通过程中具体传输的文件单位，发送过程以Packet的方式进行，但 一个packet包含多个Chunk,同时对于每个chunk进行checksum计算，生成checksum bytes。

**Packet**
Packet的结构：数据包和heatbeat包  一个Packet数据包的组成结构主要分为 Packet Header 、PacketData  Packet Header 中又分为：
![10eed6bcc563463ea0b8cd5adf99adec-image.png](//img.wqkenqing.ren.qiniudns.com/file/2017/7/10eed6bcc563463ea0b8cd5adf99adec-image.png)
Packet Data部分是一个Packet的实际数据部分。
主要内容有

* 一个4字节校验
* Checksum
* Chunk部分，Chunk部分最大为512字节
![c68e61da1e8148ab99b43fe8e3f5408e-image.png](//img.wqkenqing.ren/file/2017/7/c68e61da1e8148ab99b43fe8e3f5408e-image.png)
Packet创建过程：首先将字节流数据写入一个buffer缓冲区中，也就是从偏移量为25的位置（checksumStart）开 始写Packet数据Chunk的Checksum部分，从偏移量为533的位置（dataStart）开始写Packet数据的Chunk Data部分，直到一个Packet创建完成为止。

```注意：当写一个文件的最后一个Block的最后一个Packet时，如果一个Packet的大小未能达到最大长度，也就是上图对应的缓冲区 中，Checksum与Chunk Data之间还保留了一段未被写过的缓冲区位置，在发送这个Packet之前，会检查Chunksum与Chunk Data之间的缓冲区是否为空白缓冲区（gap），如果有则将Chunk Data部分向前移动，使得Chunk Data 1与Chunk Checksum N相邻，然后才会被发送到DataNode节点```

#### hdsf架构(主要组成是节点）
主要的构成角色有：Client、NameNode、SecondayNameNode、DataNode
![5ba6f1ec6b9c4b0982dc2ce73ff9c444-image.png](//img.wqkenqing.ren/file/2017/7/5ba6f1ec6b9c4b0982dc2ce73ff9c444-image.png)

+ Client：系统使用者，调用HDFS API操作文件；与NN交互获取文件元数据;与DN交互进行数据读写, 注意：写数据时文件切分由Client完成
+ Namenode：Master节点 （也称元数据节点）是系统唯一的管理者。负责元数据的管理(名称空间和数据块映射信息);配置副本策略；处理客户端请求
+ Datanode：数据存储节点(也称Slave节点)，存储实际的数据；执行数据块的读写；汇报存储信息给NN
+ Secondary NameNode：备胎，namenode的工作量；是NameNode的冷备份；合并fsimage和fsedits然后再发给namenode

```careful:``` 注意：在hadoop 2.x 版本，当启用 hdfs ha 时，将没有这一角色
**热冷备份说明**：
热备份：b是a的热备份，如果a坏掉。那么b马上运行代替a的工作  冷备份：b是a的冷备份，如果a坏掉。那么b不能马上代替a工作。但是b上存储a的一些信息，减少a坏掉之后的损失
**hdfs构架原则**

1. 元数据与数据分离：文件本身的属性（即元数据）与文件所持有的数据分离
2. 主/从架构：一个HDFS集群是由一个NameNode和一定数目的DataNode组成
3. 一次写入多次读取：HDFS中的文件在任何时间只能有一个Writer。当文件被创建，接着写入数据，最后，一旦文件被关闭，就不能再修改。
4. 移动计算比移动数据更划算：数据运算，越靠近数据，执行运算的性能就越好，由于hdfs数据分布在不同机器上，要让网络的消耗最低，并提高系统的吞吐量，最佳方式是将运算的执行移到离它要处理的数据更近的地方，而不是移动数据

**针对第四条的解释**：
在上文中交代到hdfs中的文件是以block的形式存放在集群中，所以一个文件可以是被切分成很多block存放在集群的机器中针对第四条，移动计算比移动数据更划算，是因为，从理论上讲，集群的计算能力是很方便扩展的，如服务器的硬件提升，或增加服务器等。但网络带宽等资源却很容易达到瓶颈或增加经济负担，所以将计算转移至每个block就近的机器进行计算，会比将所有的block合到一个机器上再进行计算要划算，所以，叫移动计算要比移动数据划算

##### NameNode
NameNode是整个文件系统的管理与计算节点，是HDFS中最复杂的一个实体，它与管理着HDFS文件系统中最重要的两个关系


1. HDFS文件系统中的文件目录树，以及文件的数据块索引，即每个文件对应的数据块列表  数据块和数据节点的对应关系，即某一块数据块保存在哪些数据节点的信息  **第一个关系**即目录树、元数据和数据块的索引信息持久化到物理存储中，具体的实现是保存在命名空间的镜像fsimage和编辑日志edits中，**careful**：在fsimage中，并没有记录每一个block对应到那几个Datanodes的对应表信息
2. **第二个关系是**在NameNode启动后，每个DataNode对本地的磁盘进行扫描，将本DataNode上保存的block信息上报至NameNode,Namenode在接收到每个Datanode的块信息汇报后，将接收到的块信息，以及其所在的Datanode信息等保存在内存中。HDFS就是通过这种块信息汇报的方式来完成 block -> Datanodes list的对应表构建（**careful**）
类似于数据库中的检查点，为了避免edits日志过大，在Hadoop1.X 中，SecondaryNameNode会按照时间阈值（比如24小时）或者edits大小阈值（比如1G），周期性的将fsimage和edits的合 并，然后将最新的fsimage推送给NameNode。而在Hadoop2.X中，这个动作是由Standby NameNode来完成.
由此可看出，这两个文件一旦损坏或丢失，将导致整个HDFS文件系统不可用
在hadoop1.X为了保证这两种元数据文件的高可用性，一般的做法，将dfs.namenode.name.dir设置成以逗号分隔的多个目录，这多个目录至少不要在一块磁盘上，最好放在不同的机器上，比如：挂载一个共享文件系统
fsimage\edits 是序列化后的文件，想要查看或编辑里面的内容，可通过 hdfs 提供的 oiv\oev 命令，
命令: hdfs oiv （offline image viewer） 用于将fsimage文件的内容转储到指定文件中以便于阅读,，如文本文件、XML文件，该命令需要以下参数：
-i (必填参数) –inputFile <arg> 输入FSImage文件
-o (必填参数) –outputFile <arg> 输出转换后的文件，如果存在，则会覆盖
-p (可选参数） –processor <arg> 将FSImage文件转换成哪种格式： (Ls|XML|FileDistribution).默认为Ls
示例：hdfs oiv -i /data1/hadoop/dfs/name/current/fsimage_0000000000019372521 -o /home/hadoop/fsimage.txt
命令：hdfs oev (offline edits viewer 离线edits查看器）的缩写， 该工具只操作文件因而并不需要hadoop集群处于运行状态。
示例: hdfs oev -i edits_0000000000000042778-0000000000000042779 -o edits.xml
支持的输出格式有binary（hadoop使用的二进制格式）、xml（在不使用参数p时的默认输出格式）和stats（输出edits文件的统计信息）
由此可以总结到：NameNode管理着DataNode，接收DataNode的注册、心跳、数据块提交等信息的上报，并且在心跳中发送数据块**复制**、**删除**、**恢复**等指令；同时，NameNode还为客户端对**文件系统目录树的操作**和对**文件数据读写**、对**HDFS系统进行管理提供支持**
另 Namenode 启动后会进入一个称为**安全模式**的特殊状态。处于安全模式 的 Namenode 是不会进行数据块的复制的。 Namenode 从所有的 Datanode 接收心跳信号和块状态报告。 块状态报告包括了某个 Datanode 所有的数据 块列表。每个数据块都有一个指定的最小副本数。当 Namenode 检测确认某 个数据块的副本数目达到这个最小值，那么该数据块就会被认为是副本安全 (safely replicated) 的；在一定百分比（这个参数可配置）的数据块被 Namenode 检测确认是安全之后（加上一个额外的 30 秒等待时间）， Namenode 将退出安全模式状态。接下来它会确定还有哪些数据块的副本没 有达到指定数目，并将这些数据块复制到其他 Datanode 上。  ##### Secondary NameNode  在HA cluster中又称为standby node
主要作用：  1.如上文提到的合并fsimage和eits日志，将eits日志文件大小控制在一个限度下  大致流程如下  namenode 响应 Secondary namenode 请求，将 edit log 推送给 Secondary namenode ， 开始重新写一个新的 edit log  Secondary namenode 收到来自 namenode 的 fsimage 文件和 edit log  Secondary namenode 将 fsimage 加载到内存，应用 edit log ， 并生成一 个新的 fsimage 文件  Secondary namenode 将新的 fsimage 推送给 Namenode  Namenode 用新的 fsimage 取代旧的 fsimage ， 在 fstime 文件中记下检查 点发生的时
![aed541bebcc04fb79e2de3c504b7ee46-image.png](//img.wqkenqing.ren/file/2017/7/aed541bebcc04fb79e2de3c504b7ee46-image.png)


#### HDFS写文件  1.x 默认的block大小是64M 2.X版本默认block的大小是 128M ![d0c33b33bfbc41e8a493553395e52ef0-image.png](//img.wqkenqing.ren/file/2017/7/d0c33b33bfbc41e8a493553395e52ef0-image.png)
如上图所示  + Client预先设置的block参数切分FIle

+ CLient向NameNode发送写数据请求，
+ NameNode，记录block信息，并返回可用的DataNode(具体的返回规则参考下文)
+ client向DataNode发送block1；发送过程是以流式写入具体流程是

1. 将64M的block1按64k的packet划分
2. 然后将第一个packet发送给host2
3. host2接收完后，将第一个packet发送给host1，同时client想host2发送第二个packet
4. host1接收完第一个packet后，发送给host3，同时接收host2发来的第二个packet
5. 以此类推，如图红线实线所示，直到将block1发送完毕
6. host2,host1,host3向NameNode，host2向Client发送通知，说“消息发送完了”。
7. client收到host2发来的消息后，向namenode发送消息，说我写完了。这样就真完成了。
8. 发送完block1后，再向host7，host8，host4发送block2  当客户端向 HDFS 文件写入数据的时候，一开始是写到本地临时文件中。假设该文件的副 本系数设置为 3 ，当本地临时文件累积到一个数据块的大小时，客户端会从 Namenode 获取一个 Datanode 列表用于存放副本。然后客户端开始向第一个 Datanode 传输数据，第一个 Datanode 一小部分一小部分 (4 KB) 地接收数据，将每一部分写入本地仓库，并同时传输该部分到列表中 第二个 Datanode 节点。第二个 Datanode 也是这样，一小部分一小部分地接收数据，写入本地 仓库，并同时传给第三个 Datanode 。最后，第三个 Datanode 接收数据并存储在本地。因此， Datanode 能流水线式地从前一个节点接收数据，并在同时转发给下一个节点，数据以流水线的 方式从前一个 Datanode 复制到下一个
![2c77aaad2f684820bf8a6b475b79d2f1-image.png](//img.wqkenqing.ren/file/2017/7/2c77aaad2f684820bf8a6b475b79d2f1-image.png)

  写入的过程，按hdsf默认设置，1T文件，我们需要3T的存储，3T的网络流量  在执行读或写的过程中，NameNode和DataNode通过HeartBeat进行保存通信，确定DataNode活着。如果发现DataNode死掉了，就将死掉的DataNode上的数据，放到其他节点去。读取时，要读其他节点去  挂掉一个节点，没关系，还有其他节点可以备份；甚至，挂掉某一个机架，也没关系；其他机架上，也有备份
##### hdfs读文件

  ![8fb62c84f57a4203a2dbedf5f68920d9-image.png](//img.wqkenqing.ren/file/2017/7/8fb62c84f57a4203a2dbedf5f68920d9-image.png)

  客户端通过调用FileSystem对象的open()方法来打开希望读取的文件，对于HDFS来说，这个对象时分布文件系统的一个实例；  DistributedFileSystem通过使用RPC来调用NameNode以确定文件起始块的位置，同一Block按照重复数会返回多个位置，这些位置按照Hadoop集群拓扑结构排序，距离客户端近的排在前面  前两步会返回一个FSDataInputStream对象，该对象会被封装成DFSInputStream对象，DFSInputStream可以方便的管理datanode和namenode数据流，客户端对这个输入流调用read()方法  存储着文件起始块的DataNode地址的DFSInputStream随即连接距离最近的DataNode，通过对数据流反复调用read()方法，将数据从DataNode传输到客户端  到达块的末端时，DFSInputStream会关闭与该DataNode的连接，然后寻找下一个块的最佳DataNode，这些操作对客户端来说是透明的，客户端的角度看来只是读一个持续不断的流  一旦客户端完成读取，就对FSDataInputStream调用close()方法关闭文件读取
  ##### block持续化结构
  DataNode节点上一个Block持久化到磁盘上的物理存储结构，如下图所示：  ![df10f0ac586f4baebc2587842aec5675-image.png](//img.wqkenqing.ren/file/2017/7/df10f0ac586f4baebc2587842aec5675-image.png)

 每个Block文件（如上图中blk_1084013198文件）都对应一个meta文件（如上图中blk_1084013198_10273532.meta文件），Block文件是一个一个Chunk的二进制数据（每个Chunk的大小是512字节），而meta文件是与每一个Chunk对应的Checksum数据，是序列化形式存储  ---  至上我们大致了解了HDFS。正如上文提到的Hadoop的特点，高可能，高容错性。若光从上文提到的特性可能还不足以说明，如NameNode环节就提到了NameNode的重要作用，但若NameNode出现了故障，对整个机集会是毁灭性的打击，于是Hadoop也引入其它的一些手段来保存高可用，高容错。接下来我们就来探讨下
### Hadoop HA的引入
 HA：High Available即高可用性集群，是保证业务连续性的有效解决方案，一般有两个或两个以上的节点，且分为活动节点及备用节点。  在HA具体实现方法不同的情况下，HA框架的流程是一致的, 不一致的就是如何存储和管理日志。在Active NN和Standby NN之间要有个共享的存储日志的地方，Active NN把EditLog写到这个共享的存储日志的地方，Standby NN去读取日志然后执行，这样Active和Standby NN内存中的HDFS元数据保持着同步。一旦发生主从切换Standby NN可以尽快接管Active NN的工作; 默认并未启用 hdfs ha。
 SPOF方案回顾：

1. Secondary NameNode：它不是HA，它只是阶段性的合并edits和fsimage，以缩短集群启动的时间。当NN失效的时候，Secondary NN并无法立刻提供服务，Secondary NN甚至无法保证数据完整性：如果NN数据丢失的话，在上一次合并后的文件系统的改动会丢失
2. Backup NameNode (HADOOP-4539)：它在内存中复制了NN的当前状态，算是Warm Standby，可也就仅限于此，并没有failover等。它同样是阶段性的做checkpoint，也无法保证数据完整性
3\. 手动把name.dir指向NFS（Network File System），这是安全的Cold Standby，可以保证元数据不丢失，但集群的恢复则完全靠手动
4\. Facebook AvatarNode：Facebook有强大的运维做后盾，所以Avatarnode只是Hot Standby，并没有自动切换，当主NN失效的时候，需要管理员确认，然后手动把对外提供服务的虚拟IP映射到Standby NN，这样做的好处是确保不会发生脑裂的场景。其某些设计思想和Hadoop 2.0里的HA非常相似，从时间上来看，Hadoop 2.0应该是借鉴了Facebook的做法 ![32ec8d45379b4e4d99505b03b1b33e61-image.png](//img.wqkenqing.ren/file/2017/7/32ec8d45379b4e4d99505b03b1b33e61-image.png)

5\. PrimaryNN 与StandbyNN之间通过NFS来共享FsEdits、FsImage文件，这样主备NN之间就拥有了一致的目录树和block信息；而block的 位置信息，可以根据DN向两个NN上报的信息过程中构建起来。这样再辅以虚IP，可以较好达到主备NN快速热切的目的。但是显然，这里的NFS又引入了新的SPOF
6\. 在主备NN共享元数据的过程中，也有方案通过主NN将FsEdits的内容通过与备NN建立的网络IO流，实时写入备NN，并且保证整个过程的原子性。这种方案，解决了NFS共享元数据引入的SPOF，但是主备NN之间的网络连接又会成为新的问题
#### hadoop2.X ha 原理:  hadoop2.x之后，Clouera提出了QJM/Qurom Journal Manager，这是一个基于Paxos算法实现的HDFS HA方案，它给出了一种较好的解决思路和方案,示意图如下：
![bc057fbb4b4047928bf06b7a43364335-image.png](//img.wqkenqing.ren/file/2017/7/bc057fbb4b4047928bf06b7a43364335-image.png)

  + 基本原理就是用2N+1台 JN 存储EditLog，每次写数据操作有大多数（>=N+1）返回成功时即认为该次写成功，数据不会丢失了。当然这个算法所能容忍的是最多有N台机器挂掉，如果多于N台挂掉，这个算法就失效了。这个原理是基于Paxos算法
  + 在HA架构里面SecondaryNameNode这个冷备角色已经不存在了，为了保持standby NN时时的与主Active NN的元数据保持一致，他们之间交互通过一系列守护的轻量级进程JournalNode  + 任何修改操作在 Active NN上执行时，JN进程同时也会记录修改log到至少半数以上的JN中，这时 Standby NN 监测到JN 里面的同步log发生变化了会读取 JN 里面的修改log，然后同步到自己的的目录镜像树里面，
  ![608621d2ab52466db89e8a95d165f6e7-image.png](//img.wqkenqing.ren/file/2017/7/608621d2ab52466db89e8a95d165f6e7-image.png)

 当发生故障时，Active的 NN 挂掉后，Standby NN 会在它成为Active NN 前，读取所有的JN里面的修改日志，这样就能高可靠的保证与挂掉的NN的目录镜像树一致，然后无缝的接替它的职责，维护来自客户端请求，从而达到一个高可用的目的  QJM方式来实现HA的主要优势：
 1\. 不需要配置额外的高共享存储，降低了复杂度和维护成本
 2\. 消除spof
 3\. 系统鲁棒性(Robust:健壮)的程度是可配置
 4\. JN不会因为其中一台的延迟而影响整体的延迟，而且也不会因为JN的数量增多而影响性能（因为NN向JN发送日志是并行的）  datanode的fencing: 确保只有一个NN能命令DN。HDFS-1972中详细描述了DN如何实现fencing
 1\. 每个NN改变状态的时候，向DN发送自己的状态和一个序列号
 2\. DN在运行过程中维护此序列号，当failover时，新的NN在返回DN心跳时会返回自己的active状态和一个更大的序列号。DN接收到这个返回则认为该NN为新的active  3\. 如果这时原来的active NN恢复，返回给DN的心跳信息包含active状态和原来的序列号，这时DN就会拒绝这个NN的命令  客户端fencing：确保只有一个NN能响应客户端请求，让访问standby nn的客户端直接失败。在RPC层封装了一层，通过FailoverProxyProvider以重试的方式连接NN。通过若干次连接一个NN失败后尝试连接新的NN，对客户端的影响是重试的时候增加一定的延迟。客户端可以设置重试此时和时间  Hadoop提供了ZKFailoverController角色，部署在每个NameNode的节点上，作为一个deamon进程, 简称zkfc，
 ![3cfc6fc17a8e47509465442f6eaf7c14-image.png](//img.wqkenqing.ren/file/2017/7/3cfc6fc17a8e47509465442f6eaf7c14-image.png)

   FailoverController主要包括三个组件:
   1\. HealthMonitor: 监控NameNode是否处于unavailable或unhealthy状态。当前通过RPC调用NN相应的方法完成
   2\. ActiveStandbyElector: 管理和监控自己在ZK中的状态
   3\. ZKFailoverController 它订阅HealthMonitor 和ActiveStandbyElector 的事件，并管理NameNode的状态  ZKFailoverController主要职责：      1\. 健康监测：周期性的向它监控的NN发送健康探测命令，从而来确定某个NameNode是否处于健康状态，如果机器宕机，心跳失败，那么zkfc就会标记它处于一个不健康的状态
   2\. 会话管理：如 果NN是健康的，zkfc就会在zookeeper中保持一个打开的会话，如果NameNode同时还是Active状态的，那么zkfc还会在 Zookeeper中占有一个类型为短暂类型的znode，当这个NN挂掉时，这个znode将会被删除，然后备用的NN，将会得到这把锁，升级为主 NN，同时标记状态为Active
   3\. 当宕机的NN新启动时，它会再次注册zookeper，发现已经有znode锁了，便会自动变为Standby状态，如此往复循环，保证高可靠，需要注意，目前仅仅支持最多配置2个NN
   4\. master选举：如上所述，通过在zookeeper中维持一个短暂类型的znode，来实现抢占式的锁机制，从而判断那个NameNode为Active状态  **hadoop2.x Federation**：  单Active NN的架构使得HDFS在集群扩展性和性能上都有潜在的问题，当集群大到一定程度后，NN进程使用的内存可能会达到上百G，NN成为了性能的瓶颈  常用的估算公式为1G对应1百万个块，按缺省块大小计算的话，大概是64T (这个估算比例是有比较大的富裕的，其实，即使是每个文件只有一个块，所有元数据信息也不会有1KB/block)  为了解决这个问题,Hadoop 2.x提供了HDFS Federation, 示意图如下：
   ![e5015b90accf4fe6a7729afe692ffa64-image.png](//img.wqkenqing.ren/file/2017/7/e5015b90accf4fe6a7729afe692ffa64-image.png)

  多个NN共用一个集群里的存储资源，每个NN都可以单独对外提供服务  每个NN都会定义一个存储池，有单独的id，每个DN都为所有存储池提供存储  DN会按照存储池id向其对应的NN汇报块信息，同时，DN会向所有NN汇报本地存储可用资源情况  如果需要在客户端方便的访问若干个NN上的资源，可以使用客户端挂载表，把不同的目录映射到不同的NN，但NN上必须存在相应的目录  设计优势：  改动最小，向前兼容；现有的NN无需任何配置改动；如果现有的客户端只连某台NN的话  分离命名空间管理和块存储管理  客户端挂载表：通过路径自动对应NN、使Federation的配置改动对应用透明  (与上面ha方案中介绍的最多2个NN冲突？)  至此hadoop中的hdfs高可用特性，高容错的实现又有了更深理解，但针对hdfs还一层设计实现**机架感知**
#### 机架感知
分布式的集群通常包含非常多的机器，由于受到机架槽位和交换机网口的限制，通常大型的分布式集群都会跨好几个机架，由多个机架上的机器共同组成一个分布 式集群。机架内的机器之间的网络速度通常都会高于跨机架机器之间的网络速度，并且机架之间机器的网络通信通常受到上层交换机间网络带宽的限制。  具体到hadoop集群，由于hadoop的HDFS对数据文件的分布式存放是按照分块block存储，每个block会有多个副本(默认为3)，并且为了数据的安全和高效，所以hadoop默认对3个副本的存放策略为：
在本地机器的hdfs目录下存储一个block  在另外一个rack的某个datanode上存储一个block
在该机器的同一个rack下的某台机器上存储最后一个block
这样的策略可以保证对该block所属文件的访问能够优先在本rack下找到，如果整个rack发生了异常，也可以在另外的rack上找到该block的副本。这样足够的高效，并且同时做到了数据的容错。
hadoop对机架的感知并非是自适应的，亦即，hadoop集群分辨某台slave机器是属于哪个rack并非是只能的感知的，而是需要 hadoop的管理者人为的告知hadoop哪台机器属于哪个rack，这样在hadoop的namenode启动初始化时，会将这些机器与rack的对 应信息保存在内存中，用来作为对接下来所有的HDFS的写块操作分配datanode列表时（比如3个block对应三台datanode）的选择 datanode策略，做到hadoop allocate block的策略：尽量将三个副本分布到不同的rack。
具体实现本文不在深究，在此附上网上的一些解决方式
[机架感知实现1](http://www.cnblogs.com/cloudma/articles/hadoop-topology.html)  [机架感知实现2](http://blog.csdn.net/magicdreaming/article/details/7629773)

---

至此对hdfs的理解与总结告一段落，后续有了新的理解再进行补充



