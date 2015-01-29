## use Winston graphics to display a graph
using Winston

linterp(A,B,a,b,W) = (a + A/W*(b-a),a + B/W*(b-a))

function wxyrange(u, L, R, B, T, W, H; offset=1)
    tuple(linterp(u.x.val.lo, u.x.val.hi + offset, L, R, W)...,
          linterp(u.y.val.lo, u.y.val.hi + offset, B, T, H)...)
end
    

function add_rect(p, xl,xr,yb,yt,col)
    x=[xl,xr]
    y=[0.0, 0.0]
    Winston.add(p, Winston.FillBetween(x,y+yb,x,y+yt, "color", col))
end



""" 

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

"""
function wgraph(r, L=-5, R=5, B=-5, T=5; W=2^9, H=2^8, offset::Int=1)
    cols=[:red=>"red", :black=>"black", :white=>"white"]
    
    red, black, white = GRAPH(r, L, R, B, T, W, H)
    p = FramedPlot()
    add_rect(p, L + offset, R, B + offset, T, cols[:red])
    for u in white
        add_rect(p, wxyrange(u, L,R,B,T,W,H, offset=offset)..., cols[:white])
    end
    for u in black
        add_rect(p, wxyrange(u, L,R,B,T,W,H, offset=offset)..., cols[:black])
    end

    p
end

