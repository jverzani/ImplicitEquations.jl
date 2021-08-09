## extend logical operators so that we can have a notation like

#f(x,y) < 0 or f(x,y) == 0

#import Base: <, <=, ==, !=, !==, >=, >
import Base: &, |, !

abstract type Predicate end

"""

A predicate is defined in terms of a function of two variables, an
inquality, and either another function or a real number.  They are
conveniently created by the functions `Lt`, `Le`, `Eq`, `Ne`, `Ge`,
and `Gt`. The equivalent unicode operators:

* `≪` (`\\ll[tab]`),
* `≦` (`\\leqq[tab]`),
* `⩵` (`\\Equal[tab]`),
* `≶` (`\\lessgtr[tab]`)  or `≷` (`\\gtrless[tab]`),
* `≧` (`\\geqq[tab]`),
* `≫` (`\\leqq[tab]`) may also be used.

The use of Julia's usual comparison operators is no longer supported.

To combine predicates, `&` and `|` can be used.

To negate a predicate, `!` is used.

"""
mutable struct Pred <: Predicate
    f
    op
    val
end


## meta these
preds = [(:Lt, :≪, :<), # \ll
         (:Le, :≦, :<=), # \leqq
         (:Eq, :⩵, :(==)), # \Equal
         (:Ge, :≧, :>=), # \gegg
         (:Gt, :≫, :>) # \gg
         ]


    # type piracy of CommonEq
    for (fn,uop, op) ∈ (
        (:Lt, :≪, :<), # \ll
        (:Le, :≦, :<=), # \leqq
        (:Eq, :⩵, :(==)), # \Equal
        (:Ge, :≧, :>=), # \gegg
        (:Gt, :≫, :>) # \gg
    )
    fnname =  string(fn)
    @eval begin
        (CommonEq.$fn)(f::Function, x::Real) = Pred(f, $op, x)
        (CommonEq.$fn)(f::Function, g::Function) = $(fn)((x,y) -> f(x,y) - g(x,y), 0)
    end
    eval(Expr(:export, fn))
end

CommonEq.Ne(f::Function, x::Real) = Pred(f, !== , x)
CommonEq.Ne(f::Function, g::Function) = Ne((x,y) -> f(x,y) - g(x,y), 0)
const Neq = Ne # deprecate Neq





"""

Predicates can be joined together with either `&` or `|`. Individual
predicates can be negated with `!`. The parsing rules require the
individual predicates to be enclosed with parentheses, as in `(f==0) | (g==0)`.

"""
mutable struct Preds <: Predicate
    ps
    ops
end

## Some algebra for Pred and Preds
(&)(r1::Pred, r2::Pred) = Preds([r1,r2], Any[&])
(|)(r1::Pred, r2::Pred) = Preds([r1,r2], Any[|])

(&)(ps::Preds, r1::Pred) = Preds(vcat(ps.ps, r1), vcat(ps.ops, &))
(&)(r1::Pred, ps::Preds) = ps & r1
(|)(ps::Preds, r1::Pred) = Preds(vcat(ps.ps, r1), vcat(ps.ops, |))
(|)(r1::Pred, ps::Preds) = ps | r1
