---
title:  mapreduce组件总结
date: 2020-05-11
tags: bigdata
---


# mapreduce组件总结

<!-- more -->
相关组件大致有
1. Inputformat
2. Inputsplit
3. ReadRecorder
4. mapper
5. Combiner
6. Partioner
7. Reduce
8. GroupComparator
9. Reduce

# shuffle

![2019-03-19-15-39-59](http://img.wqkenqing.ren/2019-03-19-15-39-59.png)
![2019-03-19-16-46-06](http://img.wqkenqing.ren/2019-03-19-16-46-06.png)

```
shuffle 被称为mapreduce的核心,一个真正让奇迹发生的地方.但它到底是什么呢?简练的讲,它就是 map out 到 reduce in 这段过程中对数据的处理过程.
```
shuffle过程中主要发生的操作有,Partion,Sort,spill,merge,copy,sort,merge.(还有可能有combine操作)

具体流程是
map out后,Collector 对out后的数据进行处理. 数据将会写入到内存缓冲区,该内存缓冲区的数据达到80%后,会开启一个溢写线程,在磁盘本地创建一个文件.如果reduce设置了多个分区,写入buffer区的数据,会被打上一个分区标记.通过sortAndSpill()方法进行指对数据按分区号,key排序.最后溢出的文件是分区的,按key有序的文件.若buffer区中的20%一直未被填满,buffer写入进程不会断.但若达到100%,Buffer写入进程则会阻塞.并在buffer区中的数据全部spill完后才会再开启. (buffer区的内存默认是100M),spill过程中,若设置过combiner.则会对数据先进行combiner逻辑处理,再将处理后的数据写出

spill完成后则会对本地的spill后的文件进行Merge.即把多个spill后的文件进行合并,并排序.最后会行成一个有序文件

当1个Map Task 完成后,reduce 就会开启copy进程(默认是5个线程).这个过程中会通过http请求去各taskTracker(nodemanager),拉取相应的spill&merge后的文件.
当copy完成后,则又会对数据进行merge.这个过程中同样有个类似map shuffle 中的buffer 溢写的阶段. 这个过程同样会触发combiner组件.这里的merge数据源有三种
1. memory to memory
2. memory to disk
3. disk   to disk 
默认1是不开启的.

copy phase 完成后,是reduceTask 中的 sort phase
即对merge 中的文件继续进行sort and group .

当sort phase 完成.则开启reduce phase .到此shuffle正式完成.

##二次排序
```

```
mapreduce 常见的辅助排序
1. partitioner
2. key的比较Comparator
3. 分组函数Grouping Comparator

## join 
map join ,semi join ,reduce join
## 
