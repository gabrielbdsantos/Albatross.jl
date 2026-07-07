"""
    evaluate_streamtube_fields(a, θ, Δθ, U_in, turbine, environment,
        aerodynamics)

Evaluate aerodynamic and performance fields at azimuth collocation points.

# Arguments

- `a`: Induction factor(s) (–).
- `θ`: Azimuth collocation points (rad).
- `Δθ`: Azimuthal weights (rad).
- `U_in`: Incoming streamtube velocity used by the momentum balance (m/s).
- `turbine`: Turbine model.
- `environment`: Environmental conditions.
- `aerodynamics`: Section aerodynamics model.

# Returns

- `StructVector{DMSTStreamtubeFields}` evaluated at each `θ`.

# See Also

[`build_streamtube_contexts`](@ref), [`DMSTStreamtubeFields`](@ref).
"""
function evaluate_streamtube_fields(a, θ, Δθ, U_in, turbine, environment, aerodynamics)
    ctxs = build_streamtube_contexts(θ, Δθ, U_in, turbine, environment, aerodynamics)
    return evaluate_streamtube_fields(a, ctxs)
end

"""
    evaluate_streamtube_fields(a, ctxs)

Evaluate aerodynamic and performance fields from induction factors and a
precomputed streamtube context collection.

# Arguments

- `a`: Induction factor(s) (–).
- `ctxs::AbstractVector{<:DMSTStreamtubeContext}`: Streamtube invariants and
  model parameters returned by [`build_streamtube_contexts`](@ref).

# Returns

- `StructVector{DMSTStreamtubeFields}` evaluated at each collocation point in
  `ctxs.θ`.

# See Also

[`build_streamtube_contexts`](@ref), [`DMSTStreamtubeContext`](@ref),
[`DMSTStreamtubeFields`](@ref).
"""
function evaluate_streamtube_fields(a, ctxs::AbstractVector{<:DMSTStreamtubeContext})
    U_r, aoa = _local_kinematics(a, ctxs.U_in, ctxs.ω, ctxs.R, ctxs.sinθ, ctxs.cosθ, pitch.(ctxs.section))
    Re, Ma, Cl, Cd = _local_aerodynamics(
        U_r, aoa, ctxs.c, ctxs.ρ, ctxs.μ, ctxs.v_sound,
        ctxs.aerodynamics, ctxs.section
    )
    Ct, Cn = _section_force_coefficients(aoa, Cl, Cd)
    Th, Cth = _section_thrust(
        U_r, ctxs.U_in, Ct, Cn, ctxs.B, ctxs.H, ctxs.R, ctxs.c, ctxs.ρ,
        ctxs.Δθ, ctxs.sinθ, ctxs.cosθ, ctxs.abs_sinθ
    )
    Q, Cq = _section_torque(U_r, Ct, ctxs.H, ctxs.R, ctxs.c, ctxs.ρ)
    P, Cp = _section_power(
        Q, ctxs.ω, ctxs.H, ctxs.R, ctxs.ρ, ctxs.U_inf, ctxs.Δθ, ctxs.B
    )

    return StructVector{DMSTStreamtubeFields}(
        (a, ctxs.θ, U_r, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Q, P, Cth, Cq, Cp)
    )
end

"""
    evaluate_streamtube_fields(sol)

Postprocess a nonlinear DMST solution into aerodynamic and performance fields.

# Arguments

- `sol::DMSTNonlinearSolution`: Nonlinear solution from [`solve`](@ref).

# Returns

- Concatenated upstream and downstream `StructVector{DMSTStreamtubeFields}`.

# See Also

[`solve`](@ref), [`DMSTNonlinearSolution`](@ref).
"""
evaluate_streamtube_fields(sol::DMSTNonlinearSolution) =
    evaluate_streamtube_fields([sol.a_up; sol.a_down], [sol.ctxs_up; sol.ctxs_down])
