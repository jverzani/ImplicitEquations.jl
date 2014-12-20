using Gadfly
using DataFrames

cols=[:red=>"red", :black=>"black", :white=>"white"]
linterp(a,b,A,B,P) = (a + A/W*(b-a),a a + B/W*(b-a))
function xyrange(u, L, R, B, T, W, H)
    tuple(linterp(u.x.val.lo, u.x.val.hi, L, R, W)...,
          linterp(u.y.val.lo, u.y.val.hi, B, T, H)...)
end


function df_graph(r, L=-10, R=10, B=-10, T=10, W=2^8, H=2^7)

    U = GRAPH(r, L, R, B, T, W, H)

    d = DataFrame(x_min=L, x_max=R, y_min=B, y_max=T, col=cols[:red])
    
    for (k, v) in U
        for u in v[:white]
            push!(d, tuple(xyrange(u, L,R,B,T,W,H)..., cols[:white]))
        end
        for u in v[:black]
            push!(d, tuple(xyrange(u, L,R,B,T,W,H)..., col[:black]]))
        end
    end

    d
end


function ggraph(r, L=-10, R=10, B=-10, T=10; W=2^8, H=2^7)

    U = GRAPH(r, L, R, B, T, W, H)

    
    d = DataFrame(x_min=L, x_max=R, y_min=B, y_max=T, col=cols[:red])

    
    for (k, v) in U
        for u in v[:white]
            push!(d, tuple(xyrange(u, L,R,B,T,W,H)..., cols[:white]))
        end
        for u in v[:black]
            push!(d, tuple(xyrange(u, L,R,B,T,W,H)..., col[:black]]))
        end
    end

    plot(d, x_min=:x_min, x_max=:x_max, y_min=:y_min, y_max=:y_max,col=:col, Geom.rectbin)
end
    
