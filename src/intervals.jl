
import Base: <, <=, ==, !==, >=, >,
             &, |, !, ==,
             +, -, *, /, ^

## a few definitionsn for ValidatedNumerics that don't fit in there:
## Validated numerics doesn't define these, as the order ins't a total order 
Base.isless{T<:Real, S<:Real}(i::Interval{T}, j::Interval{S}) = isless(i.hi, j.lo)
<={T<:Real, S<:Real}(i::Interval{T}, j::Interval{S}) = <=(i.hi, j.lo)

#Base.max(i::Interval, j::Interval) = Interval(max(i.lo,j.lo), max(i.hi,j.hi))
#Base.min(i::Interval, j::Interval) = Interval(min(i.lo,j.lo), min(i.hi,j.hi))



## BInterval represents TRUE (true, true), FALSE (false, false) and MAYBE (false, true)
immutable BInterval <: Integer
    lo :: Bool
    hi :: Bool

    function BInterval(a::Bool, b::Bool)
        if a & !b
            a,b=b,a
        end
        new(a, b)
    end
end

const TRUE = BInterval(true, true)
const FALSE = BInterval(false, false)
const MAYBE = BInterval(false, true)

Base.convert(::Type{BInterval}, y::Bool) = y ? TRUE : FALSE
Base.promote_rule(::Type{BInterval}, ::Type{Bool}) = BInterval

(&)(x::BInterval, y::BInterval) = BInterval(x.lo & y.lo, x.hi & y.hi)
(|)(x::BInterval, y::BInterval) = BInterval(x.lo | y.lo, x.hi | y.hi)
(!)(x::BInterval) = BInterval(!x.lo, !x.hi)
==(x::BInterval, y::BInterval) = (x.lo==y.lo)&&(x.hi==y.hi)

## ...
function negate_op(op)
    (op === <)   && return(>=)
    (op === <=)  && return(>)
    (op === ==)  && return(!==)
    (op === !==) && return(==)
    (op === >=)  && return(<)
    (op === >)   && return(<=)
    (op === in)  && return((x,y) -> !in(x,y))
end

## OIinterval includes interval, if defined on interval and if continuous on interval
immutable OInterval <: Real
    val::Interval
    def::BInterval
    cont::BInterval
    OInterval(val, def, cont) = new(val, def, cont)
end

@compat Base.show(io::IO,  o::OInterval)  = print(io, "OInterval: ", o.val, " def=", o.def, " cont=",o.cont)

## some outer constructors...
OInterval{T <: Real, S <: Real}(a::T, b::S) = OInterval(ValidatedNumerics.Interval(a,b), TRUE, TRUE)
OInterval(a::OInterval, b::OInterval) = a === a ? a : error("a is not b?") ## why is this one necessary?
OInterval(a) = OInterval(a,a)   # thin one...
OInterval(i::Interval) = OInterval(i.lo, i.hi)

Base.convert(::Type{OInterval}, i::Interval) = OInterval(i.lo, i.hi)
Base.convert{S<:Real}(::Type{OInterval}, x::S) = OInterval(x)
Base.promote_rule{A<:Real}(::Type{OInterval}, ::Type{A}) = OInterval

## A region is two OIntervals.
immutable Region
    x::OInterval
    y::OInterval
end

## not good for v0.5+
#call(f::Function, u::Region) = f(u.x, u.y)


ValidatedNumerics.diam(x::OInterval) = diam(x.val)

## extend functions for OInterval
## Notice these return BIntervals -- not Bools
##  bypass isless...

<(i::OInterval, j::OInterval)  = i.val <  j.val ? TRUE : (i.val > j.val ? FALSE : MAYBE)
<=(i::OInterval, j::OInterval) = i.val <= j.val ? TRUE : (i.val > j.val ? FALSE : MAYBE)
==(i::OInterval, j::OInterval) =
    if i.val == j.val
        TRUE
    elseif (i < j) == TRUE
        FALSE
    elseif (i > j) == TRUE
        FALSE
    else
        MAYBE
    end
!==(i::OInterval, j::OInterval) = (i < j == TRUE) ? TRUE : ((i > j ==TRUE) ? TRUE : MAYBE)
>=(i::OInterval, j::OInterval) = j < i
>(i::OInterval, j::OInterval) = j <= i


"""

Screen a value using `NaN` values.
Use as  with `f(x,y) = x*y * screen(x > 0)`

Also aliased to I_(x>0)

An expression like `x::OInterval > 0` is not Boolean, but
rather a `BInterval` which allows for a "MAYBE" state. As such, a
simple ternary operator, like `x > 0 ? 1 : NaN` won't work, to screen values.

"""
screen(ex) = (ex == FALSE) ? NaN : 1 
const I_ = screen               # indicator function like!

## Functions which are continuous everywhere
## +, -, *, sin, cos, ...
function +(x::OInterval, y::OInterval)
    val = x.val + y.val
    def = x.def & y.def
    cont = x.cont & y.cont
    OInterval(val, def, cont)
end

function -(x::OInterval, y::OInterval)
    val = x.val - y.val
    def = x.def & y.def
    cont = x.cont & y.cont
    OInterval(val, def, cont)
end
-(x::OInterval) = OInterval(-x.val, x.def, x.cont)

function *(x::OInterval, y::OInterval)
    val = x.val * y.val
    def = x.def & y.def
    cont = x.cont & y.cont
    OInterval(val, def, cont)
end


Base.sin(x::OInterval) = OInterval(sin(x.val), x.def, x.cont)
Base.cos(x::OInterval) = OInterval(cos(x.val), x.def, x.cont)
Base.sec(x::OInterval) = 1/cos(x)
Base.csc(x::OInterval) = 1/sin(x)
Base.tan(x::OInterval) = sin(x)/cos(x)
Base.cot(x::OInterval) = 1/tan(x)

Base.sinh(x::OInterval) = (exp(x) - exp(-x))/2
Base.cosh(x::OInterval) = (exp(x) + exp(-x))/2
Base.sech(x::OInterval) = 1/cosh(x)
Base.csch(x::OInterval) = 1/sinh(x)
Base.tanh(x::OInterval) = sinh(x)/cosh(x)
Base.coth(x::OInterval) = 1/tanh(x)

function Base.asin(x::OInterval)
    if x.val.hi < -1.0 ||  x.val.lo > 1.0  
        OInterval(x.val, FALSE, FALSE)
    elseif (x.val.lo < -1.0) & (x.val.hi > 1.0)
        OInterval(Interval(-pi/2, pi/2), x.def & MAYBE, x.cont)
    elseif x.val.hi > 1
        OInterval(Interval(asin(x.val.lo), pi/2), x.def & MAYBE, x.cont)
    elseif x.val.lo < -1
        OInterval(Interval(-pi/2, asin(x.val.hi)), x.def & MAYBE, x.cont)
    else
        OInterval(asin(x.val), x.def, x.cont)
    end
end
Base.acsc(x::OInterval) = asin(1/x)

function Base.acos(x::OInterval)
    if x.val.lo > 1.0 || x.val.hi < -1.0
        OInterval(x.val, FALSE, FALSE)
    elseif (x.val.lo < -1.0) & (x.val.hi > 1.0)
        OInterval(Interval(-pi/2, pi/2), x.def & MAYBE, x.cont)
    elseif x.val.hi > 1
        OInterval(Interval(acos(x.val.lo), pi/2), x.def & MAYBE, x.cont)
    elseif x.val.lo < -1
        OInterval(Interval(-pi/2, acos(x.val.hi)), x.def & MAYBE, x.cont)
    else
        OInterval(acos(x.val), x.def, x.cont)
    end
end
Base.asec(x::OInterval) = acos(1/x)

Base.atan(x::OInterval) = OInterval(atan(x.val), x.def, x.cont)
Base.acot(x::OInterval) = OInterval(acot(x.val), x.def, x.cont)



Base.asinh(x::OInterval) = log(x + sqrt(1 - x^2))
Base.acosh(x::OInterval) = log(x + sqrt(x + 1)*sqrt(x - 1))
Base.atanh(x::OInterval) = 1/2*(log(1+x) - log(1-x))
Base.asech(x::OInterval) = acosh(1/x)
Base.acsch(x::OInterval) = asinh(1/x)
Base.acoth(x::OInterval) = atanh(1/x)



Base.exp(x::OInterval) = OInterval(exp(x.val), x.def, x.cont)
## discontinous functions

## /
## division is slow
function /(x::OInterval, y::OInterval)
    ## 0 is the issue. 
    if 0.0 ∈ y.val
        ## maybe defined, maybe continuous
        OInterval(x.val/y.val, x.def & MAYBE, x.cont & MAYBE)
    else
        OInterval(x.val/y.val, x.def & y.def, x.cont & y.cont)
    end
end

## log
function Base.log(x::OInterval) 
    if x.val.hi <= 0
        OInterval(x.val, FALSE, FALSE)
    elseif x.val.lo <= 0
        OInterval(log(x.val), BInterval(false, x.def.hi), x.cont)
    else
        OInterval(log(x.val), x.def, x.cont)
    end
end
Base.log(k::Irrational{:e},x::OInterval) = log(x)
Base.log(k::Real, x::OInterval) = log(x)/log(k)

function ^(a::OInterval, x::OInterval)
    OInterval(a.val^x.val, x.def, x.cont)
end

## x^n
function ^(x::OInterval, n::Integer)
    OInterval(x.val^n, x.def, x.cont)
end

## Rational ones can be exact, whereas floating point exponents are not. The main
## example would be `x^(1/3)` and `x^(1//3)`
function ^(x::OInterval, q::Rational)
    q < 0 && return(1/x^(-q))
    ## clean up odd denominator
    if isodd(q.den)
        val = x.val^(q.num)
        val = Interval(sign(val.lo)*abs(val.lo)^(1/q.den), sign(val.hi) * abs(val.hi)^(1/q.den))
    else
        ## nothing to salvage by working over Q.
        return(x^float(q))
    end
    OInterval(val, x.def, x.cont)
end

function ^(x::OInterval, r::Real)
    r < 0 && return(1/x^(-r))
    if x.val.hi < 0
        OInterval(x.val, BInterval(false, false), x.cont)
    elseif x.val.lo < 0
        OInterval(x.val^r, BInterval(false, x.def.hi), x.cont)
    else
        OInterval(x.val^r, x.def, x.cont)
    end
end

Base.sqrt(x::OInterval) = x^(1//2)
Base.cbrt(x::OInterval) = x^(1//3)

## abs, max, min, floor, trunc, ...
Base.abs(x::OInterval) = OInterval(abs(x.val), x.def, x.cont)
function Base.floor(x::OInterval)
    val = floor(x.val)
    def = x.def
    cont = BInterval(x.def.lo & (val.lo == val.hi), x.def.hi)
    OInterval(val, def, cont)
end

function Base.ceil(x::OInterval)
    val = ceil(x.val)
    def = x.def
    cont = BInterval(x.def.lo, (val.lo == val.hi) & x.def.hi)
    OInterval(val, def, cont)
end

Base.max(x::OInterval, y::OInterval) = OInterval(max(x.val, y.val), x.def & y.def, x.cont & y.cont)
Base.min(x::OInterval, y::OInterval) = OInterval(min(x.val, y.val), x.def & y.def, x.cont & y.cont)
    

## others sign, mod, ...
function Base.sign(x::OInterval)
    OInterval(sign(x.val), x.def, x.cont & ((x.val.lo < 0 < x.val.hi) ? MAYBE : TRUE))
end

## pixels are [0, W) x [0, H) where (0,0) lower left, (W-1, H-1) upper right
## we assume reg is of the form [a,b) x [c,d)
## TODO: Should this depend on the operation? f(I) < a should use wider I, f(I) > a should use narrower?
function xy_region(u, L, R, B, T, W, H)
    px, py = u.x.val,  u.y.val
    a = L + px.lo * (R - L) / W
    b = L + (px.hi) * (R - L) / W
    c = B + py.lo * (T - B) / H
    d = B + (py.hi) * (T - B) / H
    delta = sqrt(eps())
    
    x, y  = OInterval(a+(u.x.cont==TRUE)*delta,b-delta), OInterval(c+0*delta,d-delta)
    x, y
end

function compute_fxy(p::Pred, u::Region, L, R, B, T, W, H)
    x, y = xy_region(u, L, R, B, T, W, H)
    p.f(x, y)
end

"""

Compute whether predicate holds in a given region. Returns FALSE, TRUE or MAYBE

"""
function compute(p::Pred, u::Region, L, R, B, T, W, H)
    fxy = compute_fxy(p, u, L, R, B, T, W, H)

    (fxy.def == FALSE) && return (FALSE)
    ValidatedNumerics.isempty(fxy.val) && return (FALSE & fxy.def)

    if p.op === ==
        return((p.val ∈ fxy.val) ? MAYBE : FALSE)
    elseif negate_op(p.op) === ==
        return((p.val ∈ fxy.val) ? MAYBE : TRUE)
    end

    out = p.op(fxy, p.val)

    ## domain tracking
    out & fxy.def
end

## build up answer
function compute(ps::Preds, u::Region, L, R, B, T, W, H)
    vals = [compute(p, u, L, R, B, T, W, H) for p in ps.ps]
    val = shift!(vals)
    for i in 1:length(ps.ops)
        val = ps.ops[i](val, vals[i])
    end
    val
end

"""

Does this function have a zero crossing? Heuristic check.

We return `TRUE` or `MAYBE`. However, that 
leaves some functions showing too much red in the case where there is no zero.

"""
function cross_zero(r::Pred, u::Region, L, R, B, T, W, H)
    x, y = xy_region(u, L, R, B, T, W, H)
    dx, dy = diam(x), diam(y)
    
    n = 20                      # number of random points chosen
    λ1s, λ2s = [0.0; 1.0;rand(n)], [0.0; 1.0; rand(n)]
    β1s, β2s = [1.0; 0.0; rand(n)], [1.0; 0.0; rand(n)]
    for i in 1:(n+2)
        rx, ry = x.val.lo + λ1s[i]*dx, y.val.lo + λ2s[i] * dy
        sx, sy = x.val.lo + β1s[i]*dx, y.val.lo + β2s[i] * dy
        ll = OInterval(rx), OInterval(ry)
        ur = OInterval(sx), OInterval(sy)
        val = (r.f(ll...) - r.val) * (r.f(ur...) - r.val)
        ((val <= 0)==TRUE) && return(TRUE)
    end
    return(MAYBE)              
end


"""

Does this function have a value in the pixel satisfying the inequality? Return `TRUE` or `MAYBE`.

"""
function check_inequality(r::Pred, u::Region, L, R, B, T, W, H)
    x, y = xy_region(u, L, R, B, T, W, H)
    dx, dy = diam(x), diam(y)
    # check 10 random points, here fxy.def == TRUE so we can evaluate function
    n = 10
    λ1s, λ2s = [0.0; 1.0; rand(n)], [0.0; 1.0; rand(n)]
    for i in 1:n
        rx, ry = x.val.lo + λ1s[i]*dx, y.val.lo + λ2s[i] * dy
        if r.op(r.f(rx,ry), r.val)
            return(TRUE)
        end
    end
    return(MAYBE)
end
