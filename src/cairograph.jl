using ImplicitEquations
using Base.Graphics, Cairo, Gtk
import ValidatedNumerics: diam
import ImplicitEquations: xy_region

function plot_new(W, H)
    w = @GtkWindow()
    c = @GtkCanvas(W, H)
    push!(w, c)
    showall(w)
    c
end


## paint initial area red
function paint_red(ctx, L, R, B, T, W, H)
    #    set_coords(ctx, 0, 0, W, H, L, R, T, B) ## entire area
    set_coords(ctx, 0, 0, W, H, 0, W, H, 0) ## entire area
    set_source_rgb(ctx, 1, 0, 0)            # rgb
    paint(ctx)
end

function paint_region(ctx, u,  L, R, B, T, W, H, how)
    reset_clip(ctx)
#    x,y = xy_region(u, L, R, B, T, W, H)
    #    rectangle(ctx, x.lo, y.lo, diam(x), diam(y))
    rectangle(ctx, u.x.val.lo, u.y.val.lo, diam(u.x.val)-1, diam(u.y.val)-1)
    set_source_rgb(ctx, how...) # how = (1,1,1) or (0,0,0)
    fill_preserve(ctx)
    stroke(ctx)
end

function show_regions(ctx, r, Us, L, R, B, T, W, H)
    for (k,U) in Us
        for u in U[:white]
            paint_region(ctx, u, L, R, B, T, W, H, (1,1,1))
        end
        for u in U[:black]
            paint_region(ctx, u, L, R, B, T, W, H, (0,0,0))
        end
    end
end



function cgraph(r, L=-5, R=5, B=-5, T=5, W=2^7, H=2^7)
    c = plot_new(W,H)
    U = GRAPH(r, L, R, B, T, W, H)

    tmp = (c) -> begin
        ctx = getgc(c)
        paint_red(ctx, L, R, B, T, W, H)
        show_regions(ctx, r, U,  L, R, B, T, W, H)
    end
    c.draw = tmp
    reveal(c)
    U
end