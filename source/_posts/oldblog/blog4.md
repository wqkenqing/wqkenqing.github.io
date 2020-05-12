---

title: List学习
date: 2019-07-16
tags:

---
此处简介
<!--more-->

### List学习
 `ArrayList不是线程安全的，只能用在单线程环境下，多线程环境下可以考虑用Collections.synchronizedList(List l)函数返回一个线程安全的ArrayList类，也可以使用concurrent并发包下的CopyOnWriteArrayList类`

ArrayList实现了Serializable接口，因此它支持序列化，能够通过序列化传输，实现了RandomAccess接口，支持快速随机访问，实际上就是通过下标序号进行快速访问，实现了Cloneable接口，能被克隆。

每个ArrayList实例都有一个容量，该容量是指用来存储列表元素的数组的大小。它总是至少等于列表的大小。随着向ArrayList中不断添加元素，其容量也自动增长。自动增长会带来数据向新数组的重新拷贝，因此，如果可预知数据量的多少，可在构造ArrayList时指定其容量。在添加大量元素前，应用程序也可以使用ensureCapacity操作来增加ArrayList实例的容量，这可以减少递增式再分配的数量。
每个ArrayList实例都有一个容量，该容量是指用来存储列表元素的数组的大小。它总是至少等于列表的大小。随着向ArrayList中不断添加元素，其容量也自动增长。自动增长会带来数据向新数组的重新拷贝，因此，如果可预知数据量的多少，可在构造ArrayList时指定其容量。在添加大量元素前，应用程序也可以使用ensureCapacity操作来增加ArrayList实例的容量，这可以减少递增式再分配的数量。
从上述代码中可以看出，数组进行扩容时，会将老数组中的元素重新拷贝一份到新的数组中，每次数组容量的增长大约是其原容量的1.5倍。这种操作的代价是很高的，因此在实际使用时，我们应该尽量避免数组容量的扩张。当我们可预知要保存的元素的多少时，要在构造ArrayList实例时，就指定其容量，以避免数组扩容的发生。或者根据实际需求，通过调用ensureCapacity方法来手动增加ArrayList实例的容量。

Object oldData[] = elementData;//为什么要用到oldData[]
乍一看来后面并没有用到关于oldData， 这句话显得多此一举！但是这是一个牵涉到内存管理的类， 所以要了解内部的问题。 而且为什么这一句还在if的内部，这跟elementData = Arrays.copyOf(elementData, newCapacity); 这句是有关系的，下面这句Arrays.copyOf的实现时新创建了newCapacity大小的内存，然后把老的elementData放入。好像也没有用到oldData，有什么问题呢。问题就在于旧的内存的引用是elementData， elementData指向了新的内存块，如果有一个局部变量oldData变量引用旧的内存块的话，在copy的过程中就会比较安全，因为这样证明这块老的内存依然有引用，分配内存的时候就不会被侵占掉，然后copy完成后这个局部变量的生命期也过去了，然后释放才是安全的。不然在copy的的时候万一新的内存或其他线程的分配内存侵占了这块老的内存，而copy还没有结束，这将是个严重的事情。 关于ArrayList和Vector区别如下：

    ArrayList在内存不够时默认是扩展50% + 1个，Vector是默认扩展1倍。
    Vector提供indexOf(obj, start)接口，ArrayList没有。
    Vector属于线程安全级别的，但是大多数情况下不使用Vector，因为线程安全需要更大的系统开销。



 ArrayList还给我们提供了将底层数组的容量调整为当前列表保存的实际元素的大小的功能。它可以通过trimToSize方法来实现。代码如下：

关于ArrayList的源码，给出几点比较重要的总结：

    1、注意其三个不同的构造方法。无参构造方法构造的ArrayList的容量默认为10，带有Collection参数的构造方法，将Collection转化为数组赋给ArrayList的实现数组elementData。

    2、注意扩充容量的方法ensureCapacity。ArrayList在每次增加元素（可能是1个，也可能是一组）时，都要调用该方法来确保足够的容量。当容量不足以容纳当前的元素个数时，就设置新的容量为旧的容量的1.5倍加1，如果设置后的新容量还不够，则直接新容量设置为传入的参数（也就是所需的容量），而后用Arrays.copyof()方法将元素拷贝到新的数组（详见下面的第3点）。从中可以看出，当容量不够时，每次增加元素，都要将原来的元素拷贝到一个新的数组中，非常之耗时，也因此建议在事先能确定元素数量的情况下，才使用ArrayList，否则建议使用LinkedList。

    3、ArrayList的实现中大量地调用了Arrays.copyof()和System.arraycopy()方法。我们有必要对这两个方法的实现做下深入的了解。

http://www.cnblogs.com/ITtangtang/p/3948555.html


. LinkedList是用链表结构存储数据的，很适合数据的动态插入和删除，随机访问和遍历速度比较慢。另外，接口中没有定义的方法get，remove，insertList，专门用于操作表头和表尾元素，可以当作堆栈、队列和双向队列使用。LinkedList没有同步方法。如果多个线程同时访问一个List，则必须自己实现访问同步。一种解决方法是在创建 List时构造一个同步的List：
             List list = Collections.synchronizedList(new LinkedList(...));

查看Java源代码，发现当数组的大小不够的时候，
需要重新建立数组，然后将元素拷贝到新的数组内，ArrayList和Vector的扩展数组的大小不同。

http://www.tuicool.com/articles/iQZBFb


http://www.cnblogs.com/azai/archive/2010/12/09/1901272.html

---
#### 简化
+ Collections.synchronizedList(List l)
+ Serializable 、RandomAccess 、Cloneable
+ ensureCapacity

  从上面的源码剖析可以看出这三种List实现的一些典型适用场景，如果经常对数组做随机插入操作，特别是插入的比较靠前，那么LinkedList的性能优势就非常明显，而如果都只是末尾插入，则ArrayList更占据优势，如果需要线程安全，则使用Vector或者创建线程安全的ArrayList。

在使用基于数组实现的ArrayList 和Vector 时我们要指定初始容量，因为我们在源码中也看到了，在添加时首先要进行容量的判断，如果容量不够则要创建新数组，还要将原来数组中的数据复制到新数组中，这个过程会减低效率并且会浪费资源。