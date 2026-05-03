using Albatross
using AirfoilDefinitions
using NNFoil: KulfanParameters

environment = EnvironmentConditions(
    ConstantPropertyFluid(),
    UniformInflow(10)
)

blade_section = BladeSection(
    shape = KulfanParameters(coordinates(NACA4("0015"))),
    chord = 0.25,
    ref_point = 0.25 / 4,
    r = 1.0,
    z = 0.0,
    pitch = 0.0
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
