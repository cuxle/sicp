# 2.2 Sequences and Hierarchical Data

## Main Idea

Section 2.2 continues data abstraction with sequences and hierarchical data.

The big idea:

> Many complex data-processing tasks can be expressed as sequence pipelines.

Common pipeline shape:

```text
enumerate -> filter -> map -> accumulate
```

This style separates a problem into clear steps:

- generate candidate data
- keep what matches a condition
- transform each item
- combine the result

---

## Trees

A list is a linear sequence:

```scheme
(list 1 2 3 4)
```

A tree is hierarchical data, often represented by nested lists:

```scheme
(list 1 (list 2 3) 4)
```

Its leaves are:

```text
1, 2, 3, 4
```

The sublist `(list 2 3)` is not a leaf. Its elements `2` and `3` are leaves.

---

## Counting Leaves

To count leaves in a tree:

```scheme
(define (count-leaves x)
  (cond [(null? x) 0]
        [(not (pair? x)) 1]
        [else (+ (count-leaves (car x))
                 (count-leaves (cdr x)))]))
```

Plain-language rules:

- empty tree: `0` leaves
- ordinary element: `1` leaf
- pair/list: count leaves in `car` and `cdr`, then add

Example:

```scheme
(count-leaves (list 1 (list 2 3) 4)) ; 4
```

---

## Scaling a Tree

`scale-tree` keeps the same tree shape but multiplies each leaf.

Example:

```scheme
(scale-tree (list 1 (list 2 3) 4) 2)
```

Result:

```scheme
(list 2 (list 4 6) 8)
```

Important:

> Change the leaves, keep the shape.

Recursive version:

```scheme
(define (scale-tree tree factor)
  (cond [(null? tree) nil]
        [(not (pair? tree)) (* tree factor)]
        [else (cons (scale-tree (car tree) factor)
                    (scale-tree (cdr tree) factor))]))
```

`map` version:

```scheme
(define (scale-tree tree factor)
  (map (lambda (sub-tree)
         (if (pair? sub-tree)
             (scale-tree sub-tree factor)
             (* sub-tree factor)))
       tree))
```

In the `map` version:

- `map` walks over the top-level elements of `tree`
- `lambda` decides how each element should change

---

## Filter

`filter` keeps only elements that satisfy a predicate.

Example:

```scheme
(filter even? (list 1 2 3 4 5 6))
```

Result:

```scheme
(list 2 4 6)
```

Implementation:

```scheme
(define (filter predicate sequence)
  (cond [(null? sequence) nil]
        [(predicate (car sequence))
         (cons (car sequence)
               (filter predicate (cdr sequence)))]
        [else
         (filter predicate (cdr sequence))]))
```

Plain-language rules:

- if the list is empty, return empty
- if the first item satisfies the predicate, keep it
- otherwise drop it
- continue with the rest of the list

---

## Accumulate

`accumulate` combines a sequence into one result.

```scheme
(define (accumulate op initial sequence)
  (if (null? sequence)
      initial
      (op (car sequence)
          (accumulate op initial (cdr sequence)))))
```

Examples:

```scheme
(accumulate + 0 (list 2 4 6)) ; 12
(accumulate * 1 (list 1 2 3 4)) ; 24
```

Parameter meanings:

- `op`: how to combine items
- `initial`: value for the empty list
- `sequence`: list to process

---

## Sequence Pipeline

Example problem:

> Sum the squares of all odd numbers from 1 to 5.

Pipeline:

```text
1..5 -> odd numbers -> squares -> sum
```

Code:

```scheme
(accumulate +
            0
            (map square
                 (filter odd?
                         (enumerate-interval 1 5))))
```

Steps:

```text
1, 2, 3, 4, 5
-> 1, 3, 5
-> 1, 9, 25
-> 35
```

Another example:

```scheme
(accumulate +
            0
            (map square
                 (filter even?
                         (enumerate-interval 1 6))))
```

Steps:

```text
1, 2, 3, 4, 5, 6
-> 2, 4, 6
-> 4, 16, 36
-> 56
```

---

## Enumerating Intervals

`enumerate-interval` creates a list of integers:

```scheme
(enumerate-interval 1 5)
```

Result:

```scheme
(list 1 2 3 4 5)
```

Implementation:

```scheme
(define (enumerate-interval low high)
  (if (> low high)
      nil
      (cons low
            (enumerate-interval (+ low 1) high))))
```

---

## Enumerating Trees

`enumerate-tree` flattens a tree into a list of leaves.

Example:

```scheme
(enumerate-tree (list 1 (list 2 3) 4))
```

Result:

```scheme
(list 1 2 3 4)
```

Implementation:

```scheme
(define (enumerate-tree tree)
  (cond [(null? tree) nil]
        [(not (pair? tree)) (list tree)]
        [else (append (enumerate-tree (car tree))
                      (enumerate-tree (cdr tree)))]))
```

Why `(list tree)` for a leaf?

> Because `enumerate-tree` should always return a list.

For a single leaf `3`, it returns `(list 3)`, not `3`.

---

## Sum of Odd Squares in a Tree

Problem:

> Sum the squares of all odd leaves in a tree.

Code:

```scheme
(define (sum-odd-squares tree)
  (accumulate +
              0
              (map square
                   (filter odd?
                           (enumerate-tree tree)))))
```

Example:

```scheme
(sum-odd-squares (list 1 (list 2 3) (list 4 5)))
```

Steps:

```text
tree leaves: 1, 2, 3, 4, 5
odd leaves: 1, 3, 5
squares: 1, 9, 25
sum: 35
```

Result:

```scheme
35
```

---

## Even Fibonacci Numbers

Problem:

> List all even Fibonacci numbers from `fib(0)` through `fib(n)`.

Pipeline:

```text
0..n -> fib values -> even values -> list
```

Code:

```scheme
(define (even-fibs n)
  (accumulate cons
              nil
              (filter even?
                      (map fib
                           (enumerate-interval 0 n)))))
```

Example:

```text
fib(0..7) = 0, 1, 1, 2, 3, 5, 8, 13
```

So:

```scheme
(even-fibs 7)
```

Result:

```scheme
(list 0 2 8)
```

---

## Flatmap

`flatmap` is used when each input element produces a list of results, and all those lists should be flattened.

Definition:

```scheme
(define (flatmap proc seq)
  (accumulate append nil (map proc seq)))
```

Short version:

> `flatmap = map, then append`

Example with `map`:

```scheme
(map (lambda (x) (list x (- x)))
     (list 2 4))
```

Result:

```scheme
((2 -2) (4 -4))
```

Example with `flatmap`:

```scheme
(flatmap (lambda (x) (list x (- x)))
         (list 2 4))
```

Result:

```scheme
(2 -2 4 -4)
```

---

## Generating Pairs

Problem:

> Generate all pairs `(i, j)` where `1 <= j < i <= n`.

Code:

```scheme
(flatmap
 (lambda (i)
   (map (lambda (j) (list i j))
        (enumerate-interval 1 (- i 1))))
 (enumerate-interval 1 n))
```

For `n = 4`, result:

```scheme
((2 1) (3 1) (3 2) (4 1) (4 2) (4 3))
```

Important:

> The order follows the outer enumeration of `i`.

For `n = 3`, result:

```scheme
((2 1) (3 1) (3 2))
```

---

## Prime-Sum Pairs

Problem:

> Generate all pairs `(i, j)` where `1 <= j < i <= n` and `i + j` is prime.

Predicate:

```scheme
(define (prime-sum? pair)
  (prime? (+ (car pair) (cadr pair))))
```

Attach the sum:

```scheme
(define (make-pair-sum pair)
  (list (car pair)
        (cadr pair)
        (+ (car pair) (cadr pair))))
```

Full pipeline:

```scheme
(define (prime-sum-pairs n)
  (map make-pair-sum
       (filter prime-sum?
               (flatmap
                (lambda (i)
                  (map (lambda (j) (list i j))
                       (enumerate-interval 1 (- i 1))))
                (enumerate-interval 1 n)))))
```

For `n = 4`, prime-sum pairs are:

```scheme
((2 1) (3 2) (4 1) (4 3))
```

After adding sums:

```scheme
((2 1 3) (3 2 5) (4 1 5) (4 3 7))
```

---

## Permutations

Problem:

> Generate all permutations of a list.

Key idea:

> Choose one element as the first, then permute the rest.

Code:

```scheme
(define (permutations s)
  (if (null? s)
      (list nil)
      (flatmap (lambda (x)
                 (map (lambda (p) (cons x p))
                      (permutations (remove x s))))
               s)))
```

Example:

```scheme
(permutations (list 1 2))
```

Result:

```scheme
((1 2) (2 1))
```

For `(list 1 2 3)`, the idea is:

```text
choose 1 first -> permute (2 3)
choose 2 first -> permute (1 3)
choose 3 first -> permute (1 2)
```

`flatmap` is useful because each chosen first element produces a list of permutations.

---

## Current Position

Covered today:

- trees and leaves
- `count-leaves`
- `scale-tree`
- `filter`
- `accumulate`
- sequence pipelines
- `enumerate-interval`
- `enumerate-tree`
- `sum-odd-squares`
- `even-fibs`
- `flatmap`
- pair generation
- prime-sum pairs
- permutations

Next suggested step:

> Continue Section 2.2 with nested mappings and the picture language, or move toward Section 2.3 symbolic data after a brief review.

