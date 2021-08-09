module ImplicitEquations


import IntervalArithmetic: Interval, diam, isempty
using RecipesBase
using CommonEq

include("predicates.jl")
include("intervals.jl")
include("tupper.jl")
include("asciigraphs.jl")
include("plot_recipe.jl")

export screen, I_
export asciigraph
export Lt, ≪, Le, ≦, Eq, ⩵, Ne, ≶, ≷, Ge, ≧, Gt, ≫
export Neq

#export GRAPH, OInterval
#export Region, compute, negate_op
#export TRUE, FALSE, MAYBE




end # module
