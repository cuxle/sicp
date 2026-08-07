# 3.3 Tables, Constraints, and Simulation

## Main Idea

Section 3.3 continues mutable data.

After queues and one-dimensional tables, SICP shows larger systems built from local state and mutation:

- two-dimensional tables
- constraint propagation
- digital circuit simulation

The shared theme:

> Stateful objects can be connected into larger systems where changes propagate.

---

## Two-Dimensional Tables

A one-dimensional table maps:

```text
key -> value
```

A two-dimensional table maps:

```text
key1 + key2 -> value
```

Example:

```text
math + '+ -> add-proc
math + '* -> mul-proc
complex + 'real-part -> real-part-proc
```

This is useful for the operation tables from Chapter 2.

---

## Nested Table Structure

A two-dimensional table can be represented as nested association lists:

```scheme
(*table*
  (math
    (+ . add-proc)
    (* . mul-proc))
  (complex
    (real-part . real-part-proc)
    (magnitude . magnitude-proc)))
```

Plain-language structure:

```text
outer key -> subtable
inner key -> value
```

Example lookup:

```scheme
(lookup 'math '* table)
```

Steps:

1. find the `math` subtable
2. inside that subtable, find `*`
3. return `mul-proc`

---

## Two-Dimensional Lookup

```scheme
(define (lookup key-1 key-2 table)
  (let ((subtable (assoc key-1 (cdr table))))
    (if subtable
        (let ((record (assoc key-2 (cdr subtable))))
          (if record
              (cdr record)
              false))
        false)))
```

Plain-language steps:

- use `key-1` to find a subtable
- if the subtable exists, use `key-2` inside it
- if a record is found, return its value
- otherwise return false

---

## Two-Dimensional Insert

```scheme
(define (insert! key-1 key-2 value table)
  (let ((subtable (assoc key-1 (cdr table))))
    (if subtable
        (let ((record (assoc key-2 (cdr subtable))))
          (if record
              (set-cdr! record value)
              (set-cdr! subtable
                        (cons (cons key-2 value)
                              (cdr subtable)))))
        (set-cdr! table
                  (cons (list key-1
                              (cons key-2 value))
                        (cdr table)))))
  'ok)
```

Cases:

1. Subtable exists and record exists: update the value.
2. Subtable exists but record does not exist: add a record to the subtable.
3. Subtable does not exist: create a new subtable and attach it to the table.

---

## Connection to `put` and `get`

Chapter 2 used data-directed programming:

```scheme
(put op type proc)
(get op type)
```

A two-dimensional table can implement this:

```text
operation + type -> procedure
```

Example:

```text
real-part + (rectangular) -> real-part-rectangular
add + (rational rational) -> add-rational
```

SICP first used this abstraction, then later showed how mutable tables can implement it.

---

## Constraint Propagation

Constraint propagation is a system where values are connected by relationships.

Example temperature formula:

```text
F = 9/5 * C + 32
```

In an ordinary function:

```text
C -> F
```

But in a constraint system:

```text
C <-> F
```

If `C` is known, the system can compute `F`.

If `F` is known, the system can compute `C`.

Core distinction:

> Functions are single-direction computations. Constraints are multi-direction relationships.

---

## Connectors

A connector is like a stateful value holder.

It can:

- hold a value
- know whether it currently has a value
- remember who set the value
- forget a value
- connect to constraints
- notify constraints when its value changes

Plain-language view:

> A connector is a box that can store a value and notify its neighbors.

---

## Constraints

A constraint represents a relationship among connectors.

Example addition constraint:

```text
a + b = c
```

It can infer missing values in multiple directions:

- if `a` and `b` are known, compute `c`
- if `a` and `c` are known, compute `b`
- if `b` and `c` are known, compute `a`

Example:

```text
a = 3
c = 10
```

Then:

```text
b = 7
```

This is more general than a one-way function.

---

## Constraint Networks

The Celsius/Fahrenheit formula:

```text
F = 9/5 * C + 32
```

can be built from connectors and small constraints.

When `C` is set:

1. `C` notifies connected constraints.
2. Constraints compute intermediate values.
3. Intermediate connectors notify their constraints.
4. Eventually `F` receives a value.

This is propagation through a network.

Real-world analogies:

- spreadsheets
- reactive programming
- data-flow systems
- dependency graphs
- UI state propagation

---

## Digital Circuit Simulation

SICP also builds a digital circuit simulator.

Main objects:

- wires
- gates
- delays
- agenda

This is a discrete-event simulation.

---

## Wires

A wire is a stateful object.

It has:

- a signal value, usually `0` or `1`
- a list of actions to run when the signal changes

Plain-language view:

> A wire stores a signal and notifies listeners when the signal changes.

This is similar to connectors in the constraint system.

---

## Gates

Gates connect wires and define signal relationships.

Examples:

- inverter
- and-gate
- or-gate

For an inverter:

```text
input 0 -> output 1
input 1 -> output 0
```

But output changes are not instant.

They happen after a delay.

---

## Agenda

An agenda is a time-ordered event queue.

Example:

```text
time 5: set wire A to 1
time 8: update wire C
time 10: update wire D
```

The simulator processes events in time order.

Why is an agenda needed?

> Circuit elements have propagation delays. Signal changes happen later, not immediately.

So the simulator schedules future actions:

```text
current time + delay -> action
```

This is event-driven simulation.

---

## Architecture Lesson

Constraint systems and circuit simulators show a different style of program organization.

Instead of:

```text
main function calls everything in order
```

we get:

```text
stateful objects connected in a network
changes propagate through messages and scheduled events
```

This resembles:

- event systems
- message queues
- frontend reactive updates
- spreadsheet recalculation
- simulation engines
- async systems

Core lesson:

> Stateful modules can be composed into larger systems, but time, change, and propagation must be modeled carefully.

---

## Current Position

Covered:

- two-dimensional tables
- nested association lists
- lookup and insert for two-key tables
- connection between tables and `put`/`get`
- constraint propagation
- connectors and constraints
- Celsius/Fahrenheit as a relation
- digital circuit simulation
- wires, gates, delays, and agenda

Next suggested step:

> Continue to Section 3.4: concurrency and shared state.

