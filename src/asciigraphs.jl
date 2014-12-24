## ASCII display

cols = [:red=>".", :white=>" ", :black=>"x"]

function irange(u, W, H)
    x, y = u.x.val, u.y.val
    rx = (1 + itrunc(x.lo)):(1 + itrunc(x.hi) - 1)
    ry = (1 + H - itrunc(y.hi)):(1 + H - itrunc(y.lo) - 1)
    rx, ry
end

function asciigraph(r, L=-5, R=5, B=-5, T=5; W=2^4, H=2^4)
    U, black, white = GRAPH(r, L, R, B, T, W, H)
    
    graph = repmat([cols[:red]], H, W)
    for u in white
        r1, r2 = irange(u, W, H)
        graph[r2, r1] = cols[:white]
    end
    for u in black
        r1, r2 = irange(u, W, H)
        graph[r2, r1] = cols[:black]
    end
    
    mat = graph
    for i in 1:size(mat,1)
        println(join(mat[i,:]))
    end
    U
end
            

