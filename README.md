# ImplicitEquations

[![Build Status](https://travis-ci.org/jverzani/ImplicitEquations.jl.svg?branch=master)](https://travis-ci.org/jverzani/ImplicitEquations.jl)



The paper
[Tupper](http://www.dgp.toronto.edu/people/mooncake/papers/SIGGRAPH2001_Tupper.pdf)
details a method for graphing two-dimensional implicit equations and
inequalities involving two variables. This package gives an
implementation of the most basic of the paper's algorithms to allow
the `julia` user to naturally represent and easily render such graphs.


For example, the
[Trident of Newton](http://www-history.mcs.st-and.ac.uk/Curves/Trident.html)
can be represented in Cartesian form as follows:

```
using ImplicitEquations
using Winston # for wgraph
## trident of Newton
c,d,e,h = 1,1,1,1
f(x,y) = x*y
g(x,y) = c*x^3 + d*x^2 + e*x + h
wgraph(f==g)
```

![Newton trident](http://i.imgur.com/1vhqSUz.png)

Or the [Devils curve](http://www-groups.dcs.st-and.ac.uk/~history/Curves/Devils.html)

```
a,b = -1,2
f(x,y) = y^4 - x^4 + a*y^2 + b*x^2
r = (f==0)
pwgraph(r)
```

Inequalities can be graphed as well

```
f(x,y)= (y-5)*cos(4*sqrt((x-4)^2 + y^2))
g(x,y) = x*sin(2*sqrt(x^2 + y^2))
r = f < g
pwgraph(r, -10, 10, -10, 10, W=2^9, H=2^9)
```

![Inequality](http://i.imgur.com/AqnHLMr.png)


The coloring scheme employed follows Tupper:

* white for the predicate `r` definitely not being satisfied for the pixel,
* black if the predicate is definitely satisfied somewhere in the pixel,
* and red if it is unknown.

This graph has extra thin lines to indicate the algorithm: break up the picture by regions
and check if the regions satisfy the predicate. If definitely not,
paint the region white; if definitely yes, paint the region black;
else subdivide into 4 regions and repeat until subdivision is below
the pixel level. At which point, check for solutions using a random
set of points and the intermediate value theorem.


For the
[Batman equation](http://yangkidudel.wordpress.com/2011/08/02/love-and-mathematics/)
we use `screen` to restrict ranges and logical operators to combine
predicates.

```
f(x,y) = ((x/7)^2 + (y/3)^2 - 1) *     screen(abs(x)>3) * screen(y > -3*sqrt(33)/7) 
f1(x,y) = ( abs(x/2)-(3 * sqrt(33)-7) * x^2/112 -3 +sqrt(1-(abs((abs(x)-2))-1)^2)-y)
f2(x,y) = y - (9 - 8*abs(x)) *         screen((abs(x)>= 3/4) &  (abs(x) <= 1) )
f3(x,y) = y - (3*abs(x) + 3/4) *       screen((1/2 < abs(x)) & (abs(x) < 3/4))
f4(x,y) = y - 2.25 *                   screen(abs(x) <= 1/2) 
f5(x,y) = (6 * sqrt(10)/7 + (1.5-.5 * abs(x)) - 6 * sqrt(10)/14 * sqrt(4-(abs(x)-1)^2) -y) * screen(abs(x) >= 1)
r = (f==0) | (f1==0) | (f2== 0) | (f3==0) | (f4==0) | (f5==0)
wgraph(r)
```


![Batman Curve](http://i.imgur.com/NuOY92b.png)


The above example illustrates a few things:

* predicates can be joined logically with `&`, `|`. Use `!` for negation.

* The `screen` function can be used to restrict values according to
  some predicate call.

* the logical comparisons such as `(abs(x)>= 3/4) & (abs(x) <= 1)`
  within `screen` are not typical in that one can't write `3/4 <=
  abs(x) <= 1` with typical `Julian` syntax. This is due to the "`x`s"
  being evaluated are not numbers, but rather intervals (via
  `ValidatedNumerics`). For intervals, values may be true, false or
  "maybe" so a different interpretation of the logical operators is
  given that doesn't lend itself to the more convenient notation.

* rendering can be slow. There are two reasons: images that require a
  lot of checking, such as the inequality above, are slow just because
  more regions must be analyzed. As well, some operations are slow,
  such as division, as adjustments for discontinuities are slow.


The graphs can be rendered in different ways. The `asciigraph`
function is always available and makes a text-based plot. The `wgraph`
function is loaded withn `Winston` is. The `cgraph` function is loaded
if `Cairo` is. SVG based solutions, useful in `IJulia`, are for
`Patchwork` and `Gadfly`, though these must be copy and pasted in.


## TODO

*LOTS*:

* `@doc`
* integrate plotting routines
* http://www.xamuel.com/graphs-of-implicit-equations/
* http://www.peda.com/grafeq/gallery.html
* branch cut tracking
* increase speed (could color 1-pixel regions better if so, perhaps; division checks; type stability).
* work into `Gadfly` and/or `Winston` graphics. (Started)
