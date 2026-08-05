# 2.3 Symbolic Data Notes

## Main Idea

Section 2.3 introduces symbolic data.

The big idea:

> Programs can manipulate symbols and expressions as data.

This is a major step beyond numerical computation. A Scheme expression can be executed, but it can also be quoted and treated as a data structure.

---

## Quote

Without quote, Scheme evaluates an expression:

```scheme
(+ 1 2)
```

Result:

```scheme
3
```

With quote:

```scheme
'(+ 1 2)
```

Scheme does not perform the addition. It treats the expression as data.

`'` is shorthand for `quote`:

```scheme
'x
```

is the same as:

```scheme
(quote x)
```

And:

```scheme
'(+ 1 2)
```

is the same as:

```scheme
(quote (+ 1 2))
```

Plain-language rule:

> Quote means: do not evaluate this; keep it as data.

---

## Symbols Are Not Strings

Symbol:

```scheme
'apple
```

String:

```scheme
"apple"
```

They are different.

For learning:

- a string is text
- a symbol is more like a name, label, or identifier

Examples of symbols:

```scheme
'x
'y
'red
'circle
'+
'*
```

---

## Quoted Expressions Are Structured Data

This:

```scheme
'(+ 1 2)
```

is not a string. It is a list-like symbolic expression.

It can be decomposed:

```scheme
(car '(+ 1 2)) ; '+
(cdr '(+ 1 2)) ; '(1 2)
```

For:

```scheme
(define exp '(+ x 3))
```

we have:

```scheme
(car exp)   ; '+
(cadr exp)  ; 'x
(caddr exp) ; 3
```

This matters because programs can analyze expressions.

---

## Symbols and Variables

Predicate:

```scheme
(symbol? 'x)       ; true
(symbol? 3)        ; false
(symbol? '(+ x 3)) ; false
```

`'(+ x 3)` is a list, not a single symbol.

Symbol equality:

```scheme
(eq? 'x 'x) ; true
(eq? 'x 'y) ; false
```

Same variable check:

```scheme
(define (same-variable? v1 v2)
  (and (symbol? v1)
       (symbol? v2)
       (eq? v1 v2)))
```

---

## Symbolic Differentiation

SICP uses symbolic differentiation to show that expressions can be represented and transformed as data.

Example:

```scheme
(deriv '(+ x 3) 'x)
```

Expected result:

```scheme
1
```

because:

```text
d/dx (x + 3) = 1
```

---

## Representing Sums

Expression:

```scheme
'(+ x 3)
```

Representation:

```scheme
(list '+ 'x 3)
```

Selectors and predicates:

```scheme
(define (sum? x)
  (and (pair? x) (eq? (car x) '+)))

(define (addend s)
  (cadr s))

(define (augend s)
  (caddr s))
```

Meanings:

- `sum?`: is this an addition expression?
- `addend`: first addend
- `augend`: second addend

This creates an abstraction barrier for expression representation.

---

## Basic Differentiation Rules

Numbers:

```text
d(number)/dx = 0
```

Same variable:

```text
d(x)/dx = 1
```

Different variable:

```text
d(y)/dx = 0
```

Sum:

```text
d(a + b)/dx = da/dx + db/dx
```

Product:

```text
d(a * b)/dx = a * db/dx + da/dx * b
```

Important simplification for this learning stage:

> Different symbols are treated as independent variables.

So:

```scheme
(deriv 'x 'x) ; 1
(deriv 'y 'x) ; 0
```

---

## Constructors Can Simplify

Use constructors such as `make-sum` instead of directly building raw lists.

Example:

```scheme
(make-sum 1 0) ; 1
(make-sum 0 'x) ; 'x
(make-sum 'x 'y) ; '(+ x y)
```

For products:

```scheme
(make-product m1 m2)
```

can simplify:

- anything times `0` is `0`
- anything times `1` is itself

This is the same abstraction-barrier idea:

> Constructors should keep data in a cleaner representation.

---

## Product Rule Example

Expression:

```scheme
(deriv '(* x 3) 'x)
```

Math:

```text
d/dx (x * 3)
```

Using product rule:

```text
a = x
b = 3
a' = 1
b' = 0

a*b' + a'*b
= x*0 + 1*3
= 3
```

Result:

```scheme
3
```

Another example:

```scheme
(deriv '(* x y) 'x)
```

Because `y` is treated as independent from `x`:

```text
d/dx (x*y) = y
```

---

## Full Derivative Shape

The symbolic derivative procedure follows the math rules directly:

```scheme
(define (deriv exp var)
  (cond [(number? exp) 0]
        [(variable? exp)
         (if (same-variable? exp var) 1 0)]
        [(sum? exp)
         (make-sum (deriv (addend exp) var)
                   (deriv (augend exp) var))]
        [(product? exp)
         (make-sum
          (make-product (multiplier exp)
                        (deriv (multiplicand exp) var))
          (make-product (deriv (multiplier exp) var)
                        (multiplicand exp)))]
        [else
         (error "unknown expression type -- DERIV" exp)]))
```

Main point:

> The structure of the program mirrors the structure of the mathematical rules.

---

## Sets as Symbolic Data

A set is a collection of distinct elements.

Common operations:

- `element-of-set?`: is an element in the set?
- `adjoin-set`: add an element
- `intersection-set`: intersection
- `union-set`: union

Again, the point is data abstraction:

> A set can have different internal representations, while keeping the same external operations.

---

## Unordered List Representation

Example set:

```scheme
(list 1 2 3)
```

Element check:

```scheme
(define (element-of-set? x set)
  (cond [(null? set) false]
        [(equal? x (car set)) true]
        [else (element-of-set? x (cdr set))]))
```

Adjoin:

```scheme
(define (adjoin-set x set)
  (if (element-of-set? x set)
      set
      (cons x set)))
```

Intersection:

```scheme
(define (intersection-set set1 set2)
  (cond [(or (null? set1) (null? set2)) nil]
        [(element-of-set? (car set1) set2)
         (cons (car set1)
               (intersection-set (cdr set1) set2))]
        [else
         (intersection-set (cdr set1) set2)]))
```

Example:

```text
{1, 2, 3} intersection {2, 3, 4} = {2, 3}
{1, 2, 3} union {2, 3, 4} = {1, 2, 3, 4}
```

Unordered list lookup is `O(n)`.

---

## Ordered List Representation

If the set is ordered:

```scheme
(list 2 4 6 8 10)
```

then lookup can stop early.

Example: searching for `5`

```text
2 -> continue
4 -> continue
6 -> stop
```

Once we see `6`, we know `5` cannot appear later.

Element check:

```scheme
(define (element-of-set? x set)
  (cond [(null? set) false]
        [(= x (car set)) true]
        [(< x (car set)) false]
        [else (element-of-set? x (cdr set))]))
```

Worst-case time is still `O(n)`, but average behavior can improve.

---

## Binary Search Tree Representation

A set can also be represented as a binary search tree.

Each node has:

- entry
- left branch
- right branch

Rule:

```text
all values in left branch < entry
all values in right branch > entry
```

Example:

```text
        7
       / \
      3   9
     / \   \
    1   5   11
```

Searching for `11`:

```text
7 -> 9 -> 11
```

If the tree is balanced, lookup is about `O(log n)`.

If the tree is badly unbalanced, it can degrade to `O(n)`.

---

## Tree Node Interface

Tree representation:

```scheme
(define (make-tree entry left right)
  (list entry left right))
```

Selectors:

```scheme
(define (entry tree)
  (car tree))

(define (left-branch tree)
  (cadr tree))

(define (right-branch tree)
  (caddr tree))
```

Element lookup:

```scheme
(define (element-of-set? x set)
  (cond [(null? set) false]
        [(= x (entry set)) true]
        [(< x (entry set))
         (element-of-set? x (left-branch set))]
        [(> x (entry set))
         (element-of-set? x (right-branch set))]))
```

Again, upper-level code uses selectors such as `entry`, `left-branch`, and `right-branch`, not raw `car`, `cadr`, and `caddr`.

---

## Tree to Ordered List

A binary search tree can be converted to an ordered list using inorder traversal:

```text
left subtree -> entry -> right subtree
```

Code:

```scheme
(define (tree->list tree)
  (if (null? tree)
      nil
      (append (tree->list (left-branch tree))
              (cons (entry tree)
                    (tree->list (right-branch tree))))))
```

Example:

```text
        4
       / \
      2   6
     / \ / \
    1  3 5  7
```

Inorder traversal:

```text
1, 2, 3, 4, 5, 6, 7
```

---

## Current Position

Covered:

- quote and symbolic expressions
- symbols vs strings
- expression decomposition with `car`, `cadr`, `caddr`
- symbolic differentiation
- sum and product expression interfaces
- constructor-based simplification
- set abstraction
- unordered set representation
- ordered set representation
- binary search tree representation
- tree to ordered list via inorder traversal

Next suggested step:

> Continue Section 2.3 with Huffman encoding trees.

