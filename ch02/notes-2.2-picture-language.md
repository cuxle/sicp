# 2.2 Picture Language Notes

## Main Idea

The picture language is not mainly about drawing pictures.

It demonstrates an important design idea:

> A system becomes powerful when its combination operations have closure property.

Here, closure property means:

> Combining objects of a kind produces another object of the same kind.

This is different from the closure created by `lambda` remembering its environment.

---

## Painters

A painter can be understood as:

> A procedure that draws something inside a given frame.

The key is that painter operations return painters.

Examples:

```scheme
(beside painter1 painter2)
(below painter1 painter2)
```

Both mean:

```text
painter + painter -> painter
```

So the result can be composed again:

```scheme
(below (beside painter1 painter2)
       painter3)
```

This works because `(beside painter1 painter2)` is still a painter.

---

## Transformations

Painter transformations also return painters:

```scheme
(flip-vert painter)
(flip-horiz painter)
(rotate90 painter)
```

They have this shape:

```text
painter -> painter
```

So they can be used inside other painter combinations:

```scheme
(beside (flip-vert wave)
        (below wave wave))
```

This expression is valid because both arguments to `beside` are painters.

---

## Recursive Splitting

`right-split` recursively builds a more complex painter:

```scheme
(define (right-split painter n)
  (if (= n 0)
      painter
      (let ((smaller (right-split painter (- n 1))))
        (beside painter
                (below smaller smaller)))))
```

Plain-language reading:

- if `n = 0`, return the original painter
- otherwise, build a smaller split
- put the original painter on the left
- put two smaller painters on the right, one above the other

`up-split` is similar, but uses a different direction:

```scheme
(define (up-split painter n)
  (if (= n 0)
      painter
      (let ((smaller (up-split painter (- n 1))))
        (below painter
               (beside smaller smaller)))))
```

Common point:

> Both recursively split a painter into a more complex painter.

Difference:

> `right-split` grows to the right; `up-split` grows upward.

---

## Abstracting Split

The two split procedures have the same structure.

Only the combiners differ:

- `right-split`: outer combiner `beside`, inner combiner `below`
- `up-split`: outer combiner `below`, inner combiner `beside`

So the common pattern can be abstracted:

```scheme
(define (split first-combiner second-combiner)
  (define (rec painter n)
    (if (= n 0)
        painter
        (let ((smaller (rec painter (- n 1))))
          (first-combiner painter
                          (second-combiner smaller smaller)))))
  rec)
```

Then:

```scheme
(define right-split (split beside below))
(define up-split (split below beside))
```

This is the same SICP idea again:

> Find the common pattern, then pass the changing rules as procedures.

---

## Square of Four

`square-of-four` abstracts a four-part layout.

It receives four transformation functions:

```scheme
(define (square-of-four tl tr bl br)
  (lambda (painter)
    (let ((top (beside (tl painter) (tr painter)))
          (bottom (beside (bl painter) (br painter))))
      (below bottom top))))
```

The four arguments are transformation rules:

- `tl`: how to transform the top-left painter
- `tr`: how to transform the top-right painter
- `bl`: how to transform the bottom-left painter
- `br`: how to transform the bottom-right painter

It receives functions instead of four painters because it describes:

> How the same painter should be transformed in four positions.

So:

```scheme
(square-of-four tl tr bl br)
```

returns a procedure. That returned procedure receives the actual painter later.

---

## Summary

The picture language teaches:

- painters are procedures
- painter combinations return painters
- painter transformations return painters
- this closure property supports recursive composition
- high-order procedures can abstract layout patterns

The main lesson:

> Complex structures can be built from simple parts when the combination result has the same interface as the parts.

Next suggested step:

> Continue to Section 2.3: symbolic data.

