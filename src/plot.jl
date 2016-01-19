## plotting code using Plots


linterp(A,B,a,b,W) = (a + A/W*(b-a),a + B/W*(b-a))

function xyrange(u, L, R, B, T, W, H; offset=0)
    tuple(linterp(u.x.val.lo, u.x.val.hi + offset, L, R, W)...,
          linterp(u.y.val.lo, u.y.val.hi + offset, B, T, H)...)
end


## show_vals draws in the pixels for given color
## It has a generic fallback using Plots, but the backend specific calls can be much faster

## calling fill_beween is about 10 times faster than rect!
function show_vals(plt::Plots.Plot{Plots.PyPlotPackage}, vals, L,R,B,T,W,H, col, offset=1)
    for u in vals
        x0, x1, y0, y1 = xyrange(u, L,R,B,T,W,H, offset=offset)
        PyPlot.fill_between([x0,x1], [0,0]+y0, [0,0]+y1, color=col)
    end
end

## about 3 times faster than Plots.jl generic fallback, but Geom.rectbin isn't right
## function show_vals(plt::Union{Plots.Plot{Plots.ImmersePackage},Plots.Plot{Plots.GadflyPackage}},
##                    vals, L,R,B,T,W,H, col, offset=1)
##     eval(Expr(:using, :DataFrames))
    
##     d = DataFrames.DataFrame(x_min=float(L), x_max=float(R), y_min=float(B), y_max=float(T), col=col)
    
##     for u in vals
##         push!(d, tuple(xyrange(u, L,R,B,T,W,H, offset=offset)..., col))
##     end
##     layers = Gadfly.layer(d,
##                           xmin=:x_min, xmax=:x_max, ymin=:y_min, ymax=:y_max,
##                           x=:x_min, y=:y_min,
##                           Gadfly.Theme(default_color=parse(Gadfly.Colorant, string(col))),
##                           Gadfly.Geom.rectbin)
##     for layer in layers
##         push!(plt.o[2], layer)
##     end
## end

"""
Plot a filled in rectangle using Plots
"""
function rect!(plt, x,y,w=1,h=1; color=:blue, alpha=0.5)
    plot!(plt, [x,x+w], [y+h, y+h], fillrange=y, color=color, fillalpha=alpha)
end

function show_vals(plt, vals, L,R,B,T,W,H, col, offset=1)
    for u in vals
        x0, x1, y0, y1 = xyrange(u, L,R,B,T,W,H, offset=offset)
        rect!(plt, x0, y0, x1-x0, y1-y0, color=col)
    end
end


"""

Plotting of implicit functions.

An implicit function or equation is defined in terms of a logical
condition and a function of two variables. These produce `Predicate`
objects.

This function allows their plotting over a specified region.

The algorithm, breaks the region into blocks. The ultimate resolution
is given by `W` and `H`. The algorithm used, due to Tupper, colors
region if it knows the predicate is true or false, and otherwise
resolves the region into 4 equal-sized subregions and test each subregion
again to determine if it is true, false, or still maybe.

This function calls the `plot` function from the `Plots` package. To
specify which backend plotting package is used, you can do so after
loading Plots, or qualifying the backend, as with:
`Plots.immerse()`. For unicode plots, the `asciigraph` function is
used.


Examples:
```
using ImplicitEquations
Plots.immerse()   # faster  then pyplot

a,b = -1,2
f(x,y) = y^4 - x^4 + a*y^2 + b*x^2
plot(f == 0)

## trident of Newton
c,d,e,h = 1,1,1,1
f(x,y) = x*y
g(x,y) =c*x^3 + d*x^2 + e*x + h
plot(eq(f,g), title="Trident of Newton") ## aka f ⩵ g (using Unicode\Equal[tab])

f(x,y)= (y-5)*cos(4*sqrt((x-4)^2 + y^2))
g(x,y) = x*sin(2*sqrt(x^2 + y^2))
r = f < g
plot(r, (:x, -10, 10), (:y, -10, 10), W=2^9, H=2^9, show_red=true)  # ([label], xmin, xmax), ([label],ymin, ymax),
                                                                    # W=pixels_wide, H=pixels_high
```

"""
function Plots.plot(p::Predicate,
                    x=(:x, -5, 5),
                    y=(:y, -5, 5);
                    W=2^8, H=2^7,
                    title="",
                    offset::Int=0,
                    cols=Dict(:red=>:red, :black=>:black, :white=>:white),
                    show_red::Bool=false,
                    kwargs...)

    plt=Plots.plot(title = title, legend=false)
    
    if length(x) > 2
        xlabel = x[1]
        x = x[2:3]
        plot!(plt, xlabel=string(xlabel))
    end
    L,R = x
    
    if length(y) > 2
        ylabel = y[1]
        y=y[2:3]
        plot!(plt, ylabel=string(ylabel))
    end
    B, T = y
    
    if isa(plt, Plots.Plot{Plots.UnicodePlotsPackage})
        warn("Plotting with the `UnicodePlots` backend, just calls `asciigraph`")
        return(asciigraph(p, L, R, B, T,W=W,H=H))
    end

    plot!(xlim=(L,R), ylim=(B, T))
    
    red, black, white = GRAPH(p, L, R, B, T, W, H)
    show_red && show_vals(plt, red, L,R,B,T,W,H, cols[:red], offset)
    show_vals(plt, white,  L,R,B,T,W,H, cols[:white], offset)
    show_vals(plt, black,  L,R,B,T,W,H, cols[:black], offset)
    
    plt
end
