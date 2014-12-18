module ImplicitEquations


using ValidatedNumerics
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

end # module
