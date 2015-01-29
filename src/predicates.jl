## extend logical operators so that we can have a notation like

#f(x,y) < 0 or f(x,y) == 0


abstract Predicate

"""

A predicate is defined in terms of a function of two variables, an
inquality, and either another function or a real number.  For example,
`f < 0` or `f >= g`. The one case `f==g` is not defined, as it crosses
up `Gadfly` and other code that compares functions for equality. Use
`eq(f,g)` instead or `f \Equal<tab> g`.

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
Base.(:<)(f::Function, x::Real) = Pred(f, < , x) 
Base.(:<)(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), < , 0)

Base.(:<=)(f::Function, x::Real) = Pred(f, <= , x)
Base.(:<=)(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), <= , 0)

Base.(:(==))(f::Function, x::Real) = Pred(f, == , x)
## ==(f::Function, g::Function) this crosses up Gadfly and others so...
eq(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), == , 0)
## unicode variants
⩵(f::Function, x::Real) =  f == x
⩵(f::Function, g::Function) = eq(f,g)


Base.(:(!=))(f::Function, x::Real) = Pred(f, != , x)
neq(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), != , 0)

≶(x::Real, y::Real) = (x != y)
≶(f::Function, x::Real) = (f != x)
≶(f::Function, g::Function) = neq(f, g)

≷(x::Real, y::Real) = (x != y)
≷(f::Function, x::Real) = (f != x)
≷(f::Function, g::Function) = neq(f, g)






Base.(:>=)(f::Function, x::Real) = Pred(f, >= , x)
Base.(:>=)(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), >= , 0)

Base.(:>)(f::Function, x::Real) = Pred(f, > , x)
Base.(:>)(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), > , 0)

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
Base.(:&)(r1::Pred, r2::Pred) = Preds([r1,r2], Any[&])
Base.(:|)(r1::Pred, r2::Pred) = Preds([r1,r2], Any[|])

Base.(:&)(ps::Preds, r1::Pred) = Preds([ps.ps, r1], [ps.ops, &])
Base.(:&)(r1::Pred, ps::Preds) = ps & r1
Base.(:|)(ps::Preds, r1::Pred) = Preds([ps.ps, r1], [ps.ops, |])
Base.(:|)(r1::Pred, ps::Preds) = ps | r1


