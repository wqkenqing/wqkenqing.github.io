---
title: Lambda&Stream.md
tags: 日常总结
abstract: Lambda积累
---

# Lambda&Stream积累

<!-- more -->
## Lambda
Lambda主要是一个类语法长糖,尽量为java引入函数编程等实现,细节后续再补充

## Stream
java8提拱的新特性之一就有stream.stream主要是针对集合的处理类.提供了一系列集合处理方式.
配合使用lambda写出简介优美的代码

### Stream的使用

通过如
``` java

List<Integer> list = new ArrayList<>();
list.stream();//即可以开启串行流;
list.parallelStream().filter(a -> {
            return a > 20;
        });//开启并行流
```
串行流即内部单线程顺序执行,并行则是启用多线程执行.
后者并不一定效率就比前者高.因为并行执行启用分配线程资源时同样要消耗时间和资源,在一定量级下,前者的执行效率一度要高过后者.        

我这里对三种对集合的处理形式的比较,可以简单参考一下
1. stream 串行流
2. parallelStream 并行流
3. 常规循环式

``` java

  List<Integer> list = new ArrayList<>();
        for (int i = 0; i < 100000; i++) {
            list.add(getRandomNum());
        }

        DateUtil.setBegin();
        list.stream().filter(a -> {
            return a > 20;
        });

        DateUtil.setStop();
        System.out.println("串行耗时"+DateUtil.calCostTime());

        DateUtil.setBegin();
        list.parallelStream().filter(a -> {
            return a > 20;
        });
        DateUtil.setStop();
        System.out.println("并行耗时"+DateUtil.calCostTime());
        int count = 0;


        DateUtil.setBegin();
        for (int l : list) {
            if (l > 20) {
                count++;
            }
        }
        DateUtil.setStop();
        System.out.println("循环耗时"+DateUtil.calCostTime());

```
经由相当量次的测试后,我觉得如果要对集合中的数据进行遍历操作,根据量级的不同,
建议低量级还是采用普通循环,量级特别大,可考虑用并行流.书写方便,又不是大批量数据处理操作
可以直接采用串行流

### Stream的操作分类
1. Intermediate
2. Terminal
3. Short-circuiting
