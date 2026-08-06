# 3.1 Assignment and Local State

## Main Idea

Chapter 3 introduces state.

In Chapters 1 and 2, programs mostly behaved like mathematical functions:

```scheme
(square 5) ; 25
```

The same input gives the same output.

Chapter 3 changes the model:

> A program can remember what happened before.

State means:

> The result of an operation can depend not only on its input, but also on the history of previous operations.

---

## State Example: Withdrawal

Suppose an account starts with balance `100`.

If we withdraw `25`:

```text
balance becomes 75
```

If we withdraw `25` again:

```text
balance becomes 50
```

The same operation:

```text
withdraw 25
```

can produce different results because the internal state changed.

---

## `set!`

Scheme uses `set!` to change an existing variable.

Example:

```scheme
(define balance 100)

(set! balance (- balance 25))
```

After this:

```scheme
balance ; 75
```

Important distinction:

- `define`: creates a binding
- `set!`: changes an existing binding

---

## Simple Global Withdraw

```scheme
(define balance 100)

(define (withdraw amount)
  (if (>= balance amount)
      (begin
        (set! balance (- balance amount))
        balance)
      "Insufficient funds"))
```

`begin` is used to run expressions in order:

1. update `balance`
2. return the new `balance`

Example:

```scheme
(withdraw 25) ; 75
(withdraw 25) ; 50
(withdraw 60) ; "Insufficient funds"
(withdraw 15) ; 35
```

This demonstrates state:

> Calling the same procedure with the same argument can return different results at different times.

---

## Why Global State Is Dangerous

The global `balance` can be changed from anywhere.

In larger programs, global state makes reasoning harder because many parts of the program may affect the same value.

A better design is local state.

---

## Local State with Closures

```scheme
(define (make-withdraw balance)
  (lambda (amount)
    (if (>= balance amount)
        (begin
          (set! balance (- balance amount))
          balance)
        "Insufficient funds")))
```

`make-withdraw` does not directly withdraw money.

It creates a withdraw procedure that remembers its own `balance`.

Example:

```scheme
(define W1 (make-withdraw 100))
```

Then:

```scheme
(W1 25) ; 75
(W1 25) ; 50
```

The balance is stored in the closure created by `make-withdraw`.

---

## Independent Local States

```scheme
(define W1 (make-withdraw 100))
(define W2 (make-withdraw 100))
```

`W1` and `W2` have separate balances.

Example:

```scheme
(W1 30) ; 70
(W2 10) ; 90
(W1 20) ; 50
```

Final balances:

```text
W1 = 50
W2 = 90
```

They do not affect each other.

Key idea:

> Closure + `set!` gives a procedure private mutable state.

This is an early form of an object.

---

## Account Object with Message Passing

A real account should support more than withdrawal.

It may support:

- withdraw
- deposit
- balance query

SICP uses message passing:

```scheme
(define (make-account balance)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin
          (set! balance (- balance amount))
          balance)
        "Insufficient funds"))

  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)

  (define (dispatch m)
    (cond [(eq? m 'withdraw) withdraw]
          [(eq? m 'deposit) deposit]
          [else (error "Unknown request -- MAKE-ACCOUNT" m)]))

  dispatch)
```

Usage:

```scheme
(define acc (make-account 100))

((acc 'deposit) 50)  ; 150
((acc 'withdraw) 30) ; 120
```

Why two pairs of parentheses?

```scheme
(acc 'withdraw)
```

returns the withdraw procedure.

Then:

```scheme
((acc 'withdraw) 30)
```

calls that returned procedure with `30`.

---

## Connection to Chapter 2

Chapter 2 also used message passing for data representation.

Example idea:

```scheme
(z 'real-part)
```

Chapter 3 adds mutable state.

Now:

```scheme
(acc 'withdraw)
(acc 'deposit)
```

return operations that can modify the internal `balance`.

Difference:

- Chapter 2 message-passing objects mainly encapsulate representation.
- Chapter 3 message-passing objects encapsulate representation and mutable state.

---

## Identity

State introduces object identity.

Example:

```scheme
(define acc1 (make-account 100))
(define acc2 (make-account 100))
```

Even though both accounts start with the same balance, they are not the same account.

Why?

- each call to `make-account` creates a new local state
- each account has its own `balance`
- changing one account does not change the other

Plain-language version:

> Same current value does not mean same object.

Two bank accounts can both have balance `100`, but they are still two different accounts.

---

## Why State Makes Reasoning Harder

Without state, expressions can often be replaced by their values.

Example:

```scheme
(+ 1 2)
```

can be replaced by:

```scheme
3
```

With state, a procedure call may also change the world.

Example:

```scheme
(W1 10)
```

does not only return a value. It also changes `W1`'s internal balance.

This is called a side effect.

Important lesson:

> State is useful, but it makes program reasoning depend on time and history.

---

## Current Position

Covered:

- assignment with `set!`
- global state
- local state
- closures with mutable variables
- withdraw procedure
- account object
- message passing
- object identity
- side effects

Next suggested step:

> Continue Section 3.1 with the costs of assignment, shared state, and why the environment model becomes necessary.

