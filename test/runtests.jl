using ImplicitEquations
using Base.Test


f(x,y) = y-x
g(x,y) = y+x

ImplicitEquations.GRAPH(f == 0, -5, 5, -5, 5, 2^4, 2^4)
ImplicitEquations.GRAPH(f <= 0, -5, 5, -5, 5, 2^4, 2^4)
ImplicitEquations.GRAPH(f <  g, -5, 5, -5, 5, 2^4, 2^4)
ImplicitEquations.GRAPH(eq(f, g), -5, 5, -5, 5, 2^4, 2^4)
ImplicitEquations.GRAPH(f ≕ g, -5, 5, -5, 5, 2^4, 2^4)
