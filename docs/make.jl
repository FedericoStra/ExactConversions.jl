using ExactConversions
using Documenter

DocMeta.setdocmeta!(ExactConversions, :DocTestSetup, :(using ExactConversions); recursive=true)

makedocs(;
    modules=[ExactConversions],
    authors="Federico Stra <stra.federico@gmail.com> and contributors",
    repo="https://github.com/FedericoStra/ExactConversions.jl/blob/{commit}{path}#{line}",
    sitename="ExactConversions.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://FedericoStra.github.io/ExactConversions.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/FedericoStra/ExactConversions.jl",
)
