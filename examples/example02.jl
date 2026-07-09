# Example for a straight-bladed vertical axis wind turbine (VAWT)
# based on the experimental turbine reported by Li et al. in
# *Study on power performance for straight-bladed vertical axis
# wind turbine by field and wind tunnel test* (Renewable Energy, 2016).
#
# This example sets up a two-bladed H-Darrieus turbine with fixed pitch,
# NACA 0021 airfoil section, and the DMST workflow used to estimate the
# power coefficient as a function of tip-speed ratio.
#
# # References
# - Q. Li et al., "Study on power performance for straight-bladed vertical
#   axis wind turbine by field and wind tunnel test," Renewable Energy, vol.
#   90, pp. 291–300, 2016, doi: 10.1016/j.renene.2016.01.002.
using Albatross
using AirfoilDefinitions
using NNFoil: KulfanParameters

# Experimental data
tsr_exp = [
    1.0115, 1.1097, 1.2079, 1.3061, 1.4113, 1.5166, 1.6009, 1.7131, 1.8043, 1.9166,
    2.0077, 2.113, 2.2041, 2.3233, 2.4073, 2.5193, 2.6103, 2.7222, 2.8129, 2.9177,
]
cp_exp = [
    0.0343, 0.0451, 0.0558, 0.0666, 0.0794, 0.0966, 0.1095, 0.1245, 0.1353, 0.1482,
    0.1568, 0.1697, 0.1783, 0.1847, 0.1869, 0.1804, 0.174, 0.1633, 0.1397, 0.1225,
]

# DMST setup
environment = Environment(
    ConstantPropertyFluid(),
    UniformInflow(8.0)
)

blade_section = BladeSection(
    shape = KulfanParameters(coordinates(NACA4("0021"))),
    chord = 0.265,
    reference_point = 0.265 / 5,
    radial_position = 1.0,
    spanwise_position = 0.0,
    pitch = deg2rad(6.0)
)

aerodynamics = NeuralSectionAerodynamics(; model_size = :xsmall)

blade = UniformStraightBlade(
    section = blade_section,
    span = 1.2
)

momentum = RankineFroude()

options = DMSTSolverOptions()

tsr = Float64[]
cp = Float64[]
omegas = 8.0:1.0:24.0

for omega in omegas
    kinematics = ConstantAngularVelocity(omega)
    turbine = UniformBladeHDarrieus(
        blade = blade,
        kinematics = kinematics,
        num_blades = 2
    )
    grid = DMSTGrid(
        azimuthal = UniformAzimuthalGrid(36),
        spanwise = UniformSpanwiseGrid(turbine, 1)
    )
    tsr_local = omega * blade_section.radial_position / environment.inflow.U
    solidity = turbine.num_blades * blade_section.chord / blade_section.radial_position
    dmst = DMST(turbine, environment, momentum, aerodynamics, grid, options)
    solution = solve(dmst)
    solution_fields = evaluate_streamtube_fields(solution)

    append!(tsr, tsr_local)
    append!(cp, sum(solution_fields.Cp))
end

# # Uncomment to plot the Cp x TSR curve
# using Plots
# display(plot(tsr_plot, cp_plot, xlabel = "TSR", ylabel = "Cp", label = "Standard DMST", dpi = 600, lw = 3))
# display(scatter!(tsr_exp, cp_exp, label = "Experimental", lw = 3, mc = :black))
