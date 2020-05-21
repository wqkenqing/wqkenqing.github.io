---

title: maven小结
date: 2019-07-16
tags:

---

此处简介

<!--more-->

## maven小结
### 什么是maven
就是一款帮助程序员构建项目的工具,我们只需要告诉Maven需要哪些Jar 包，它会帮助我们下载所有的Jar，极大提升开发效率。

### Maven规定的目录结构


### Maven基本命令
+ -v:查询Maven版本
`本命令用于检查maven是否安装成功。Maven安装完成之后，在命令行输入mvn -v，若出现maven信息，则说明安装成功`

+ compile：编译
+ test:测试项目
+ package:打包
+ clean:删除target文件夹
+ install:安装 将当前项目放到Maven的本地仓库中。供其他项目使用

### 什么是Maven仓库？
Maven仓库用来存放Maven管理的所有Jar包。分为：**本地仓库** 和 **本地仓库**。
+ 本地仓库
Maven本地的Jar包仓库。
+ 中央仓库
Maven官方提供的远程仓库。
>当项目编译时，Maven首先从本地仓库中寻找项目所需的Jar包，若本地仓库没有，再到Maven的中央仓库下载所需Jar包。

什么是“坐标”？
在Maven中，坐标是Jar包的唯一标识，Maven通过坐标在仓库中找到项目所需的Jar包。

如下代码中，groupId和artifactId构成了一个Jar包的坐标。

```
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>1.1.1</version>
</dependency>
```

**groupId**:所需Jar包的项目名
**artifactId**:所需Jar包的模块名
**version**:所需Jar包的版本号

传递依赖 与 排除依赖
+ 传递依赖：如果我们的项目引用了一个Jar包，而该Jar包又引用了其他Jar包，那么在默认情况下项目编译时，Maven会把直接引用和简洁引用的Jar包都下载到本地。
+ 排除依赖：如果我们只想下载直接引用的Jar包，那么需要在pom.xml中做如下配置：(将需要排除的Jar包的坐标写在中)

```
<exclusions>
    <exclusion>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-classic</artifactId>
    </exclusion>
</exclusions>
```

依赖冲突
若项目中多个Jar同时引用了相同的Jar时，会产生依赖冲突，但Maven采用了两种避免冲突的策略，因此在Maven中是不存在依赖冲突的。
短路优先
本项目——>A.jar——>B.jar——>X.jar
本项目——>C.jar——>X.jar
声明优先
若引用路径长度相同时，在pom.xml中谁先被声明，就使用谁。

聚合
什么是聚合？
将多个项目同时运行就称为聚合。
如何实现聚合？
只需在pom中作如下配置即可实现聚合：

```
<modules>
        <module>../模块1</module>
        <module>../模块2</module>
        <module>../模块3</module>
    </modules>
```
继承
什么是继承？
在聚合多个项目时，如果这些被聚合的项目中需要引入相同的Jar，那么可以将这些Jar写入父pom中，各个子项目继承该pom即可。
如何实现继承？
父pom配置：将需要继承的Jar包的坐标放入标签即可。

```
<dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.apache.shiro</groupId>
                <artifactId>shiro-spring</artifactId>
                <version>1.2.2</version>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

子pom配置：

```
<parent>
    <groupId>父pom所在项目的groupId</groupId>
    <artifactId>父pom所在项目的artifactId</artifactId>
    <version>父pom所在项目的版本号</version>
</parent>
```

---
Maven本地资源库

>通常情况下，可改变默认的 .m2 目录下的默认本地存储库文件夹到其他更有意义的名称，例如
![Alt text](./1489394095038.png)

当你建立一个 Maven 的项目，Maven 会检查你的 pom.xml 文件，以确定哪些依赖下载。首先，Maven 将从本地资源库获得 Maven 的本地资源库依赖资源，如果没有找到，然后把它会从默认的 Maven 中央存储库 – http://repo1.maven.org/maven2/ 查找下载