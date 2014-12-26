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


export eq, ≕
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

Jewel.@require Cairo begin
    include(Pkg.dir("ImplicitEquations", "src", "cairograph.jl"))
    export cgraph
end

Jewel.@require PyPlot begin
    include(Pkg.dir("ImplicitEquations", "src", "pyplotgraph.jl"))
    import PyPlot: plot
    plot(p::Predicate, args...;kwargs...) = pgraph(p, args...; kwargs...)
    export pgraph
end


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




end # module
