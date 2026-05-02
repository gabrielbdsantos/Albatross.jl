<h1 align="center">
    Albatross.jl
</h1>

<div align="center">

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://gabrielbdsantos.github.io/Albatross.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://gabrielbdsantos.github.io/Albatross.jl/dev/)
[![Build Status](https://github.com/gabrielbdsantos/Albatross.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/gabrielbdsantos/Albatross.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

</div>

> [!WARNING]
> This project is under active development. Breaking changes may occur at any
> time, and backward compatibility is not guaranteed until a stable release.

## Developer Installation

Albatross is in active development and its API is not yet stable. The
instructions below are intended for developers and early adopters only.

1. Download [Julia](https://julialang.org/downloads/) version 1.11 or later.
1. Clone the repository

    ```sh
    git clone https://github.com/gabrielbdsantos/Albatross.jl
    ```

1. Enter the repository, launch Julia, and type

    ```julia-repl
    julia> import Pkg
    julia> Pkg.activate(".")
    julia> Pkg.instantiate()
    ```

## License

Albatross.jl is released under the terms of the MIT license. See the
[LICENSE](./LICENSE) file for details.
