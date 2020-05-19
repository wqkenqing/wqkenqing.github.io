---
title: cvim f失灵问题修复
date: 2020-05-19
tags: cvim



---

此处是简介

<!--more-->

```
cvim突然失灵,调试发现是js版本问题.cvim插件发行版暂未解决该问题.但有对应的修复分支
```



问题修复

one : 克隆库: https://github.com/antonioyon/chromium-vim/tree/issue-716-fix-broken-hints

two: 切换分支到 `issue-716-fix-broken-hints`

three: 若无npm 则先安装npm

four: npm install , make

five: chrome 地址栏输入 chrome://extensions .选择加载已解压文件

six: 刷新页面,检查是否已经生效

