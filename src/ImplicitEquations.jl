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

export eq, neq, ⩵, ≷, ≶
export screen, I_
export asciigraph

#export GRAPH, OInterval
#export Region, compute, negate_op
#export TRUE, FALSE, MAYBE

## conditionally load plotting outputs
@require Winston begin
    include(Pkg.dir("ImplicitEquations", "src", "winstongraph.jl"))
    import Winston: plot
    plot(p::Predicate, args...; show_red::Bool=false, kwargs...) = wgraph(p, args...;  show_red=show_red, kwargs...)
    export wgraph
end


@require PyPlot begin
    include(Pkg.dir("ImplicitEquations", "src", "pyplotgraph.jl"))
    import PyPlot: plot
    plot(p::Predicate, args...; show_red::Bool=false, kwargs...) = pgraph(p, args...;  show_red=show_red, kwargs...)
    export pgraph
end

@require Gadfly begin
    include(Pkg.dir("ImplicitEquations", "src", "gadflygraph.jl"))
    import Gadfly: plot
    plot(p::Predicate, args...; show_red::Bool=false, kwargs...) = ggraph(p, args...; show_red=show_red, kwargs...)
    export ggraph
end


@require Patchwork begin
    using Patchwork.SVG
    include(Pkg.dir("ImplicitEquations", "src", "patchworkgraph.jl"))
    ## should have a plot method???
    export pwgraph
end

## This has an issue, as we assume Gtk here, but Winston may load with Tk...
@require Cairo begin
    if !haskey(ENV, "WINSTON_OUTPUT")
        ENV["WINSTON_OUTPUT"] = "Gtk"
    else
        ENV["WINSTON_OUTPUT"] != "Gtk" && error("Loading cairo will cause an issue with Tk")
    end
    include(Pkg.dir("ImplicitEquations", "src", "cairograph.jl"))
    export cgraph
end




end # module
