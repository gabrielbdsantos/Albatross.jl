@concrete struct StreamtubeContext
    θ
    Δθ
    U_in

    sinθ
    cosθ
    abs_sinθ

    ω
    c
    R
    H
    U_inf
    ρ
    μ
    c_sound
    B
    k

    section <: AbstractBladeSection
    aerodynamics <: AbstractSectionAerodynamics
end

function make_streamtube_context(θ, Δθ, U_in, turbine, ambient, aerodynamics)
    z = nothing
    t = nothing

    blade = blades(turbine)
    blade_section = section(blade, z)

    sinθ = sin.(θ)
    cosθ = cos.(θ)
    abs_sinθ = abs.(sinθ)

    return StreamtubeContext(
        θ,
        Δθ,
        U_in,
        sinθ,
        cosθ,
        abs_sinθ,
        angular_velocity(kinematics(turbine), t),
        chord(blade, z),
        radial_pos(blade, z),
        span(blade),
        velocity(ambient.inflow),
        density(ambient.fluid),
        viscosity(ambient.fluid),
        speed_of_sound(ambient.fluid),
        num_blades(turbine),
        1,
        blade_section,
        aerodynamics,
    )
end

function _make_single_streamtube_context(ctx::StreamtubeContext, i::Int)
    return StreamtubeContext(
        [
            _getindex(getproperty(ctx, p), i)
                for p in fieldnames(StreamtubeContext)
        ]...
    )
end

@inline _getindex(x::AbstractVector, i::Int) = Base.getindex(x, i)
@inline _getindex(x, ::Int) = x
