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
    - `upstream`: upstream-half [`DMSTOutput`](@ref)
    - `downstream`: downstream-half [`DMSTOutput`](@ref)
    - `integrated`: integrated/global quantities (currently `nothing`)
    - `stats`: [`DMSTSolveStats`](@ref) diagnostics

!!! note "Backward compatibility"

    Legacy field-style accessors (e.g. `sol.a`, `sol.Cth`, `sol.Cp`) are still
    accessible and return concatenated upstream + downstream arrays.

!!! note "Current limitations"

    The current implementation assumes a simplified turbine model and uniform
    blade representation. It will be generalized as blade indexing, spanwise
    variation, and full interface compliance are introduced.
"""
function solve(dmst::DMST)
    U_inf = velocity(dmst.environment.inflow)

    function s_up(u)
        return streamtube(
            u,
            points(dmst.grid.azimuthal.upstream),
            weights(dmst.grid.azimuthal.upstream),
            U_inf,
            dmst.turbine,
            dmst.environment,
            dmst.aerodynamics
        )
    end

    function f_up(du, u, _)
        du .= drag_coefficient.(dmst.momentum, u) .- s_up(u).Cth
        return nothing
    end

    u0 = zeros(length(dmst.grid.azimuthal.upstream))
    sol_up = NonlinearSolve.solve(
        NonlinearSolve.NonlinearProblem{true}(f_up, u0),
        NonlinearSolve.SimpleNewtonRaphson()
    )

    U_wake = U_inf .* wake_velocity_ratio.(dmst.momentum, reverse(sol_up.u))
    function s_down(u)
        return streamtube(
            u,
            points(dmst.grid.azimuthal.downstream),
            weights(dmst.grid.azimuthal.downstream),
            U_wake,
            dmst.turbine,
            dmst.environment,
            dmst.aerodynamics
        )
    end

    function f_down(du, u, _)
        du .= drag_coefficient.(dmst.momentum, u) .- s_down(u).Cth
        return nothing
    end

    u0 = zeros(length(dmst.grid.azimuthal.downstream))
    sol_down = NonlinearSolve.solve(
        NonlinearSolve.NonlinearProblem{true}(f_down, u0),
        NonlinearSolve.SimpleNewtonRaphson()
    )

    up_stats = DMSTPassSolveStats(
        converged = NonlinearSolve.SciMLBase.successful_retcode(sol_up.retcode),
        num_iters = 0,
        residual_norm = LinearAlgebra.norm(sol_up.resid),
        elapsed_time = 0.0,
    )

    down_stats = DMSTPassSolveStats(
        converged = NonlinearSolve.SciMLBase.successful_retcode(sol_down.retcode),
        num_iters = 0,
        residual_norm = LinearAlgebra.norm(sol_down.resid),
        elapsed_time = 0.0,
    )

    stats = DMSTSolveStats(
        upstream = up_stats,
        downstream = down_stats,
        coupling_iters = 0,
        coupling_residual = Inf,
        coupling_converged = !dmst.options.enable_coupling,
        elapsed_time = 0.0
    )

    return DMSTSolution(
        upstream = s_up(sol_up.u),
        downstream = s_down(sol_down.u),
        integrated = nothing,
        stats = stats
    )
end

"""
    streamtube(a, θ, Δθ, U_in, turbine, ambient, aerodynamics) -> DMSTOutput

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
- `ambient`: Environmental conditions (fluid and inflow).
- `aerodynamics`: Section aerodynamics model.

# Returns

- [`DMSTOutput`](@ref) with field values evaluated at each `θ`.
"""
function streamtube(a, θ, Δθ, U_in, turbine, ambient, aerodynamics)
    z = nothing
    t = nothing
    ω = angular_velocity(kinematics(turbine), t)
    blade = blades(turbine)
    blade_section = section(blade, z)
    c = chord(blade, z)
    R = radial_pos(blade, z)
    H = span(blade)
    U_inf = velocity(ambient.inflow)
    ρ = density(ambient.fluid)
    μ = viscosity(ambient.fluid)
    c_sound = speed_of_sound(ambient.fluid)
    B = num_blades(turbine)
    sinθ = sin.(θ)
    cosθ = cos.(θ)
    abs_sinθ = abs.(sinθ)

    U_r, aoa = _local_kinematics(a, U_in, ω, R, sinθ, cosθ)
    Re, Ma, Cl, Cd = _local_aerodynamics(
        U_r, aoa, ρ, c, μ, c_sound, aerodynamics, blade_section
    )
    Ct, Cn = _section_force_coefficients(aoa, Cl, Cd)
    Th, Cth = _section_thrust(
        U_r, U_in, Ct, Cn, B, H, R, c, ρ, Δθ, sinθ, cosθ, abs_sinθ
    )
    Q, Cq = _section_torque(U_r, Ct, H, R, c, ρ)
    P, Cp = _section_power(Q, ω, H, R, ρ, U_inf, Δθ, B)

    return DMSTOutput(
        a = a, θ = θ, U_r = U_r, aoa = aoa, Re = Re, Ma = Ma, Cl = Cl, Cd = Cd,
        Ct = Ct, Cn = Cn, Th = Th, Cq = Cq, Q = Q, Cth = Cth, Cp = Cp,
    )
end

function _local_kinematics(a, U_in, ω, R, sinθ, cosθ)
    # Local induced velocity (Equation 1).
    U_a = @. U_in * (1 - a)

    # Relative velocity experienced by the blade (Equation 8) and angle of
    # attack (Equation 7).
    Vt = @. -(ω * R + U_a * cosθ)
    Vn = @. -U_a * sinθ

    U_r = @. sqrt(Vt^2 + Vn^2)
    aoa = @. atan(Vn, -Vt)

    return (; U_r, aoa)
end

function _local_aerodynamics(U_r, aoa, ρ, c, μ, c_sound, model, blade_section)
    Re = @. ρ * U_r * c / μ
    Ma = @. U_r / c_sound
    flow_state = LocalFlowState(aoa, Re, Ma)

    # Estimates the local lift and drag coefficients.
    aero_coeffs = aerodynamic_coefficients(model, flow_state, blade_section)

    return Re, Ma, aero_coeffs.Cl, aero_coeffs.Cd
end

function _section_force_coefficients(aoa, Cl, Cd)
    # Tangential and normal force coefficients (Equations 9 and 10).
    Ct = @. Cl * sin(aoa) - Cd * cos(aoa)
    Cn = @. Cl * cos(aoa) + Cd * sin(aoa)

    return (; Ct, Cn)
end

function _section_thrust(U_r, U_in, Ct, Cn, B, H, R, c, ρ, Δθ, sinθ, cosθ, abs_sinθ)
    k = 1

    # Instantaneous thrust (Equation 11).
    A_blade_surface = H * c
    q_local = @. 0.5 * ρ * A_blade_surface * U_r^2
    Th = @. q_local * -(Ct * cosθ + Cn * sinθ)

    # Instantaneous thrust coefficient (Equation 13).
    A_streamtube = @. H * R * Δθ * abs_sinθ
    q_streamtube = @. 0.5 * ρ * A_streamtube * U_in^2
    Cth = @. k * B / 2pi * (Δθ * Th) / q_streamtube

    return (; Th, Cth)
end

function _section_torque(U_r, Ct, H, R, c, ρ)
    A_blade_surface = H * c
    q_local = @. 0.5 * ρ * A_blade_surface * U_r^2
    Cq = @. R * Ct
    Q = @. q_local * Cq

    return (; Q, Cq)
end

function _section_power(Q, ω, H, R, ρ, U_inf, Δθ, B)
    k = 1
    P = @. Q * ω

    A_turbine = H * 2R
    q_inf = @. 0.5 * ρ * A_turbine * U_inf^3
    Cp = @. k * (B / 2pi) * (Δθ * P) / q_inf

    return (; P, Cp)
end
