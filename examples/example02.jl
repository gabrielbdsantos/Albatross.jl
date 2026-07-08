#=
Example for a straight-bladed vertical axis wind turbine (VAWT) 
based on the experimental turbine reported by Li et al. in 
*Study on power performance for straight-bladed vertical axis 
wind turbine by field and wind tunnel test* (Renewable Energy, 2016).

The example sets up a 2-bladed H-Darrieus turbine with fixed pitch,
NACA 0021 airfoil section, and the DMST workflow used to estimate the
power coefficient as a function of tip-speed ratio.

# References
- Li, Q. et al. (2016). Renewable Energy 90:291–300.
=#
using Albatross
using AirfoilDefinitions
using NNFoil: KulfanParameters
using Printf

environment = Environment(
    ConstantPropertyFluid(),
    UniformInflow(8)
)

blade_section = BladeSection(
    shape = KulfanParameters(coordinates(NACA4("0021"))),
    chord = 0.265,
    reference_point = 0.265 / 5,
    radial_position = 1.0,
    spanwise_position = 0.0,
    pitch = deg2rad(-6.0)
)

aerodynamics = NeuralSectionAerodynamics(; model_size = :xsmall)

blade = UniformStraightBlade(
    section = blade_section,
    span = 1.2
)

omegas = 8.0:1.0:24.0

momentum = SteirosHultmark()

options = DMSTSolverOptions()

println("=" ^ 65)
@printf("  %-8s  %-8s %-8s  %-10s  %-10s  %-10s\n", "omega", "TSR", "solidity", "Cp total", "Cp up", "Cp down")
println("=" ^ 65)

tsr_plot = Float64[]
cp_plot = Float64[]

for omega in omegas
    global tsr_plot, cp_plot
    kinematics = ConstantAngularVelocity(omega)
    turbine = UniformBladeHDarrieus(blade = blade,
    kinematics = kinematics,
    num_blades = 2)
    grid = DMSTGrid(
    azimuthal = UniformAzimuthalGrid(36),
    spanwise = UniformSpanwiseGrid(turbine, 1))
    tsr     = omega * blade_section.radial_position / environment.inflow.U
    solidity = turbine.num_blades*blade_section.chord/blade_section.radial_position
    dmst = DMST(turbine, environment, momentum, aerodynamics, grid, options)
    solution = solve(dmst)
    solution_fields = evaluate_streamtube_fields(solution)

    n       = length(solution_fields.Cp) ÷ 2
    Cp_tot  = sum(solution_fields.Cp)
    Cp_up   = sum(solution_fields.Cp[1:n])
    Cp_dn   = sum(solution_fields.Cp[n+1:end])

    append!(tsr_plot, tsr)
    append!(cp_plot, sum(solution_fields.Cp))

    @printf("  %-8.2f  %-8.3f %-8.2f  %-10.4f  %-10.4f  %-10.4f\n",
            omega, tsr, solidity, Cp_tot, Cp_up, Cp_dn)
end
println("=" ^ 65)

# If needed, you can plot the Cp x TSR curve by using Plots package
#=
using Plots

display(plot(tsr_plot, cp_plot, xlabel="TSR", ylabel="Cp", label="Standard DMST", dpi=600, lw=3))

# Experimental data
tsr_exp = [1.0115, 1.1097, 1.2079, 1.3061, 1.4113, 1.5166, 1.6009, 1.7131, 1.8043, 1.9166,
2.0077, 2.1130, 2.2041, 2.3233, 2.4073, 2.5193, 2.6103, 2.7222, 2.8129, 2.9177]
cp_exp = [0.0343, 0.0451, 0.0558, 0.0666, 0.0794, 0.0966, 0.1095, 0.1245, 0.1353, 0.1482,
0.1568, 0.1697, 0.1783, 0.1847, 0.1869, 0.1804, 0.1740, 0.1633, 0.1397, 0.1225]

display(scatter!(tsr_exp, cp_exp, label="Experimental", lw=3, mc=:black))
=#
