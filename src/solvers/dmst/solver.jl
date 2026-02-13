"""
    DMST <: AbstractSolver

Double-Multiple Streamtube (DMST) solver for Darrieus-type VAWTs.

`DMST` combines a turbine model, environmental conditions, a momentum/induction
model, a section aerodynamics model, and an azimuthal discretization method to
compute local loads and performance quantities over the upstream and downstream
half-rotations.

# Fields

- `turbine<:AbstractDarrieusTurbine`: Darrieus turbine model to be solved.
- `environment<:EnvironmentConditions`: Ambient/environmental conditions (fluid
  and inflow).
- `momentum<:AbstractMomentumTheory`: Momentum/induction submodel used to
  relate induction to thrust.
- `aerodynamics<:AbstractSectionAerodynamics`: Section aerodynamics model
  returning airfoil coefficients.
- `discretization<:AbstractDMSTDiscretization`: DMST azimuthal discretization
  (azimuth points and weights).

!!! note "Current limitations"

    The current `solve(::DMST)` implementation assumes a simplified
    turbine/blade representation and will be generalized as the geometry
    interfaces mature.
"""
@concrete struct DMST <: AbstractSolver
    turbine <: AbstractDarrieusTurbine
    environment <: EnvironmentConditions
    momentum <: AbstractMomentumTheory
    aerodynamics <: AbstractSectionAerodynamics
    discretization <: AbstractDMSTDiscretization
end

function DMST(
        ; turbine::T_turbine,
        environment::T_environment,
        momentum::T_momentum,
        aerodynamics::T_aerodynamics,
        discretization::T_discretization,
    ) where {
        T_turbine <: AbstractDarrieusTurbine,
        T_environment <: EnvironmentConditions,
        T_momentum <: AbstractMomentumTheory,
        T_aerodynamics <: AbstractSectionAerodynamics,
        T_discretization <: AbstractDMSTDiscretization,
    }
    return DMST(turbine, environment, momentum, aerodynamics, discretization)
end

"""
    solve(dmst::DMST) -> DMSTOutput

Run the DMST solver
The solution is obtained by solving, independently for each azimuthal point,
a nonlinear balance between:

- the thrust/drag relation implied by the momentum model, and
- the thrust coefficient computed from the aerodynamic streamtube evaluation.

# Arguments

- `dmst::DMST`: DMST solver configuration.

# Returns

- [`DMSTOutput`](@ref)

!!! note "Current limitations"

    The current implementation assumes a simplified turbine model and uniform
    blade representation. It will be generalized as blade indexing, spanwise
    variation, and full interface compliance are introduced.
"""
function solve(dmst::DMST)
    U_inf = velocity(dmst.environment.inflow)
    u0 = zeros(num_azimuths(dmst.discretization))

    function s_up(u)
        return streamtube(
            u,
            upstream_azimuths(dmst.discretization),
            upstream_deltas(dmst.discretization),
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

    sol_up = NonlinearSolve.solve(
        NonlinearSolve.NonlinearProblem{true}(f_up, u0),
        NonlinearSolve.SimpleNewtonRaphson()
    )

    U_wake = U_inf .* wake_velocity_ratio.(dmst.momentum, reverse(sol_up.u))
    function s_down(u)
        return streamtube(
            u,
            downstream_azimuths(dmst.discretization),
            downstream_deltas(dmst.discretization),
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

    sol_down = NonlinearSolve.solve(
        NonlinearSolve.NonlinearProblem{true}(f_down, u0),
        NonlinearSolve.SimpleNewtonRaphson()
    )

    return [s_up(sol_up.u); s_down(sol_down.u)]
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
    c = chord(blade, z)
    R = radial_pos(blade, z)
    H = height(blade)
    U_inf = velocity(ambient.inflow)

    # Mysterious coefficient. According to Ayati et. al. [1], this coefficient
    # assumes different values across the literature. Some studies adopt k = 2
    # and even k = 4.
    k = 1

    U_a = @. U_in * (1 - a)

    # Relative velocity experienced by the blade (Equation 8) and angle of
    # attack (Equation 7).
    U_r, aoa = local_flow_conditions(θ, U_a, ω, R)

    # Local Reynolds and Mach numbers.
    ρ = density(ambient.fluid)
    μ = viscosity(ambient.fluid)
    c_sound = speed_of_sound(ambient.fluid)
    Re = @. ρ * U_r * c / μ
    Ma = @. U_r / c_sound

    # Defines the local flow state.
    flow_state = LocalFlowState(aoa, Re, Ma)

    # Estimates the local lift and drag coefficients.
    aero_coeffs = aerodynamic_coefficients(
        aerodynamics, flow_state, section(blades(turbine), z)
    )
    Cl = aero_coeffs.Cl
    Cd = aero_coeffs.Cd

    # Tangential and normal force coefficients (Equation 9 and 10).
    Ct = @. Cl * sin(aoa) - Cd * cos(aoa)
    Cn = @. Cl * cos(aoa) + Cd * sin(aoa)

    # Instantaneous thrust (Equation 11).
    A_blade_surface = H * c
    q_local = @. (1 / 2) * ρ * A_blade_surface * U_r^2
    Th = @. q_local * -(Ct * cos(θ) + Cn * sin(θ))

    Cq = @. R * Ct
    Q = @. q_local * Cq

    # Instantaneous thrust coefficient (Equation 13).
    A_streamtube = @. H * R * Δθ * abs(sin(θ))
    q_streamtube = @. (1 / 2) * ρ * A_streamtube * U_in^2
    Cth = @. k * num_blades(turbine) / 2pi * (Δθ * Th) / q_streamtube

    # Instantaneous power coefficient (Equation 14).
    A_turbine = H * (2 * R)
    q_inf = @. (1 / 2) * ρ * A_turbine * U_inf^3
    Cp = @. k * (num_blades(turbine) / 2pi) * (Δθ * Q * ω) / q_inf

    return DMSTOutput(
        a = a, θ = θ, U_r = U_r, aoa = aoa, Re = Re, Ma = Ma, Cl = Cl, Cd = Cd,
        Ct = Ct, Cn = Cn, Th = Th, Cq = Cq, Q = Q, Cth = Cth, Cp = Cp,
    )
end

"""
    local_flow_conditions(θ, U, ω, R)

Compute the local relative velocity magnitude and angle of attack for a
blade section at the given conditions.

# Arguments

- `θ`: Azimuth angles (rad).
- `U`: Local axial/streamtube velocity at the rotor plane (m/s).
- `ω`: Rotor angular velocity (rad/s).
- `R`: Rotor radius (m).

# Returns

- `U_r`: Relative velocity magnitude (m/s).
- `aoa`: Angle of attack (rad).

# Notes

Sign conventions follow the current DMST implementation; changes to azimuth
reference or rotation direction should be reflected here consistently.
"""
function local_flow_conditions(θ, U, ω, R)
    Vt = @. -(ω * R + U * cos(θ))
    Vn = @. -U * sin(θ)

    U_r = @. sqrt(Vt^2 + Vn^2)
    aoa = @. atan(Vn, -Vt)

    return U_r, aoa
end
