# ImplicitEquations

[![Build Status](https://travis-ci.org/jverzani/ImplicitEquations.jl.svg?branch=master)](https://travis-ci.org/jverzani/ImplicitEquations.jl)



The paper
[Tupper](http://www.dgp.toronto.edu/people/mooncake/papers/SIGGRAPH2001_Tupper.pdf)
details a method for graphing two-dimensional implicit equations and
inequalities involving two variables. This package gives an
implementation of the most basic of the paper's algorithms to allow
the `julia` user to naturally represent and easily render such graphs.


For example, the
[conchoid](http://www-groups.dcs.st-and.ac.uk/~history/Curves/Conchoid.html)
can be represented in Cartesian form as follows:

```
a,b= 3,1
f(x,y) = (x-b)^2*(x^2 + y^2) - a*x^2
r = (f == 0)
cgraph(r)
```

Or the [Devils curve](http://www-groups.dcs.st-and.ac.uk/~history/Curves/Devils.html)

```
a,b = -1,2
f(x,y) = y^4 - x^4 + a*y^2 + b*x^2
r = (f==0)
cgraph(r)
```

Inequalities can be graphed as well

```
f(x,y)= (y-5)*cos(4*sqrt((x-4)^2 + y^2))
g(x,y) = x*sin(2*sqrt(x^2 + y^2))
r = f < g
cgraph(r, -10, 10, -10, 10, 2^9, 2^9)
```


The coloring scheme employed follows Tupper:

* white for the predicate `r` definitely not being satisfied for the pixel,
* black if the predicate is definitely satisfied somewhere in the pixel
* and red if it is unknown.


For this
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
pwgraph(r)
```


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

* rendering can be slow. This picture shows the algorithm: split the
  domain into intervals. If the statement is `FALSE` color the pixels
  white, if `TRUE` color them black, if not divide into 4 smaller
  regions and check again. 

[Imgur](http://i.imgur.com/NuOY92b.png)

	For images that require a lot of checking, the graphs can be **really slow** to render.




## TODO

*LOTS*:

* `@doc`
* integrate plotting routines
* http://www.xamuel.com/graphs-of-implicit-equations/
* http://www.peda.com/grafeq/gallery.html
* branch cut tracking
* increase speed (could color 1-pixel regions better if so, perhaps).
* work into `Gadfly` and/or `Winston` graphics
