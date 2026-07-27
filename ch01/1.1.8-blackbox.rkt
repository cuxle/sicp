#lang sicp

;; ============================================================
;; SICP 1.1.8  过程作为黑箱抽象
;; ============================================================

;; ---------- 1) 对外只暴露 sqrt：调用者不必知道牛顿法 ----------

(define (square x) (* x x))

(define (average x y)
  (/ (+ x y) 2))

;; ---------- 2) 块结构：把「只为 sqrt 服务」的过程藏在里面 ----------
;;
;; 好处：
;; - 名字不污染外面（别人也能定义自己的 good-enough?）
;; - 内层能直接用外层的 x（词法作用域），少传很多参数

(define (sqrt x)
  (define (good-enough? guess)
    (< (abs (- (square guess) x)) 0.001))
  (define (improve guess)
    (average guess (/ x guess)))
  (define (sqrt-iter guess)
    (if (good-enough? guess)
        guess
        (sqrt-iter (improve guess))))
  (sqrt-iter 1.0))

;; 试：(sqrt 9)  (sqrt 2)


;; ---------- 3) 习题 1.6：new-if 为什么会出问题？ ----------
;; Alyssa 想用普通过程模拟 if：

(define (new-if predicate then-clause else-clause)
  (cond (predicate then-clause)
        (else else-clause)))

;; (new-if (= 2 3) 0 5)  ; => 5，看起来挺好

;; 但如果拿它改写 sqrt-iter：
;;
;; (define (sqrt-iter guess x)
;;   (new-if (good-enough? guess x)
;;           guess
;;           (sqrt-iter (improve guess x) x)))
;;
;; 会怎样？见课堂讲解（应用序 + 无限递归）。


;; ---------- 4) 习题 1.7：更好的 good-enough?（相对变化） ----------
;; 想法：看新旧猜测差了多少，而不是 |guess² - x|

(define (sqrt-alt x)
  (define (good-enough? guess prev)
    (< (abs (- guess prev))
       (* guess 0.001)))   ; 相对误差大约千分之一
  (define (improve guess)
    (average guess (/ x guess)))
  (define (sqrt-iter guess prev)
    (if (good-enough? guess prev)
        guess
        (sqrt-iter (improve guess) guess)))
  (sqrt-iter 1.0 0.0))

;; 对比试试很小/很大的数：
;; (sqrt 0.0001)
;; (sqrt-alt 0.0001)
;; (sqrt 1e13)      ; 视实现可能很慢或不准
;; (sqrt-alt 1e13)

A. improve 执行的时候发现一个未知变量x，它会去它的上一层找这个变量x的定义，如果找不到，就报错
B. 因为scheme调用函数是走的应用序，调用一个函数时先计算它的参数值，而new-if的参数值predicate then-clause else-clause
   全部计算一遍，进而会把后续的逻辑走入死循环。而scheme自带的if只会走一个分支，要么then，要么else
C. 0.0000001, 这个值平方根时0.0001，计算时good-enough 0.0001/0.0000002 = 0.00005， 这个返回true，但是这个值并不是理想的答案
