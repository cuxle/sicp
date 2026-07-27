# SICP 学习仓库

用 Scheme 学习《计算机程序的构造和解释》（SICP）的练习与笔记。  
远程仓库：<https://github.com/cuxle/sicp>

## 环境准备（任何一台电脑）

1. 安装 [Racket](https://racket-lang.org/)
2. 安装 SICP 语言包：
   ```text
   raco pkg install sicp
   ```
3. 用 DrRacket 或 Cursor 打开 `.rkt` 文件；文件开头需有：
   ```scheme
   #lang sicp
   ```
4. 在 DrRacket 中点 Run，或在终端用 `racket 文件名.rkt` 运行

## 在另一台电脑用 Cursor 续学

```text
git clone https://github.com/cuxle/sicp.git
cd sicp
```

然后用 Cursor 打开该文件夹，把本仓库路径发给 Agent，并说明当前学到哪一节（可看下面的进度表）。

## 目录结构

```text
sicp/
├── README.md                 ← 本说明
├── PROGRESS.md               ← 学习进度（换机时先看这个）
└── ch01/                     ← 第 1 章
    ├── 1.1-expressions.rkt
    ├── 1.1.5-substitution.rkt
    ├── 1.1.7-sqrt.rkt
    ├── 1.1.8-blackbox.rkt
    ├── 1.2.1-recursion-iteration.rkt
    ├── 1.2.2-tree-recursion.rkt
    ├── homework-01.rkt
    ├── homework-02.rkt
    └── notes-*.md            ← 小节笔记
```

## 学习约定

- **课堂示例**：`ch01/1.x.x-*.rkt`（带注释的演示代码）
- **作业**：`homework-*.rkt` 或聊天里作答
- **笔记**：`notes-*.md`（大白话要点，方便复习）
- 语言：Scheme（`#lang sicp`），目标是打编程底子，不是赶进度

## 教材

- 英文 HTML：[SICP](https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book.html)
- PDF：[SICP PDF](https://mitp-content-server.mit.edu/books/content/sectodeploy/books/11272/11272.pdf)
- 中文：《计算机程序的构造和解释（原书第 2 版）》

## 同步到 GitHub

在本机改完后：

```text
git add .
git commit -m "描述你改了什么"
git push
```

另一台电脑：

```text
git pull
```
