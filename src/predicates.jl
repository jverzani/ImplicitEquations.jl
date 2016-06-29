## extend logical operators so that we can have a notation like

#f(x,y) < 0 or f(x,y) == 0

import Base: <, <=, ==, !=, !==, >=, >, &, |, !

abstract Predicate

"""

A predicate is defined in terms of a function of two variables, an
inquality, and either another function or a real number.  For example,
`f < 0` or `f >= g`. The case `f==g` and `f != g` are not defined, as doing so crosses
up `Gadfly` and other code that compares functions for equality. Use
`eq(f,g)`  or `f \Equal<tab> g` for equality and `neq(f,g)` or `f \gtrless<tab> g` for not equal.

Available operations to produce predicates:

* `<`
* `<=`, `≤` (`\le<tab>`)
* `==` (`Function == Real`), `eq(f,g)`, `⩵` (`\Equal<tab>`)
* `!==` (`Function != Real`), `neq(f,g)`, `≷` (`\gtrless<tab>`), `≶` (`\lessgtr<tab>`)
* `>=`, `≥` (`\ge<tab>`)
* `>`

To combine predicates, `&` and `|` can be used.

To negate a predicate, `!` is used.

"""
type Pred <: Predicate
    f::Function
    op
    val
end

## meta these
<(f::Function, x::Real) = Pred(f, < , x) 
<(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), < , 0)

<=(f::Function, x::Real) = Pred(f, <= , x)
<=(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), <= , 0)

==(f::Function, x::Real) = Pred(f, == , x)
## ==(f::Function, g::Function) this crosses up Gadfly and others so...
eq(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), == , 0)
## unicode variants
⩵(f::Function, x::Real) =  f == x
⩵(f::Function, g::Function) = eq(f,g)


!=(f::Function, x::Real) = Pred(f, != , x)
neq(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), != , 0)

≶(x::Real, y::Real) = (x != y)
≶(f::Function, x::Real) = (f != x)
≶(f::Function, g::Function) = neq(f, g)

≷(x::Real, y::Real) = (x != y)
≷(f::Function, x::Real) = (f != x)
≷(f::Function, g::Function) = neq(f, g)






>=(f::Function, x::Real) = Pred(f, >= , x)
>=(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), >= , 0)

>(f::Function, x::Real) = Pred(f, > , x)
>(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), > , 0)

Base.isless(x::Real, f::Function) = (f >= x)
Base.isless(f::Function, x::Real) = (f < x)


"""

Predicates can be joined together with either `&` or `|`. Individual
predicates can be negated with `!`. The parsing rules require the
individual predicates to be enclosed with parentheses, as in `(f==0) | (g==0)`.

"""
type Preds <: Predicate
    ps
    ops
end

## Some algebra for Pred and Preds
(&)(r1::Pred, r2::Pred) = Preds([r1,r2], Any[&])
(|)(r1::Pred, r2::Pred) = Preds([r1,r2], Any[|])

(&)(ps::Preds, r1::Pred) = Preds([ps.ps, r1], [ps.ops, &])
(&)(r1::Pred, ps::Preds) = ps & r1
(|)(ps::Preds, r1::Pred) = Preds(vcat(ps.ps, r1), vcat(ps.ops, |))
(|)(r1::Pred, ps::Preds) = ps | r1


