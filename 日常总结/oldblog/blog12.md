---

title: git小结
date: 2019-07-16
tags:

---

此处简介

<!--more-->


## git小结
### 常用指令小结
+ git init 初始化
+ git add 将工作区的变更提交至暂存区
+ git commit -m 将暂存区的内容提交至版本库
+ git log 查看记录
+ git reflog 操作记录
+ git --hard commit id 回到对应的id版本下
+ git status 查看状态
+ git log --pretty=oneline 简约查看log
+ git diff 查看文件与版本库中的差异
+ git checkout -- file 文件在工作区的修改全部撤销
+ git remote add origin git@github.com:michaelliao/learngit.git 添加远程库
+ git push -u origin master 推送分支
+ git clone git@github.com:michaelliao/gitskills.git 克隆
+ git checkout -b dev 创建并切换分支
+ git branch dev 创建分支
+ git checkout dev  切换分支
+ git merge dev 合并分支
+ git branch -d  删除分支
+ git stash 紧急切分支时，将工作区的变更内容暂存起来。
+ git stash list 查看stash列表
+ git stash apply 回复当前分支stash内容
+ git stash pop 删除stash内容
+ git branch -D 强行删除
+ git checkout -b dev origin/dev 拉下远程分支
+ git push origin branch-name 推送分支
+ git pull 从远程库拉取更新
+ git push origin branch-name 将本地库中的更新推送至远程库
+ git branch --set-upstream branch-name origin/branch-name 建立本地分支与远程库的联系
+ git tag <name>用于新建一个标签，默认为HEAD，也可以指定一个commit id；打标签
+ git tag -a <tagname> -m "blablabla..."可以指定标签信息；
+ git tag -s <tagname> -m "blablabla..."可以用PGP签名标签；
+ git push origin <tagname>
+ git push origin --tags
+ git tag -d <tagname>
+ git push origin :refs/tags/<tagname>