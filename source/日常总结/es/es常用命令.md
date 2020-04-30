---

title: es常用命令
date: 2020-02-25
tags:

---

查看集群是否健康


```
GET /_cluster/healt

```

查看节点列表


```
GET /_cat/nodes?v

加v将表头显示出来

```


## 索引

### 查询所有索引

```
GET /_cat/indices?v
```

### 查看某个索引的映射

```
GET /indeName/mapping
```

### 查看某个索引的设置

```
GET /indeName/mapping

```
### 添加一个索引

```
PUT /indexName
{
  "settings": {
     "number_of_shards": 3,
     "number_of_replicas": 1
   },
   "mappings": {
     "man": {
       "dynamic": "strict",
       "properties": {
         "name": {
           "type": "text"
         },
         "age": {
           "type": "integer"
         },
         "birthday": {
           "type": "date",
           "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
         },
         "address":{
           "dynamic": "true",
           "type": "object"
         }
       }
     }
   }
  }

```

dynamic关键词说明:
"dynamic":"strict"  表示如果遇到陌生field会报错
"dynamic": true  表示如果遇到陌生字段，就进行dynamic mapping
"dynamic": "false"   表示如果遇到陌生字段，就忽略

---

### 删除索引

删除单个索引

```

DELETE /indexName

```

删除多个

```

DELETE /indexName1,indexName2

```

### 添加字段映射


```
PUT /indexName/_mapping/Field
{
  "properties":{
    "Field":{
      "type":"text"
    }
  }
}
```

### 索引的别名


#### 创建索引别名

```
PUT /indeName/_alias/aliasName

```

获取索引别名

```
GET /indexName/_alias/*

```
查询别名对应的索引

```
GET /*/_alias/aliasName

```


## 文档

### 向索引中添加文档

1. 自定义ID

```
PUT /indexName/type/id
{
  "Field1":"message",
  "Field2":"message",
  "Field3":"message",
  "Field4":"message"
}

```  

2. 随机生成id

```
POST /indexName/type
{
  "Field1":"message",
  "Field2":"message",
  "Field3":"message",
  "Field4":"message"
}
```

后者则会自动生成id字符串

3. 修改文档

全文修改,即所有字段信息都要修改

```
PUT /indexName/type/id
{
  "Field1":"update message",
  "Field2":"update message",
  "Field3":"message",
  "Field4":"message"
}
```
部份修改

```
POST /indexName/type/id/_update
{
  "doc": {
    "FIELD": "message"
  }
}

```
脚本(再深入)

```

POST /indexName/type/_id/_update
{
  "script": {
    "lang": "painless",
    "source": "ctx._source.age += 10"
  }
}
```
在修改document的时候，如果该文档不存在，则使用upsert操作进行初始化

```
POST people/man/1/_update
{
  "script": "ctx._source.age += 10",
  "upsert": {
    "age": 20
  }
}
```

### 删除文档


删除单个文档

```
DELETE /indexName/type/id

```

删除type下所有的文档

```
POST /indexName/type/_delete_by_query?conflicts=proceed
{
  "query":{
    "match_all":{

    }
  }
}

```

### 查询文档

查询单个文档

```
GET /indexName/type/id

```

批量查询文档(待验证)

```
GET /_mget
{
  "docs": [
      {
        "_index": "index1",
        "_type": "type",
        "_id": 1
      },
      {
        "_index": "index2",
        "_type": "type",
        "_id": 2
      }
    ]
}

```
```

GET /indexName/type/_mget
{
"docs":[
{
  "FEILD":"value"
},
{
  "FEILD2":"value"
}
  ]
}


```


查询所有文档

简单查询

```
GET /indexName/_serach

```

法二

```
POST /people/_serach
{
  "query":{
    "match_all":{
    }
  }
}

```
查询某些字段内容
```

后面跟了 ?_source=field1,field2

POST /people/_serach?_source=field1,field2
{
  "query":{
    "match_all":{
    }
  }
}

```

查询多个索引下的多个type

```
GET /index1,index2/type1,type2/_search
```

查询所有索引下的部分type
```
GET /_all/type1,type2/_search

```


### 模糊查询
```

POST /indexName/_search
{
  "query":{
    "match":{
      "field":"message"
    }
  }
  ,
  "sort":[
  {
    "filed":{"order":"desc"}
  }
  ]
}


```
**注意**
message将会被拆分进行匹配,若message是中文,则会按切分后的每个字来匹配,若
message是英语,则会是按每个单词来匹配

![](http://img.wqkenqing.ren/51ccc5cad8b8fbbbb6ef55d3106bfe43.png)
![示列图](http://img.wqkenqing.ren/47a3ffe716f0026c004b155836a56641.png)


全文搜索(按准度)

```
GET indexName/_search
{
  "query":{
    "match":{
      "Field":{
        "query":"val1 val2",
        "operator":"and"
      }
    }
  }
}

```

即Fileld 中必须有val1,val2


按匹配度查询
```
GET /indexName/_search
{
"query":{
  "match":{
    "Field":{
      "query":"val1 val2 val3"
      "minimum_should_match":"val" eg:20%
    }

  }
}
}
```
即indexName,按Field中 val1 val2 val3 匹配度达到val即返回查询


### 高级查询

简单精准查询

```
GET /indexName/_search
{
  "query":{
    "match_phrase":{
      "Field":"val"
    }
  }
}
```
即查询要完全匹配val,但若val只有一个中文,则会Field只要含有val,就会被查出


slop结合
```
GET /people/_search
{
  "query": {
    "match_phrase": {
      "name": {
        "query": "张三",
        "slop": 3
      }
    }
  }
}
```
解读：slop是移动次数，上面案例表示“张”、“三”两个字可以经过最多挪动3次查询到！

rescore (重打分）

```
GET /forum/article/_search
{
  "query": {
    "match": {
      "content": "java spark"
    }
  },
  "rescore":{
    "window_size": 50,
    "query": {
      "rescore_query": {
        "match_phrase": {
          "content": {
            "query": "java spark",
            "slop": 50
          }
        }
      }
    }
  }
}

```


多字段匹配查询

```
GET /indexName/_search
{
  "query":{
    "multi_match":{
      "query":"val"
      "fields":["val1","val2"]
    }
  }
}

```

在多个字段中,也是模糊查询val
```
GET /people/_search
{
  "query": {
    "query_string": {
      "query": "(叶良辰 AND 火) OR (赵日天 AND 风)",
      "fields": ["name","desc"]
    }
  }
}
```

### 字段查询

精准查询

```
GET /indexName/_search
{
"query":{
  "term":{
    "field":"val"
  }
}
}


```

分页查询

```
GET /indexName/_search
{
  "query":{
    "match_all":{}
  },
  "from":num,
  "size":num
}
```

### 范围查询

数据值型

```

GET /people/_search
{
  "query": {
    "range": {
      "age": {
        "gt": 16,
        "lte": 30
      }
    }
  }
}

```
日期类型

```
GET /people/_search
{
  "query": {
    "range": {
      "birthday": {
        "gte": "2013-01-01",
        "lte": "now"
      }
    }
  }
}

```


```


GET book/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "range": {
          "date": {
            "gt": "now-1M"
          }
        }
      },
      "boost": 1.2
    }
  }
}

```

"gt": "now-1M"表示从今天开始，往前推一个月！


### 过滤查询

法一

```


POST /people/man/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "range": {
          "age": {
            "gte": 20,
            "lte": 30
          }
        }
      },
      "boost": 1.2
    }
  }
}


```

法二

```
POST /people/_search
{
  "query": {
    "bool": {
      "filter": {
        "term": {
          "age": 18
        }
      }
    }
  }
}
```


### 布尔查询
should查询
注意：should相当于 或 ，里面的match也是模糊匹配

```
POST /people/_search
{
  "query": {
    "bool": {
      "should": [
        {
          "match": {
            "name": "叶良辰"
          }
        },
        {
          "match": {
            "desc": "赵日天"
          }
        }
      ]
    }
  }
}

```

must查询
注意：两个条件都要满足，并且这里也会把must里面的“叶良辰”拆分成“叶”、“良”和“辰”进行查询；“赵日天”拆分成“赵”、“日”、和“天”！



```

POST /people/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "name": "叶良辰"
          }
        },
        {
          "match": {
            "desc": "赵日天"
          }
        }
      ]
    }
  }
}

```

must与filter相结合
这里也会把must里面的“叶良辰”拆分成“叶”、“良”和“辰”进行查询



```

POST /people/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "name": "叶良辰"
          }
        },
        {
          "match": {
            "desc": "赵日天"
          }
        }
      ],
      "filter": [
        {
          "term": {
            "age": 18
          }
        }
      ]
    }
  }
}
```

must_not
注意：下面语句是精准匹配

```
POST /people/_search
{
  "query": {
    "bool": {
      "must_not": {
        "term": {
          "name": "叶良辰"
        }
      }
    }
  }
}
```

### 聚合查询

根据字段类型查询


```

GET /people/man/_search
{
  "size": 0,
  "aggs": {
    "group_by_age": {
      "terms": {
        "field": "age"
      }
    }
  }
}
```


查询总体值

```
POST /people/_search
{
  "aggs": {
    "grads_age": {
      "stats": {
        "field": "age"
      }
    }
  }
}

```

查询最小值

```
POST /people/_search
{
  "aggs": {
    "grads_age": {
      "min": {
        "field": "age"
      }
    }
  }
}

```

根据国家分组，然后计算年龄平均值：



```

GET /people/man/_search
{
  "size": 0,
  "aggs": {
    "group_by_age": {
      "terms": {
        "field": "country"
      },
      "aggs": {
        "avg_age": {
          "avg": {
            "field": "age"
          }
        }
      }
    }
  }
}

```
解决：上面的reason里面说的很清楚，将fielddata设置为true就行了：

```

POST /people/_mapping/man
{
  "properties": {
    "country": {
      "type": "text",
      "fielddata": true
    }
  }
}
```


### 排序查询

```
排序查询通常没有排到我们想要的结果，因为字段分词后，有很多单词，再排序跟我们想要的结果又出入

解决办法：把需要排序的字段建立两次索引，一个排序，另一个不排序。

如下面的案例：把title.raw的fielddata设置为true，是排序的；而title的fielddata默认是false，可以用来搜索

index: true 是在title.raw建立索引可以被搜索到，

fielddata: true是让其可以排序

PUT /blog
{
  "mappings": {
    "article": {
      "properties": {
        "auther": {
          "type": "text"
        },
        "title": {
          "type": "text",
          "fields": {
            "raw":{
              "type": "text",
              "index": true,
              "fielddata": true
            }
          }
        },
        "content":{
          "type": "text",
          "analyzer": "english"
        },
        "publishdate": {
          "type": "date"
        }
      }
    }
  }
}

```


```
GET /blog/article/_search
{
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "title.raw": {
        "order": "desc"
      }
    }
  ]
}

```


### scroll查询


```
当搜索量比较大的时候，我们在短时间内不可能一次性搜索完然后展示出来

这个时候，可以使用scroll进行搜索

比如下面的案例，可以先搜索3条数据，然后结果中会有一个_scroll_id，下次搜索就可以直接用这个_scroll_id进行搜索了
```


```
GET test_index/test_type/_search?scroll=1m
{
  "query": {
    "match_all": {}
  },
  "sort": "_doc",
  "size": 3
}
```

step3 把scroll_id粘贴到下面的命令中再次搜索

```
GET _search/scroll
{
  "scroll": "1m",
  "scroll_id": "DnF1ZXJ5VGhlbkZldGNoBQAAAAAAAAA6FnZPSl9sbVR4UVVDU1NLb2wxVXJlbWcAAAAAAAAAPhZ2T0pfbG1UeFFVQ1NTS29sMVVyZW1nAAAAAAAAADsWdk9KX2xtVHhRVUNTU0tvbDFVcmVtZwAAAAAAAAA8FnZPSl9sbVR4UVVDU1NLb2wxVXJlbWcAAAAAAAAAPRZ2T0pfbG1UeFFVQ1NTS29sMVVyZW1n"
}

```
