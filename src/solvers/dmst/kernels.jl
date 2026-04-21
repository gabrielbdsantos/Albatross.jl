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

function _local_aerodynamics(U_r, aoa, c, ρ, μ, c_sound, model, blade_section)
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
    A_blade_surface = @. H * c
    q_local = @. 0.5 * ρ * A_blade_surface * U_r^2
    Th = @. q_local * -(Ct * cosθ + Cn * sinθ)

    # Instantaneous thrust coefficient (Equation 13).
    A_streamtube = @. H * R * Δθ * abs_sinθ
    q_streamtube = @. 0.5 * ρ * A_streamtube * U_in^2
    Cth = @. k * B / 2pi * (Δθ * Th) / q_streamtube

    return (; Th, Cth)
end

function _section_torque(U_r, Ct, H, R, c, ρ)
    A_blade_surface = @. H * c
    q_local = @. 0.5 * ρ * A_blade_surface * U_r^2
    Cq = @. R * Ct
    Q = @. q_local * Cq

    return (; Q, Cq)
end

function _section_power(Q, ω, H, R, ρ, U_inf, Δθ, B)
    k = 1
    P = @. Q * ω

    A_turbine = @. H * 2R
    q_inf = @. 0.5 * ρ * A_turbine * U_inf^3
    Cp = @. k * (B / 2pi) * (Δθ * P) / q_inf

    return (; P, Cp)
end
