#lang sicp

;; ============================================================
;; SICP 1.2.2  树形递归
;; ============================================================

;; ---------- 1. 斐波那契：最直白（也最慢）的树递归 ----------
;;
;; Fib(n) = 0                     若 n = 0
;;        = 1                     若 n = 1
;;        = Fib(n-1) + Fib(n-2)   否则

(define (fib n)
  (cond ((= n 0) 0)
        ((= n 1) 1)
        (else (+ (fib (- n 1))
                 (fib (- n 2))))))

;; (fib 5) 会画出一棵「调用树」——大量重复计算。
;; 步数大约随 φ^n 增长（指数），空间大约 O(n)（树的最大深度）。


;; ---------- 2. 斐波那契：迭代版（线性迭代）----------
;; 状态：a = Fib(count), b = Fib(count-1)，一步步往前挪。

(define (fib-iter n)
  (define (iter a b count)
    (if (= count 0)
        b
        (iter (+ a b) a (- count 1))))
  (iter 1 0 n))

;; 对比：
;; (fib 30)      ; 树递归，可能明显变慢
;; (fib-iter 30) ; 瞬间


;; ---------- 3. 换零钱（书上经典树递归例子）----------
;; 一共有多少种方式，用下面这些硬币凑出 amount：
;; 美制：50, 25, 10, 5, 1

(define (count-change amount)
  (cc amount 5))

(define (cc amount kinds-of-coins)
  (cond ((= amount 0) 1)   ; 刚好凑完：一种方法（什么都不做）
        ((or (< amount 0) (= kinds-of-coins 0)) 0) ; 无解
        (else (+ (cc amount
                     (- kinds-of-coins 1))           ; 不用第一种硬币
                 (cc (- amount
                        (first-denomination kinds-of-coins))
                     kinds-of-coins)))))             ; 至少用一枚第一种

(define (first-denomination kinds-of-coins)
  (cond ((= kinds-of-coins 1) 1)
        ((= kinds-of-coins 2) 5)
        ((= kinds-of-coins 3) 10)
        ((= kinds-of-coins 4) 25)
        ((= kinds-of-coins 5) 50)))

;; (count-change 100)  ; => 292
;; (count-change 10)
