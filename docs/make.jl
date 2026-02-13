using Albatross
using Documenter

DocMeta.setdocmeta!(Albatross, :DocTestSetup, :(using Albatross); recursive = true)

makedocs(;
    # modules = [Albatross],
    authors = "Gabriel B. Santos <gabriel.bertacco@unesp.br>",
    sitename = "Albatross.jl",
    format = Documenter.HTML(;
        canonical = "https://gabrielbdsantos.github.io/Albatross.jl",
        edit_link = "main",
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo = "github.com/gabrielbdsantos/Albatross.jl",
    devbranch = "main",
)
