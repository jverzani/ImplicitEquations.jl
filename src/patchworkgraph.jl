## patchwork graph

using Patchwork, Patchwork.SVG ## Must load these first!
using ImplicitEquations
using Docile

"""

Function to graph, using `Patchwork`, a predicate related to a
two-variable, real-valued function `f`, such as `f == 0`.

Example:

```
f(x,y) = x^2 + 2y^2
pwgraph((f >= 2) & (f <= 7))
```

Set `offset=0` to see squares comprising algorithm.

Can pass in additional patchwork commands via additional argument. 

"""
function pwgraph(r, L=-5, R=5, B=-5, T=5, pwcmds...; W=2^8, H=2^8, λ=2, offset=1)

    red, black, white = ImplicitEquations.GRAPH(r, L, R, B, T, W, H)


    function drect(r, col="black")
        width, height = ValidatedNumerics.diam(r.x.val), ValidatedNumerics.diam(r.y.val)
        rect(x=λ*r.x.val.lo, y = λ*(H - width - r.y.val.lo),
        width = λ*width+offset,
        height = λ*height+offset,
             fill=col)
    end


    cmds =  [rect(x=0,y=0,width=λ*W,height=λ*H, fill="red")]

    for u in black
        push!(cmds, drect(u, "black"))
    end
    for u in white
        push!(cmds, drect(u, "white"))
    end

    for cmd in pwcmds
        push!(cmds, cmd)
    end
    
    svg(cmds..., width=λ*W, height=λ*H)
end

export pwgraph
