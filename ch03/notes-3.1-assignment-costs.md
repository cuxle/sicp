# 3.1 Assignment Costs and Environment Model Preview

## Main Idea

Assignment introduces state, and state introduces time.

Once a program uses `set!`, understanding an expression may require knowing what happened before.

Core lesson:

> State is useful, but it makes reasoning harder.

---

## Referential Transparency

In a program without mutation, an expression can often be replaced by its value.

Example:

```scheme
(+ 1 2)
```

can be replaced by:

```scheme
3
```

So:

```scheme
(* (+ 1 2) 4)
```

can be understood as:

```scheme
(* 3 4)
```

This property is called referential transparency.

Plain-language version:

> An expression can be safely replaced by its value without changing program behavior.

---

## State Breaks Referential Transparency

Example:

```scheme
(define W (make-withdraw 100))
```

Then:

```scheme
(W 25) ; 75
(W 25) ; 50
```

The same expression:

```scheme
(W 25)
```

returns different results at different times.

So we cannot simply say:

```scheme
(W 25) = 75
```

because the next call may not be `75`.

State makes program meaning depend on history.

---

## Shared State

There is an important difference between two names pointing to the same object and two separately created objects.

### Shared Account

```scheme
(define acc (make-account 100))
(define p acc)
(define q acc)
```

Here `p` and `q` point to the same account.

Example:

```scheme
((p 'withdraw) 30) ; 70
((q 'withdraw) 20) ; 50
```

Final balance:

```text
50
```

Why?

> `p` and `q` share the same internal balance.

---

### Independent Accounts

```scheme
(define p (make-account 100))
(define q (make-account 100))
```

Here `p` and `q` are separate accounts.

Example:

```scheme
((p 'withdraw) 30) ; 70
((q 'withdraw) 20) ; 80
```

Final balances:

```text
p = 70
q = 80
```

Why?

> Each call to `make-account` creates a new local state.

---

## Equality vs Identity

State forces us to distinguish:

- equality: do two values currently look the same?
- identity: are they the same object?

Two accounts can both have balance `100`, but they are still different accounts if they were created separately.

Plain-language rule:

> Same state does not mean same object.

---

## Order Matters with Shared State

Example:

```scheme
(define x 10)

(define (add-one)
  (set! x (+ x 1))
  x)

(define (double)
  (set! x (* x 2))
  x)
```

Order 1:

```scheme
(add-one)
(double)
```

Steps:

```text
x = 10
add-one -> x = 11
double -> x = 22
```

Final result:

```text
22
```

Order 2:

```scheme
(double)
(add-one)
```

Steps:

```text
x = 10
double -> x = 20
add-one -> x = 21
```

Final result:

```text
21
```

Same operations, different order, different result.

Core lesson:

> Shared mutable state makes execution order important.

---

## Why Substitution Model Is Not Enough

In Chapter 1, we used the substitution model.

Example:

```scheme
(square 5)
```

can be understood as:

```scheme
(* 5 5)
```

This works well when variables are just names for values.

But with assignment:

```scheme
(define balance 100)
(set! balance 75)
```

`balance` is no longer simply replaceable by `100`.

It behaves more like:

> a name connected to a storage location whose contents can change.

So we need a new model.

---

## Environment Model Preview

The environment model explains evaluation using environments.

An environment is like a table of name bindings:

```text
x -> 10
balance -> 100
```

For:

```scheme
(define x 10)
```

the global environment gets:

```text
x -> 10
```

For:

```scheme
(set! x 20)
```

the binding is changed:

```text
x -> 20
```

---

## Procedure Calls and Environments

Calling a procedure creates a new local environment.

Example:

```scheme
(define (square x)
  (* x x))

(square 5)
```

The call creates a local environment:

```text
x -> 5
```

Then the body:

```scheme
(* x x)
```

is evaluated in that environment.

---

## Closures Remember Environments

Example:

```scheme
(define W (make-withdraw 100))
```

This creates an environment:

```text
balance -> 100
```

The returned procedure `W` remembers this environment.

Then:

```scheme
(W 25)
```

finds `balance` in the remembered environment and changes it:

```text
balance: 100 -> 75
```

This is why `W` can remember its balance.

---

## Separate Calls Create Separate Environments

```scheme
(define W1 (make-withdraw 100))
(define W2 (make-withdraw 100))
```

This creates two different environments:

```text
E1:
balance -> 100

E2:
balance -> 100
```

`W1` remembers `E1`.

`W2` remembers `E2`.

So:

```text
W1 changes E1's balance
W2 changes E2's balance
```

They do not affect each other.

---

## Current Position

Covered:

- referential transparency
- how state breaks substitution-style reasoning
- shared state
- independent state
- equality vs identity
- execution order and mutation
- why substitution model is not enough
- preview of the environment model

Next suggested step:

> Continue to Section 3.2 and study the environment model formally.

