---

title: JVM问题
date: 2019-07-16
tags: 

---
此处简介
<!--more-->

JVM问题
1、堆内存溢出
2、持久代内存溢出
3、系统频繁FGC

框架使用不当
4、错误使用框架提供API
5、日志框架使用不当
OS内存溢出
6、某系统物理内存溢出
数据库问题
7、慢SQL问题

案例1、堆内存溢出
JVM基础知识
1、Jvm内存分为三个大区，young区，old区和perm区；其中young区又包含三个区：Edgn区、S0、S1区
2、young区和old区属于heap区，占据堆内存；perm区称为持久代，不占据堆内存。
堆内存溢出
性能问题发现过程

查看服务器上报错日志，发现有如下报错信息［java.lang.OutOfMemoryError: Java heap space］；根据报错信息确定是jvm 堆内存空间不够导致，于是使用jvm命令（下图）查看，发现此时old区内存空间已经被占满了，同时使用jvisualvm监控工具也
发现old区空间被占满（右图），整个heap区空间已经无法再容纳新对象进入。
建议
考虑大量数据一次性写入内存场景

持久代内存溢出
现象

压测某系统接口，压测前1分钟左右tps 400多，之后
Tps直降为零，后台报错日志：java.lang.OutOfMemoryError:PermGen space，通过jvm监控工具查看持久代（perm区）空间被占满，Old区空闲；

问题定位过程
通过注释代码块定位问题，考虑到perm区溢出大部分跟类对象大量创建有关，故锁定问题在序列化框架使用可能有问题；
对于比较棘手难解决的perm溢出问题，作者构建了一个perm区溢出的场景，可以采用如下定位方案
1、添加jvm dump配置
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/data/dump.bin
2、安装eclipse mat分析工具
3、将dump文件导入eclipse，点击［Leak Suspects］，找到跟公司有关的代码进行分析
此处不过多讲解，大家可以去网上查阅资料学习
解决办法
跟开发沟通后选择去掉msgpack0.6版本框架，采用java原成序列化框架，修改后系统tps稳定在400多，gc情况正常
修改前后gc情况对比
修复前
类似问题如何避免

1、去掉项目无用jar包
2、避免大量使用类对象、大量使用反射
案例3、频繁FGC
（1）系统某接口频繁FGC
问题排查：
先查JVM内存信息找可疑对象
从内存对象实例信息中发现跟mysql连接有关，然后检测mysql配置信息
 <bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">

发现系统采用的是 spring框架的数据源，没有用连接池；

思考
使用连接池有什么好处？
连接复用、减少连接重复建立和销毁造成的大量资源消耗


然后换做hikaricp连接池做对比测试
 <bean id="dataSource" class="com.zaxxer.hikari.HikariDataSource"
压测半小时未出现fgc，问题得到解决
类似问题如何避免

1、研发规范统一DB连接池，避免研发误用
2、减少大对象、临时对象使用

案例4、错误使用框架提供API
现象
某系统本身业务逻辑处理能力很快（研发本机自测tps可以到达2w多），但是接入到framework框架后，TPS最高只能到达300笔/S左右，而且系统负载很低

问题排查
根据这种现象说明系统可能是堵在了某块方法上，根据这种情况一般采用线程dump的方式来查看系统具体哪些线程出现异常情况，通过线程dump 发现 ［TIMED_WAITING］状态的业务线程占比很高
根据线程dump信息，找到公司包名开头的信息，然后从下往上查看
线程dump信息，从信息中我们可以看到

framework.servlet.fServlet.doPost：框架api封装了servlet dopost方法做了某些操作
framework.servlet.fServlet.execute：框架api执行servelt
framework.process.fProcessor.process：框架api进行自身逻辑处理
framework.filter.impl.AuthFilter.before：框架使用过滤器进行用户权限过滤

 。。。。。。然后就是进行http请求操作
由此我们断定，就是在框架进行权限校验这块堵住了。之后跟开发沟通这块的
问题即可

分析思路
压测端 ：net  服务器  jvm
服务端：net  服务器 nginx tomcat jvm（应用程序）算法 db（mysql redis）