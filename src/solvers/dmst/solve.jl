"""
    solve(dmst::DMST)

Run the DMST solver.

The solution is obtained by solving, independently for each azimuthal point,
a nonlinear balance between the thrust predicted by the momentum model and
the thrust coefficient computed from the aerodynamic streamtube evaluation.

# Arguments

- `dmst::DMST`: DMST solver configuration.

# Returns

- [`DMSTSolution`](@ref), containing:
    - `upstream`: upstream half-cycle [`DMSTStreamtubeOutput`](@ref)
    - `downstream`: downstream half-cycle [`DMSTStreamtubeOutput`](@ref)
    - `integrated`: integrated/global quantities (currently `nothing`)
    - `stats`: solver diagnostics [`DMSTSolveStats`](@ref)

!!! note "Current limitations"

    The current implementation assumes a simplified turbine model and uniform
    blade representation. It will be generalized as blade indexing, spanwise
    variation, and full interface compliance are introduced.
"""
function solve(dmst::DMST)
    U_inf = velocity(dmst.environment.inflow)
    ctx_up = make_streamtube_context(
        points(dmst.grid.azimuthal.upstream),
        weights(dmst.grid.azimuthal.upstream),
        U_inf,
        dmst.turbine,
        dmst.environment,
        dmst.aerodynamics
    )

    a_up, up_stats = _solve_streamtubes_uncoupled(ctx_up, dmst.momentum, dmst.options)
    up_streamtube = evaluate_streamtube(a_up, ctx_up)

    U_wake = U_inf .* wake_velocity_ratio.(dmst.momentum, reverse(a_up))
    ctx_down = make_streamtube_context(
        points(dmst.grid.azimuthal.downstream),
        weights(dmst.grid.azimuthal.downstream),
        U_wake,
        dmst.turbine,
        dmst.environment,
        dmst.aerodynamics
    )

    a_down, down_stats = _solve_streamtubes_uncoupled(ctx_down, dmst.momentum, dmst.options)
    down_streamtube = evaluate_streamtube(a_down, ctx_down)

    stats = DMSTSolveStats(
        upstream = up_stats,
        downstream = down_stats,
        coupling_iters = 0,
        coupling_residual = Inf,
        coupling_converged = true,
        elapsed_time = 0.0
    )

    return DMSTSolution(
        upstream = up_streamtube,
        downstream = down_streamtube,
        integrated = nothing,
        stats = stats
    )
end

function _solve_streamtubes_uncoupled(
        ctx::StreamtubeContext,
        momentum::AbstractMomentumTheory,
        options::DMSTSolverOptions
    )
    a = similar(ctx.θ)
    a_min, a_max = options.solution_bounds
    current_u = zero(_getindex(ctx.θ, 1))

    stats = StreamtubeSolveStats(length(ctx.θ))

    for i in axes(ctx.θ, 1)
        residual(u, _) = (
            drag_coefficient(momentum, u) - _evaluate_streamtube_thrust(u, ctx, i)
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

        # NOTE:NonlinearSolve.SimpleNewtonRaphson() returns `nothing` for sol.stats.
        # Thus far there is no way to get the number of iterations.
        # Need to check this later.
        stats.num_iters[i] = 0 # sol.stats.nsteps

        a[i] = current_u = clamp(stats.converged[i] ? sol.u : current_u, a_min, a_max)
    end

    return a, stats
end

"""
    evaluate_streamtube(a, θ, Δθ, U_in, turbine, environment, aerodynamics)

Evaluate DMST quantities for a set of azimuthal collocation points.

Given an induction factor vector `a` at azimuth angles `θ` with associated
azimuthal weights `Δθ`, this function computes local flow conditions, section
aerodynamic coefficients, force components, and nondimensional performance
contributions for a single streamtube evaluation (upstream or downstream).

# Arguments

- `a`: Induction factor(s) (-).
- `θ`: Azimuth angles (rad).
- `Δθ`: Azimuthal weights or interval sizes (rad), size-compatible with `θ`.
- `U_in`: Incoming streamtube velocity used by the momentum balance (m/s).
- `turbine`: Turbine model (Darrieus-type).
- `environment`: Environmental conditions (fluid and inflow).
- `aerodynamics`: Section aerodynamics model.

# Returns

- [`DMSTStreamtubeOutput`](@ref) with field values evaluated at each `θ`.
"""
function evaluate_streamtube(a, θ, Δθ, U_in, turbine, environment, aerodynamics)
    ctx = make_streamtube_context(θ, Δθ, U_in, turbine, environment, aerodynamics)
    return evaluate_streamtube(a, ctx)
end

function evaluate_streamtube(a, ctx::StreamtubeContext)
    U_r, aoa = _local_kinematics(a, ctx.U_in, ctx.ω, ctx.R, ctx.sinθ, ctx.cosθ)
    Re, Ma, Cl, Cd = _local_aerodynamics(
        U_r, aoa, ctx.c, ctx.ρ, ctx.μ, ctx.c_sound, ctx.aerodynamics, ctx.section
    )
    Ct, Cn = _section_force_coefficients(aoa, Cl, Cd)
    Th, Cth = _section_thrust(
        U_r, ctx.U_in, Ct, Cn, ctx.B, ctx.H, ctx.R, ctx.c, ctx.ρ,
        ctx.Δθ, ctx.sinθ, ctx.cosθ, ctx.abs_sinθ
    )
    Q, Cq = _section_torque(U_r, Ct, ctx.H, ctx.R, ctx.c, ctx.ρ)
    P, Cp = _section_power(Q, ctx.ω, ctx.H, ctx.R, ctx.ρ, ctx.U_inf, ctx.Δθ, ctx.B)

    return DMSTStreamtubeOutput(
        a = a, θ = ctx.θ, U_r = U_r, aoa = aoa, Re = Re, Ma = Ma, Cl = Cl, Cd = Cd,
        Ct = Ct, Cn = Cn, Th = Th, Q = Q, P = P, Cth = Cth, Cq = Cq, Cp = Cp,
    )
end

function _evaluate_streamtube_thrust(a, ctx::StreamtubeContext, i::Int)
    U_in = _getindex(ctx.U_in, i)

    U_r, aoa = _local_kinematics(a, U_in, ctx.ω, ctx.R, ctx.sinθ[i], ctx.cosθ[i])

    # NOTE: Cl and Cd are one-sized vectors. Need to check this later and
    # perhaps update NNFoil.jl so that it handles scalar inputs properly.
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
