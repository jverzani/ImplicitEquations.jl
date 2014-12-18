
## extend so that we can have a notation like

#f(x,y) < 0 or f(x,y) == 0

type Pred
    f::Function
    op
    val
end

type Preds
    ps
    ops
end

## Some algebra of pred
Base.(:&)(r1::Pred, r2::Pred) = Preds([r1,r2], Any[&])
Base.(:|)(r1::Pred, r2::Pred) = Preds([r1,r2], Any[|])

Base.(:&)(ps::Preds, r1::Pred) = Preds([ps.ps, r1], [ps.ops, &])
Base.(:&)(r1::Pred, ps::Preds) = ps & r1
Base.(:|)(ps::Preds, r1::Pred) = Preds([ps.ps, r1], [ps.ops, |])
Base.(:|)(r1::Pred, ps::Preds) = ps | r1



## meta this...
Base.(:<)(f::Function, x::Real) = Pred(f, < , x)
Base.(:<)(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), < , 0)

Base.(:<=)(f::Function, x::Real) = Pred(f, <= , x)
Base.(:<=)(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), <= , 0)

Base.(:(==))(f::Function, x::Real) = Pred(f, == , x)
Base.(:(==))(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), == , 0)

Base.(:>=)(f::Function, x::Real) = Pred(f, >= , x)
Base.(:>=)(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), >= , 0)

Base.(:>)(f::Function, x::Real) = Pred(f, > , x)
Base.(:>)(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), > , 0)

Base.(:(!==))(f::Function, x::Real) = Pred(f, !== , x)
Base.(:(!==))(f::Function, g::Function) = Pred((x,y) -> f(x,y) - g(x,y), !== , 0)

Base.isless(x::Real, f::Function) = (f >= x)
Base.isless(f::Function, x::Real) = (f < x)
