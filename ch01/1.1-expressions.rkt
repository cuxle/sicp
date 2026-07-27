#lang sicp

;; ============================================
;; SICP 1.1  程序设计的基本元素
;; ============================================
;;
;; 在 DrRacket 中打开本文件。先安装：
;;   raco pkg install sicp
;; 然后点 Run，在下方交互区实验。
;; ============================================

;; --- 1. 基本表达式 ---
486

;; --- 2. 组合式：(运算符 操作数...) ---
(+ 137 349)
(- 1000 334)
(* 5 99)
(/ 10 5)

;; 嵌套：由内向外求值
(+ (* 3 5) (- 10 6))

;; --- 3. 命名 ---
(define size 2)
(* 5 size)

(define pi 3.14159)
(define radius 10)
(* pi (* radius radius))

;; --- 4. 过程（函数）---
(define (square x)
  (* x x))

(square 21)
(square (+ 2 5))

(define (sum-of-squares x y)
  (+ (square x) (square y)))

(sum-of-squares 3 4)

;; --- 5. 条件 ---
(define (abs x)
  (if (< x 0)
      (- x)
      x))

(abs -5)
(abs 12)
