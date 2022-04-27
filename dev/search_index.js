var documenterSearchIndex = {"docs":
[{"location":"#ImplicitEquations","page":"ImplicitEquations","title":"ImplicitEquations","text":"","category":"section"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"ImplicitEquations","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"This paper by Tupper details a method for graphing two-dimensional implicit equations and inequalities. This package gives an implementation of the paper's basic algorithms to allow the Julia user to naturally represent and easily render graphs of implicit functions and equations.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"The IntervalConstraintProgramming packages gives an alternative implementation.","category":"page"},{"location":"#Examples","page":"ImplicitEquations","title":"Examples","text":"","category":"section"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"The basic idea is to express a equation in x and y variables in terms of a function of two variables as a predicate. The plot function Plots is used to plot these predicates.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"using Plots, ImplicitEquations","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"For example, the Devils curve is graphed over the default region as follows:","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"a,b = -1,2\nf(x,y) = y^4 - x^4 + a*y^2 + b*x^2\nr = (f ⩵ 0) # \\Equal[tab]\nplot(r)","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"The f ⩵ 0 expression above creates a Predicate that is graphed by plot.  Predicates are generated using the function Lt, Le, Eq, Neq, Ge, and Gt. The infix unicode operators ≪ (\\ll[tab]), ≦ (\\leqq[tab]), ⩵ (\\Equal[tab]), ≶ (\\lessgtr[tab]) or ≷ (\\gtrless[tab]), ≧ (\\geqq[tab]), ≫ (\\leqq[tab]) may also be used.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"For example, the Trident of Newton can be represented in Cartesian form as follows:","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"## trident of Newton\nc,d,e,h = 1,1,1,1\nf(x,y) = x*y\ng(x,y) = c*x^3 + d*x^2 + e*x + h\nplot(Eq(f,g)) ## aka f ⩵ g (using Unicode\\Equal<tab>)","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"Inequalities can be graphed as well","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"f(x,y) = x - y\nplot(f ≪ 0) # \\ll[tab]","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"This example is from Tupper's paper:","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"f(x,y) = (y-5)* cos(4sqrt((x-4)^2 +y^2))\ng(x,y) = x * sin(2*sqrt(x^2 + y^2))\n\nplot(Ge(f,  g), xlims=(-10, 10), ylims=(-10, 10))","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"This graph illustrates the algorithm employed to graph f ⩵ 0 where f(x,y) = y - sqrt(x):","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"(Image: Algorithm)","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"The basic algorithm is to initially break up the graphing region into square regions. (This uses the number of pixels, which are specified by W and H above.)","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"These regions are checked for the predicate.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"If definitely not, the region is labeled \"white;\"\nif definitely yes, the region is labeled \"black;\"\nelse the square region is subdivided into 4 smaller regions and the above is repeated until subdivision would be below the pixel level. At which point, the remaining \"1-by-1\" pixels are checked for possible solutions, for example for equalities where continuity is known a random sample of points is investigated with the intermediate value theorem. A region may be labeled \"black\" or \"red\" if the predicate is still ambiguous.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"The graph plots each \"black\" region as a \"pixel\". The \"red\" regions may optionally be colored, if a named color is passed through the keyword red.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"For example, the Devil's curve is a bit different with red coloring:","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"a,b = -1,2\nf(x,y) = y^4 - x^4 + a*y^2 + b*x^2\nr = (f ⩵ 0)\nplot(r, red=:red)   # show undecided regions in red","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"The plot function accepts the usual keywords of Plots and also:","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"the number of pixels is a power of 2 and specified by plot(pred, N=4, M=5). The default is M=8 by N=8 or 256 x 256.\nthe colors red and black can be adjusted with the keywords red and black.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"This example, the Batman equation, Uses a few new things: the screen function is used to restrict ranges and logical operators to combine predicates.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"f0(x,y) = ((x/7)^2 + (y/3)^2 - 1)  *   screen(abs(x)>3) * screen(y > -3*sqrt(33)/7)\nf1(x,y) = ( abs(x/2)-(3 * sqrt(33)-7) * x^2/112 -3 +sqrt(1-(abs((abs(x)-2))-1)^2)-y)\nf2(x,y) = y - (9 - 8*abs(x))       *   screen((abs(x)>= 3/4) &  (abs(x) <= 1) )\nf3(x,y) = y - (3*abs(x) + 3/4)     *   I_((1/2 < abs(x)) & (abs(x) < 3/4))    # alternate name for screen\nf4(x,y) = y - 2.25                 *   I_(abs(x) <= 1/2)\nf5(x,y) = (6 * sqrt(10)/7 + (1.5-.5 * abs(x)) - 6 * sqrt(10)/14 * sqrt(4-(abs(x)-1)^2) -y) * screen(abs(x) >= 1)\n\nr = (f0 ⩵ 0) | (f1 ⩵ 0) | (f2 ⩵ 0) | (f3 ⩵ 0) | (f4 ⩵ 0) | (f5 ⩵ 0)\nplot(r, xlims=(-7, 7), ylims=(-4, 4), red=:black)","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"The above example illustrates a few things:","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"predicates can be joined logically with &, |. Use ! for negation.\nThe screen function can be used to restrict values according to some predicate call.\nthe logical comparisons such as (abs(x) >= 3/4) & (abs(x) <= 1) within screen are not typical in that one can't write 3/4 <= abs(x) <= 1, a convenient Julian syntax. This is due to the fact that the \"xs\" being evaluated are not numbers, rather intervals via ValidatedNumerics. For intervals, values may be true, false or \"maybe\" so a different interpretation of the logical operators is given that doesn't lend itself to the more convenient notation.\nrendering can be slow. There are two reasons: images that require a lot of checking, such as the inequality above, are slow just because more regions must be analyzed. As well, some operations are slow, such as division, as adjustments for discontinuities are slow. (And by slow, it can mean really slow. The difference between rendering (1-x^2)*(2-y^2) and csc(1-x^2)*cot(2-y^2) can be 10 times.)","category":"page"},{"location":"#Maps","page":"ImplicitEquations","title":"Maps","text":"","category":"section"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"If a function fC rightarrow C is passed through the map argument of plot, each rectangle to render is mapped by the function f prior to drawing. This allows for viewing of conformal maps. This example is one of several:","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"f(x,y) = x\nplot(f ≧ 1/2, map=z -> 1/z)","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"The region that is mapped above is not the half plane x = 12, but truncated by y  5 due to the default values of ylims. Hence we don't see the full circle.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"As well, the pieces plotted are polygonal approximations to the correct image. Consequently, gaps can appear.","category":"page"},{"location":"#A-\"typical\"-application","page":"ImplicitEquations","title":"A \"typical\" application","text":"","category":"section"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"A common calculus problem is to find the tangent line using implicit differentiation. We can plot the predicate to create the implicit graph, then add a layer with plot!:","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"f(x,y) = x^2 + y^2\nplot(f ⩵ 2*3^2)\n\n## now add tangent at (3,3)\na,b = 3,3\ndydx(a,b) = -b/a             # implicit differentiation to get dy/dx = -y/x\ntl(x) = b + dydx(a,b)*(x-a)\nplot!(tl, linewidth=3, -5, 5)","category":"page"},{"location":"#D-Plots","page":"ImplicitEquations","title":"3D Plots","text":"","category":"section"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"Embedding in 3D is done using the zpos keyword. This can be used to create Z-scans. The following example produces cross sections through an ellipsoid, though it isn't displayed.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"using Plots, ColorSchemes\nusing ImplicitEquations\n\n\nellipsoid(x,y,z) = 6y^2 + 3x^2 + z^2 - 2.8y*z\nzrange = -2.5:0.5:2.5\n\nplt = plot( palette = palette(cgrad([:red,:green,:blue],length(zrange))), camera=(45,45),xlabel=\"x\",ylabel=\"y\",zlabel=\"z\")\n[plot!(plt,((x,y)->ellipsoid(x,y,z))⩵ 5, zpos=z) for z=zrange]\nplt","category":"page"},{"location":"#Alternatives","page":"ImplicitEquations","title":"Alternatives","text":"","category":"section"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"Many such plots are simply a single level of a contour plot. Contour plots can be drawn with the Plots package too. A simple contour plot will be faster than this package.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"The SymPy package exposes SymPy's plot_implicit feature that will implicitly plot a symbolic expression in 2 variables including inequalities. The algorithm there also follows Tupper and uses interval arithmetic, as possible.","category":"page"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"The package IntervalConstraintProgramming  also allows for this type of graphing, and more.","category":"page"},{"location":"#Reference","page":"ImplicitEquations","title":"Reference","text":"","category":"section"},{"location":"","page":"ImplicitEquations","title":"ImplicitEquations","text":"Modules = [ImplicitEquations]","category":"page"},{"location":"#ImplicitEquations.plot_implicit","page":"ImplicitEquations","title":"ImplicitEquations.plot_implicit","text":"Plotting of implicit functions.\n\nAn implicit function or equation is defined in terms of a logical condition and a function of two variables. These produce Predicate objects.\n\nPredicates may be plotted over a specified region, the default begin [-5,5] x [-5,5].\n\nThe algorithm, breaks the region into blocks. The ultimate resolution is given by W=2^n and H=2^m. The algorithm used, due to Tupper, colors region if it knows the predicate is true or false, and otherwise resolves the region into 4 equal-sized subregions and test each subregion again to determine if it is true, false, or still maybe. This repeats until W and H can't be subdivided.\n\nThe plotting of a predicate simply plots each block that is knows satisfies the predicate \"black\" and each ambiguous block \"red.\" By taking m and n larger the graphs look less \"blocky\" but take more time to render.\n\nFor text-based plots, the asciigraph function is available.\n\nExamples:\n\nusing Plots, ImplicitEquations\n\na,b = -1,2\nf(x,y) = y^4 - x^4 + a*y^2 + b*x^2\nplot(f ⩵ 0)\n\n## trident of Newton\nc,d,e,h = 1,1,1,1\nf(x,y) = x*y\ng(x,y) =c*x^3 + d*x^2 + e*x + h\nplot(Eq(f,g); title=\"Trident of Newton\") ## aka f ⩵ g (using Unicode\\Equal[tab])\n\n## inequality\nf(x,y)= (y-5)*cos(4*sqrt((x-4)^2 + y^2))\ng(x,y) = x*sin(2*sqrt(x^2 + y^2))\nr = f ≦ g\nplot(r; ylim=(-10, 10), xlim=(-10, 10), N=9, M=9)\n\n\n\n\n\n","category":"constant"},{"location":"#ImplicitEquations.Pred","page":"ImplicitEquations","title":"ImplicitEquations.Pred","text":"A predicate is defined in terms of a function of two variables, an inquality, and either another function or a real number.  They are conveniently created by the functions Lt, Le, Eq, Ne, Ge, and Gt. The following equivalent unicode operators may be used:\n\n≪ (\\ll[tab]),\n≦ (\\leqq[tab]),\n⩵ (\\Equal[tab]),\n≶ (\\lessgtr[tab])  or ≷ (\\gtrless[tab]),\n≧ (\\geqq[tab]),\n≫ (\\leqq[tab])\n\nTo combine predicates, & and | can be used.\n\nTo negate a predicate, ! is used.\n\n\n\n\n\n","category":"type"},{"location":"#ImplicitEquations.Preds","page":"ImplicitEquations","title":"ImplicitEquations.Preds","text":"Predicates can be joined together with either & or |. Individual predicates can be negated with !. The parsing rules require the individual predicates to be enclosed with parentheses, as in (f==0) | (g==0).\n\n\n\n\n\n","category":"type"},{"location":"#ImplicitEquations.GRAPH-NTuple{7, Any}","page":"ImplicitEquations","title":"ImplicitEquations.GRAPH","text":"Main algorithm of Tupper.\n\nBreak region into square regions for each square region, subdivide into 4 regions. For each check if there is no solution, if so add to white. Otherwise, refine the region by repeating until we can't subdivide\n\nAt that point, check each pixel-by-pixel region for possible values.\n\nReturn red, black, and white vectors of Regions.\n\n\n\n\n\n","category":"method"},{"location":"#ImplicitEquations.asciigraph","page":"ImplicitEquations","title":"ImplicitEquations.asciigraph","text":"Function to graph, using ascii characters, a predicate related to a two-dimensional equation, such as f == 0 or f < g, where f and g are functions, e.g., f(x,y) = y - sqrt(x). The positional arguments are L, R, B, T which indicate the x-y range of the graph of the equation. The keyword arguments W and H indicate the number of pixels to use.\n\nSet offset=0 to see algorithm\n\nA pixel is important, as the graph will color a pixel\n\n\"white\" (e.g., \" \") if no solution exists in the region indicated by the pixel\n\"black\" (e.g., \"x\") if a solution is known to exist in the region\n\"red\" (e.g. \".\") if a solution might exist\n\nExample\n\njulia> f(x,y) = x^2 + y^2\nf (generic function with 1 method)\n\njulia> r = f ⩵ 4^2\nImplicitEquations.Pred(f, ==, 16)\n\njulia> asciigraph(r)\n\n     .xxxxx\n    xx    xx\n   x.      xx\n  x.        xx\n xx          xx\n x            x\n x            x\n x            x\n x            x\n xx          x.\n  xx        .x\n   xx      .x\n    xx    xx\n     xxxxx.\n\n\n\n\n\n\n","category":"function"},{"location":"#ImplicitEquations.check_inequality-Tuple{ImplicitEquations.Pred, ImplicitEquations.Region, Any, Any, Any, Any, Any, Any}","page":"ImplicitEquations","title":"ImplicitEquations.check_inequality","text":"Does this function have a value in the pixel satisfying the inequality? Return TRUE or MAYBE.\n\n\n\n\n\n","category":"method"},{"location":"#ImplicitEquations.compute-Tuple{ImplicitEquations.Pred, ImplicitEquations.Region, Any, Any, Any, Any, Any, Any}","page":"ImplicitEquations","title":"ImplicitEquations.compute","text":"Compute whether predicate holds in a given region. Returns FALSE, TRUE or MAYBE\n\n\n\n\n\n","category":"method"},{"location":"#ImplicitEquations.cross_zero-Tuple{ImplicitEquations.Pred, ImplicitEquations.Region, Any, Any, Any, Any, Any, Any}","page":"ImplicitEquations","title":"ImplicitEquations.cross_zero","text":"Does this function have a zero crossing? Heuristic check.\n\nWe return TRUE or MAYBE. However, that leaves some functions showing too much red in the case where there is no zero.\n\n\n\n\n\n","category":"method"},{"location":"#ImplicitEquations.screen-Tuple{Any}","page":"ImplicitEquations","title":"ImplicitEquations.screen","text":"Screen a value using NaN values. Use as  with f(x,y) = x*y * screen(x > 0)\n\nAlso aliased to I_(x>0)\n\nAn expression like x::OInterval > 0 is not Boolean, but rather a BInterval which allows for a \"MAYBE\" state. As such, a simple ternary operator, like x > 0 ? 1 : NaN won't work, to screen values.\n\n\n\n\n\n","category":"method"}]
}
