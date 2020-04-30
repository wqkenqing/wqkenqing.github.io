---

title: String StringBuffer StringBuilder
date: 2019-07-16
tags:

---
此处简介

<!--more-->
### String StringBuffer StringBuilder
* String s =new String("ok")
*
（1）String ok1=new String(“ok”);
（2）String ok2=“ok”;
我相信很多人都知道这两种方式定义字符串，但他们之间的差别又有多少人清楚呢。画出这两个字符串的内存示意图：

```
String ok1=new String(“ok”)。首先会在堆内存申请一块内存存储字符串ok,ok1指向其内存块对象。同时还会检查字符串常量池中是否含有ok字符串,若没有则添加ok到字符串常量池中。所以 new String()可能会创建两个对象.
```

     String ok2=“ok”。 先检查字符串常量池中是否含有ok字符串,如果有则直接指向, 没有则在字符串常量池添加ok字符串并指向它.所以这种方法最多创建一个对象，有可能不创建对象所以String ok1=new String(“ok”);//创建了两个对象String ok2=“ok”;//没有创建对象

`比较类中的数值是否相等使用equals(),比较两个包装类的引用是否指向同一个对象时用==`


```
String ok="ok";
String ok1=new String("ok");
System.out.println(ok==ok1);//fasle
```
明显不是同一个对象，一个指向字符串常量池，一个指向new出来的堆内存块，new的字符串在编译期是无法确定的。所以输出false

```
String ok="apple1";
String ok1="apple"+1;
System.out.println(ok==ok1);//true
```

    String ok="apple1";
    int temp=1;
    String ok1="apple"+temp;
    System.out.println(ok==ok1)

#### Intern()方法
但我们可以通过intern()方法扩展常量池。
         intern()是扩充常量池的一个方法,当一个String实例str调用intern()方法时,java会检查常量池中是否有相同的字符串,如果有则返回其引用,如果没有则在常量池中增加一个str字符串并返回它的引用。

`String类具有immutable(不能改变)性质,当String变量需要经常变换时,会产生很多变量值,应考虑使用StringBuffer提高效率。在开发时，注意String的创建方法`

`使用System.out.println(obj.hashcode())输出的时对象的哈希码，
而非内存地址。在Java中是不可能得到对象真正的内存地址的，因为Java中堆是由JVM管理的不能直接操作。
只能说此时打印出的Hash码表示了该对象在JAVA虚拟机中的内存位置，
Java虚拟机会根据该hash码最终在真正的的堆空间中给该对象分配一个地址.
但是该地址 是不能通过java提供的api获取的
`
+ String变量连接新字符串会改变hashCode值，变量是在JVM中“连接——断开”；
+ StringBuffer变量连接新字符串不会改变hashCode值，因为变量的堆地址不变。
+ StringBuilder变量连接新字符串不会改变hashCode值，因为变量的堆地址不变。

#### 比较String、StringBuffer、StringBuilder性能

+ String类由于Java中的共享设计，在修改变量值时使其反复改变栈中的对于堆的引用地址，所以性能低。
+ StringBuilder是线性不安全的，适合于单线程操作，其性能比StringBuffer略高。
+ StringBuffer和StringBuilder类设计时改变其值，其堆内存的地址不变，避免了反复修改栈引用的地址，其性能高。

当String使用引号创建字符串时，会先去字符串池中找，找到了就返回，找不到就在字符串池中增加一个然后返回，这样由于共享提高了性能。

 而new String()无论内容是否已经存在，都会开辟新的堆空间，栈中的堆内存也会改变。

性能简介
StringBuilder>StringBuffer>String


http://www.jb51.net/article/78057.htm


StringBuffer中的setLength与delete的效率比较
+ 前者主要是通过将底层的storage数组长度设置为0
+ 后者则是另复制一份至另一空间，长度设为0
所以后则的效率会相对慢一点