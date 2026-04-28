using Albatross
using BenchmarkTools

const SUITE = BenchmarkGroup()

SUITE["DMST"] = BenchmarkGroup()
SUITE["DMST"]["solve"] = include("01_solve_out_of_place.jl")
