---

title: sparkstreaming 窗口操作
date: 2019-07-16
tags: sparkstreaming

---

sparkstreaming时间窗口设置

<!--more-->

## 说明

通过sparkstreaming设置窗口函数,可达到如,每10秒计算前30秒内数据的效果

如上 主要有两个参数

1. 窗口大小
2. 滑动距离

val windowedWordCounts = pairs.reduceByKeyAndWindow(_ + _, Seconds(30), Seconds(10))

如上

## 常用api

| Transformation | Meaning |
| :--- | :----: |
| window(windowLength, slideInterval)	 | Return a new DStream which is computed based on windowed batches of the source DStream.|
| countByWindow(windowLength,slideInterval)	    | Return a sliding window count of elements in the stream.|
|reduceByWindow(func, windowLength,slideInterval)| |
|reduceByKeyAndWindow(func,windowLength, slideInterval, [numTasks])| |
|reduceByKeyAndWindow(func, invFunc,windowLength, slideInterval, [numTasks])	| |
|countByValueAndWindow(windowLength,slideInterval, [numTasks])	| |

