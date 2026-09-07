using Test
using Albatross

using AirfoilDefinitions
using DelimitedFiles
using NNFoil

const DMST_SNAPSHOT = begin
    data = readdlm(joinpath(DATA_DIR, "01_basic_solution.csv"))
    @assert size(data) == (24, 3)

    (;
        a = vec(data[:, 1]),
        Cth = vec(data[:, 2]),
        Cp = vec(data[:, 3]),
    )
end

function make_dmst_case(;
        momentum = RankineFroude(),
        options = DMSTSolverOptions(),
        submodels = DMSTSubmodels(),
    )
    environment = Environment(
        ConstantPropertyFluid(),
        UniformInflow(10.0),
    )

    blade_section = BladeSection(
        shape = KulfanParameters(coordinates(NACA4("0015"))),
        chord = 0.25,
        reference_point = 0.25 / 4,
        radial_position = 1.0,
        spanwise_position = 0.0,
        pitch = 0.0,
    )

    aerodynamics = NeuralSectionAerodynamics(; model_size = :xsmall)

    blade = UniformStraightBlade(
        section = blade_section,
        span = 2.0,
    )
    turbine = UniformBladeHDarrieus(
        blade = blade,
        kinematics = ConstantAngularVelocity(20.0),
        num_blades = 3,
    )

    grid = DMSTGrid(
        azimuthal = UniformAzimuthalGrid(12),
        spanwise = UniformSpanwiseGrid(turbine, 1),
    )

    return DMST(
        turbine = turbine,
        environment = environment,
        momentum = momentum,
        aerodynamics = aerodynamics,
        grid = grid,
        options = options,
        submodels = submodels,
    )
end

@testset "Solution regression" begin
    dmst = make_dmst_case()
    sol = solve(dmst)
    aero_fields = evaluate_streamtube_fields(sol)

    @test aero_fields.a ≈ DMST_SNAPSHOT.a
    @test aero_fields.Cth ≈ DMST_SNAPSHOT.Cth
    @test aero_fields.Cp ≈ DMST_SNAPSHOT.Cp
end
