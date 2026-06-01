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
using BenchmarkTools
using Printf
using Plots

environment = Environment(
    ConstantPropertyFluid(),
    UniformInflow(12)
)

blade_section = BladeSection(
    shape = KulfanParameters(coordinates(NACA4("0021"))),
    chord = 0.25,
    reference_point = 0.25 / 4,
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

display(plot(tsr_plot, cp_plot, xlabel="TSR", ylabel="Cp", label="Standard", dpi=600, lw=3))
