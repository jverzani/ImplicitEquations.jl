## This kinda follows the algorithm laid out in
## http://www.dgp.toronto.edu/people/mooncake/papers/SIGGRAPH2001_Tupper.pdf
## the paper is much more thorough

## Helper function to find initial partition into squares
function fill_bottom(W,H)
    k = min(floor(Integer,log2(W)), floor(Integer, log2(H)))
    rects = Any[] # Array{Int,1}[] #

    ## fill in
    w,h = 0, 2^k

    while (W - w) >= 2^k
        push!(rects, [w+0, w+2^k, 0, 2^k])
        w = w + 2^k
    end

    j= k - 1
    while j > 0
        if (W - w) >= 2^j
            for i in 1:2^(k-j)
                push!(rects, [w+0, w+2^j, (i-1)*2^j, i*2^j])
            end
            w = w + 2^j
        end
        j = j - 1
    end
    rects, h
end

## Helper function to break a rectangle into squares of size 2^j x 2^j
function break_into_squares(W, H)
    rects = Any[] # Array{Int,1}[] #
    offset = 0

    while H - offset > 0
        nrects, h = fill_bottom(W, H-offset)
        nrects = map(u -> [0,0,offset, offset] + u, nrects)
        append!(rects, nrects)
        offset = offset + h
    end
    rects
end


"""
Main algorithm of Tupper.

Break region into square regions
for each square region, subdivide into 4 regions. For each check if there is no solution, if so add to white. Otherwise, refine the region by repeating until we can't subdivide

At that point, check each pixel-by-pixel region for possible values.

Return red, black and white vectors of Regions.
"""
function GRAPH(r, L, R, B, T, W, H)
    rects = break_into_squares(W, H)
    
    k = min(floor(Integer,log2(W)), floor(Integer,log2(H))) # largest square is size 2^k x 2^k

    reds = [Region(OInterval(u[1], u[2]), OInterval(u[3], u[4])) for u in rects]
    sizehint!(reds, W)
    
    red = Region[]         # 1-pixel red, can't decide via check_continuity
    black = Region[]
    white = Region[]

    while (k >= 0) & (length(reds) > 0)
        reds = RefinePixels(r, reds, L, R, B, T, W, H, black, white, red)
        k = k - 1
    end
    red, black, white 
end

## Refine the region
function RefinePixels(r, U_k, L, R, B, T, W, H, black, white, red)
    ## Uk_1 a refinement of U_k which hold red regions
    Uk_1 = Region[]
    for u in U_k
        out = compute(r, u,  L, R, B, T, W, H)
        if out == TRUE
            push!(black, u)
        elseif out == FALSE
            push!(white, u)
        else
            ## subdivide and call again if possible,
            x = u.x.val; y = u.y.val
            dx, dy = diam(x), diam(y)
            if (dx > 1) & (dy > 1)
                hx = div(dx,2); hy = div(dy,2)
                for i in 0:1, j in 0:1
                    uij = Region(OInterval(x.lo + i*hx, x.lo + (i+1)*hx), 
                                      OInterval(y.lo + j*hy, y.lo + (j+1)*hy))
                    push!(Uk_1, uij)
                end
            else
                ## these are red with diameter 1, could be white or black
                val = check_continuity(r, u, L, R, B, T, W, H)
                if val == TRUE
                    push!(black, u)
                elseif val == FALSE
                    push!(white, u)
                else
                    push!(red, u)
                end
            end
        end
    end
    Uk_1
end

## for 1-pixel squares, check NaN and continuity
## Return TRUE (Black), FALSE (white) or MAYBE (red)
function check_continuity(r::Pred, u, L, R, B, T, W, H)
    
    fxy = compute_fxy(r, u,  L, R, B, T, W, H)

    ## check for NaN
    if ValidatedNumerics.isempty(fxy.val)
        return(FALSE)
    end
    if (fxy.def == FALSE) || (fxy.def == MAYBE)
        return(FALSE)
    end
    
    ## now check continuity,
    val = FALSE
    if (fxy.cont == TRUE) && ((r.op === ==) || (r.op === eq) || (r.op === ⩵) || (r.op === <=) || (r.op === >=))
        ## use intermediate value theorem here
        val = val | cross_zero(r, u, L, R, B, T, W, H)
        
    end

    ## Now check for inequalities
    ineqs = [<, <= , ≤, ≶, ≷, ≥, >=, >]
    if (fxy.def == TRUE) && any([r.op === op for op in ineqs])
        ## just check points
        val = val | check_inequality(r, u, L, R, B, T, W, H)
    end

    ## What to do if fxy.cont !== TRUE...
    default = MAYBE
    if val == MAYBE
        return(default)
    else
        return(val)
    end
end

## Return TRUE, FALSE or MAYBE for predicates
function check_continuity(rs::Preds, u, L, R, B, T, W, H)
    vals = map(r -> check_continuity(r, u, L, R, B, T, W, H), rs.ps)
    val = shift!(vals)
    for i in 1:length(rs.ops)
        val = rs.ops[i](val, vals[i])
    end
    val
end
