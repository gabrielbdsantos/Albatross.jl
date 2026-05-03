"""
    solve(dmst::DMST)

Run the DMST solver.

The solution is obtained by solving, independently for each azimuthal point,
a nonlinear balance between the thrust predicted by the momentum model and
the thrust coefficient computed from the aerodynamic streamtube evaluation
[ayati2019doublemultiple,steiros2018drag](@cite).

# Arguments

- `dmst::DMST`: DMST solver configuration.

# Returns

- [`DMSTNonlinearSolution`](@ref)

# Note

The current implementation assumes a simplified turbine model and uniform blade
representation. It will be generalized as blade indexing, spanwise variation,
and full interface compliance are introduced.
"""
function solve(dmst::DMST)
    n_up = length(dmst.grid.azimuthal.upstream)
    n_down = length(dmst.grid.azimuthal.downstream)

    STATS_TYPE = DMSTSolveStats{Bool, Float64, Int64, Float64}
    stats_up = StructArrays.StructVector{STATS_TYPE}(undef, n_up)
    stats_down = StructArrays.StructVector{STATS_TYPE}(undef, n_down)

    a_up = Vector{Float64}(undef, n_up)
    a_down = Vector{Float64}(undef, n_down)

    U_inf = velocity(dmst.environment.inflow)
    ctx_up = make_streamtube_context(
        points(dmst.grid.azimuthal.upstream),
        weights(dmst.grid.azimuthal.upstream),
        U_inf,
        dmst.turbine,
        dmst.environment,
        dmst.aerodynamics
    )
    solve_streamtubes_uncoupled!(a_up, stats_up, ctx_up, dmst.momentum, dmst.options)

    U_wake = U_inf .* wake_velocity_ratio.(dmst.momentum, reverse(a_up))
    ctx_down = make_streamtube_context(
        points(dmst.grid.azimuthal.downstream),
        weights(dmst.grid.azimuthal.downstream),
        U_wake,
        dmst.turbine,
        dmst.environment,
        dmst.aerodynamics
    )
    solve_streamtubes_uncoupled!(a_down, stats_down, ctx_down, dmst.momentum, dmst.options)

    return DMSTNonlinearSolution(a_up, a_down, ctx_up, ctx_down, stats_up, stats_down)
end

function solve_streamtubes_uncoupled!(
        a::AbstractVector{<:Real},
        stats::AbstractVector{<:DMSTSolveStats},
        ctx::StreamtubeContext,
        momentum::AbstractMomentumTheory,
        options::DMSTSolverOptions,
    )
    a_min, a_max = options.solution_bounds
    current_u = zero(_getindex(ctx.θ, 1))

    for i in axes(ctx.θ, 1)
        residual(u, _) = (
            drag_coefficient(momentum, u) - evaluate_streamtube_thrust(u, ctx, i)
        )

        prob = NonlinearSolve.NonlinearProblem(residual, current_u)
        sol = NonlinearSolve.solve(
            prob,
            alg = options.algorithm,
            abstol = options.abstol,
            reltol = options.reltol,
            maxiters = options.maxiters
        )

        stats.converged[i] = (
            NonlinearSolve.SciMLBase.successful_retcode(sol.retcode) && isfinite(sol.u)
        )
        stats.residual[i] = sol.resid

        # NOTE:`AbstractSimpleNonlinearSolveAlgorithm` returns `sol.stats =
        # nothing`. So, there is currently no way to get the number of
        # iterations for such a case. Need to check this later.
        stats.num_iters[i] = (
            options.algorithm isa
                NonlinearSolve.SimpleNonlinearSolve.AbstractSimpleNonlinearSolveAlgorithm
                ? 0
                : sol.stats.nsteps
        )

        a[i] = current_u = clamp(stats.converged[i] ? sol.u : current_u, a_min, a_max)
    end

    return nothing
end

function evaluate_streamtube_thrust(a, ctx::StreamtubeContext, i::Int)
    U_in = _getindex(ctx.U_in, i)

    U_r, aoa = _local_kinematics(a, U_in, ctx.ω, ctx.R, ctx.sinθ[i], ctx.cosθ[i])
    _, _, Cl, Cd = _local_aerodynamics(
        U_r, aoa, ctx.c, ctx.ρ, ctx.μ, ctx.c_sound, ctx.aerodynamics, ctx.section
    )
    Ct, Cn = _section_force_coefficients(aoa, Cl, Cd)
    _, Cth = _section_thrust(
        U_r, U_in, Ct, Cn, ctx.B, ctx.H, ctx.R, ctx.c, ctx.ρ,
        ctx.Δθ[i], ctx.sinθ[i], ctx.cosθ[i], ctx.abs_sinθ[i]
    )

    return Cth
end
