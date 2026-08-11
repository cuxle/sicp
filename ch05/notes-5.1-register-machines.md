# SICP 5.1：寄存器机器

学习日期：2026-08-11

## 这一节在讲什么

第 5 章开始把视角往下拉：

```text
高级语言里的函数、递归、环境，最后到底怎么被机器一步一步执行？
```

5.1 先介绍一种简化的机器模型：寄存器机器。

可以把它理解成一个低配版 CPU 模型。

一台寄存器机器主要有：

```text
寄存器：几个小格子，用来保存当前值
操作器：做基本运算，比如 +、*、=、remainder
控制器：指令流程，告诉机器下一步干什么
栈：保存现场，尤其是递归和子程序调用时
```

## 迭代阶乘

迭代版阶乘：

```scheme
(define (factorial n)
  (define (iter product counter)
    (if (> counter n)
        product
        (iter (* counter product)
              (+ counter 1))))
  (iter 1 1))
```

计算 `(factorial 4)` 时：

```text
product=1, counter=1
product=1, counter=2
product=2, counter=3
product=6, counter=4
product=24, counter=5
结束，返回 24
```

迭代过程不需要保存很多“回来以后还要做的事”，只需要不断更新几个当前变量。

对应寄存器：

```text
n：目标数字
product：当前乘积
counter：当前计数
```

控制器大概是：

```scheme
(controller
  (assign product (const 1))
  (assign counter (const 1))

test-counter
  (test (op >) (reg counter) (reg n))
  (branch (label factorial-done))

  (assign product
          (op *) (reg counter) (reg product))
  (assign counter
          (op +) (reg counter) (const 1))
  (goto (label test-counter))

factorial-done)
```

翻译成普通伪代码：

```text
product = 1
counter = 1

while counter <= n:
    product = counter * product
    counter = counter + 1

return product
```

## 常见指令

```scheme
(assign <register> <value>)
```

写寄存器。

例如：

```scheme
(assign counter
        (op +) (reg counter) (const 1))
```

意思是：

```text
counter = counter + 1
```

---

```scheme
(test <condition>)
```

测试条件，把结果放到一个类似 `flag` 的位置。

---

```scheme
(branch <label>)
```

如果刚才的测试为真，就跳转。

例如：

```scheme
(test (op >) (reg counter) (reg n))
(branch (label factorial-done))
```

意思是：

```text
如果 counter > n，就跳到 factorial-done。
```

---

```scheme
(goto <label-or-register>)
```

无条件跳转。

---

```scheme
(save <register>)
```

把寄存器当前值压入栈。

---

```scheme
(restore <register>)
```

从栈顶取出值，恢复到寄存器。

---

```scheme
(perform <operation>)
```

执行一个有副作用的操作，不关心返回值。

例如打印：

```scheme
(perform (op print) (reg val))
```

## 递归阶乘

递归版阶乘：

```scheme
(define (factorial n)
  (if (= n 1)
      1
      (* n (factorial (- n 1)))))
```

计算 `(factorial 4)` 时：

```text
factorial(4) 要等 factorial(3) 回来后乘 4
factorial(3) 要等 factorial(2) 回来后乘 3
factorial(2) 要等 factorial(1) 回来后乘 2
factorial(1) 是 base case
```

所以要保存：

```text
4, 3, 2
```

回来时反着取：

```text
2, 3, 4
```

这就是栈的特点：

```text
后进先出
```

英文叫 LIFO：

```text
Last In, First Out
```

递归阶乘机器会用到：

```text
n：当前参数
val：当前算出来的结果
continue：返回地址
```

其中 `continue` 的作用是：

```text
保存“当前子任务算完后，应该回到哪里继续”。
```

例如：

```scheme
(+ (f x) 1)
```

在计算 `(f x)` 之前，机器要记住：

```text
等 f(x) 算完后，回来继续做 “结果 + 1”。
```

这就是返回地址。

## gcd 机器

最大公约数：

```scheme
(define (gcd a b)
  (if (= b 0)
      a
      (gcd b (remainder a b))))
```

寄存器：

```text
a
b
t
```

其中 `t` 是临时寄存器，也就是中转站。

控制器大概是：

```scheme
test-b
  (test (op =) (reg b) (const 0))
  (branch (label gcd-done))
  (assign t (op rem) (reg a) (reg b))
  (assign a (reg b))
  (assign b (reg t))
  (goto (label test-b))

gcd-done
```

翻译成普通代码：

```text
while b != 0:
    t = a % b
    a = b
    b = t

return a
```

例子：

```text
gcd(206, 40)

a=206, b=40
t=206%40=6
a=40, b=6

t=40%6=4
a=6, b=4

t=6%4=2
a=4, b=2

t=4%2=0
a=2, b=0

结束，答案 a=2
```

当 `b = 0` 时，答案在 `a` 里，因为 Scheme 定义里就是：

```scheme
(if (= b 0)
    a
    ...)
```

## 数据通路和控制器

寄存器机器可以分成两部分：

```text
数据通路 datapath
控制器 controller
```

数据通路：

```text
寄存器、操作器、连线。
```

控制器：

```text
指令流程，告诉机器下一步做什么。
```

比喻：

```text
厨房设备 = 数据通路
菜谱步骤 = 控制器
```

## 递归和迭代在机器层面的区别

迭代过程：

```text
不断更新固定几个寄存器。
空间通常是 O(1)。
```

递归过程：

```text
每一层都要保存现场，比如 n 和 continue。
空间通常是 O(n)。
```

这解释了第 1 章说过的：

```text
递归过程空间 O(n)
迭代过程空间 O(1)
```

第 5 章把这个抽象结论落到了机器层面：

```text
递归过程要 save/restore 很多层现场。
迭代过程只是在几个寄存器里改值。
```

## 本节总结

```text
register：存值
operation：做基本运算
controller：安排执行步骤
assign：写寄存器
test：测试条件
branch：条件跳转
goto：无条件跳转
save：压栈保存
restore：出栈恢复
perform：执行副作用操作
continue：保存返回地址
```

5.1 的核心：

```text
高级语言里的递归、迭代、返回、调用，最终都可以落成寄存器、栈和跳转指令。
```

下一步：进入 5.2，学习如何用 Scheme 写一个寄存器机器模拟器。

