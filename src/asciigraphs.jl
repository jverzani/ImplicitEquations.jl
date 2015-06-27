## ASCII display



function irange(u, W, H)
    x, y = u.x.val, u.y.val
    rx = (1 + trunc(Integer, x.lo)):(1 + trunc(Integer, x.hi) - 1)
    ry = (1 + H - trunc(Integer, y.hi)):(1 + H - trunc(Integer, y.lo) - 1)
    rx, ry
end


""" 

Function to graph, using ascii characters, a predicate related to a
two-dimensional equation, such as `f == 0` or `f < g`, where `f` and
`g` are functions, e.g., `f(x,y) = y - sqrt(x)`. The positional
arguments are `L`, `R`, `B`, `T` which indicate the x-y range of the 
graph of the equation. The keywork arguments `W` and `H` indicate the number
of pixels to use.

Set `offset=0` to see algorithm

A pixel is important, as the graph will color a pixel

- "white" (e.g., " ") if no solution exists in the region indicated by the pixel
- "black" (e.g., "x") if a solution is known to exist in the region
- "red" (e.g. ".") if a solution _might_ exist

"""
function asciigraph(r, L=-5, R=5, B=-5, T=5; W=2^4, H=2^4)

    cols = Dict()
    cols[:red]="."; cols[:white]=" ";cols[:black]="x"
    
    red, black, white = GRAPH(r, L, R, B, T, W, H)
    
    graph = repmat([:red], H, W)
    for u in white
        r1, r2 = irange(u, W, H)
        graph[r2, r1] = :white
    end
    for u in black
        r1, r2 = irange(u, W, H)
        graph[r2, r1] = :black
    end
    
    mat = graph
    m,n = size(mat)
    for i in 1:m
        for j in 1:n
            print(cols[mat[i,j]])
        end
        print("\n")
    end
end
            

