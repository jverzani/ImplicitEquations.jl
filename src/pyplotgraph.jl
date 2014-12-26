using PyPlot
using Docile
using ImplicitEquations

linterp(A,B,a,b,W) = (a + A/W*(b-a),a + B/W*(b-a))

function pxyrange(u, L, R, B, T, W, H; offset=1)
    xs = linterp(u.x.val.lo, u.x.val.hi, L, R, W)
    ys = linterp(u.y.val.lo, u.y.val.hi, B, T, H)
    xs, ys
end
    

function padd_rect(xl, xr,yb,yt,col)
    fill_between([xl,xr], [0,0]+yb, [0,0]+yt, color=col)
end



@doc """ 

Function to graph, using `Winston`, a predicate related to a
two-dimensional equation, such as `f == 0` or `f < g`, where `f` and
`g` are functions, e.g., `f(x,y) = y - sqrt(x)`. The positional
arguments are `L`, `R`, `B`, `T` which indicate the x-y range of the 
graph of the equation. The keywork arguments `W` and `H` indicate the number
of pixels to use.

Set `offset=0` to see algorithm

A pixel is important, as the graph will color a pixel

- white if no solution exists in the region indicated by the pixel
- black if a solution is known to exist in the region
- red if a solution _might_ exist

""" ->
function pgraph(r, L=-5, R=5, B=-5, T=5; W=2^9, H=2^8, offset::Int=1)
    cols=[:red=>"red", :black=>"black", :white=>"white"]
    
    red, black, white = ImplicitEquations.GRAPH(r, L, R, B, T, W, H)

    clf()
    p = gcf()
    axis([L,R,B,T])
    padd_rect(L, R, B, T, cols[:red])
    for u in white
       xs, ys = pxyrange(u, L,R,B,T,W,H)
        padd_rect(xs...,ys..., cols[:white])
    end
    for u in black
        xs, ys = pxyrange(u, L,R,B,T,W,H)
        padd_rect(xs...,ys..., cols[:black])
    end
    p
end
