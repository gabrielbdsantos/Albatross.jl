using Albatross
using Test
using Aqua
using JET

@testset "Albatross.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Albatross)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(Albatross; target_defined_modules = true)
    end
    # Write your tests here.
end
