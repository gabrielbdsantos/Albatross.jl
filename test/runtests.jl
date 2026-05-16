using Test
using Albatross
using InteractiveUtils: subtypes

const DATA_DIR = joinpath(@__DIR__, "data")

@testset failfast = true "Albatross.jl" begin
    @testset "Unit tests" begin
        for (root, dirs, files) in walkdir(joinpath(@__DIR__, "unittests"))
            endswith.(files, ".jl") .&& include.(joinpath.(root, files))
        end
    end

    @testset "Code analysis" begin
        @testset "Code quality (Aqua.jl)" begin
            import Aqua
            Aqua.test_all(Albatross)
        end

        @testset "Code linting (JET.jl)" begin
            import JET
            kwargs = (
                VERSION > v"1.12"
                    ? (target_modules = (Albatross,),)
                    : (target_defined_modules = true,)
            )
            JET.test_package(Albatross; kwargs...)
        end
    end
end
