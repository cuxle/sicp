# 3.4 Concurrency and Shared State

## Main Idea

Section 3.4 discusses what happens when multiple processes access and modify the same state concurrently.

Core lesson:

> Shared mutable state is already hard. Shared mutable state with concurrency is much harder.

The main problem is that operations that look like one step may actually contain multiple smaller steps that can interleave.

---

## Lost Update

Suppose:

```text
balance = 100
```

Two people withdraw concurrently:

```text
Peter withdraws 10
Paul withdraws 20
```

Correct final balance:

```text
100 - 10 - 20 = 70
```

But a withdrawal operation contains smaller steps:

```text
read balance
compute new balance
write new balance
```

Bad interleaving:

```text
Peter reads balance = 100
Peter computes 90

Paul reads balance = 100
Paul computes 80

Peter writes 90
Paul writes 80
```

Final balance:

```text
80
```

This is wrong. Peter's update was lost.

This is called a lost update.

---

## Critical Section

A critical section is a part of a program that must not be interleaved with another process.

For account withdrawal, the critical section includes:

```text
read balance
compute new balance
write balance
```

These steps must act like one protected operation.

---

## Serializer

A serializer wraps a procedure so that only one serialized procedure can run at a time.

Plain-language idea:

> A serializer is like a door. Only one process can pass through at once.

Example:

```scheme
(define protected-withdraw
  (serializer withdraw))
```

Calling `protected-withdraw` means:

1. acquire lock
2. run `withdraw`
3. release lock

This prevents another serialized operation from entering the same critical section at the same time.

---

## Serializer Implementation

SICP's serializer shape:

```scheme
(define (make-serializer)
  (let ((mutex (make-mutex)))
    (lambda (p)
      (define (serialized-p . args)
        (mutex 'acquire)
        (let ((val (apply p args)))
          (mutex 'release)
          val))
      serialized-p)))
```

Key points:

- `make-serializer` creates a mutex.
- It returns a wrapper procedure.
- The wrapper receives a procedure `p`.
- It returns a protected version of `p`.

The protected procedure:

```scheme
(define (serialized-p . args)
  ...)
```

can accept any number of arguments.

`args` is a list of arguments.

```scheme
(apply p args)
```

calls the original procedure `p` with those arguments.

Example:

```scheme
(apply + (list 1 2 3))
```

is equivalent to:

```scheme
(+ 1 2 3)
```

---

## Engineering Note: Releasing Locks

The SICP example is focused on the idea.

In real engineering, if:

```scheme
(apply p args)
```

fails before:

```scheme
(mutex 'release)
```

then the lock may never be released.

Real systems usually use a pattern like:

```text
lock.acquire()
try:
    work()
finally:
    lock.release()
```

Core engineering lesson:

> Always release locks even when the protected work fails.

---

## Mutex

A mutex is a mutual-exclusion lock.

It supports messages:

```scheme
'acquire
'release
```

Plain-language meaning:

- `acquire`: try to enter the protected section
- `release`: leave the protected section

SICP's mutex shape:

```scheme
(define (make-mutex)
  (let ((cell (list false)))
    (define (the-mutex m)
      (cond [(eq? m 'acquire)
             (if (test-and-set! cell)
                 (the-mutex 'acquire))]
            [(eq? m 'release)
             (clear! cell)]))
    the-mutex))
```

Important distinction:

- `the-mutex` is a procedure.
- `(the-mutex 'acquire)` is a procedure call.
- `cell` is the mutable data storing lock state.

`(the-mutex 'acquire)` does not return a pair. It sends an acquire message to the mutex object.

---

## Cell

The lock state is stored in:

```scheme
(list false)
```

This is a mutable one-element list.

Meaning:

```text
false -> lock is free
true  -> lock is occupied
```

Reading:

```scheme
(car cell)
```

Changing:

```scheme
(set-car! cell true)
(set-car! cell false)
```

---

## Test and Set

```scheme
(define (test-and-set! cell)
  (if (car cell)
      true
      (begin
        (set-car! cell true)
        false)))
```

Meaning:

- if `cell` is already true, the lock is occupied, return true
- if `cell` is false, set it to true and return false

Plain-language:

> Check whether the lock is occupied. If it is free, immediately occupy it.

---

## Why `test-and-set!` Must Be Atomic

If two processes run `test-and-set!` at the same time, both might see:

```text
cell = false
```

Then both could think they acquired the lock.

So `test-and-set!` must be atomic:

> It must run as one indivisible operation.

Real machines usually need hardware support for this, such as atomic test-and-set or compare-and-swap instructions.

Core lesson:

> Locking itself needs a lower-level atomic operation.

---

## Busy Waiting

In:

```scheme
(if (test-and-set! cell)
    (the-mutex 'acquire))
```

if `test-and-set!` returns true, the lock is occupied.

So the mutex recursively retries.

This is busy waiting:

```text
while lock is busy:
    keep trying
```

It is simple, but can waste CPU in real systems.

---

## Same Shared State Needs Same Lock

If `withdraw` and `deposit` both modify the same `balance`, they must use the same serializer.

If they use different serializers:

```text
withdraw uses lock A
deposit uses lock B
```

then they can still run at the same time.

That is almost like not protecting `balance` at all.

Core rule:

> Operations that modify the same shared state must share the same lock.

---

## Serialized Sets

A serializer does not only protect one procedure.

It can define a serialized set of procedures that cannot interleave with each other.

Example account operations:

- withdraw
- deposit

Both access the same `balance`, so they should belong to the same serialized set.

This allows unrelated operations to run concurrently while protecting related state.

---

## Transfers and Multi-Object Operations

Transfer:

```text
transfer 10 from A to B
```

can be understood as:

```text
A withdraws 10
B deposits 10
```

This involves two accounts.

If the transfer is interrupted halfway:

```text
A has been debited
B has not yet been credited
```

the system can temporarily be inconsistent.

This is the beginning of transaction-like thinking:

> A multi-object operation may need to behave as one whole operation.

---

## Deadlock

Deadlock can happen when multiple processes acquire multiple locks in different orders.

Example:

```text
T1: transfer A -> B
T2: transfer B -> A
```

Bad interleaving:

```text
T1 locks A
T2 locks B
T1 waits for B
T2 waits for A
```

Now both are waiting forever.

This is deadlock.

Core cause:

> Circular waiting for resources.

---

## Avoiding Deadlock with Lock Order

One common strategy:

> Always acquire locks in a fixed global order.

Example:

```text
account A id = 1
account B id = 2
```

Whether transferring A -> B or B -> A, always lock the lower id first:

```text
lock A, then lock B
```

This prevents:

```text
one process locks A then waits for B
another locks B then waits for A
```

because everyone follows the same order.

Fixed ordering reduces deadlock risk by preventing circular waiting.

---

## Real-World Connections

This section connects to many real engineering issues:

- multi-threaded shared memory
- concurrent database updates
- inventory overselling
- duplicate payment handling
- optimistic locks
- pessimistic locks
- distributed locks
- transactions
- idempotency
- eventual consistency

SICP uses a small account example, but the underlying problem is very real:

> Once state is shared and concurrent, correctness depends on controlling interleavings.

---

## Section Summary

Covered:

- lost update
- critical sections
- serializers
- serializer implementation
- mutex
- `test-and-set!`
- why atomic operations are necessary
- busy waiting
- shared state requiring the same lock
- serialized sets
- multi-object operations
- deadlock
- fixed lock ordering

Core lesson:

> Concurrency makes the cost of mutable state much more visible.

Next suggested step:

> Continue to Section 3.5: streams.

