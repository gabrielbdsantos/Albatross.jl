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

- [`DMSTNonlinearSolution`](@ref), containing upstream and downstream
  induction factors, solve contexts, and per-streamtube nonlinear diagnostics.

!!! note "Current limitations"

    The current implementation assumes a simplified turbine model and uniform
    blade representation. It will be generalized as blade indexing, spanwise
    variation, and full interface compliance are introduced.

# See Also

[`evaluate_streamtube_fields`](@ref).
"""
function solve(dmst::DMST)
    n_up = length(dmst.grid.azimuthal.upstream)
    n_down = length(dmst.grid.azimuthal.downstream)

    stats_up = StructVector(DMSTSolveStats() for _ in 1:n_up)
    stats_down = StructVector(DMSTSolveStats() for _ in 1:n_down)

    a_up = Vector{Float64}(undef, n_up)
    a_down = Vector{Float64}(undef, n_down)

    U_inf = velocity(dmst.environment.inflow)
    ctxs_up = build_streamtube_contexts(
        points(dmst.grid.azimuthal.upstream),
        weights(dmst.grid.azimuthal.upstream),
        U_inf,
        dmst.turbine,
        dmst.environment,
        dmst.aerodynamics,
        dmst.loss
    )
    solve_streamtubes_uncoupled!(a_up, stats_up, ctxs_up, dmst.momentum, dmst.options)

    U_wake = U_inf .* wake_velocity_ratio.(dmst.momentum, reverse(a_up))
    ctxs_down = build_streamtube_contexts(
        points(dmst.grid.azimuthal.downstream),
        weights(dmst.grid.azimuthal.downstream),
        U_wake,
        dmst.turbine,
        dmst.environment,
        dmst.aerodynamics,
        dmst.loss
    )
    solve_streamtubes_uncoupled!(a_down, stats_down, ctxs_down, dmst.momentum, dmst.options)

    return DMSTNonlinearSolution(a_up, a_down, ctxs_up, ctxs_down, stats_up, stats_down)
end

function solve_streamtubes_uncoupled!(
        a::AbstractVector{<:Real},
        stats::AbstractVector{<:DMSTSolveStats},
        contexts::AbstractVector{<:DMSTStreamtubeContext},
        momentum::AbstractMomentumTheory,
        options::DMSTSolverOptions,
    )
    a_min, a_max = options.induction_bounds
    current_u = zero(first(contexts.θ))

    for i in eachindex(contexts)
        residual(u, _) = (
            thrust_coefficient(momentum, u) - _streamtube_thrust_coefficient(u, contexts[i])
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

function _streamtube_thrust_coefficient(a, ctx::DMSTStreamtubeContext)
    U_r, aoa = _local_kinematics(a, ctx)
    aoa = _apply_curvature(aoa, U_r, ctx)
    _, _, Cl, Cd = _local_aerodynamics(U_r, aoa, ctx)
    Ct, Cn = _section_force_coefficients(aoa, Cl, Cd)
    _, Cth = _section_thrust(U_r, Ct, Cn, ctx)
    return Cth
end
