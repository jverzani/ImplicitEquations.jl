[![ImplicitEquations](http://pkg.julialang.org/badges/ImplicitEquations_0.4.svg)](http://pkg.julialang.org/?pkg=ImplicitEquations&ver=0.4)
&nbsp;
Linux: [![Build Status](https://travis-ci.org/jverzani/ImplicitEquations.jl.svg?branch=master)](https://travis-ci.org/jverzani/ImplicitEquations.jl)
&nbsp;
Windows: [![Build Status](https://ci.appveyor.com/api/projects/status/github/jverzani/ImplicitEquations.jl?branch=master&svg=true)](https://ci.appveyor.com/project/jverzani/implicitequations-jl)

# ImplicitEquations


In a paper, [Tupper](http://www.dgp.toronto.edu/people/mooncake/papers/SIGGRAPH2001_Tupper.pdf)
presents a method for graphing two-dimensional implicit equations and
inequalities. This package gives an
implementation of the paper's basic algorithms to allow
the `Julia` user to naturally represent and easily render graphs of
implicit functions and equations.


We give one example, others may be viewed as an `IJulia` notebook ([here](http://nbviewer.ipython.org/github/jverzani/ImplicitEquations.jl/blob/master/docs/examples.ipynb)).

The
[Devils curve](http://www-groups.dcs.st-and.ac.uk/~history/Curves/Devils.html)
is graphed over the default region as follows:

```
using Plots
pyplot()
using ImplicitEquations

a,b = -1,2
f(x,y) = y^4 - x^4 + a*y^2 + b*x^2
plot(f ⩵ 0)  # \Equal[tab]
```

![DevilsCurve](http://i.imgur.com/LChTzC1.png)


### See also:


The package
[IntervalConstraintProgramming ](https://github.com/dpsanders/IntervalConstraintProgramming.jl)
offers a faster, more general implentation of this type of graphing
and more. It has a different means to specify the underlying
equation. 
