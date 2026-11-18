"""
    evaluate_streamtube_fields(a, θ, Δθ, U_in, turbine, environment,
        aerodynamics, submodels)

Evaluate aerodynamic and performance fields at azimuth collocation points.

# Arguments

- `a`: Induction factor(s) (–).
- `θ`: Azimuth collocation points (rad).
- `Δθ`: Azimuthal weights (rad).
- `U_in`: Incoming streamtube velocity used by the momentum balance (m/s).
- `turbine`: Turbine model.
- `environment`: Environmental conditions.
- `aerodynamics`: Section aerodynamics model.
- `submodels::DMSTSubmodels`: Submodels that modify the DMST evaluation.

# Returns

- `StructVector{DMSTStreamtubeFields}` evaluated at each `θ`.

# See Also

[`build_streamtube_contexts`](@ref), [`DMSTStreamtubeFields`](@ref).
"""
function evaluate_streamtube_fields(
        a, θ, Δθ, U_in, turbine, environment, aerodynamics, submodels
    )
    ctxs = build_streamtube_contexts(
        θ, Δθ, U_in, turbine, environment, aerodynamics, submodels
    )
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
    U_r, φ = _local_kinematics(a, ctxs.U_in, ctxs.ω, ctxs.R, ctxs.sinθ, ctxs.cosθ)
    aoa = _effective_aoa(ctxs.submodels, φ, U_r, ctxs.ω, ctxs.R, ctxs.c, ctxs.section)
    Re, Ma, Cl, Cd = _local_aerodynamics(
        U_r, aoa, ctxs.c, ctxs.ρ, ctxs.μ, ctxs.v_sound,
        ctxs.aerodynamics, ctxs.section
    )
    Ct, Cn = _section_force_coefficients(φ, Cl, Cd)
    Th, Cth = _section_thrust(
        U_r, ctxs.U_in, Ct, Cn, ctxs.B, ctxs.H, ctxs.R, ctxs.c, ctxs.ρ,
        ctxs.Δθ, ctxs.sinθ, ctxs.cosθ, ctxs.abs_sinθ
    )
    Q, Cq = _section_torque(U_r, Ct, ctxs.H, ctxs.R, ctxs.c, ctxs.ρ)
    P, Cp = _section_power(
        Q, ctxs.ω, ctxs.H, ctxs.R, ctxs.ρ, ctxs.U_inf, ctxs.Δθ, ctxs.B
    )

    return StructVector{DMSTStreamtubeFields}(
        (a, ctxs.θ, U_r, φ, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Q, P, Cth, Cq, Cp)
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

"""
    evaluate_streamtube_fields_sequential(sol::DMSTNonlinearSolution)

Sequential counterpart to [`evaluate_streamtube_fields`](@ref) for stateful
section aerodynamics models — i.e. dynamic-stall corrections that depend on
an angle-of-attack history, such as
[`GormontBergDynamicStallSectionAerodynamics`](@ref).

A stateful model's `Cl`/`Cd` depend on the order in which streamtubes are
visited, so they cannot be recovered from a plain array broadcast over the
converged induction factors (what [`evaluate_streamtube_fields`](@ref) does).
This function instead [`reset_state!`](@ref)s the aerodynamics model and
replays the upstream and downstream streamtubes *in order*, calling
[`advance_state!`](@ref) after each converged induction factor — exactly
mirroring what `solve(::DMST)` did internally, so it reproduces the same
`Cl`/`Cd` trajectory.

For stateless models this gives the same result as
[`evaluate_streamtube_fields`](@ref), just computed one streamtube at a time.

# Arguments

- `sol::DMSTNonlinearSolution`: Nonlinear solution from [`solve`](@ref).

# Returns

- Concatenated upstream and downstream `StructVector{DMSTStreamtubeFields}`.

# See Also

[`solve`](@ref), [`DMSTNonlinearSolution`](@ref),
[`evaluate_streamtube_fields`](@ref).
"""
function evaluate_streamtube_fields_sequential(sol::DMSTNonlinearSolution)
    a = [sol.a_up; sol.a_down]
    ctxs = [sol.ctxs_up; sol.ctxs_down]

    reset_state!(first(ctxs).aerodynamics)

    n = length(ctxs)
    θ = similar(a); U_r = similar(a); φ = similar(a); aoa = similar(a)
    Re = similar(a); Ma = similar(a); Cl = similar(a); Cd = similar(a)
    Ct = similar(a); Cn = similar(a); Th = similar(a); Q = similar(a)
    P = similar(a); Cth = similar(a); Cq = similar(a); Cp = similar(a)

    for i in 1:n
        ctx = ctxs[i]
        U_r_i, φ_i = _local_kinematics(a[i], ctx)
        aoa_i = _effective_aoa(ctx.submodels, φ_i, U_r_i, ctx)
        Re_i, Ma_i, Cl_i, Cd_i = _local_aerodynamics(U_r_i, aoa_i, ctx)
        Ct_i, Cn_i = _section_force_coefficients(φ_i, Cl_i, Cd_i)
        Th_i, Cth_i = _section_thrust(U_r_i, Ct_i, Cn_i, ctx)
        Q_i, Cq_i = _section_torque(U_r_i, Ct_i, ctx)
        P_i, Cp_i = _section_power(Q_i, ctx)

        advance_state!(ctx.aerodynamics, aoa_i)

        θ[i] = ctx.θ; U_r[i] = U_r_i; φ[i] = φ_i; aoa[i] = aoa_i
        Re[i] = Re_i; Ma[i] = Ma_i; Cl[i] = Cl_i; Cd[i] = Cd_i
        Ct[i] = Ct_i; Cn[i] = Cn_i; Th[i] = Th_i; Q[i] = Q_i
        P[i] = P_i; Cth[i] = Cth_i; Cq[i] = Cq_i; Cp[i] = Cp_i
    end

    return StructVector{DMSTStreamtubeFields}(
        (a, θ, U_r, φ, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Q, P, Cth, Cq, Cp)
    )
end
