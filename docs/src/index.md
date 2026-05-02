# Albatross.jl

Albatross is a Julia software for reduced-order analysis of vertical-axis wind
turbines.

!!! warning "WARNING"

    This project is under active development. Breaking changes may occur at any
    time, and backward compatibility is not guaranteed until a stable release.

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
