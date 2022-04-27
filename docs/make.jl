using Documenter
using ImplicitEquations


ENV["PLOTS_TEST"] = "true"
ENV["GKSwstype"] = "100"


DocMeta.setdocmeta!(ImplicitEquations, :DocTestSetup, :(using ImplicitEquations); recursive = true)

makedocs(
    sitename = "ImplicitEquations",
    format = Documenter.HTML(ansicolor=true),
    modules = [ImplicitEquations]
)

deploydocs(
    repo = "github.com/jverzani/ImplicitEquations.jl"
)
