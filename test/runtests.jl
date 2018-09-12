using ImplicitEquations
using Test


f(x,y) = y-x
g(x,y) = y+x

ImplicitEquations.GRAPH(f ⩵ 0, -5, 5, -5, 5, 2^4, 2^4)
ImplicitEquations.GRAPH(f ≦ 0, -5, 5, -5, 5, 2^4, 2^4)
ImplicitEquations.GRAPH(f ≪  g, -5, 5, -5, 5, 2^4, 2^4)

ImplicitEquations.GRAPH(f ≶  g, -5, 5, -5, 5, 2^4, 2^4)
ImplicitEquations.GRAPH(f ≷  g, -5, 5, -5, 5, 2^4, 2^4)
ImplicitEquations.GRAPH(Neq(f, g), -5, 5, -5, 5, 2^4, 2^4)

ImplicitEquations.GRAPH(Eq(f, g), -5, 5, -5, 5, 2^4, 2^4)
ImplicitEquations.GRAPH(f ⩵ g, -5, 5, -5, 5, 2^4, 2^4)
