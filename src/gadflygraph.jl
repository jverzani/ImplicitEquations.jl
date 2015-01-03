using Gadfly
using DataFrames
using ImplicitEquations, Docile

cols=[:red=>color("red"), :black=>color("black"), :white=>color("white")]
linterp(A,B,a,b,W) = (a + A/W*(b-a),a + B/W*(b-a))
function gxyrange(u, L, R, B, T, W, H)
    tuple(linterp(u.x.val.lo, u.x.val.hi, L, R, W)...,
          linterp(u.y.val.lo, u.y.val.hi, B, T, H)...)
end


function df_graph(r, L=-5, R=5, B=-5, T=5, W=2^8, H=2^7)
    ## Not sure why these colors don't work now...
    #cols=[:red=>color("red"), :black=>color("black"), :white=>color("white")]

    cols=[:red=>"red", :black=>"black", :white=>"white"]
    
    reds, blacks, whites = ImplicitEquations.GRAPH(r, L, R, B, T, W, H)

    d = DataFrames.DataFrame(x_min=float(L), x_max=float(R), y_min=float(B), y_max=float(T), col=cols[:red])

    for u in whites
        push!(d, tuple(gxyrange(u, L,R,B,T,W,H)..., cols[:white]))
    end
    for u in blacks
        push!(d, tuple(gxyrange(u, L,R,B,T,W,H)..., cols[:black]))
    end

    d
end

@doc """

Function to graph within `Gadfly`.

How to add a layer???
""" ->
function ggraph(r, L=-5, R=5, B=-5, T=5; W=2^8, H=2^7)
    
    d = df_graph(r, L, R, B, T, W, W)
    
    Gadfly.plot(d, x_min=:x_min, x_max=:x_max, y_min=:y_min, y_max=:y_max, color=:col, Geom.rectbin)
end
    
