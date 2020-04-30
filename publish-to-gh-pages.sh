#!/bin/bash
set -ev

# get clone master
git clone https://github.com/wqkenqing/wqkenqing.github.io.git .deploy_git
cd .deploy_git
git checkout master

cd ../
mv .deploy_git/.git/ ./public/

cd ./public

git config user.name "wqkenqing"
git config user.email "wqkeqningto@126.com"

cd ./public
# add commit timestamp
git add .
git commit -m "Travis CI Auto Builder at `date +"%Y-%m-%d %H:%M"`"

# Github Pages
git push --force --quiet "https://${REPO_TOKEN}@${GH_REF}" master:master


# Coding Pages
#git push --force --quiet "https://Leafney:${CodingToken}@${CD_REF}" master:master
