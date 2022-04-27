
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jverzani.github.io/ImplicitEquations.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jverzani.github.io/ImplicitEquations.jl/dev)
[![Build Status](https://github.com/jverzani/ImplicitEquations.jl/workflows/CI/badge.svg)](https://github.com/jverzani/ImplicitEquations.jl/actions)
[![codecov](https://codecov.io/gh/jverzani/ImplicitEquations.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jverzani/ImplicitEquations.jl)



# ImplicitEquations


In a paper, [Tupper](https://doi.org/10.1145/383259.383267)
presents a method for graphing two-dimensional implicit equations and
inequalities. This package gives an
implementation of the paper's basic algorithms to allow
the `Julia` user to naturally represent and easily render graphs of
implicit functions and equations.


We give one example, others may be viewed in the documentation.

The
[Devils curve](http://www-groups.dcs.st-and.ac.uk/~history/Curves/Devils.html)
is graphed over the default region as follows:

```
using Plots, ImplicitEquations

a,b = -1,2
f(x,y) = y^4 - x^4 + a*y^2 + b*x^2

plot(f ⩵ 0)  # \Equal[tab] or Eq(f, 0)
```

![DevilsCurve](http://i.imgur.com/LChTzC1.png)
