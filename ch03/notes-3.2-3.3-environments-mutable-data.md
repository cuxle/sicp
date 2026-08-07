# 3.2 - 3.3 Environments and Mutable Data

## Main Idea

After assignment is introduced, the substitution model is no longer enough.

We need the environment model to explain:

- where variables are found
- what procedure calls create
- why closures remember variables
- what `set!` changes
- why separate objects have separate state
- how mutable data structures work

---

## Environment Model Basics

An environment is a chain of frames.

Each frame contains bindings:

```text
name -> value
```

Example:

```scheme
(define x 10)
(define y 20)
```

Global environment:

```text
x -> 10
y -> 20
```

When evaluating a variable, Scheme looks in the current environment first. If the name is not found, it looks in the enclosing environment.

---

## Procedure Calls

Calling a procedure creates a new local environment.

Example:

```scheme
(define x 10)

(define (f y)
  (+ x y))

(f 3)
```

Evaluation:

- global environment has `x -> 10`
- calling `(f 3)` creates a new frame with `y -> 3`
- the new frame points to the environment where `f` was defined
- in `(+ x y)`, `y` is found locally, `x` is found globally

Result:

```scheme
13
```

---

## Local Bindings Shadow Outer Bindings

Example:

```scheme
(define x 100)

(define (g x)
  (* x 2))

(g 5)
```

The parameter `x` creates a local binding:

```text
x -> 5
```

This local `x` shadows the global `x -> 100`.

Result:

```scheme
10
```

Plain-language rule:

> The nearest binding wins.

---

## Closures Remember Environments

Example:

```scheme
(define (make-adder n)
  (lambda (x)
    (+ x n)))

(define add10 (make-adder 10))
```

Calling `make-adder` creates an environment:

```text
n -> 10
```

The returned lambda remembers this environment.

Then:

```scheme
(add10 7)
```

creates a new frame:

```text
x -> 7
```

The lambda body can find:

```text
x = 7
n = 10
```

Result:

```scheme
17
```

Core rule:

> Closure = procedure + the environment where it was created.

---

## `set!` Changes an Existing Binding

Example:

```scheme
(define W (make-withdraw 100))
```

This creates an environment:

```text
balance -> 100
```

The returned withdraw procedure remembers that environment.

When:

```scheme
(W 30)
```

it changes the remembered binding:

```text
balance: 100 -> 70
```

Then:

```scheme
(W 20)
```

changes the same binding:

```text
balance: 70 -> 50
```

Core rule:

> `set!` modifies the nearest existing binding found along the environment chain.

---

## Separate Creation vs Shared Reference

Separate calls create separate environments:

```scheme
(define W1 (make-withdraw 100))
(define W2 (make-withdraw 100))
```

This creates:

```text
E1: balance -> 100
E2: balance -> 100
```

`W1` remembers `E1`, and `W2` remembers `E2`.

But:

```scheme
(define W1 (make-withdraw 100))
(define W2 W1)
```

creates only one withdraw procedure and one remembered environment.

Example:

```scheme
(W1 10) ; 90
(W2 20) ; 70
```

Final balance:

```text
70
```

because `W1` and `W2` share the same state.

---

## Internal Definitions

Internal helper procedures can access variables from the outer procedure environment.

Example:

```scheme
(define (outer x)
  (define (inner y)
    (+ x y))
  inner)

(define add3 (outer 3))
(add3 10)
```

When `(outer 3)` is called, it creates:

```text
x -> 3
```

The returned `inner` remembers that environment.

When `(add3 10)` is called:

- `y` is found in the call frame
- `x` is found in the remembered outer frame

Result:

```scheme
13
```

---

## Counters as Local State

Example:

```scheme
(define (make-counter)
  (let ((count 0))
    (lambda ()
      (set! count (+ count 1))
      count)))
```

Usage:

```scheme
(define c1 (make-counter))
(define c2 (make-counter))

(c1) ; 1
(c1) ; 2
(c2) ; 1
(c1) ; 3
```

Each counter has its own private `count`.

This is the same pattern:

> private state + procedure that changes it.

---

## Mutable Pairs

Before this point, pairs were mostly read with:

```scheme
car
cdr
```

Now SICP introduces mutation of pair contents:

```scheme
set-car!
set-cdr!
```

Example:

```scheme
(define p (cons 1 2))
(set-car! p 10)
```

Now:

```scheme
(car p) ; 10
(cdr p) ; 2
```

`set-car!` changes the left part of the pair.

`set-cdr!` changes the right part of the pair.

---

## Shared Mutable Pairs

Example:

```scheme
(define p (cons 1 2))
(define q p)

(set-cdr! q 99)
```

`p` and `q` point to the same pair.

So:

```scheme
(car p) ; 1
(cdr p) ; 99
```

Core lesson:

> Shared reference + mutation means changes are visible through all shared names.

---

## Pair Notation

A pair has two slots:

```text
[ car | cdr ]
```

Example:

```scheme
(cons 1 2)
```

can be drawn as:

```text
[1 | 2]
```

The notation is just a drawing, not Scheme syntax.

A list is many pairs linked together:

```scheme
(list 1 2 3)
```

means:

```scheme
(cons 1
      (cons 2
            (cons 3 nil)))
```

Drawing:

```text
[1 | *] -> [2 | *] -> [3 | nil]
```

---

## Queue Representation

A queue is first-in, first-out.

Operations:

```scheme
(make-queue)
(empty-queue? queue)
(front-queue queue)
(insert-queue! queue item)
(delete-queue! queue)
```

SICP represents a queue using two levels of pairs.

The queue object itself is a pair:

```text
[ front-ptr | rear-ptr ]
```

The queue contents are a linked list of pairs:

```text
[A | *] -> [B | *] -> [C | nil]
```

Full picture:

```text
queue pair:
[ front-ptr | rear-ptr ]
      |          |
      v          v
    [A | *] -> [B | *] -> [C | nil]
```

Meaning:

- the outer pair stores two pointers
- `front-ptr` points to the first node
- `rear-ptr` points to the last node
- each queue node is also a pair
- node `car` stores the item
- node `cdr` points to the next node

---

## Queue Selectors and Mutators

```scheme
(define (front-ptr queue)
  (car queue))

(define (rear-ptr queue)
  (cdr queue))

(define (set-front-ptr! queue item)
  (set-car! queue item))

(define (set-rear-ptr! queue item)
  (set-cdr! queue item))

(define (make-queue)
  (cons nil nil))

(define (empty-queue? queue)
  (null? (front-ptr queue)))
```

Empty queue:

```text
[nil | nil]
```

---

## Front of Queue

```scheme
(define (front-queue queue)
  (if (empty-queue? queue)
      (error "FRONT called with an empty queue" queue)
      (car (front-ptr queue))))
```

If the queue is:

```text
A -> B -> C
```

then:

```scheme
(front-ptr queue)
```

points to:

```text
[A | points-to-B]
```

and:

```scheme
(front-queue queue)
```

returns:

```scheme
A
```

Distinction:

- `front-ptr`: the node
- `front-queue`: the item inside the node

---

## Inserting into a Queue

```scheme
(define (insert-queue! queue item)
  (let ((new-pair (cons item nil)))
    (cond [(empty-queue? queue)
           (set-front-ptr! queue new-pair)
           (set-rear-ptr! queue new-pair)
           queue]
          [else
           (set-cdr! (rear-ptr queue) new-pair)
           (set-rear-ptr! queue new-pair)
           queue])))
```

If the queue is empty, both front and rear point to the new node.

If the queue is not empty:

1. create a new node
2. set the old rear node's `cdr` to the new node
3. update `rear-ptr` to the new node

This makes insertion at the rear constant time.

---

## Deleting from a Queue

```scheme
(define (delete-queue! queue)
  (cond [(empty-queue? queue)
         (error "DELETE! called with an empty queue" queue)]
        [else
         (set-front-ptr! queue (cdr (front-ptr queue)))
         queue]))
```

If the queue is:

```text
A -> B -> C
```

after deletion:

```text
B -> C
```

`front-ptr` points to:

```text
[B | points-to-C]
```

`front-queue` returns:

```scheme
B
```

---

## Shared Queue

Example:

```scheme
(define q1 (make-queue))
(define q2 q1)

(insert-queue! q1 'A)
(insert-queue! q2 'B)
```

`q1` and `q2` point to the same queue.

Final contents:

```text
A -> B
```

Both names see the same queue.

---

## Tables

A table maps keys to values.

Example:

```text
apple  -> 10
banana -> 20
```

SICP starts with a simple association list.

A record is a pair:

```scheme
(key . value)
```

Example records:

```scheme
((apple . 10) (banana . 20))
```

For:

```scheme
records = ((apple . 10) (banana . 20))
```

we have:

```scheme
(car records)  ; (apple . 10)
(caar records) ; apple
```

because:

```scheme
caar = car of car
```

---

## Assoc

```scheme
(define (assoc key records)
  (cond [(null? records) false]
        [(equal? key (caar records)) (car records)]
        [else (assoc key (cdr records))]))
```

`assoc` searches records by key.

If it finds the record:

```scheme
(apple . 10)
```

it returns the whole record, not just the value.

Returning the whole record is useful because update can mutate the record's `cdr`.

---

## Lookup and Insert

A table may be represented as:

```scheme
(*table* (apple . 10) (banana . 20))
```

The records are in:

```scheme
(cdr table)
```

Lookup:

```scheme
(define (lookup key table)
  (let ((record (assoc key (cdr table))))
    (if record
        (cdr record)
        false)))
```

Insert or update:

```scheme
(define (insert! key value table)
  (let ((record (assoc key (cdr table))))
    (if record
        (set-cdr! record value)
        (set-cdr! table
                  (cons (cons key value)
                        (cdr table)))))
  'ok)
```

Example:

```scheme
(insert! 'apple 99 table)
(lookup 'apple table) ; 99
```

If the key already exists, `insert!` updates it.

If the key does not exist, `insert!` adds a new record.

---

## Connection to Chapter 2

Chapter 2 used data-directed programming with:

```scheme
(put op type proc)
(get op type)
```

Chapter 3's table implementation shows how such a table can be built using mutable data.

This is a pattern in SICP:

> First use an abstraction, then later reveal how it may be implemented.

---

## Current Position

Covered:

- environment model basics
- closure environments
- `set!` and binding mutation
- internal definitions
- counters
- mutable pairs
- shared mutable structures
- queue representation
- queue insertion and deletion
- association-list tables
- lookup and insertion

Next suggested step:

> Continue 3.3 with two-dimensional tables and more mutable structures, then move toward simulation examples.

