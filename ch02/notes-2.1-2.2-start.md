# 2.1 - 2.2 Start Learning Notes

## Main Idea

Chapter 2 is about data abstraction.

Chapter 1 focused on abstracting processes. Chapter 2 starts abstracting data:

> Use a set of operations to construct and use data, instead of depending on how the data is stored internally.

The important idea is the abstraction barrier:

> Upper-level code should use the public operations. It should not depend on the internal representation.

---

## Rational Numbers

A rational number such as `3/5` has two parts:

- numerator: `3`
- denominator: `5`

The basic interface is:

```scheme
(make-rat n d) ; construct a rational number
(numer x)      ; get numerator
(denom x)      ; get denominator
```

These are the basic operations:

- `make-rat`: make a rational number
- `numer`: select the numerator
- `denom`: select the denominator

Operations such as addition and multiplication are built on top of this interface.

Example addition formula:

```text
a/b + c/d = (ad + bc) / bd
```

Code:

```scheme
(define (add-rat x y)
  (make-rat (+ (* (numer x) (denom y))
               (* (numer y) (denom x)))
            (* (denom x) (denom y))))
```

Example:

```text
1/2 + 1/3 = 5/6
```

---

## Cons, Car, and Cdr

Scheme can build a pair with `cons`:

```scheme
(cons 3 7)
```

Think of it as:

```text
[3 | 7]
```

Then:

```scheme
(car (cons 3 7)) ; 3
(cdr (cons 3 7)) ; 7
```

Historical note:

- `car` came from "Contents of Address Register"
- `cdr` came from "Contents of Decrement Register"

For learning, remember:

- `car`: first / left part
- `cdr`: second / right part

Rational numbers can be represented as pairs:

```scheme
(define (make-rat n d)
  (cons n d))

(define (numer x)
  (car x))

(define (denom x)
  (cdr x))
```

Upper-level rational operations should use `make-rat`, `numer`, and `denom`, not direct `cons`, `car`, and `cdr`.

---

## Normalizing Rational Numbers

`make-rat` should reduce rational numbers by `gcd`.

Example:

```text
6/8 -> 3/4
```

because:

```text
gcd(6, 8) = 2
```

A better constructor:

```scheme
(define (make-rat n d)
  (let ((g (gcd n d)))
    (cons (/ n g) (/ d g))))
```

It is also useful to keep the denominator positive.

Example:

```text
4/-8 -> -1/2
```

The constructor is a good place to centralize these rules, so all rational numbers have a consistent representation.

---

## Data Can Be Represented by Procedures

SICP shows that a pair does not have to be a physical box.

It can be represented by a procedure:

```scheme
(define (cons x y)
  (lambda (m)
    (m x y)))
```

If:

```scheme
(define p (cons 3 7))
```

then `p` is a procedure that remembers `3` and `7`.

`car` can be defined as:

```scheme
(define (car z)
  (z (lambda (p q) p)))
```

`cdr` can be defined as:

```scheme
(define (cdr z)
  (z (lambda (p q) q)))
```

Why this works:

- `cons` returns a procedure that remembers `x` and `y`.
- `car` passes in a selector that chooses the first value.
- `cdr` passes in a selector that chooses the second value.

Big idea:

> Data is defined by behavior, not only by physical representation.

If something supports the right operations, it can serve as that data type.

---

## Interval Arithmetic

Some real-world numbers are uncertain.

Example:

```text
100 ohms may really mean [99, 101]
```

An interval represents a range:

```text
[lower, upper]
```

Basic interface:

```scheme
(make-interval lower upper)
(lower-bound x)
(upper-bound x)
```

Interval addition:

```text
[1, 2] + [3, 4] = [4, 6]
```

Code:

```scheme
(define (add-interval x y)
  (make-interval (+ (lower-bound x) (lower-bound y))
                 (+ (upper-bound x) (upper-bound y))))
```

Interval multiplication checks all endpoint products:

```scheme
(define (mul-interval x y)
  (let ((p1 (* (lower-bound x) (lower-bound y)))
        (p2 (* (lower-bound x) (upper-bound y)))
        (p3 (* (upper-bound x) (lower-bound y)))
        (p4 (* (upper-bound x) (upper-bound y))))
    (make-interval (min p1 p2 p3 p4)
                   (max p1 p2 p3 p4))))
```

Example:

```text
[-2, 3] * [4, 5] = [-10, 15]
```

because the endpoint products are:

```text
-2*4 = -8
-2*5 = -10
3*4 = 12
3*5 = 15
```

---

## Dependency Problem

In normal algebra:

```text
x / x = 1
```

But in interval arithmetic:

```text
[1, 2] / [1, 2] = [1/2, 2]
```

Reason:

> Interval arithmetic does not know that the two appearances of `x` refer to the same uncertain value.

It treats them as independent ranges, so uncertainty can become wider.

This is called the dependency problem.

Big lesson:

> A data representation affects the behavior of computations built on top of it.

---

## Lists

Section 2.2 begins with sequences.

A list is a sequence:

```scheme
(list 1 2 3)
```

It can be understood as nested pairs:

```scheme
(cons 1
      (cons 2
            (cons 3
                  nil)))
```

For:

```scheme
(define x (list 10 20 30))
```

we have:

```scheme
(car x)       ; 10
(cdr x)       ; (20 30)
(car (cdr x)) ; 20
```

For lists:

- `car` gets the first element.
- `cdr` gets the rest of the list.

---

## List Recursion

Lists naturally split into:

```text
first element + rest of list
```

So list procedures often follow this pattern:

1. If the list is empty, return a base value.
2. Otherwise process `(car items)`.
3. Recur on `(cdr items)`.

Example length:

```scheme
(define (length items)
  (if (null? items)
      0
      (+ 1 (length (cdr items)))))
```

Example list reference:

```scheme
(define (list-ref items n)
  (if (= n 0)
      (car items)
      (list-ref (cdr items) (- n 1))))
```

Example:

```scheme
(list-ref (list 5 8 13 21) 2) ; 13
```

---

## Append

`append` joins two lists:

```scheme
(append (list 1 2) (list 3 4 5))
```

Result:

```scheme
(list 1 2 3 4 5)
```

Implementation:

```scheme
(define (append list1 list2)
  (if (null? list1)
      list2
      (cons (car list1)
            (append (cdr list1) list2))))
```

Important:

> `append` walks along the first list.

So its time cost depends mainly on the length of the first list.

---

## Map

`map` applies a procedure to every element of a list and returns a new list.

Example:

```scheme
(map square (list 1 2 3 4))
```

Result:

```scheme
(list 1 4 9 16)
```

Implementation:

```scheme
(define (map proc items)
  (if (null? items)
      nil
      (cons (proc (car items))
            (map proc (cdr items)))))
```

Using `lambda`:

```scheme
(map (lambda (x) (+ x 1))
     (list 5 6 7))
```

Result:

```scheme
(list 6 7 8)
```

Big idea:

> `map` is where higher-order procedures meet sequence data.

---

## Current Position

We have started Chapter 2 and reached the beginning of Section 2.2.

Covered:

- rational-number abstraction
- abstraction barriers
- pairs with `cons`, `car`, and `cdr`
- procedure representation of pairs
- interval arithmetic
- dependency problem
- lists
- list recursion
- `append`
- `map`

Next suggested step:

> Continue Section 2.2 with mapping over trees, hierarchical data, and sequence operations such as `filter` and `accumulate`.

