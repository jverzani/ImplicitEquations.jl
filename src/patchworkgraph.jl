## patchwork graph

using Patchwork, Patchwork.SVG
#using ImplicitEquations

@doc """
doc this ...
""" ->
function pwgraph(r, L=-5, R=5, B=-5, T=5, W=2^8, H=2^8; λ=2)
    red, black, white = GRAPH(r, L, R, B, T, W, H)


    function drect(r, col="black")
        width, height = ValidatedNumerics.diam(r.x.val), ValidatedNumerics.diam(r.y.val)
        rect(x=λ*r.x.val.lo, y = λ*(H - width - r.y.val.lo),
        width = λ*width,
        height = λ*height,
             fill=col)
    end


    cmds =  [rect(x=0,y=0,width=λ*W,height=λ*H, fill="red")]

    for u in black
        push!(cmds, drect(u, "black"))
    end
    for u in white
        push!(cmds, drect(u, "white"))
    end

    svg(cmds..., width=λ*W, height=λ*H)
end

export pwgraph
