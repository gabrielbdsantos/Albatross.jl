"""
    evaluate_aerodynamic_fields(solution)
    evaluate_aerodynamic_fields(a, ctx)
    evaluate_aerodynamic_fields(a, θ, Δθ, U_in, turbine, environment,
        aerodynamics)

Evaluate DMST quantities for a set of azimuthal collocation points.

Given an induction factor vector `a` at azimuth angles `θ` with associated
azimuthal weights `Δθ`, this function computes local flow conditions, section
aerodynamic coefficients, force components, and nondimensional performance
contributions for a single streamtube evaluation (upstream or downstream).

# Arguments

- `a`: Induction factor(s) (-).
- `ctx::StreamtubeContext`: Streamtube invariants.
- `solution::DMSTNonlinearSolution`: Nonlinear solution.
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
function evaluate_aerodynamic_fields(a, θ, Δθ, U_in, turbine, environment, aerodynamics)
    ctx = make_streamtube_context(θ, Δθ, U_in, turbine, environment, aerodynamics)
    return evaluate_aerodynamic_fields(a, ctx)
end

function evaluate_aerodynamic_fields(a, ctx::StreamtubeContext)
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

    return StructArrays.StructVector(
        DMSTStreamtubeFields.(
            a, ctx.θ, U_r, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Q, P, Cth, Cq, Cp
        )
    )
end

function evaluate_aerodynamic_fields(solution::DMSTNonlinearSolution)
    up = evaluate_aerodynamic_fields(solution.a_up, solution.ctx_up)
    down = evaluate_aerodynamic_fields(solution.a_down, solution.ctx_down)
    return [up; down]
end
