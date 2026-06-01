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
using BenchmarkTools
using Printf
using Plots

environment = Environment(
    ConstantPropertyFluid(),
    UniformInflow(8)
)

blade_section = BladeSection(
    shape = KulfanParameters(coordinates(NACA4("0021"))),
    chord = 0.265,
    reference_point = 0.265 / 4,
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

display(plot(tsr_plot, cp_plot, xlabel="TSR", ylabel="Cp", label="Standard", dpi=600, lw=3))
