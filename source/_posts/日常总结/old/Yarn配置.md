---

title: Yarn配置细节
date: 2019-06-13
tags: 

---
此处简介

<!--more-->
# Yarn配置细节
##内存,核数设置
<!-- more -->

```

        <property>
      <name>yarn.nodemanager.resource.memory-mb</name>
      <value>4096</value>
  </property>

  <property>
      <name>yarn.scheduler.minimum-allocation-mb</name>
      <value>1024</value>
  </property>
  <property>
      <name>yarn.scheduler.maximum-allocation-mb</name>
      <value>3072</value>
  </property>
  <!--该配置用于配置任务请求时的资源. -->
  <property>
      <name>yarn.app.mapreduce.am.resource.mb</name>
      <value>2048</value>
  </property>

  <property>
      <name>yarn.app.mapreduce.am.command-opts</name>
      <value>-Xmx3276m</value>
  </property>
    <property>
      <name>yarn.nodemanager.resource.cpu-vcores</name>
      <value>2</value>
  </property>
  <property>
      <name>yarn.scheduler.maximum-allocation-vcores</name>
      <value>3</value>
  </property>


  ```
  