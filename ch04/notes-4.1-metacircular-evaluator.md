# 4.1 The Metacircular Evaluator

## Main Idea

Chapter 4 is about metalinguistic abstraction.

The central question:

> Can we use Scheme to implement a language?

Section 4.1 builds a metacircular evaluator:

> An evaluator for a Scheme-like language, written in Scheme itself.

This brings together earlier ideas:

- symbolic data from Chapter 2
- environment model from Chapter 3
- procedural abstraction from Chapter 1

---

## Evaluator as Rules

An evaluator is a set of rules for evaluating expressions.

Examples:

```scheme
(+ 1 2)
```

should be treated as procedure application.

```scheme
'(+ 1 2)
```

should be treated as quoted data.

The evaluator must distinguish expression types and apply the correct rule.

---

## `eval`

`eval` is the main dispatcher.

It receives:

```scheme
(eval exp env)
```

Meaning:

> Evaluate expression `exp` in environment `env`.

Its structure is a dispatch over expression types:

```scheme
(define (eval exp env)
  (cond
    [(self-evaluating? exp) exp]
    [(variable? exp) (lookup-variable-value exp env)]
    [(quoted? exp) (text-of-quotation exp)]
    [(assignment? exp) (eval-assignment exp env)]
    [(definition? exp) (eval-definition exp env)]
    [(if? exp) (eval-if exp env)]
    [(lambda? exp)
     (make-procedure (lambda-parameters exp)
                     (lambda-body exp)
                     env)]
    [(begin? exp)
     (eval-sequence (begin-actions exp) env)]
    [(cond? exp)
     (eval (cond->if exp) env)]
    [(application? exp)
     (apply (eval (operator exp) env)
            (list-of-values (operands exp) env))]
    [else
     (error "Unknown expression type -- EVAL" exp)]))
```

Core idea:

> `eval` asks what kind of expression it has, then follows the matching evaluation rule.

---

## Self-Evaluating Expressions

Some expressions evaluate to themselves.

Examples:

```scheme
3
"hello"
```

So:

```scheme
(eval 3 env) ; 3
```

---

## Variables

If the expression is a variable, the evaluator looks it up in the environment.

Example:

```text
x -> 10
```

Then:

```scheme
(eval 'x env) ; 10
```

At the evaluator implementation level, the variable expression is represented as a symbol.

---

## Quote

Quote means:

> Do not evaluate this expression. Return it as data.

Example:

```scheme
'(+ 1 2)
```

does not produce:

```scheme
3
```

It produces the expression as data:

```scheme
(+ 1 2)
```

Important distinction:

```scheme
(+ 1 2)
```

is procedure application.

```scheme
'(+ 1 2)
```

is quoted data.

`quote` cannot be an ordinary procedure, because ordinary procedures evaluate their arguments first. That would destroy the purpose of quote.

---

## Assignment and Definition

Assignment:

```scheme
(set! x 20)
```

Evaluation rule:

1. evaluate the right-hand expression
2. find existing binding for `x`
3. change that binding

Definition:

```scheme
(define x 10)
```

Evaluation rule:

1. evaluate the value expression
2. create or update a binding in the current environment

Procedure definition:

```scheme
(define (square x)
  (* x x))
```

can be treated as shorthand for:

```scheme
(define square
  (lambda (x) (* x x)))
```

---

## If Is a Special Form

Example:

```scheme
(if (= x 0)
    1
    (/ 1 x))
```

If `if` were an ordinary procedure, all arguments would be evaluated before calling it.

If `x = 0`, this would evaluate:

```scheme
(/ 1 0)
```

and cause an error.

But real `if` evaluates only:

1. the predicate
2. the consequent if predicate is true
3. the alternative if predicate is false

So `if` must be a special form.

Core rule:

> Ordinary applications evaluate all operands. Special forms have their own evaluation rules.

---

## Lambda

Evaluating:

```scheme
(lambda (x) (* x x))
```

does not run the body.

It creates a compound procedure object containing:

- parameters
- body
- defining environment

This is how the evaluator implements closures.

---

## Begin

`begin` evaluates expressions in order and returns the last value.

Example:

```scheme
(begin
  (set! x 10)
  (+ x 1))
```

The first expression updates state.

The second expression provides the result.

---

## Cond as a Derived Expression

`cond` can be converted into nested `if`.

Example:

```scheme
(cond [(> x 0) x]
      [(= x 0) 0]
      [else (- x)])
```

can become:

```scheme
(if (> x 0)
    x
    (if (= x 0)
        0
        (- x)))
```

So the evaluator does not need primitive support for `cond`.

It can transform `cond` into `if`, then evaluate the result.

---

## Application

Ordinary procedure application has this shape:

```scheme
(operator operand1 operand2 ...)
```

Examples:

```scheme
(+ 1 2)
(square 5)
```

Evaluation rule:

1. evaluate the operator
2. evaluate the operands
3. apply the resulting procedure to the resulting argument values

For:

```scheme
'(+ 1 2)
```

we have:

```scheme
(operator exp) ; '+
(operands exp) ; '(1 2)
```

---

## `apply`

`apply` receives:

```scheme
(apply procedure arguments)
```

Meaning:

> Apply `procedure` to `arguments`.

It distinguishes two kinds of procedures:

```scheme
(define (apply procedure arguments)
  (cond [(primitive-procedure? procedure)
         (apply-primitive-procedure procedure arguments)]
        [(compound-procedure? procedure)
         (eval-sequence
          (procedure-body procedure)
          (extend-environment
           (procedure-parameters procedure)
           arguments
           (procedure-environment procedure)))]
        [else
         (error "Unknown procedure type -- APPLY" procedure)]))
```

---

## Primitive Procedures

Primitive procedures are provided by the underlying Scheme system.

Examples:

- `+`
- `-`
- `*`
- `/`
- `=`
- `car`
- `cdr`
- `cons`

The evaluator can delegate them to the host Scheme.

---

## Compound Procedures

Compound procedures are user-defined procedures.

Example:

```scheme
(define (square x)
  (* x x))
```

Applying:

```scheme
(square 5)
```

creates a new environment:

```text
x -> 5
```

Then evaluates the body:

```scheme
(* x x)
```

in that environment.

---

## Eval and Apply Mutual Recursion

`eval` and `apply` call each other.

For:

```scheme
(square 5)
```

`eval`:

1. sees an application
2. evaluates `square`
3. evaluates `5`
4. calls `apply`

`apply`:

1. creates an environment
2. evaluates the procedure body
3. calls `eval` on the body

So:

```text
eval -> apply -> eval -> apply -> ...
```

This is the metacircular loop.

---

## Procedure Objects

Compound procedures can be represented as:

```scheme
(list 'procedure parameters body env)
```

Constructor:

```scheme
(define (make-procedure parameters body env)
  (list 'procedure parameters body env))
```

Selectors:

```scheme
(define (procedure-parameters p)
  (cadr p))

(define (procedure-body p)
  (caddr p))

(define (procedure-environment p)
  (cadddr p))
```

This is data abstraction again.

---

## Environment Representation

An environment is a chain of frames.

A frame contains variables and values:

```text
variables: (x y)
values:    (10 20)
```

Frame constructor:

```scheme
(define (make-frame variables values)
  (cons variables values))
```

Selectors:

```scheme
(define (frame-variables frame)
  (car frame))

(define (frame-values frame)
  (cdr frame))
```

Extending an environment:

```scheme
(define (extend-environment vars vals base-env)
  (if (= (length vars) (length vals))
      (cons (make-frame vars vals) base-env)
      ...))
```

This creates a new frame and attaches it in front of the base environment.

---

## Lookup and Set

Variable lookup searches from the current frame outward.

Example:

```text
E1:
  x -> 1

E0:
  x -> 100
  y -> 200
```

Looking up `x` gives:

```text
1
```

because the nearest binding wins.

For:

```scheme
(set! x 9)
```

the evaluator modifies the nearest existing binding:

```text
E1:
  x -> 9

E0:
  x -> 100
  y -> 200
```

---

## Tagged List Predicates

Many expression types can be recognized by their first symbol.

Helper:

```scheme
(define (tagged-list? exp tag)
  (if (pair? exp)
      (eq? (car exp) tag)
      false))
```

Examples:

```scheme
(define (quoted? exp)
  (tagged-list? exp 'quote))

(define (if? exp)
  (tagged-list? exp 'if))

(define (lambda? exp)
  (tagged-list? exp 'lambda))
```

This works because Scheme programs are represented as lists.

Example:

```scheme
'(if (> x 0) x (- x))
```

has:

```scheme
(car exp) ; 'if
```

---

## Expression Selectors

For `if`:

```scheme
(if predicate consequent alternative)
```

Selectors:

```scheme
(define (if-predicate exp)
  (cadr exp))

(define (if-consequent exp)
  (caddr exp))

(define (if-alternative exp)
  (if (not (null? (cdddr exp)))
      (cadddr exp)
      'false))
```

For:

```scheme
'(if (> x 0) x (- x))
```

we have:

```scheme
(cadr exp)  ; '(> x 0)
(caddr exp) ; 'x
```

For applications:

```scheme
(define (operator exp)
  (car exp))

(define (operands exp)
  (cdr exp))
```

For:

```scheme
'(+ 1 2)
```

we have:

```scheme
(operator exp) ; '+
(operands exp) ; '(1 2)
```

---

## List of Values

For ordinary applications, operands must be evaluated before `apply`.

Example:

```scheme
(+ (* 2 3) 4)
```

Operands:

```scheme
((* 2 3) 4)
```

Evaluated values:

```scheme
(6 4)
```

`list-of-values` performs this evaluation:

```scheme
(define (list-of-values exps env)
  (if (no-operands? exps)
      '()
      (cons (eval (first-operand exps) env)
            (list-of-values (rest-operands exps) env))))
```

---

## Driver Loop

An evaluator usually has a REPL:

```text
Read
Eval
Print
Loop
```

SICP's driver loop reads an input expression, evaluates it in the global environment, prints the result, then repeats.

This gives a mini Scheme interpreter.

---

## Derived Expressions

A derived expression is a syntax form that can be transformed into more basic forms.

Examples:

- `cond` can become nested `if`
- `let` can become lambda application

Example:

```scheme
(let ((x 2)
      (y 3))
  (+ x y))
```

can be transformed into:

```scheme
((lambda (x y)
   (+ x y))
 2
 3)
```

Core idea:

> A language can have a small core plus derived syntax.

Real-world analogies:

- `for` can be translated into lower-level loops
- JSX can be translated into function calls
- TypeScript types can be erased to JavaScript
- `async/await` can be translated into promise/state-machine style code

---

## Section Summary

Covered:

- evaluator as rules
- `eval`
- `apply`
- special forms
- ordinary application
- quote
- if
- lambda
- begin
- cond as derived syntax
- compound procedures
- primitive procedures
- environments
- lookup and assignment
- tagged-list expression predicates
- derived expressions such as `let`
- REPL / driver loop

Core lesson:

> A programming language can be implemented as a data-driven evaluator over symbolic expressions and environments.

Next suggested step:

> Continue with 4.1 details or move to 4.2 lazy evaluation.

