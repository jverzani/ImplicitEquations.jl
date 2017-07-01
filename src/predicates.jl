## extend logical operators so that we can have a notation like

#f(x,y) < 0 or f(x,y) == 0

import Base: <, <=, ==, !=, !==, >=, >
import Base: &, |, !

abstract type Predicate{T} end

"""

A predicate is defined in terms of a function of two variables, an
inequality, and either another function or a real number. 
They are conveniently created by the functions `Lt`, `Le`, `Eq`, `Neq`, `Ge`, and `Gt`. The unicode operators
`≪` (`\ll[tab]`), `≦` (`\leqq[tab]`), `⩵` (`\Equal[tab]`), `≶` (`\lessgtr[tab]`)  or `≷` (`\gtrless[tab]`), `≧` (`\geqq[tab]`), `≫` (`\leqq[tab]`) may also be used.


To combine predicates, `&` and `|` can be used.

To negate a predicate, `!` is used.

"""
struct Pred{T} <: Predicate{T}
    f::Function
    op::Function
    val::T
end
# could metaprogram these, but had issue with Gt and Ge.
"""
    `Lt(f, x)` or `f ≪ x`
    
Create predicate for plotting. 

The operators are `Lt` (≪, \ll[tab]), `Le` (≦ \leqq[tab]), `Ge` (≧ \geqq[tab]), `Gt` (≫ \gg[tab]), 
`Eq` (⩵ \Equal[tab]), or `Neq` (≷ \gtrless[tab] or ≶ \lessgtr[tab]).
"""
Lt(f::Function, x::Real) = Pred(f, <, x)
≪(f::Function, x::Real) = Lt(f, x)
Lt(f::Function, g::Function) = Lt((x,y) -> f(x,y) - g(x,y), 0)
≪(f::Function, g::Function) = Lt(f,g)


"""
    `Le(f, x)` or `f ≦ x`
    
Create predicate for plotting. 

The operators are `Lt` (≪, \ll[tab]), `Le` (≦ \leqq[tab]), `Ge` (≧ \geqq[tab]), `Gt` (≫ \gg[tab]), 
`Eq` (⩵ \Equal[tab]), or `Neq` (≷ \gtrless[tab] or ≶ \lessgtr[tab]).
"""
Le(f::Function, x::Real) = Pred(f, <=, x)
≦(f::Function, x::Real) = Le(f, x)
Le(f::Function, g::Function) = Le((x,y) -> f(x,y) - g(x,y), 0)
≦(f::Function, g::Function) = Le(f,g)

"""
    `Eq(f, x)` or `f ⩵ x`
    
Create predicate for plotting. 

The operators are `Lt` (≪, \ll[tab]), `Le` (≦ \leqq[tab]), `Ge` (≧ \geqq[tab]), `Gt` (≫ \gg[tab]), 
`Eq` (⩵ \Equal[tab]), or `Neq` (≷ \gtrless[tab] or ≶ \lessgtr[tab]).
"""
Eq(f::Function, x::Real) = Pred(f, ==, x)
⩵(f::Function, x::Real) = Eq(f, x)
Eq(f::Function, g::Function) = Eq((x,y) -> f(x,y) - g(x,y), 0)
⩵(f::Function, g::Function) = Eq(f,g)

"""
    `Ge(f, x)` or `f ≧ x`
    
Create predicate for plotting. 

The operators are `Lt` (≪, \ll[tab]), `Le` (≦ \leqq[tab]), `Ge` (≧ \geqq[tab]), `Gt` (≫ \gg[tab]), 
`Eq` (⩵ \Equal[tab]), or `Neq` (≷ \gtrless[tab] or ≶ \lessgtr[tab]).
"""
Ge(f::Function, x::Real) = Le((x,y) -> -f(x,y), -x)
≧(f::Function, x::Real) = Ge(f, x)
Ge(f::Function, g::Function) = Ge((x,y) -> f(x,y) - g(x,y), 0)
≧(f::Function, g::Function) = Ge(f,g)


"""
    `Gt(f, x)` or `f ≫ x`
    
Create predicate for plotting. 

The operators are `Lt` (≪, \ll[tab]), `Le` (≦ \leqq[tab]), `Ge` (≧ \geqq[tab]), `Gt` (≫ \gg[tab]), 
`Eq` (⩵ \Equal[tab]), or `Neq` (≷ \gtrless[tab] or ≶ \lessgtr[tab]).
"""
Gt(f::Function, x::Real) = Lt((x,y) -> -f(x,y), -x)
≫(f::Function, x::Real) = Gt(f, x)
Gt(f::Function, g::Function) = Gt((x,y) -> f(x,y) - g(x,y), 0)
≫(f::Function, g::Function) = Gt(f,g)





Neq(f::Function, x::Real) = Pred(f, != , x)
Neq(f::Function, g::Function) = Neq((x,y) -> f(x,y) - g(x,y), 0)

≶(x::Real, y::Real) = (x != y)
≶(f::Function, x::Real) = Neq(f, x)
≶(f::Function, g::Function) = Neq(f, g)

≷(x::Real, y::Real) = (x != y)
≷(f::Function, x::Real) = Neq(f, x)
≷(f::Function, g::Function) = Neq(f, g)





## Type piracy; remove
# >=(f::Function, x::Real) = Pred(f, >= , x)
# >=(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), >= , 0)

# >(f::Function, x::Real) = Pred(f, > , x)
# >(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), > , 0)

# Base.isless(x::Real, f::Function) = (f >= x)
# Base.isless(f::Function, x::Real) = (f < x)


"""

Predicates can be joined together with either `&` or `|`. Individual
predicates can be negated with `!`. The parsing rules require the
individual predicates to be enclosed with parentheses, as in `(f==0) | (g==0)`.

"""
struct Preds{T} <: Predicate{T}
    ps::Vector
    ops::Vector
end

## Some algebra for Pred and Preds
(&)(r1::Pred{T}, r2::Pred{T}) where {T} = Preds{T}([r1,r2], Any[&])
(|)(r1::Pred{T}, r2::Pred{T}) where {T} = Preds{T}([r1,r2], Any[|])

(&)(ps::Preds{T}, r1::Pred{T}) where {T} = Preds{T}([ps.ps, r1], [ps.ops, &])
(&)(r1::Pred, ps::Preds) = ps & r1
(|)(ps::Preds{T}, r1::Pred{T}) where {T} = Preds{T}(vcat(ps.ps, r1), vcat(ps.ops, |))
(|)(r1::Pred, ps::Preds) = ps | r1


