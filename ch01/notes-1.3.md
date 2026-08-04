# 1.3 Higher-Order Procedures

## Main Idea

Section 1.3 is about procedural abstraction at a higher level.

Before this section, we mostly wrote procedures that operate on numbers. In this section, procedures themselves become values:

- A procedure can be passed as an argument.
- A procedure can be returned as a result.
- A procedure can be combined with other procedures.
- A procedure can be used to express a general method of computation.

The key idea:

> Abstract the changing rule, and keep the common pattern.

---

## Procedures as Arguments

The general summation pattern can be written as:

```scheme
(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
         (sum term (next a) next b))))
```

Parameter meanings:

- `term`: how to compute the current item
- `a`: current value
- `next`: how to move to the next value
- `b`: end value

Examples:

```scheme
(define (identity x) x)
(define (inc x) (+ x 1))
(define (square x) (* x x))
(define (cube x) (* x x x))

(sum identity 1 inc 5) ; 1 + 2 + 3 + 4 + 5
(sum square 1 inc 5)   ; 1^2 + 2^2 + ... + 5^2
(sum cube 1 inc 5)     ; 1^3 + 2^3 + ... + 5^3
```

If `next` adds 2 each time, the same `sum` can sum only odd or even values:

```scheme
(define (next-by-2 x) (+ x 2))

(sum cube 1 next-by-2 7)   ; 1^3 + 3^3 + 5^3 + 7^3
(sum square 2 next-by-2 8) ; 2^2 + 4^2 + 6^2 + 8^2
```

---

## Product and Accumulate

`product` has the same shape as `sum`, but uses multiplication:

```scheme
(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
         (product term (next a) next b))))
```

`sum` and `product` can be unified by `accumulate`:

```scheme
(define (accumulate combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (term a)
                (accumulate combiner
                            null-value
                            term
                            (next a)
                            next
                            b))))
```

Then:

```scheme
(define (sum term a next b)
  (accumulate + 0 term a next b))

(define (product term a next b)
  (accumulate * 1 term a next b))
```

Review:

- For `sum`, `combiner` is `+`, and `null-value` is `0`.
- For `product`, `combiner` is `*`, and `null-value` is `1`.

---

## Lambda

`lambda` creates an anonymous procedure.

These two ideas are equivalent in use:

```scheme
(define (square x)
  (* x x))
```

```scheme
(lambda (x) (* x x))
```

Example:

```scheme
(sum (lambda (x) (* x x x)) 1 inc 5)
```

This computes:

```text
1^3 + 2^3 + 3^3 + 4^3 + 5^3
```

Use `lambda` when a small procedure is needed only at one place.

---

## Let

`let` creates local names:

```scheme
(let ((a 2)
      (b 5))
  (* a b))
```

Result:

```scheme
10
```

Important scope rule:

```scheme
(let ((x 10))
  (let ((x 2)
        (y x))
    (+ x y)))
```

Result:

```scheme
12
```

In a normal `let`, the right-hand sides are evaluated in the outer environment first. So `y` sees the outer `x = 10`, while the inner body sees the new `x = 2`.

---

## Procedures as Returned Values

A procedure can return another procedure.

Example:

```scheme
(define (make-adder n)
  (lambda (x)
    (+ x n)))

(define add-5 (make-adder 5))

(add-5 10) ; 15
```

The returned procedure remembers `n`. This is the basic idea of a closure:

> A procedure carries the environment in which it was created.

Another example:

```scheme
(define (make-multiplier n)
  (lambda (x)
    (* x n)))

(define times-3 (make-multiplier 3))

(times-3 7) ; 21
```

---

## Compose

`compose` combines two procedures:

```scheme
(define (compose f g)
  (lambda (x)
    (f (g x))))
```

`(compose f g)` means:

```text
f(g(x))
```

Examples:

```scheme
((compose square inc) 6) ; square(inc(6)) = 49
((compose inc square) 6) ; inc(square(6)) = 37
```

Order matters.

---

## Repeated

`repeated` returns a procedure that applies `f` `n` times:

```scheme
(define (repeated f n)
  (if (= n 1)
      f
      (compose f (repeated f (- n 1)))))
```

Examples:

```scheme
((repeated inc 4) 7)
```

Result:

```scheme
11
```

```scheme
((repeated square 3) 2)
```

Steps:

```text
2 -> 4 -> 16 -> 256
```

Result:

```scheme
256
```

Important:

> `repeated` repeats the whole procedure, not a fixed arithmetic change.

---

## Fixed Point

A fixed point of a function `f` is a value `x` such that:

```text
f(x) = x
```

The general search process:

```scheme
(define tolerance 0.00001)

(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
          next
          (try next))))
  (try first-guess))
```

The process repeatedly computes:

```text
guess -> f(guess) -> f(f(guess)) -> ...
```

until the value stops changing much.

Example:

```text
f(x) = x / 2
```

The fixed point is `0`.

---

## Average Damping

Direct fixed-point search can jump too much.

For example, to compute `sqrt(2)` using:

```text
y -> 2 / y
```

the guesses may jump:

```text
1.0 -> 2.0 -> 1.0 -> 2.0 -> ...
```

Average damping makes each step gentler:

```scheme
(define (average x y)
  (/ (+ x y) 2))

(define (average-damp f)
  (lambda (x)
    (average x (f x))))
```

Then square root can be expressed as:

```scheme
(define (sqrt x)
  (fixed-point
   (average-damp (lambda (y) (/ x y)))
   1.0))
```

Plain-language reading:

> Find the fixed point of the damped version of `y -> x / y`.

---

## Newton's Method

Newton's method solves equations of the form:

```text
g(x) = 0
```

For square root:

```text
y^2 = x
```

can be rewritten as:

```text
y^2 - x = 0
```

So:

```scheme
(define (sqrt x)
  (newtons-method
   (lambda (y) (- (square y) x))
   1.0))
```

For cube root:

```text
y^3 = x
```

So:

```scheme
(define (cube-root x)
  (newtons-method
   (lambda (y) (- (* y y y) x))
   1.0))
```

Important rule:

> We solve for `y`, so `y` is the lambda parameter. `x` is the known target value.

---

## Iterative Improve

Many numerical methods share the same pattern:

```text
guess -> improve -> check -> improve -> check -> ...
```

This can be abstracted:

```scheme
(define (iterative-improve good-enough? improve)
  (define (try guess)
    (if (good-enough? guess)
        guess
        (try (improve guess))))
  try)
```

The replaceable rules are:

- `good-enough?`: decides when to stop
- `improve`: decides how to improve the guess

Example idea:

```scheme
(define improve-by-1
  (iterative-improve
   (lambda (x) (> x 5))
   inc))

(improve-by-1 4) ; 6
```

`iterative-improve` returns a procedure. It does not immediately return a number. The returned procedure starts working when it receives an initial guess.

---

## Section Summary

Section 1.3 teaches that procedures are first-class values.

They can be:

- named
- passed as arguments
- returned as results
- combined
- used to express general methods

The main progression:

```text
sum -> product -> accumulate
lambda -> let
compose -> repeated
fixed-point -> average-damp -> newtons-method
iterative-improve
```

The big idea:

> We can abstract not only numbers and formulas, but also methods of computation.

Next suggested step:

> Review selected 1.3 exercises, then start Chapter 2: Data Abstraction.

