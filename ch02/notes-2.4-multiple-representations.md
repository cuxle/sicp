# 2.4 Multiple Representations for Abstract Data

## Main Idea

Section 2.4 is about supporting multiple internal representations for the same abstract data type.

The key idea:

> The same abstraction can have different internal representations, while upper-level code uses one unified interface.

This section uses complex numbers as the main example.

---

## Complex Numbers

A complex number can be written as:

```text
z = a + bi
```

Example:

```text
3 + 4i
```

Rectangular representation:

- real part: `3`
- imaginary part: `4`

Polar representation:

- magnitude: distance from origin
- angle: direction

For `3 + 4i`:

```text
magnitude = sqrt(3^2 + 4^2) = 5
```

The angle is approximately:

```text
atan(4 / 3)
```

---

## Why Multiple Representations?

Different operations are easier in different representations.

Addition is natural in rectangular form:

```text
(a + bi) + (c + di) = (a+c) + (b+d)i
```

Multiplication is natural in polar form:

```text
(r1 angle theta1) * (r2 angle theta2)
= (r1*r2) angle (theta1+theta2)
```

So no single representation is always best.

Architecture lesson:

> Representation should serve the operations the system needs.

---

## Unified Interface

For any complex number `z`, upper-level code wants to use:

```scheme
(real-part z)
(imag-part z)
(magnitude z)
(angle z)
```

It should not care whether `z` is stored in rectangular or polar form.

Complex addition can use rectangular-style selectors:

```scheme
(define (add-complex z1 z2)
  (make-from-real-imag
   (+ (real-part z1) (real-part z2))
   (+ (imag-part z1) (imag-part z2))))
```

Complex multiplication can use polar-style selectors:

```scheme
(define (mul-complex z1 z2)
  (make-from-mag-ang
   (* (magnitude z1) (magnitude z2))
   (+ (angle z1) (angle z2))))
```

Both functions depend on the abstract interface, not on the internal representation.

---

## Rectangular Representation

If a complex number is stored as:

```text
(real, imag)
```

then:

```text
real-part = real
imag-part = imag
magnitude = sqrt(real^2 + imag^2)
angle = atan(imag, real)
```

For `3 + 4i`:

```text
real-part = 3
imag-part = 4
magnitude = 5
```

---

## Polar Representation

If a complex number is stored as:

```text
(magnitude, angle)
```

then:

```text
magnitude = magnitude
angle = angle
real-part = magnitude * cos(angle)
imag-part = magnitude * sin(angle)
```

Important:

For a polar complex number with:

```text
magnitude = 5
angle = theta
```

the real part is:

```text
5 * cos(theta)
```

It is not always `5`. It is `5` only when `theta = 0`.

---

## Tagged Data

To let the system know which representation is being used, data can carry a type tag.

Tag tools:

```scheme
(define (attach-tag type-tag contents)
  (cons type-tag contents))

(define (type-tag datum)
  (car datum))

(define (contents datum)
  (cdr datum))
```

Example:

```scheme
(attach-tag 'rectangular (cons 3 4))
```

Plain-language view:

```text
tag: rectangular
contents: 3, 4
```

For polar:

```text
tag: polar
contents: magnitude, angle
```

---

## Explicit Dispatch

One way to support multiple representations is explicit dispatch.

Example:

```scheme
(define (real-part z)
  (cond [(eq? (type-tag z) 'rectangular)
         (real-part-rectangular (contents z))]
        [(eq? (type-tag z) 'polar)
         (real-part-polar (contents z))]
        [else
         (error "Unknown type -- REAL-PART" z)]))
```

Plain-language steps:

1. Check the type tag.
2. If it is rectangular, use the rectangular implementation.
3. If it is polar, use the polar implementation.
4. Otherwise report an error.

This works, but it can become hard to maintain.

Problem:

> Adding a new representation may require changing many generic operations.

For example, adding a new complex-number representation may require edits in:

- `real-part`
- `imag-part`
- `magnitude`
- `angle`

This spreads dispatch logic across the system.

---

## Data-Directed Programming

Data-directed programming avoids putting all dispatch logic inside many `cond` expressions.

Instead, it uses a table:

```text
operation + type -> procedure
```

Example table:

| Operation | Type | Procedure |
|---|---|---|
| `real-part` | `rectangular` | `real-part-rectangular` |
| `imag-part` | `rectangular` | `imag-part-rectangular` |
| `magnitude` | `rectangular` | `magnitude-rectangular` |
| `angle` | `rectangular` | `angle-rectangular` |
| `real-part` | `polar` | `real-part-polar` |
| `imag-part` | `polar` | `imag-part-polar` |
| `magnitude` | `polar` | `magnitude-polar` |
| `angle` | `polar` | `angle-polar` |

The system can provide:

```scheme
(put op type proc)
(get op type)
```

Meanings:

- `put`: register a method in the operation table
- `get`: look up a method from the operation table

---

## Apply Generic

A generic operation can use the operation table:

```scheme
(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (error "No method for these types"
                 (list op type-tags))))))
```

Plain-language steps:

1. Get the type tags of all arguments.
2. Use operation name and type tags to look up the right procedure.
3. Strip off the tags and pass the contents to the procedure.
4. If no procedure is found, report an error.

Then:

```scheme
(define (real-part z)
  (apply-generic 'real-part z))
```

This means:

> To compute `real-part`, let `apply-generic` choose the correct implementation based on the type.

---

## Why Data-Directed Style Helps

With explicit dispatch:

> The generic operations must know about every type.

With data-directed programming:

> Each type package registers the operations it supports.

For example, a polar package can register:

```scheme
(put 'real-part '(polar) real-part-polar)
(put 'imag-part '(polar) imag-part-polar)
(put 'magnitude '(polar) magnitude-polar)
(put 'angle '(polar) angle-polar)
```

Adding a new representation becomes more like adding a package, not editing many existing functions.

Real-world analogies:

- handler registry
- strategy map
- plugin registry
- command dispatcher
- operation table
- type-based method lookup

---

## Message Passing

SICP also shows another organization style: message passing.

In message passing:

> The data object receives an operation name and decides how to respond.

Example:

```scheme
(define (make-from-real-imag x y)
  (define (dispatch op)
    (cond [(eq? op 'real-part) x]
          [(eq? op 'imag-part) y]
          [(eq? op 'magnitude)
           (sqrt (+ (square x) (square y)))]
          [(eq? op 'angle)
           (atan y x)]
          [else
           (error "Unknown op" op)]))
  dispatch)
```

Then the complex number is itself a procedure.

You can send it a message:

```scheme
(z 'real-part)
(z 'magnitude)
```

This connects back to earlier ideas:

> Data can be represented by procedures.

---

## Three Organization Styles

### 1. Explicit Dispatch

Use conditionals:

```scheme
if rectangular -> ...
if polar -> ...
```

Simple, but can become hard to extend.

### 2. Data-Directed Programming

Use a table:

```text
operation + type -> procedure
```

Good for registering new types and operations.

### 3. Message Passing

Let the object receive messages:

```scheme
(z 'real-part)
```

The object decides how to respond.

---

## Section Summary

Section 2.4 teaches:

- the same abstraction can have multiple representations
- tags can identify which representation is used
- generic operations hide representation details
- explicit dispatch works but can become hard to extend
- data-directed programming improves extensibility with operation tables
- message passing is another way to organize dispatch

Core lesson:

> A system should separate what an operation means from how each representation implements it.

Next suggested step:

> Continue to Section 2.5: systems with generic operations.

