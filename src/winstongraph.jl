using Winston

cols=[:red=>"red", :black=>"black", :white=>"white"]

linterp(A,B,a,b,W) = (a + A/W*(b-a),a + B/W*(b-a))

function xyrange(u, L, R, B, T, W, H)
    tuple(linterp(u.x.val.lo, u.x.val.hi, L, R, W)...,
          linterp(u.y.val.lo, u.y.val.hi, B, T, H)...)
end
    

using Winston
function add_rect(p, xl,xr,yb,yt,col)
    x=[xl,xr]
    y=[0.0, 0.0]
    Winston.add(p, Winston.FillBetween(x,y+yb,x,y+yt, "color", col))
end
function wgraph(r, L=-5, R=5, B=-5, T=5; W=2^8, H=2^7)

    U = GRAPH(r, L, R, B, T, W, H)
    p = FramedPlot()
    add_rect(p, L, R, B, T, cols[:red])
    for (k,v) in U
        for u in v[:white]
            add_rect(p, xyrange(u, L,R,B,T,W,H)..., cols[:white])
        end
        for u in v[:black]
            add_rect(p, xyrange(u, L,R,B,T,W,H)..., cols[:black])
        end
    end

    p
end
