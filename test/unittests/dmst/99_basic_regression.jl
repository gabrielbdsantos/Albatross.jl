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
        options = DMSTSolverOptions()
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

    @test sol isa Albatross.DMSTNonlinearSolution
    @test sol.a_up isa AbstractVector
    @test sol.a_down isa AbstractVector
    @test sol.ctx_up isa Albatross.StreamtubeContext
    @test sol.ctx_down isa Albatross.StreamtubeContext
    @test sol.stats_up isa AbstractVector{<:Albatross.DMSTSolveStats}
    @test sol.stats_down isa AbstractVector{<:Albatross.DMSTSolveStats}

    @test all(sol.stats_up.converged)
    @test all(sol.stats_down.converged)
    @test all(isfinite, sol.stats_up.residual)
    @test all(isfinite, sol.stats_down.residual)

    nup = length(dmst.grid.azimuthal.upstream)
    ndn = length(dmst.grid.azimuthal.downstream)
    nexpected = nup + ndn

    @test length(sol.stats_up.converged) == nup
    @test length(sol.stats_up.residual) == nup
    @test length(sol.stats_up.num_iters) == nup
    @test length(sol.stats_up.elapsed_time) == nup

    @test length(sol.stats_down.converged) == ndn
    @test length(sol.stats_down.residual) == ndn
    @test length(sol.stats_down.num_iters) == ndn
    @test length(sol.stats_down.elapsed_time) == ndn

    @test length(sol.a_up) == nup
    @test length(sol.a_down) == ndn

    @test all(0.0 .<= sol.a_up .<= 1.0)
    @test all(0.0 .<= sol.a_down .<= 1.0)

    aero_fields = evaluate_streamtube_fields(sol)

    @test length(aero_fields.a) == nexpected
    @test length(aero_fields.θ) == nexpected
    @test length(aero_fields.Cth) == nexpected
    @test length(aero_fields.Cp) == nexpected

    @test all(isfinite, aero_fields.a)
    @test all(isfinite, aero_fields.Cth)
    @test all(isfinite, aero_fields.Cp)
end

@testset "Momentum model -- $M" for M in subtypes(AbstractMomentumTheory)
    dmst = make_dmst_case(; momentum = M())
    sol = solve(dmst)
    aero_fields = evaluate_streamtube_fields(sol)

    @test all(isfinite, aero_fields.a)
    @test all(isfinite, aero_fields.Cth)
    @test all(isfinite, aero_fields.Cp)
end

@testset "Fallback on non-converged streamtubes" begin
    dmst = make_dmst_case(; options = DMSTSolverOptions(maxiters = 1))
    sol = solve(dmst)
    aero_fields = evaluate_streamtube_fields(sol)

    @test any(.!sol.stats_up.converged) || any(.!sol.stats_down.converged)

    for field in fieldnames(DMSTStreamtubeFields)
        @test all(isfinite, getproperty(aero_fields, field))
    end
end

@testset "Converged solution respects induction bounds" begin
    lo, hi = 0.05, 0.2
    dmst = make_dmst_case(; options = DMSTSolverOptions(induction_bounds = (lo, hi)))
    sol = solve(dmst)
    aero_fields = evaluate_streamtube_fields(sol)

    @test all((lo .<= aero_fields.a) .& (aero_fields.a .<= hi))
end

@testset "Fallback solution respects induction bounds" begin
    lo, hi = 0.05, 0.2
    dmst = make_dmst_case(;
        options = DMSTSolverOptions(maxiters = 1, induction_bounds = (lo, hi))
    )
    sol = solve(dmst)
    aero_fields = evaluate_streamtube_fields(sol)

    @test any(.!sol.stats_up.converged) || any(.!sol.stats_down.converged)
    @test all((lo .<= aero_fields.a) .& (aero_fields.a .<= hi))
end

@testset "Repeatability" begin
    dmst = make_dmst_case()

    sol1 = solve(dmst)
    sol2 = solve(dmst)

    @test sol1.a_up ≈ sol2.a_up
    @test sol1.a_down ≈ sol2.a_down

    aero_fields1 = evaluate_streamtube_fields(sol1)
    aero_fields2 = evaluate_streamtube_fields(sol2)

    for field in fieldnames(DMSTStreamtubeFields)
        @test getproperty(aero_fields1, field) ≈ getproperty(aero_fields2, field)
    end
end

@testset "Solution regression" begin
    dmst = make_dmst_case()
    sol = solve(dmst)
    aero_fields = evaluate_streamtube_fields(sol)

    @test aero_fields.a ≈ DMST_SNAPSHOT.a
    @test aero_fields.Cth ≈ DMST_SNAPSHOT.Cth
    @test aero_fields.Cp ≈ DMST_SNAPSHOT.Cp
end
