using Albatross
using AirfoilDefinitions
using NNFoil: KulfanParameters

environment = Environment(
    ConstantPropertyFluid(),
    UniformInflow(10)
)

blade_section = BladeSection(
    shape = KulfanParameters(coordinates(NACA4("0015"))),
    chord = 0.25,
    reference_point = 0.25 / 4,
    radial_position = 1.0,
    spanwise_position = 0.0,
    pitch = deg2rad(0.0)
)

aerodynamics = NeuralSectionAerodynamics(; model_size = :xsmall)

blade = UniformStraightBlade(
    section = blade_section,
    span = 2.0
)

kinematics = ConstantAngularVelocity(20.0)

turbine = UniformBladeHDarrieus(
    blade = blade,
    kinematics = kinematics,
    num_blades = 3
)

momentum = RankineFroude()

grid = DMSTGrid(
    azimuthal = UniformAzimuthalGrid(36),
    spanwise = UniformSpanwiseGrid(turbine, 1)
)

options = DMSTSolverOptions()

dmst = DMST(turbine, environment, momentum, aerodynamics, grid, options)

solution = solve(dmst)
solution_fields = evaluate_streamtube_fields(solution)
