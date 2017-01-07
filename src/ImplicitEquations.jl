__precompile__(true)

module ImplicitEquations


using ForwardDiff
import ValidatedNumerics: Interval, diam, isempty
using RecipesBase
using Compat

include("predicates.jl")
include("intervals.jl")
include("tupper.jl")
include("asciigraphs.jl")
#include("plot.jl")
include("plot_recipe.jl")

export Lt, ≪, Le, ≦, Eq, ⩵, Neq, ≶, ≷, Ge, ≧, Gt, ≫
export screen, I_
export asciigraph

#export GRAPH, OInterval
#export Region, compute, negate_op
#export TRUE, FALSE, MAYBE




end # module
