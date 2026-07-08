#=
Example for a straight-bladed vertical axis wind turbine (VAWT) 
based on the experimental turbine reported by Li et al. in 
*Power coefficient measurement on a 12 kW straight bladed vertical 
axis wind turbine* (Renewable Energy, 2011).

The example sets up a 3-bladed H-Darrieus turbine with fixed pitch,
NACA 0021 airfoil section, and the DMST workflow used to estimate the
power coefficient as a function of tip-speed ratio.

# References
- Kjellin, J. et al. (2011). Renewable Energy 36:3050-3053.
=#
using Albatross
using AirfoilDefinitions
using NNFoil: KulfanParameters
using Printf

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

omegas = 6.2963:1.0:17.0370

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
    num_blades = 3)
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

display(plot(tsr_plot, cp_plot, xlabel="TSR", ylabel="Cp", label="Standard", dpi=600, lw=3))

# Experimental data
tsr_exp = [1.7476, 1.8624, 1.9668, 2.1024, 2.2275, 2.3527, 2.4569, 2.5716, 2.6968, 2.8220, 2.9369, 3.0624, 3.1879,
3.3028, 3.4285, 3.5333, 3.6590, 3.7638, 3.9002, 4.0266, 4.1316, 4.2476, 4.3738, 4.4681]
cp_exp = [0.0532, 0.0681, 0.0830, 0.1085, 0.1383, 0.1596, 0.1830, 0.2043, 0.2277, 0.2489, 0.2638, 0.2702, 0.2787,
0.2915, 0.2872, 0.2872, 0.2830, 0.2787, 0.2660, 0.2319, 0.2149, 0.1787, 0.1532, 0.1489]

display(scatter!(tsr_exp, cp_exp, label="Experimental", lw=3, mc=:black))
=#
