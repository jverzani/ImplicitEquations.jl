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


export GRAPH, OInterval
export screen, I_
export asciigraph
export Region, compute, negate_op
export TRUE, FALSE, MAYBE

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
## reload(Pkg.dir("ImplicitEquations", "src", "patchworkgraph.jl"))





end # module
