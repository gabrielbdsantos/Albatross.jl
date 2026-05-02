using Albatross
using Documenter
using DocumenterCitations

DocMeta.setdocmeta!(Albatross, :DocTestSetup, :(using Albatross); recursive = true)

makedocs(;
    # modules = [Albatross],
    authors = "Gabriel B. Santos <gabriel.bertacco@unesp.br>",
    sitename = "Albatross.jl",
    format = Documenter.HTML(;
        canonical = "https://gabrielbdsantos.github.io/Albatross.jl",
        edit_link = "main",
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = String[
            "assets/custom.css",
            "assets/citations.css",
        ],
    ),
    plugins = [
        CitationBibliography(
            joinpath(@__DIR__, "src", "references.bib");
            style = :authoryear
        )
    ],
    pages = [
        "Home" => "index.md",
        "Public API" => "public-api.md",
        "References" => "references.md",
    ],
)

deploydocs(;
    repo = "github.com/gabrielbdsantos/Albatross.jl",
    devbranch = "main",
)
