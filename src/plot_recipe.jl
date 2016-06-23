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


The `plot`ting of a predicate simply plots each block that is knows satisfies the predicate "black" and optionally that is known *not*
to satisfy the predicate "white." Optionally, the ambiguous blocks can be plotted in "red."

For text-base plots, the `asciigraph` function is available.


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

f(x,y)= (y-5)*cos(4*sqrt((x-4)^2 + y^2))
g(x,y) = x*sin(2*sqrt(x^2 + y^2))
r = f < g
plot(r, (-10, 10), (-10, 10), 9, 9, show_red=true)  # (xmin, xmax), (ymin, ymax),
                                                    # n (2^n pixels_wide), m (2^m pixels_high)
```
"""
plot_implicit = nothing


linterp(A,B,a,b,W) = (a + A/W*(b-a),a + B/W*(b-a))

function xyrange(u, L, R, B, T, W, H; offset=0)
    tuple(linterp(u.x.val.lo, u.x.val.hi + offset, L, R, W)...,
          linterp(u.y.val.lo, u.y.val.hi + offset, B, T, H)...)
end

## one way to do this - -but requires Plots to load.
## rect(x0, x1, y0, y1) = Plots.Shape([x0, x1, x1, x0], [y0,y0, y1, y1])
## rs = [rect(ImplicitEquations.xyrange(u, L,R,B,T,W,H)...) for u in r]
## seriescolor --> cols[:red]
## rs


## A plot recipe
## TODO: get keyword arguments!
@recipe function f(p::Predicate, x=(-5,5), y=(-5,5), # should be keyword arguments after here !!!
                   n::Int=8, m::Int=8,               # 9/8 too slow
                   show_red::Bool=true, show_white::Bool=false,
                   cols=Dict(:red=>:red, :black=>:black, :white=>:white)
                   )
    
    L, R = extrema(x)
    B, T = extrema(y)
    
    W = 2^n
    H = 2^m

    r, b, w = ImplicitEquations.GRAPH(p, L, R, B, T, W, H)

    ## could DRY this up
   if show_red & length(r) > 0
       @series begin
           xs = Float64[]
           ys = Float64[]
           for u in r
               x0,x1,y0,y1 = ImplicitEquations.xyrange(u, L,R,B,T,W,H)
               append!(xs, [x0,x1,x1,x0,x0]); push!(xs, NaN)
               append!(ys, [y0,y0,y1,y1,y0]); push!(ys, NaN)
           end
           pop!(xs); pop!(ys)
           x := x
           y := y
           seriestype := :shape
           markercolor := cols[:red]
           markerstrokewidth := 0
       end
   end

   if show_white & length(w) > 0
       @series begin
           xs = Float64[]
           ys = Float64[]
           for u in w
               x0,x1,y0,y1 = ImplicitEquations.xyrange(u, L,R,B,T,W,H)
               append!(xs, [x0,x1,x1,x0,x0]); push!(xs, NaN)
               append!(ys, [y0,y0,y1,y1,y0]); push!(ys, NaN)
           end
           pop!(xs); pop!(ys)
           x := x
           y := y
           seriestype := :shape
           markercolor := cols[:white]
           markerstrokewidth := 0
           
       end
   end
        


    xs = Float64[]
    ys = Float64[]
    for u in b
        x0,x1,y0,y1 = ImplicitEquations.xyrange(u, L,R,B,T,W,H)
        append!(xs, [x0,x1,x1,x0,x0]); push!(xs, NaN)
        append!(ys, [y0,y0,y1,y1,y0]); push!(ys, NaN)
    end
    pop!(xs); pop!(ys)

    seriestype --> :shape
    markercolor := cols[:black]    
    markerstrokewidth --> 0
    x --> xs
    y --> ys
    xlims --> [L, R]
    ylims --> [B, T]
    legend --> false
    ()
    
end


