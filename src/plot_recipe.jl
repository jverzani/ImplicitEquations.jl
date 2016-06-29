## plotting code using Plots


"""

Plotting of implicit functions.

An implicit function or equation is defined in terms of a logical
condition and a function of two variables. These produce `Predicate`
objects.

Predicates may be plotted over a specified region, the default begin [-5,5] x [-5,5].


The algorithm, breaks the region into blocks. The ultimate resolution
is given by `W=2^n` and `H=2^m`. The algorithm used, due to Tupper, colors
region if it knows the predicate is true or false, and otherwise
resolves the region into 4 equal-sized subregions and test each subregion
again to determine if it is true, false, or still maybe. This repeats until `W` and `H`
can't be subdivided.


The `plot`ting of a predicate simply plots each block that is knows satisfies the predicate "black" and each ambiguous block "red." By taking `m` and `n` larger the graphs look less "blocky" but take more time to render.

For text-based plots, the `asciigraph` function is available.


Examples:
```
using Plots, ImplicitEquations
pyplot()

a,b = -1,2
f(x,y) = y^4 - x^4 + a*y^2 + b*x^2
plot(f == 0)

## trident of Newton
c,d,e,h = 1,1,1,1
f(x,y) = x*y
g(x,y) =c*x^3 + d*x^2 + e*x + h
plot(eq(f,g), title="Trident of Newton") ## aka f ⩵ g (using Unicode\Equal[tab])

## inequality
f(x,y)= (y-5)*cos(4*sqrt((x-4)^2 + y^2))
g(x,y) = x*sin(2*sqrt(x^2 + y^2))
r = f < g
plot(r, (-10, 10), (-10, 10), N=9, M=9)  # (xmin, xmax), (ymin, ymax),
```
"""
plot_implicit = nothing

## Helpers to convert 
linterp(A,B,a,b,W) = (a + A/W*(b-a),a + B/W*(b-a))

function xyrange(u, L, R, B, T, W, H; offset=0)
    tuple(linterp(u.x.val.lo, u.x.val.hi + offset, L, R, W)...,
          linterp(u.y.val.lo, u.y.val.hi + offset, B, T, H)...)
end


function get_xs_ys(rs, L, R, B, T, W, H)
    xs = Float64[]
    ys = Float64[]
    for u in rs
        x0,x1,y0,y1 = ImplicitEquations.xyrange(u, L,R,B,T,W,H)
        append!(xs, [x0,x1,x1,x0,x0]); push!(xs, NaN)
        append!(ys, [y0,y0,y1,y1,y0]); push!(ys, NaN)
    end
    pop!(xs); pop!(ys)
    xs, ys
end




## A plot recipe
## x, y describe region to plot over
## N, M give no. of pixels 2^N by 2^M
## red and black are used for colors.
@recipe function f(p::Predicate, x=(-5,5), y=(-5,5);
                   N=8,
                   M=8,              # oddly m as keyword fails. 9/8 too slow
                   red=nothing,      # or :red ...
                   black=:black
                   )
    
    L, R = extrema(x)
    B, T = extrema(y)

    W = 2^N
    H = 2^M

    r, b, w = ImplicitEquations.GRAPH(p, L, R, B, T, W, H)

    ## add red as a series
    if length(r) > 0 && red != nothing
        @series begin
            xs, ys = get_xs_ys(r, L, R, B, T, W, H)
            
            seriestype := :shape
            fillcolor := red
            linewidth := 0
            x := xs
            y := ys
            
            ()
        end
    end

    ## do black
    seriestype --> :shape
    xlims --> [L, R]
    ylims --> [B, T]
    legend --> false

    fillcolor --> black
    linewidth --> 0

    xs, ys = get_xs_ys(b, L, R, B, T, W, H)
    x --> xs
    y --> ys
    
    ()
    
end


