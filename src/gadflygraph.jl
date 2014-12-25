using Gadfly
using DataFrames

cols=[:red=>"red", :black=>"black", :white=>"white"]
linterp(A,B,a,b,W) = (a + A/W*(b-a),a + B/W*(b-a))
function xyrange(u, L, R, B, T, W, H)
    tuple(linterp(u.x.val.lo, u.x.val.hi, L, R, W)...,
          linterp(u.y.val.lo, u.y.val.hi, B, T, H)...)
end


function df_graph(r, L=-10, R=10, B=-10, T=10, W=2^8, H=2^7)

    reds, blacks, whites = ImplicitEquations.GRAPH(r, L, R, B, T, W, H)

    d = DataFrames.DataFrame(x_min=float(L), x_max=float(R), y_min=float(B), y_max=float(T), col=cols[:red])
    
    for u in whites
        push!(d, tuple(xyrange(u, L,R,B,T,W,H)..., cols[:white]))
    end
    for u in blacks
        push!(d, tuple(xyrange(u, L,R,B,T,W,H)..., cols[:black]))
    end

    d
end


function ggraph(r, L=-10, R=10, B=-10, T=10; W=2^8, H=2^7)

    
    d = df_graph(r, L, R, B, T, W, W)
    
    plot(d, x_min=:x_min, x_max=:x_max, y_min=:y_min, y_max=:y_max,color=:col, Geom.rectbin)
end
    
