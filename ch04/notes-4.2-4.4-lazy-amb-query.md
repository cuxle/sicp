# SICP 第 4 章后半部分：惰性求值、非确定性计算、逻辑程序设计

学习日期：2026-08-11

## 4.2 惰性求值

普通求值的习惯是：

```scheme
(f arg1 arg2)
```

先把 `arg1`、`arg2` 都算出来，再调用 `f`。

惰性求值的习惯是：

```text
参数先不急着算，用到的时候再算。
```

例如：

```scheme
(define (try a b)
  (if (= a 0)
      1
      b))

(try 0 (/ 1 0))
```

普通求值会先计算 `(/ 1 0)`，所以报错。

惰性求值不会马上计算第二个参数。进入 `try` 之后，`if` 发现 `a = 0`，直接返回 `1`，根本不会用到 `b`，所以不会触发除以 0。

核心概念：

```text
delay-it：把表达式包起来
force-it：真正需要值时再打开
thunk：被包起来的“表达式 + 环境”
actual-value：我要真正的值，不要 thunk
memoization：第一次算完后缓存结果，后面直接复用
```

比如：

```scheme
(define (f x)
  (+ x x))

(f (+ 1 2))
```

在带记忆的惰性求值里，`(+ 1 2)` 只真正计算一次，得到 `3` 后缓存起来。最终：

```scheme
(+ 3 3) => 6
```

惰性求值的好处：

- 可以避免不必要的计算。
- 可以让普通函数表现得像控制结构。
- 可以表示无限序列：需要多少，就算多少；用不到的先不算。

惰性求值的坑：

- 遇到 `set!`、`display`、输入输出这类副作用时，执行时机会变得不直观。

一句话总结：

```text
惰性求值 = 参数先包起来，真正需要时再计算。
```

## 4.3 非确定性计算

非确定性计算的核心是：

```text
amb 给选择
require 给约束
失败就回溯
```

例如：

```scheme
(define x (amb 1 2 3))
(define y (amb 1 2 3))
(require (= (+ x y) 5))
(list x y)
```

意思是：

```text
x 从 1、2、3 里选
y 从 1、2、3 里选
要求 x + y = 5
输出满足条件的一组结果
```

搜索过程大概是：

```text
x=1, y=1 => 失败
x=1, y=2 => 失败
x=1, y=3 => 失败
x=2, y=1 => 失败
x=2, y=2 => 失败
x=2, y=3 => 成功，结果是 (2 3)
```

如果 `try-again`，继续找下一个：

```scheme
(3 2)
```

`require` 通常可以理解成：

```scheme
(define (require p)
  (if (not p)
      (amb)))
```

如果条件不满足，就调用空的 `amb`，表示当前路线失败。

失败之后系统会：

```text
回到最近的 amb 选择点
换下一个候选值
继续往下执行
```

这就是回溯。

`try-again` 之所以能找下一个答案，是因为上一次成功时，解释器保存了“下一种选择怎么继续”。

这背后对应：

```text
成功延续：当前结果成功后，接下来怎么算
失败延续：当前路线失败后，去哪里试下一条路
```

一句话总结：

```text
非确定性计算 = 程序员写候选和条件，解释器负责搜索和回溯。
```

## 4.4 逻辑程序设计

逻辑程序设计和普通 Scheme 最大的区别：

```text
Scheme：定义函数，调用函数，计算结果。
逻辑程序设计：给出事实和规则，提出查询，让系统推理答案。
```

例如事实：

```scheme
(job Alice engineer)
(job Bob engineer)
(job Carol designer)
```

查询：

```scheme
(job ?who engineer)
```

意思是：

```text
谁的 job 是 engineer？
```

结果：

```text
?who = Alice
?who = Bob
```

注意，在查询语言里：

```scheme
(job Alice engineer)
```

不是调用 `job` 函数，而是一条事实。

可以这样记：

```text
Scheme：表达式要求值
Query：模式要匹配
```

规则可以表达“如何推出新关系”。

例如：

```scheme
(rule (grandparent ?x ?z)
      (and (parent ?x ?y)
           (parent ?y ?z)))
```

意思是：

```text
如果 x 是 y 的父母，且 y 是 z 的父母，
那么 x 是 z 的祖父/祖母。
```

递归规则也可以表达多层关系。

例如：

```scheme
(rule (outranked-by ?staff-person ?boss)
      (or (supervisor ?staff-person ?boss)
          (and (supervisor ?staff-person ?middle-manager)
               (outranked-by ?middle-manager ?boss))))
```

意思是：

```text
一个人被另一个人管理，可能是直接主管，也可能是主管的主管。
```

查询语言中的 `and`、`or`、`not` 是查询组合器：

```text
and：多个条件都要满足
or：满足其中一个即可
not：在当前绑定下查不到这个条件
```

合一（unification）的关键直觉：

```text
同一个变量出现多次，表示这些位置必须一致。
```

例如：

```scheme
(?x likes ?x)
```

可以匹配：

```scheme
(Alice likes Alice)
(Bob likes Bob)
```

不能匹配：

```scheme
(Alice likes Bob)
```

一句话总结：

```text
逻辑程序设计 = 用事实和规则描述世界，然后向系统提问。
```

## 第 4 章总总结

```text
4.1：解释器怎么执行语言
4.2：改解释器，让参数延迟求值
4.3：改解释器，让程序能自动搜索和回溯
4.4：做查询语言，让系统基于事实和规则推理
```

第 4 章真正想表达的是：

```text
语言不是固定的工具。
语言的规则可以被设计、修改和扩展。
不同语言规则，会改变我们表达问题的方式。
```

下一步建议进入第 5 章：寄存器机器里的计算。

