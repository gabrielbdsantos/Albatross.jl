using Albatross
using AirfoilDefinitions
using BenchmarkTools
using NNFoil: KulfanParameters

include("utils.jl")

function make_case()
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
    blade = UniformStraightBlade(section = blade_section, span = 2.0)
    turbine = UniformBladeHDarrieus(
        blade = blade,
        kinematics = ConstantAngularVelocity(20.0),
        num_blades = 3,
    )
    momentum = RankineFroude()
    grid = DMSTGrid(
        azimuthal = UniformAzimuthalGrid(36),
        spanwise = UniformSpanwiseGrid(turbine, 1),
    )
    loss = LossModels(
        #curvature = Bangga()
    )
    return DMST(
        turbine = turbine,
        environment = environment,
        momentum = momentum,
        aerodynamics = aerodynamics,
        grid = grid,
        loss = loss,
    )
end

benchmark = @benchmarkable(
    solve(dmst),
    setup = (dmst = make_case()),
    evals = 1,
    samples = 100,
    seconds = 60.0
)

run_or_return(benchmark)
