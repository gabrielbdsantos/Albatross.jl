# Methods with explicit arguments {{{
function _local_kinematics(a, U_in, ω, R, sinθ, cosθ, β)
    U_a = @. U_in * (1 - a)

    Vt = @. -(ω * R + U_a * cosθ)
    Vn = @. -U_a * sinθ

    U_r = @. sqrt(Vt^2 + Vn^2)
    aoa = @. atan(Vn, -Vt) - β

    return (; U_r, aoa)
end

function _local_aerodynamics(U_r, aoa, c, ρ, μ, v_sound, model, blade_section)
    Re = @. ρ * U_r * c / μ
    Ma = @. U_r / v_sound
    Cl, Cd = aerodynamic_coefficients(model, blade_section, rad2deg.(aoa), Re)

    return (; Re, Ma, Cl, Cd)
end

function _section_force_coefficients(aoa, Cl, Cd)
    Ct = @. Cl * sin(aoa) - Cd * cos(aoa)
    Cn = @. Cl * cos(aoa) + Cd * sin(aoa)

    return (; Ct, Cn)
end

function _section_thrust(U_r, U_in, Ct, Cn, B, H, R, c, ρ, Δθ, sinθ, cosθ, abs_sinθ)
    A_blade_surface = @. H * c
    q_local = @. 0.5 * ρ * A_blade_surface * U_r^2
    Th = @. q_local * -(Ct * cosθ + Cn * sinθ)

    A_streamtube = @. H * R * Δθ * abs_sinθ
    q_streamtube = @. 0.5 * ρ * A_streamtube * U_in^2
    Cth = @. B / 2pi * (Δθ * Th) / q_streamtube

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
    P = @. Q * ω

    A_turbine = @. H * 2R
    q_inf = @. 0.5 * ρ * A_turbine * U_inf^3
    Cp = @. (B / 2pi) * (Δθ * P) / q_inf

    return (; P, Cp)
end

_apply_curvature(loss::LossModels, aoa, U_r, ω, R, c, section) = begin
    m = reference_point(section)
    β = pitch(section)
    @. aoa + aoa_correction(loss.curvature, ω, R, m, c, β, U_r)
end
_apply_curvature(::Nothing, aoa, ω, R, c, section, U_r) = aoa
# }}}
# Context-based methods {{{
function _local_kinematics(a, ctx::DMSTStreamtubeContext)
    U_a = ctx.U_in * (1 - a)

    Vt = -(ctx.ω * ctx.R + U_a * ctx.cosθ)
    Vn = -U_a * ctx.sinθ

    U_r = sqrt(Vt^2 + Vn^2)
    aoa = atan(Vn, -Vt) - pitch(ctx.section)

    return (; U_r, aoa)
end

function _local_aerodynamics(U_r, aoa, ctx::DMSTStreamtubeContext)
    Re = ctx.ρ * U_r * ctx.c / ctx.μ
    Ma = U_r / ctx.v_sound
    Cl, Cd = aerodynamic_coefficients(ctx.aerodynamics, ctx.section, rad2deg(aoa), Re)

    return (; Re, Ma, Cl, Cd)
end

function _section_thrust(U_r, Ct, Cn, ctx::DMSTStreamtubeContext)
    A_blade_surface = ctx.H * ctx.c
    q_local = 0.5 * ctx.ρ * A_blade_surface * U_r^2
    Th = q_local * -(Ct * ctx.cosθ + Cn * ctx.sinθ)

    A_streamtube = ctx.H * ctx.R * ctx.Δθ * ctx.abs_sinθ
    q_streamtube = 0.5 * ctx.ρ * A_streamtube * ctx.U_in^2
    Cth = ctx.B / 2pi * (ctx.Δθ * Th) / q_streamtube

    return (; Th, Cth)
end

function _section_torque(U_r, Ct, ctx::DMSTStreamtubeContext)
    A_blade_surface = ctx.H * ctx.c
    q_local = 0.5 * ctx.ρ * A_blade_surface * U_r^2
    Cq = ctx.R * Ct
    Q = q_local * Cq

    return (; Q, Cq)
end

function _section_power(Q, ctx::DMSTStreamtubeContext)
    P = Q * ctx.ω

    A_turbine = ctx.H * (2 * ctx.R)
    q_inf = 0.5 * ctx.ρ * A_turbine * ctx.U_inf^3
    Cp = (ctx.B / 2pi) * (ctx.Δθ * P) / q_inf

    return (; P, Cp)
end

_apply_curvature(aoa, U_r, ctx::DMSTStreamtubeContext) = _apply_curvature(ctx.loss, aoa, U_r, ctx)

_apply_curvature(loss::LossModels, aoa, U_r, ctx::DMSTStreamtubeContext) = begin
    m = reference_point(ctx.section)
    β = pitch(ctx.section)
    @. aoa + aoa_correction(loss.curvature, ctx.ω, ctx.R, m, ctx.c, β, U_r)
end
_apply_curvature(::Nothing, aoa, U_r, ctx::DMSTStreamtubeContext) = aoa
# }}}
