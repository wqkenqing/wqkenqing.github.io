---

title: sed & awk小结
date: 2019-07-16
tags:

---
此处简介

<!--more-->

# sed & awk小结

`一直想认真掌握sed与awk已经很久了，但一直未找个以特别详细的资料和时间来做这件事，正好这两天受到启发，转而翻墙搜索国外资源，有了很大的收获，趁次机会攻克下来`

## 前言

sed与awk总得来说是两样东西，本身无直接关联，做在日常使用时两者经常使用到，并且常常混合使用，所以此次小结放在一起，分总式结构进行小结

## sed

sed相较awk更偏于工具一点，全称应该是strem editor (即流式编辑器)。面向的是一行一行内容

### 使用形式

sed [-nefr] [动作]
选项与参数：
-n ：使用安静(silent)模式。在一般 sed 的用法中，所有来自 STDIN 的数据一般都会被列出到终端上。但如果加上 -n 参数后，则只有经过sed 特殊处理的那一行(或者动作)才会被列出来。
-e ：直接在命令列模式上进行 sed 的动作编辑；
-f ：直接将 sed 的动作写在一个文件内， -f filename 则可以运行 filename 内的 sed 动作；
-r ：sed 的动作支持的是延伸型正规表示法的语法。(默认是基础正规表示法语法)
-i ：直接修改读取的文件内容，而不是输出到终端。

动作说明： [n1[,n2]]function
n1, n2 ：不见得会存在，一般代表『选择进行动作的行数』，举例来说，如果我的动作是需要在 10 到 20 行之间进行的，则『 10,20[动作行为] 』

**function：**
a ：新增， a 的后面可以接字串，而这些字串会在新的一行出现(目前的下一行)～
c ：取代， c 的后面可以接字串，这些字串可以取代 n1,n2 之间的行！
d ：删除，因为是删除啊，所以 d 后面通常不接任何咚咚；
i ：插入， i 的后面可以接字串，而这些字串会在新的一行出现(目前的上一行)；
p ：列印，亦即将某个选择的数据印出。通常 p 会与参数 sed -n 一起运行～
s ：取代，可以直接进行取代的工作哩！通常这个 s 的动作可以搭配正规表示法！例如 1,20s/old/new/g 就是啦！

* * *

## awk

`尝试看awk已有些时日，整体效率不太好，但大体也有思路，现对awk进行一些简单总结，后面则进行实例操作`
awk的细节小点比较多，一次或无法完全总结全，但总体感觉下来发现熟悉大体模式，具体细节可以再通过即时检索解决

### awk命令的基本格式是:

> `awk '/search_pattern/ { action_to_t[](http://)ake_on_matches; another_action; }' file_to_parse`

其中searach 与action都可省略其中之一，若action省略，那么action默认为print操作
如何search省略，那么默认action针对的是每一行如
![b193032f8daa40faaffc84b673b46885-image.png](//img.wqkenqing.ren/file/2017/7/b193032f8daa40faaffc84b673b46885-image.png)
![06ddb1ad717c434e939c3d0461b2d937-image.png](//img.wqkenqing.ren/file/2017/7/06ddb1ad717c434e939c3d0461b2d937-image.png)

---
附几个操作实例如
![1b777aa53595428e9d56e0b66052f48c-image.png](//img.wqkenqing.ren/file/2017/7/1b777aa53595428e9d56e0b66052f48c-image.png)

![a1e8b526c4a042b48e0e161e6eae35fe-image.png](//img.wqkenqing.ren/file/2017/7/a1e8b526c4a042b48e0e161e6eae35fe-image.png)

![de2e1925530d410ba52f25ff0781f0b5-image.png](//img.wqkenqing.ren/file/2017/7/de2e1925530d410ba52f25ff0781f0b5-image.png)

**这里是以空白区分了列，通过$后加不同的数字，表示不同的列，$0表示这一行，$1表示第一列**，类推。


### awk的内置变量
 + **FILENAME**:当前输入文件的名称
 + **FNR**:当前输入文件数
 + **FS**:当前环境中的分隔符，默认是空白
 + **NF**:输入文件的每行对应的列数
 + **NR**:当前是第几个记录
 + **OFS**:列输出时的分隔符，默认是空白
 + **ORS**:记录输出时的分隔符，默认是新起一行
 + **RS**输入记录中的分隔符，默认是newline character

 正如以上内置变量的存在，所以，awk在正式使用进可能面临更多复杂情况，而之前那种简单模式可以无法应对。于是，常用的awk的使用形态扩充为

> awk 'BEGIN { action; }
/search/ { action; }
END { action; }' input_file

这里引入了BEGIN与END两个部份，用于做一些初始化或善后处理。
![8a8d39f410944dcc9584c7052e2e46a4-image.png](//img.wqkenqing.ren/file/2017/7/8a8d39f410944dcc9584c7052e2e46a4-image.png)

![3fb8e3723fbd439990cd8e000c673c9b-image.png](//img.wqkenqing.ren/file/2017/7/3fb8e3723fbd439990cd8e000c673c9b-image.png)


### awk的一些常见的匹配操作
+ awk '/sa/' file
+ awk '$2 ~ /^sa/' file
$number表示只匹配该列
~ 表示“是”
!~表示“不是”

---

至此一这就总结了一些较为基础的awk使用，就一般工作而言，已经能应对很多场景了。
后续我会再进行更为详细的总结
待续~~~