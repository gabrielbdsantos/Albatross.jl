using Test
using Albatross
using AirfoilDefinitions
using DelimitedFiles
using NNFoil: KulfanParameters

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
        options = DMSTOptions()
    )
    environment = EnvironmentConditions(
        ConstantPropertyFluid(),
        UniformInflow(10.0),
    )

    blade_section = BladeSection(
        shape = KulfanParameters(coordinates(NACA4("0015"))),
        chord = 0.25,
        ref_point = 0.25 / 4,
        r = 1.0,
        z = 0.0,
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
    )
end

@testset "Basic regression" begin
    dmst = make_dmst_case()

    sol = solve(dmst)

    @test sol isa Albatross.DMSTSolution
    @test sol.upstream isa Albatross.DMSTOutput
    @test sol.downstream isa Albatross.DMSTOutput
    @test sol.stats isa Albatross.DMSTSolveStats
    @test sol.integrated === nothing

    @test sol.stats.upstream isa Albatross.UncoupledStreamtubeSolveStats
    @test sol.stats.downstream isa Albatross.UncoupledStreamtubeSolveStats
    @test all(sol.stats.upstream.converged)
    @test all(sol.stats.downstream.converged)
    @test all(isfinite, sol.stats.upstream.residual)
    @test all(isfinite, sol.stats.downstream.residual)
    @test sol.stats.coupling_iters == 0
    @test sol.stats.coupling_converged

    nup = length(dmst.grid.azimuthal.upstream)
    ndn = length(dmst.grid.azimuthal.downstream)
    nexpected = nup + ndn

    @test length(sol.stats.upstream.converged) == nup
    @test length(sol.stats.upstream.residual) == nup
    @test length(sol.stats.upstream.num_iters) == nup
    @test length(sol.stats.upstream.elapsed_time) == nup

    @test length(sol.stats.downstream.converged) == ndn
    @test length(sol.stats.downstream.residual) == ndn
    @test length(sol.stats.downstream.num_iters) == ndn
    @test length(sol.stats.downstream.elapsed_time) == ndn

    @test length(sol.upstream.a) == nup
    @test length(sol.downstream.a) == ndn

    # Keep these legacy tests for now
    @test length(sol.a) == nexpected
    @test length(sol.θ) == nexpected
    @test length(sol.Cth) == nexpected
    @test length(sol.Cp) == nexpected

    @test all(isfinite, sol.a)
    @test all(isfinite, sol.Cth)
    @test all(isfinite, sol.Cp)

    @test all(-1.0 .<= sol.a .<= 1.0)
end

@testset "Momentum model -- $M" for M in subtypes(AbstractMomentumTheory)
    dmst = make_dmst_case(; momentum = M())
    sol = solve(dmst)

    @test all(isfinite, sol.a)
    @test all(isfinite, sol.Cth)
    @test all(isfinite, sol.Cp)
end

@testset "Fallback on non-converged streamtubes" begin
    dmst = make_dmst_case(; options = DMSTOptions(maxiters = 1))
    sol = solve(dmst)

    @test any(.!sol.stats.upstream.converged) || any(.!sol.stats.downstream.converged)
    @test all(isfinite, sol.a)
    @test all(isfinite, sol.Cth)
    @test all(isfinite, sol.Cp)
end

@testset "Converged solution respects induction bounds" begin
    lo, hi = 0.05, 0.2
    dmst = make_dmst_case(; options = DMSTOptions(induction_bounds = (lo, hi)))
    sol = solve(dmst)

    @test all((lo .<= sol.a) .& (sol.a .<= hi))
end

@testset "Fallback solution respects induction bounds" begin
    lo, hi = 0.05, 0.2
    dmst = make_dmst_case(;
        options = DMSTOptions(maxiters = 1, induction_bounds = (lo, hi))
    )
    sol = solve(dmst)

    @test any(.!sol.stats.upstream.converged) || any(.!sol.stats.downstream.converged)
    @test all((lo .<= sol.a) .& (sol.a .<= hi))
end

@testset "Repeatability" begin
    dmst = make_dmst_case()

    sol1 = solve(dmst)
    sol2 = solve(dmst)

    @test sol1.a ≈ sol2.a
    @test sol1.Cth ≈ sol2.Cth
    @test sol1.Cp ≈ sol2.Cp
end

@testset "Solution regression" begin
    dmst = make_dmst_case()
    sol = solve(dmst)

    @test sol.a ≈ DMST_SNAPSHOT.a
    @test sol.Cth ≈ DMST_SNAPSHOT.Cth
    @test sol.Cp ≈ DMST_SNAPSHOT.Cp
end
