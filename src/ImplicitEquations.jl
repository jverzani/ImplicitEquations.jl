module ImplicitEquations


using ValidatedNumerics

using Requires ## for @require macro

using Docile
@document

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
@require Winston begin
    include(Pkg.dir("ImplicitEquations", "src", "winstongraph.jl"))
    import Winston: plot
    plot(p::Predicate, args...;kwargs...) = wgraph(p, args...; kwargs...)
    export wgraph
end


@require PyPlot begin
    include(Pkg.dir("ImplicitEquations", "src", "pyplotgraph.jl"))
    import PyPlot: plot
    plot(p::Predicate, args...;kwargs...) = pgraph(p, args...; kwargs...)
    export pgraph
end

@require Gadfly begin
    include(Pkg.dir("ImplicitEquations", "src", "gadflygraph.jl"))
    import Gadfly: plot
    plot(p::Predicate, args...;kwargs...) = pgraph(p, args...; kwargs...)
    export ggraph
end


@require Patchwork begin
    using Patchwork.SVG
    include(Pkg.dir("ImplicitEquations", "src", "patchworkgraph.jl"))

    export pwgraph
end

## This has an issue, as we assume Gtk here, but Winston may load with Tk...
# @require Cairo begin
#     include(Pkg.dir("ImplicitEquations", "src", "cairograph.jl"))
#     export cgraph
# end


## must load cairo first
if :Cairo in names(Main)
    include(Pkg.dir("ImplicitEquations", "src", "cairograph.jl"))
    export cgraph
end



end # module
