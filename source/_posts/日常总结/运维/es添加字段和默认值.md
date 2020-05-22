title: es添加字段
date: 2020-05-22 
tags: es feild script

---

<!--more-->

```
给es添加字段
```

这里主要通过script脚本.
并且在elasticsearch1.3后这个默认配置是被关掉的.

即在elasticsearch.yml中添加
script.inline=true
script.indexed=true
一开始我在true后面加了空格,配置不被识别,所以这里要注意


开启了script.line后通过update_by_query进行操作,这里注意以下写法已经过时
```json

POST /index/_update_by_query?conflicts=proceed
{
  "script":{
    "lang":"painless",
    "inline": "ctx._source.name='trhee'"
  }
}

```

即inline这种写法已经过时. 现在主要用的是source

```json
POST /index/_update_by_query?conflicts=proceed
{
  "script":{
    "lang":"painless",
    "source": "ctx._source.name='trhee'"
  }
}
```

还能加入条件判断

```json
POST /index/_update_by_query?conflicts=proceed
{
  "script":{
    "lang":"painless",
    "source": "if(ctx._source.name==''){ctx._source.name='trhee'}"
  }
}
```

至此即可以实现对_source.name字段的数据进行默认赋值
