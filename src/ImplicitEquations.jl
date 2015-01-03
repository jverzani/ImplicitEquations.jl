module ImplicitEquations


using ValidatedNumerics
using Jewel

using Docile
@docstrings

import ValidatedNumerics: Interval, diam



include("predicates.jl")
include("intervals.jl")
include("tupper.jl")
include("asciigraphs.jl")


export eq, neq, ⩵, ≶, ≷
export screen, I_
export asciigraph

#export GRAPH, OInterval
#export Region, compute, negate_op
#export TRUE, FALSE, MAYBE

## conditionally load plotting outputs
Jewel.@require Winston begin
    include(Pkg.dir("ImplicitEquations", "src", "winstongraph.jl"))
    import Winston: plot
    plot(p::Predicate, args...;kwargs...) = wgraph(p, args...; kwargs...)
    export wgraph
end


Jewel.@require PyPlot begin
    include(Pkg.dir("ImplicitEquations", "src", "pyplotgraph.jl"))
    import PyPlot: plot
    plot(p::Predicate, args...;kwargs...) = pgraph(p, args...; kwargs...)
    export pgraph
end

## These have issues
## This has an issue, as we assume Gtk here, but Winston may load with Tk...
# Jewel.@require Cairo begin
#     include(Pkg.dir("ImplicitEquations", "src", "cairograph.jl"))
#     export cgraph
# end

## Gadfly and Patchwork fail to work with the @require macro
## To use them, copy and paste the files into a session. The order of
## module loading is important.

# Jewel.@require Gadfly begin
#     include(Pkg.dir("ImplicitEquations", "src", "gadflygraph.jl"))
#     import Gadfly: plot
#     plot(p::Predicate, args...;kwargs...) = pgraph(p, args...; kwargs...)
#     export ggraph
# end


#Jewel.@require Patchwork begin
#    using Patchwork.SVG
#    include(Pkg.dir("ImplicitEquations", "src", "patchworkgraph.jl"))

#    export pwgraph
#end

## So we try this trick which requires that the packages be loaded *before* ImplicitEquations
if :Gadfly in names(Main)
    include(Pkg.dir("ImplicitEquations", "src", "gadflygraph.jl"))
    import Gadfly: plot
    plot(p::Predicate, args...;kwargs...) = ggraph(p, args...; kwargs...)
    export ggraph
end
if :Patchwork in names(Main)
    using Patchwork.SVG
    include(Pkg.dir("ImplicitEquations", "src", "patchworkgraph.jl"))
    export pwgraph
end
if :Cairo in names(Main)
    include(Pkg.dir("ImplicitEquations", "src", "cairograph.jl"))
    export cgraph
end



end # module
