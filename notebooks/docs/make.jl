using YoungTableaux
using Documenter

DocMeta.setdocmeta!(YoungTableaux, :DocTestSetup, :(using YoungTableaux); recursive=true)

makedocs(;
    modules=[YoungTableaux],
    authors="Simeon David Schaub <schaub@mit.edu> and contributors",
    repo="https://github.com/simeonschaub/YoungTableaux.jl/blob/{commit}{path}#{line}",
    sitename="YoungTableaux.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://simeonschaub.github.io/YoungTableaux.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/simeonschaub/YoungTableaux.jl",
    devbranch="main",
)
