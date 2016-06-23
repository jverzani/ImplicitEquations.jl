VERSION >= v"0.4.0-dev+6521" && __precompile__()
module ImplicitEquations


using ValidatedNumerics

import ValidatedNumerics: Interval, diam
using RecipesBase


include("predicates.jl")
include("intervals.jl")
include("tupper.jl")
include("asciigraphs.jl")
#include("plot.jl")
include("plot_recipe.jl")

export eq, neq, ⩵, ≷, ≶
export screen, I_
export asciigraph

#export GRAPH, OInterval
#export Region, compute, negate_op
#export TRUE, FALSE, MAYBE




end # module
