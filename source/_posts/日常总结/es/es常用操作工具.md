title: es常用操作工具

date: 2020-05-21

tags: elasticsearch kibana head vscode



---

es操作工具

<!--more-->

```
es常用的操作工具介绍
```



## elasticsearch-head

elascticsearch-head是一款操作工具,这里不过多介绍,我日常使用较少,但这个工具有一个好处就是有对应的chrome插件,在非常用电脑上有相关需求时,可以通过登陆chrome账号就使用head插件应急



## kibana

kibana是elastic stack集成产中.一开始主要就是作为elasticsearch可视化需求的一个承载体,后续才单独拆开,承担了更多复杂的view功能

结合对应版本的elasticsearch部署对应的kibana版本后,即可开箱使用,这里不过多介绍具体使用细节.主要是说明下功能内容

#### Dev Tools模块

用来写DSL语句,管理elasticsearch

#### Management 模块

kibana集成的理管模块,能对index进行一些管理操作.

![image-20200521134325351](http://rgr3ifyzo.sabkt.gdipper.com/image-20200521134325351.png)

## vscode

前两者都是主流的elasticsearch的管理和操作工具,但实集使用过程中,特别是大量的DSL语句操作的时候,前两者虽然功能较全, 但操作是不方便的.因为如果把DSL比作是sql的话,在网页中书写DSL,量一大,一是语句的备份不好管理,相关内容太多,不能分类存放,容易造成误操作.

而vscode的插件库里有与elasticsearch结合的插件,这里elasticsearch for vscode 

![image-20200521135215143](http://rgr3ifyzo.sabkt.gdipper.com/image-20200521135215143.png)



安装好后,即可开箱使用.只需要将文件创建为*.es的后缀.然后设置需要启用的elasticsearch的hostp:port

设置好后,即可在vscode 下的es文件中开始写对应的dsl语句.

极为方便,而且能在某文件内容过多后,轻易的再另起一个es文件.方便维护管理

![image-20200521135527747](http://rgr3ifyzo.sabkt.gdipper.com/image-20200521135527747.png)

