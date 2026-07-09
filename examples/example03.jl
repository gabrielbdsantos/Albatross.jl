"""
Example of a straight-bladed Darrieus turbine based on the experimental study
by Kjellin et al. (2011).

# Reference

1. J. Kjellin, F. Bülow, S. Eriksson, P. Deglaire, M. Leijon, and H. Bernhoff,
   "Power coefficient measurement on a 12 kW straight bladed vertical axis wind
   turbine," Renewable Energy, vol. 36, no. 11, pp. 3050–3053, 2011, doi:
   10.1016/j.renene.2011.03.031.
"""

using Albatross
using AirfoilDefinitions
using NNFoil: KulfanParameters

# Experimental data
tsr_exp = [
    1.7476, 1.8624, 1.9668, 2.1024, 2.2275, 2.3527, 2.4569, 2.5716, 2.6968, 2.822, 2.9369,
    3.0624, 3.1879, 3.3028, 3.4285, 3.5333, 3.659, 3.7638, 3.9002, 4.0266, 4.1316, 4.2476,
    4.3738, 4.4681,
]
cp_exp = [
    0.0532, 0.0681, 0.083, 0.1085, 0.1383, 0.1596, 0.183, 0.2043, 0.2277, 0.2489, 0.2638,
    0.2702, 0.2787, 0.2915, 0.2872, 0.2872, 0.283, 0.2787, 0.266, 0.2319, 0.2149, 0.1787,
    0.1532, 0.1489,
]

# DMST setup
environment = Environment(
    ConstantPropertyFluid(),
    UniformInflow(12)
)

blade_section = BladeSection(
    shape = KulfanParameters(coordinates(NACA4("0021"))),
    chord = 0.25,
    reference_point = 0.25 / 5,
    radial_position = 3.24,
    spanwise_position = 0.0,
    pitch = deg2rad(-2.0)
)

aerodynamics = NeuralSectionAerodynamics(; model_size = :xsmall)

blade = UniformStraightBlade(
    section = blade_section,
    span = 5.0
)

momentum = SteirosHultmark()

options = DMSTSolverOptions()

tsr = Float64[]
cp = Float64[]
omegas = 6.0:1.0:17.0

for omega in omegas
    kinematics = ConstantAngularVelocity(omega)
    turbine = UniformBladeHDarrieus(
        blade = blade,
        kinematics = kinematics,
        num_blades = 3
    )
    grid = DMSTGrid(
        azimuthal = UniformAzimuthalGrid(36),
        spanwise = UniformSpanwiseGrid(turbine, 1)
    )
    current_tsr = omega * blade_section.radial_position / environment.inflow.U
    solidity = turbine.num_blades * blade_section.chord / blade_section.radial_position
    dmst = DMST(turbine, environment, momentum, aerodynamics, grid, options)
    solution = solve(dmst)
    solution_fields = evaluate_streamtube_fields(solution)

    append!(tsr, current_tsr)
    append!(cp, sum(solution_fields.Cp))
end

# If needed, you can plot the Cp x TSR curve by using Plots package
#using Plots
#display(plot(tsr, cp, xlabel = "TSR", ylabel = "Cp", label = "Albatross.jl", dpi = 600, lw = 3))
#display(scatter!(tsr_exp, cp_exp, label = "Experimental", lw = 3, mc = :black))
