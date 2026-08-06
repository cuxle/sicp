# 2.5 Systems with Generic Operations

## Main Idea

Section 2.5 extends the ideas from Section 2.4.

Section 2.4:

> One abstract data type can have multiple representations.

Example:

- complex numbers in rectangular form
- complex numbers in polar form

Section 2.5:

> A whole system can contain many different data types that need to work together.

Example generic operation:

```scheme
(add x y)
```

This might mean:

- integer + integer
- rational + rational
- complex + complex
- integer + rational
- rational + complex

The system must decide which concrete operation to use.

---

## Generic Operations

The user wants a single operation name:

```scheme
(add x y)
(mul x y)
(sub x y)
(div x y)
```

Instead of many type-specific names:

```scheme
add-integer
add-rational
add-complex
```

A generic operation can be defined as:

```scheme
(define (add x y)
  (apply-generic 'add x y))
```

Then `apply-generic` uses the type tags of `x` and `y` to find the right implementation.

Example:

```scheme
(add rational1 rational2)
```

should look up:

```text
operation: add
types: (rational rational)
```

or:

```scheme
(get 'add '(rational rational))
```

---

## Operation Table

The system can use a table:

| Operation | Type Combination | Procedure |
|---|---|---|
| `add` | `(integer integer)` | integer addition |
| `add` | `(rational rational)` | rational addition |
| `add` | `(complex complex)` | complex addition |
| `mul` | `(integer integer)` | integer multiplication |
| `mul` | `(rational rational)` | rational multiplication |
| `mul` | `(complex complex)` | complex multiplication |

This is the same data-directed idea from Section 2.4.

Plain-language rule:

> Operation name + type tags determine the concrete procedure.

---

## Type Packages

A type package contains:

- internal representation
- constructors
- selectors
- type-specific operations
- registrations into the operation table

Example rational package responsibilities:

- construct rational numbers
- get numerator and denominator
- add rational numbers
- multiply rational numbers
- register rational operations

Example registration:

```scheme
(put 'add '(rational rational)
     (lambda (x y)
       (tag (add-rat x y))))
```

Why use `tag`?

> The result must be re-tagged so the generic system can recognize it later.

If `add-rat` returned a raw pair such as `(cons 5 6)`, then later generic operations would not know it is a rational number.

So the result should be returned as tagged rational data.

---

## Mixed-Type Operations

If both arguments have the same type:

```scheme
(add rational rational)
```

the system can directly look up:

```text
add + (rational rational)
```

But if arguments have different types:

```scheme
(add integer rational)
```

there may be no direct operation for:

```text
add + (integer rational)
```

One solution is coercion, or type conversion.

Example:

```text
integer -> rational
```

Then:

```text
(add integer rational)
-> convert integer to rational
-> (add rational rational)
-> use rational addition
```

Example:

```text
3 + 1/2
-> 3/1 + 1/2
-> 7/2
```

---

## Type Tower

SICP discusses a hierarchy of numeric types:

```text
integer -> rational -> real -> complex
```

Plain-language meaning:

- an integer can be viewed as a rational number
- a rational number can be viewed as a real number
- a real number can be viewed as a complex number

Example:

```text
3
-> 3/1
-> 3.0
-> 3 + 0i
```

This lets the system raise lower-level types to higher-level types.

---

## Raise, Project, and Drop

### Raise

`raise` moves a value upward in the type tower.

Example:

```text
integer -> rational
rational -> real
real -> complex
```

This usually preserves information.

### Project

`project` tries to move a value downward.

Example:

```text
complex -> real
real -> rational
rational -> integer
```

This can lose information, so it must be done carefully.

### Drop

`drop` tries to simplify a result to the lowest safe type.

Example:

```text
3 + 0i -> 3
4/2 -> 2
```

But:

```text
3 + 4i
```

cannot safely become a real number, because the imaginary part would be lost.

Core rule:

> Raising is usually safe. Lowering must prove that no information is lost.

---

## Why Complex Cannot Always Become Real

A complex number can contain more information than a real number.

Example:

```text
3 + 4i
```

If it were forced into a real number, the imaginary part `4i` would be lost.

Only values like:

```text
3 + 0i
```

can safely become real numbers.

This is the same idea as real-world data conversion:

- `int -> decimal` is usually safe
- `decimal -> int` may lose fractional data
- rich object -> simple DTO may lose fields

---

## Polynomials

The second half of Section 2.5 uses polynomials as a larger example.

Example polynomial:

```text
3x^2 + 2x + 5
```

It has terms.

Each term has:

- order: exponent
- coefficient

Examples:

```text
3x^2 -> order 2, coefficient 3
2x   -> order 1, coefficient 2
5    -> order 0, coefficient 5
```

Term representation:

```text
(order, coefficient)
```

So:

```text
3x^2 + 2x + 5
```

can be represented as:

```text
(2, 3), (1, 2), (0, 5)
```

---

## Polynomial Interface

Terms should have constructors and selectors:

```scheme
(make-term order coeff)
(order term)
(coeff term)
```

A polynomial can be understood as:

```text
variable + term list
```

Selectors:

```scheme
(variable poly)
(term-list poly)
```

Constructor:

```scheme
(make-poly variable term-list)
```

Example:

```text
3x^2 + 2x + 5
```

has:

```text
variable: x
term list: (2,3), (1,2), (0,5)
```

Important:

```text
3x^2 + 2x + 5
```

and:

```text
3y^2 + 2y + 5
```

are not the same polynomial, because their variables differ.

---

## Sparse and Dense Representations

Polynomials can have different representations.

### Dense Representation

Store every coefficient, including zero coefficients.

Example:

```text
3x^2 + 0x + 5
```

could be:

```text
[3, 0, 5]
```

Good when most terms are present.

### Sparse Representation

Store only nonzero terms.

Example:

```text
3x^2 + 5
```

could be:

```text
(2, 3), (0, 5)
```

Good when many coefficients are zero.

This mirrors the complex-number lesson:

> The same abstraction can have multiple useful representations.

---

## Polynomial Addition

Polynomial addition combines terms with the same order.

Example:

```text
poly1 = 3x^2 + 2x + 5
poly2 = x^2 + 4
```

Term lists:

```text
poly1: (2,3), (1,2), (0,5)
poly2: (2,1), (0,4)
```

Add same-order terms:

```text
3x^2 + x^2 = 4x^2
2x has no matching term, keep it
5 + 4 = 9
```

Result:

```text
4x^2 + 2x + 9
```

Term list:

```text
(2,4), (1,2), (0,9)
```

Polynomial addition is like merging two ordered lists.

---

## Addition Practice Example

Input:

```text
poly1: (3,2), (1,5)
poly2: (2,4), (1,6), (0,7)
```

Result:

```text
(3,2), (2,4), (1,11), (0,7)
```

Reason:

```text
order 3: 2
order 2: 4
order 1: 5 + 6 = 11
order 0: 7
```

---

## Polynomial Multiplication

Polynomial multiplication:

> Multiply every term by every term, then combine terms with the same order.

Example:

```text
(2x + 3) * (x + 4)
```

Expansion:

```text
2x * x = 2x^2
2x * 4 = 8x
3 * x = 3x
3 * 4 = 12
```

Combine like terms:

```text
2x^2 + 11x + 12
```

Term multiplication rule:

```text
(order1, coeff1) * (order2, coeff2)
= (order1 + order2, coeff1 * coeff2)
```

Example:

```text
(2,3) * (1,4) = (3,12)
```

because:

```text
3x^2 * 4x = 12x^3
```

---

## Coefficients Can Be Generic

Polynomial coefficients do not have to be plain integers.

They can be:

- integers
- rational numbers
- real numbers
- complex numbers
- even other polynomials

Example:

```text
(3 + 4i)x^2 + (1/2)x + 5
```

If the numeric system already has generic operations:

```scheme
(add c1 c2)
(mul c1 c2)
```

then polynomial operations can use those generic operations for coefficients.

This creates layers:

```text
generic add
  -> polynomial add
      -> term-list add
          -> coefficient add
              -> integer/rational/complex add
```

Each layer works through its own abstraction.

---

## Section Summary

Section 2.5 teaches how to build a system of generic operations.

Covered:

- generic arithmetic operations
- type packages
- operation table
- re-tagging results
- mixed-type operations
- coercion
- type tower
- `raise`, `project`, and `drop`
- polynomials as a generic type
- sparse and dense polynomial representations
- polynomial addition
- polynomial multiplication
- generic coefficients

Core lesson:

> A large generic system is built by combining tagged data, operation dispatch, type conversion, and abstraction barriers.

Next suggested step:

> Review Chapter 2, then decide whether to do selected exercises or start Chapter 3: Modularity, Objects, and State.

