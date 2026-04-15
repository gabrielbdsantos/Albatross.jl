using Albatross
using Test
using Aqua
using JET

using InteractiveUtils: subtypes

const DATA_DIR = joinpath(@__DIR__, "data")

@testset failfast = true "Albatross.jl" begin
    @testset "DMST" begin
        include("dmst/01_basic_regression.jl")
    end

    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Albatross)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(Albatross; target_defined_modules = true)
    end
end
