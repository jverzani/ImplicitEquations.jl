module ImplicitEquations


using ValidatedNumerics
using Jewel

using Docile
@docstrings

import ValidatedNumerics: Interval, diam



include("predicates.jl")
include("intervals.jl")
include("asciigraphs.jl")
include("tupper.jl")


export screen, I_
export asciigraph
export eq, ≕
#export GRAPH, OInterval
#export Region, compute, negate_op
#export TRUE, FALSE, MAYBE

## conditionally load plotting outputs
Jewel.@require Winston begin
    include(Pkg.dir("ImplicitEquations", "src", "winstongraph.jl"))
    export wgraph
end

Jewel.@require Cairo begin
    include(Pkg.dir("ImplicitEquations", "src", "cairograph.jl"))
    export cgraph
end


## Patchwork doesn't work, as doesn't Gadfly...
## Fails. Perhaps try reload(Pkg.dir("ImplicitEquations", "src", "patchworkgraph.jl"))

#Jewel.@require Patchwork begin
#    using Patchwork.SVG
#    include(Pkg.dir("ImplicitEquations", "src", "patchworkgraph.jl"))
#    export pwgraph
#end

# Jewel.@require Gadfly begin
#     include(Pkg.dir("ImplicitEquations", "src", "gadflygraph.jl"))
#     export ggraph
# end






end # module
