#lang sicp

;; 第二课作业 —— 代换模型

(define (square x)
  (* x x))

(define (sum-of-squares x y)
  (+ (square x) (square y)))

(define (f a)
  (sum-of-squares (+ a 1) (* a 2)))

;; 练习 A：在纸上写出 (f 5) 的「应用序」代换过程（逐步展开）
;; 把每一步写在下面的注释里：
;;
;; 第1步：(sum-of-squares 6 10)
;; 第2步：(+ 36 100))
;; ...
;; 最终结果：136


;; 练习 B：下面两个定义，哪个是递归过程？哪个产生迭代计算过程？
;; （先凭感觉答；下一节会正式讲。这里只要求你猜 + 说明理由）
;;
;; (define (fact-rec n)
;;   (if (= n 1)
;;       1
;;       (* n (fact-rec (- n 1)))))
;;
;; (define (fact-iter n)
;;   (define (iter product counter)
;;     (if (> counter n)
;;         product
;;         (iter (* counter product)
;;               (+ counter 1))))
;;   (iter 1 1))
;;
;; 你的判断：fact-rec


;; 练习 C：用代换模型手算 (sum-of-squares 3 4)，写出步骤
;;
;; 步骤：(sum-of-squares 3 4)
      (+ (square 3) (square 4))  
      (+ 9 16)
      
;; 结果：25
