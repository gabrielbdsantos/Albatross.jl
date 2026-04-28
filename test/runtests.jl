using Albatross
using InteractiveUtils: subtypes
using Test

const DATA_DIR = joinpath(@__DIR__, "data")

@testset failfast = true "Albatross.jl" begin
    @testset "Unit tests" begin
        for (root, dirs, files) in walkdir(joinpath(@__DIR__, "unittests"))
            endswith.(files, ".jl") .&& include.(joinpath.(root, files))
        end
    end

    @testset "Code analysis" begin
        import Aqua
        import JET

        @testset "Code quality (Aqua.jl)" begin
            Aqua.test_all(Albatross)
        end

        @testset "Code linting (JET.jl)" begin
            JET.test_package(Albatross; target_defined_modules = true)
        end
    end
end
