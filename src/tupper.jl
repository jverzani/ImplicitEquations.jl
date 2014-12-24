## This kinda follows the algorithm laid out in
## http://www.dgp.toronto.edu/people/mooncake/papers/SIGGRAPH2001_Tupper.pdf
## the paper is much more thorough

function fill_bottom(W,H)
    k = min(ifloor(log2(W)), ifloor(log2(H)))
    rects = Any[]

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
    rects = Any[]
    offset = 0

    while H - offset > 0
        nrects, h = fill_bottom(W, H-offset)
        nrects = map(u -> [0,0,offset, offset] + u, nrects)
        append!(rects, nrects)
        offset = offset + h
    end
    rects
end

function GRAPH(r, L, R, B, T, W, H)
    rects = break_into_squares(W, H)
    
    reds = [Region{Int}(OInterval(u[1], u[2]), OInterval(u[3], u[4])) for u in rects]
    black = Region{Int}[]
    white = Region{Int}[]
    
    k = min(ifloor(log2(W)), ifloor(log2(H))) # largest square is size 2^k x 2^k
    
    while (k >= 0) & (length(reds) > 0)
        reds = RefinePixels(r, reds, L, R, B, T, W, H, black, white)
        k = k - 1
    end

    reds, black, white
end

function RefinePixels(r, U_k, L, R, B, T, W, H, black, white)
    ## Uk_1 a refinement of U_k which hold red regions
    Uk_1 = Region{Int}[]
    for u in U_k
        out = compute(r, u,  L, R, B, T, W, H)
        if out == TRUE
            push!(black, u)
        elseif out == FALSE
            push!(white, u)
        else
            x = u.x.val; y = u.y.val
            dx, dy = diam(x), diam(y)
            if (dx > 1) & (dy > 1)
                hx = div(dx,2); hy = div(dy,2)
                for i in 0:1, j in 0:1
                    uij = Region{Int}(OInterval(x.lo + i*hx, x.lo + (i+1)*hx), 
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
                end
            end
        end
    end
    Uk_1
end

## for 1-pixel squares, check NaN and continuity
## Return TRUE, FALSE or MAYBE
function check_continuity(r::Pred, u, L, R, B, T, W, H)
    
    fxy = compute_fxy(r, u,  L, R, B, T, W, H)

    ## check for NaN
    if ValidatedNumerics.isempty(fxy.val)
        return(FALSE)
    end
    if (fxy.def == FALSE) || (fxy.def == MAYBE)
        return(FALSE)
    end
    
    ## now check continuity, could sample more points. This just does lower left, upper right
    if (fxy.cont == TRUE) && ((r.op === ==) || (r.op === <=) || (r.op === >=))
        ## use intermediate value theorem here
        val = cross_zero(r, u, L, R, B, T, W, H)
        return(val)
        if val == TRUE
            return(val)
        elseif val == FALSE
            return(MAYBE) 
        end
    end
    ## What to do if fxy.cont !== TRUE...
    ## what to do for a default?
    MAYBE ## Maybe
    ##FALSE
end

## Return TRUE, FALSE or MAYBE
function check_continuity(rs::Preds, u, L, R, B, T, W, H)
    vals = map(r -> check_continuity(r, u, L, R, B, T, W, H), rs.ps)
    val = shift!(vals)
    for i in 1:length(rs.ops)
        val = rs.ops[i](val, vals[i])
    end
    val
end
