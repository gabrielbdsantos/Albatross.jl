"""
    evaluate_streamtube_fields(a, θ, Δθ, U_in, turbine, environment,
        aerodynamics)

Evaluate aerodynamic and performance fields at azimuth collocation points.

# Arguments

- `a`: Induction factor(s) (-).
- `θ`: Azimuth collocation points (rad).
- `Δθ`: Azimuthal weights (rad).
- `U_in`: Incoming streamtube velocity used by the momentum balance (m/s).
- `turbine`: Turbine model.
- `environment`: Environmental conditions (fluid and inflow).
- `aerodynamics`: Section aerodynamics model.

# Returns

- `StructVector{DMSTStreamtubeFields}` evaluated at each `θ`.

# See Also

[`DMSTStreamtubeFields`](@ref)
"""
function evaluate_streamtube_fields(a, θ, Δθ, U_in, turbine, environment, aerodynamics)
    ctx = make_streamtube_context(θ, Δθ, U_in, turbine, environment, aerodynamics)
    return evaluate_streamtube_fields(a, ctx)
end

"""
    evaluate_streamtube_fields(a, ctx)

Evaluate aerodynamic and performance fields from induction factors and a
precomputed streamtube context.

# Arguments

- `a`: Induction factor(s) (-).
- `ctx::StreamtubeContext`: Streamtube invariants and model parameters.

# Returns

- `StructVector{DMSTStreamtubeFields}` evaluated at each collocation point in
  `ctx.θ`.

# See Also

[`make_streamtube_context`](@ref), [`DMSTStreamtubeFields`](@ref)
"""
function evaluate_streamtube_fields(a, ctx::StreamtubeContext)
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

    return StructVector(
        DMSTStreamtubeFields.(
            a, ctx.θ, U_r, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Q, P, Cth, Cq, Cp
        )
    )
end

"""
    evaluate_streamtube_fields(solution)

Postprocess a nonlinear DMST solution into aerodynamic and performance fields.

# Arguments

- `solution::DMSTNonlinearSolution`: Nonlinear solution from [`solve`](@ref).

# Returns

- Concatenated upstream and downstream `StructVector{DMSTStreamtubeFields}`.

# See Also

[`solve`](@ref), [`DMSTNonlinearSolution`](@ref)
"""
function evaluate_streamtube_fields(solution::DMSTNonlinearSolution)
    up = evaluate_streamtube_fields(solution.a_up, solution.ctx_up)
    down = evaluate_streamtube_fields(solution.a_down, solution.ctx_down)
    return [up; down]
end
