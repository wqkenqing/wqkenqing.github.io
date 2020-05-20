---
title: 阿里云DDNS[转载]
date: 2020-05-20
tags: DDNS




---

阿里云DDNS

<!--more-->

# 阿里云DDNS

```
因为电信带宽的动态ip的问题,域名解析时常失效,所以用到这里的DDNS
```

自己带宽的设置略过.

前提准备

1. 阿里云accesskyes配置
2. 能运行docker镜像的服务器
3. docker镜像

## 阿里云 accesskeys申请

登陆,点击右侧头像选择accesskeys即可.

获得ID与scret内容

## docker容器下载

https://hub.docker.com/r/chenhw2/aliyun-ddns-cli/



```
docker pull chenhw2/aliyun-ddns-cli
```



启动容器

```
docker run -d \
	--restart=always \
	--name ddns-aliyun \
    -e "AKID=131323131231212" \
    -e "AKSCT=dsfasfwerwefdfsfsdfsfs" \
    -e "DOMAIN=dev.foxwho.com" \
    -e "REDO=600" \
    chenhw2/aliyun-ddns-cli
```

容器启动成功后，你可以看看 域名解析是否已经自动更新解析IP



[原文地址](https://blog.csdn.net/fenglailea/article/details/102511502)

