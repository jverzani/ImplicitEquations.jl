## Additions to ValidatedNumerics
isthin(x::Interval) = (m = mid(x); m == x.lo || m == x.hi)


## These are missing in Validated NUmerics
Base.(:>=)(a::Real, i::Interval) = a >= i.hi

Base.(:<=)(a::Real, i::Interval) = a <= i.lo
Base.(:<=)(i::Interval, a::Real) = (a >= i)

Base.(:(==))(a::Real, i::Interval)  = (isthin(i) & (a in i))
Base.(:(==))(i::Interval, a::Real)  = (a == i)

Base.(:(!==))(a::Real, i::Interval) = !(a in i)
Base.(:(!==))(i::Interval, a::Real) = (a !== i)

Base.asin(i::Interval) = ValidatedNumerics.Interval(asin(i.lo), asin(i.hi))
Base.acos(i::Interval) = ValidatedNumerics.Interval(acos(i.lo), acos(i.hi))
Base.atan(i::Interval) = ValidatedNumerics.Interval(atan(i.lo), atan(i.hi))


Base.max(i::Interval, j::Interval) = Interval(max(i.lo,j.lo), max(i.hi,j.hi))
Base.min(i::Interval, j::Interval) = Interval(min(i.lo,j.lo), min(i.hi,j.hi))

# function Base.(:^)(x::Interval, q::Rational)
#     q < 0 && return(1/x^(-q))
#     ## clean up odd denominator
#     if isodd(q.den)
#         val = x^(q.num)
#         val = Interval(sign(val.lo)*abs(val.lo)^(1/q.den), sign(val.hi) * abs(val.hi)^(1/q.den))
#     else
#         ## nothing to salvage by working over Q.
#         return(x^float(q))
#     end
#     val
# end
# Base.sqrt(x::Interval) = x^(1//2)
# Base.cbrt(x::Interval) = x^(1//3)


Base.floor(x::Interval) = Interval(floor(x.lo), floor(x.hi))
Base.ceil(x::Interval) = Interval(ceil(x.lo), ceil(x.hi))

## others...







## A region is two intervals..
type Region
    x                           # Real
    y                           # Real
end
## this is hacky!!! Remove once debugged XXX
function Base.string(u::Region)
    "[$(u.x.val.lo), $(u.x.val.hi)) × [$(u.y.val.lo), $(u.y.val.hi))"
end
Base.display(as::Array{Region,1}) = display(map(string, as))        
call(f::Function, u::Region) = f(u.x, u.y)


## BInterval represents yes (true, true), no (false, false) and maybe (false, true)
immutable BInterval 
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


Base.(:&)(x::BInterval, y::BInterval) = BInterval(x.lo & y.lo, x.hi & y.hi)
Base.(:|)(x::BInterval, y::BInterval) = BInterval(x.lo | y.lo, x.hi | y.hi)



## ...
function negate_op(op)
    op === <   && return(>=)
    op === <=  && return(>)
    op === ==  && return(!==)
    op === !== && return(==)
    op === >=  && return(<)
    op === >   && return(<=)
    op === in  && return((x,y) -> !in(x,y))
end

## OIinterval includes more
type OInterval
    val::Interval
    def::BInterval
    cont::BInterval
end

OInterval(a,b) = OInterval(Interval(a,b), BInterval(true,true), BInterval(true,true))
OInterval(a) = OInterval(a,a)   # thin one..
Base.convert(::Type{OInterval}, i::Interval) = OInterval(i.lo, i.hi)


ValidatedNumerics.diam(x::OInterval) = diam(x.val)

## extend functions for OInterval

##  bypass isless...
## Need to override functions for OInterval
Base.isless(i::OInterval, j::OInterval) = isless(i.val, j.val)

## Logical values for OIntervals return BIntervals (FALSE, MAYBE, TRUE)
Base.(:<)(i::OInterval, a::Real) = BInterval(i.val < a, !(i.val >= a))
Base.(:>=)(a::Real, i::OInterval) = i < a

Base.(:(<=))(i::OInterval, a::Real) = BInterval(i.val <= a, !(i.val > a))
Base.(:>)(a::Real, i::OInterval) = i <= a

Base.(:(==))(i::OInterval, a::Real) = BInterval(i.val == a, !(i.val !== a))
Base.(:(==))(a::Real, i::OInterval) = i == a

function Base.(:(!==))(i::OInterval, a::Real)
    ValidatedNumerics.isempty(i.val) && return FALSE
    !(a ∈ i.val) ? TRUE : MAYBE
end
Base.(:(!==))(a::Real, i::OInterval) = i !== a

Base.(:(>=))(i::OInterval, a::Real) = BInterval(i.val >= a, !(i.val < a))
Base.(:(<))(a::Real, i::OInterval) = i >= a

Base.(:(>))(i::OInterval, a::Real) = BInterval(i.val > a, !(i.val <= a))
Base.(:(<=))(a::Real, i::OInterval) = i <= a


@doc """
    Screen a value using `NaN` values.
    Use as  with `f(x,y) = x*y * screen(x > 0)`

    Also aliased to I_(x>0)

    As an expression like `x::OInterval > 0` is not Boolean, but rather `BInterval`, a simple ternary
    operator use like `x > 0 ? 1 : NaN` won't work.
""" ->
screen(ex) = (ex == FALSE) ? NaN : 1 
const I_ = screen               # indicator function like!

## Functions which are continuous everywhere
## +, -, *, sin, cos, ...
Base.(:+)(x::Real, y::OInterval) = OInterval(x + y.val, y.def, y.cont)
Base.(:+)(y::OInterval, x::Real) = OInterval(x + y.val, y.def, y.cont)
function Base.(:+)(x::OInterval, y::OInterval)
    val = x.val + y.val
    def = x.def & y.def
    cont = x.cont & y.cont
    OInterval(val, def, cont)
end

Base.(:-)(x::Real, y::OInterval) = OInterval(x - y.val, y.def, y.cont)
Base.(:-)(y::OInterval, x::Real) = OInterval(-x + y.val, y.def, y.cont)
function Base.(:-)(x::OInterval, y::OInterval)
    val = x.val - y.val
    def = x.def & y.def
    cont = x.cont & y.cont
    OInterval(val, def, cont)
end
Base.(:-)(x::OInterval) = OInterval(-x.val, x.def, x.cont)

Base.(:*)(x::Real, y::OInterval) = OInterval(x * y.val, y.def, y.cont)
Base.(:*)(y::OInterval, x::Real) = OInterval(x * y.val, y.def, y.cont)
function Base.(:*)(x::OInterval, y::OInterval)
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

function Base.asec(x::OInterval)
    if x < -1
        OInterval(pi + asin(sqrt(x^2 - 1)/x), x.def, x.cont)
    elseif x > 1
        OInterval(asin(sqrt(x^2 - 1) / x), x.def, x.cont)
    else
        ## XXX not right...
    end
end
# Base.csc(x::OInterval) = 1/sin(x)
# Base.tan(x::OInterval) = sin(x)/cos(x)
# Base.cot(x::OInterval) = 1/tan(x)


Base.asinh(x::OInterval) = log(x + sqrt(1 - x^2))
Base.acosh(x::OInterval) = log(x + sqrt(x + 1)*sqrt(x - 1))
##Base.atanh(x::OInterval) = sinh(x)/cosh(x)
Base.asech(x::OInterval) = acosh(1/x)
Base.acsch(x::OInterval) = asinh(1/x)
Base.acoth(x::OInterval) = atanh(1/x)



Base.exp(x::OInterval) = OInterval(exp(x.val), x.def, x.cont)
## discontinous functions

## /
Base.(:/)(x::Real, y::OInterval) = OInterval(x,x)/y
Base.(:/)(x::OInterval, y::Real) = OInterval(x.val/y, x.def, x.cont)
function Base.(:/)(x::OInterval, y::OInterval)
    ## 0 is the issue
    if 0 ∈ y.val
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
Base.log(k::Real, x::OInterval) = log(x)/log(k)

## Powers ^, sqrt, cbrt
Base.(:^)(a::Real, x::OInterval) = exp(x * log(a))

function Base.(:^)(a::OInterval, x::OInterval)
    OInterval(a.val^x.val, x.def, x.cont)
end

## x^n
function Base.(:^)(x::OInterval, n::Integer)
    OInterval(x.val^n, x.def, x.cont)
end

## XXX this isn't right [-1,1]^(1//3) shouldn't be [0,1]
function Base.(:^)(x::OInterval, q::Rational)
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

function Base.(:^)(x::OInterval, r::Real)
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
    

## others


## pixels are [0, W) x [0, H) where (0,0) lower left, (W-1, H-1) upper right
## we assume reg is of the form [a,b) x [c,d)
function xy_region(u, L, R, B, T, W, H)
    px, py = u.x.val,  u.y.val
    a = L + px.lo * (R - L) / W
    b = L + (px.hi) * (R - L) / W
    c = B + py.lo * (T - B) / H
    d = B + (py.hi) * (T - B) / H
    x, y  = OInterval(a,b-sqrt(eps())), OInterval(c,d-sqrt(eps()))
    x, y
end

function compute_fxy(p::Pred, u::Region, L, R, B, T, W, H)
    x, y = xy_region(u, L, R, B, T, W, H)
    p.f(x, y)
end

@doc """
  compute whether predicate holds in a given region. Returns FALSE, TRUE or MAYBE
""" ->
function compute(p::Pred, u::Region, L, R, B, T, W, H)
    
    fxy = compute_fxy(p, u, L, R, B, T, W, H)
    
    ValidatedNumerics.isempty(fxy.val) && return (FALSE & fxy.def)

    if p.op === ==
        return((p.val ∈ fxy.val) ? MAYBE : FALSE)
    elseif negate_op(p.op) === ==
        return((p.val ∈ fxy.val) ? MAYBE : TRUE)
    end

    out = p.op(fxy, p.val)

#    out1 = p.op(fxy, p.val)
#    out2 = negate_op(p.op)(fxy, p.val)

#    out = (out1 != out2 ) ? BInterval(out1, out1) : BInterval(true, false)

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

@doc "Does this function have a zero crossing? Heuristic check" ->
function cross_zero(r::Pred, u::Region, L, R, B, T, W, H)
    x, y = xy_region(u, L, R, B, T, W, H)
    dx, dy = diam(x), diam(y)
    
    n = 10                      # check 10 random points
    λ1s, λ2s = [0.0, 1.0 ,rand(n)], [0.0, 1.0, rand(n)]
    β1s, β2s = [1.0, 0.0, rand(n)], [1.0, 0.0, rand(n)]
    out = Bool[]
    for i in 1:(n+2)
        rx, ry = x.val.lo + λ1s[i]*dx, y.val.lo + λ2s[i] * dy
        sx, sy = x.val.lo + β1s[i]*dx, y.val.lo + β2s[i] * dy
        ll = OInterval(rx), OInterval(ry)
        ur = OInterval(sx), OInterval(sy)
        val = (r.f(ll...) - r.val) * (r.f(ur...) - r.val)
        push!(out, ((val <= 0)==TRUE) ? true : false)
    end
    return (any(out) ? TRUE : FALSE) # MAYBE leaves red, this turns white via FALSE
end



