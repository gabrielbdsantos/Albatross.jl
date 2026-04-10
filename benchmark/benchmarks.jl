using Albatross
using BenchmarkTools

const SUITE = BenchmarkGroup()

SUITE["DMST"] = BenchmarkGroup()
SUITE["DMST"]["solve"] = include("01_basic_solver.jl")
