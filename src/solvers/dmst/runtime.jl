"""
    DMSTStreamtubeContext

Precomputed runtime data for one DMST streamtube collocation point.

# Fields

- `θ`: Azimuth collocation point (rad).
- `Δθ`: Azimuthal quadrature weight (rad).
- `U_in`: Incoming streamtube velocity used by the momentum balance (m/s).
- `sinθ`: Cached `sin(θ)` (–).
- `cosθ`: Cached `cos(θ)` (–).
- `abs_sinθ`: Cached `abs(sin(θ))` (–).
- `ω`: Rotor angular velocity (rad/s).
- `c`: Blade chord (m).
- `R`: Blade radial position (m).
- `H`: Blade span (m).
- `U_inf`: Free-stream inflow velocity (m/s).
- `ρ`: Fluid density (kg/m³).
- `μ`: Fluid dynamic viscosity (Pa·s).
- `v_sound`: Fluid speed of sound (m/s).
- `B`: Number of turbine blades (–).
- `section<:AbstractBladeSection`: Blade section used for local aerodynamic
  evaluation.
- `aerodynamics<:AbstractSectionAerodynamics`: Section aerodynamics model.
- `submodels<:DMSTSubmodels`: Submodels that modify the DMST evaluation.
"""
@concrete struct DMSTStreamtubeContext
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
    v_sound

    B

    section <: AbstractBladeSection
    aerodynamics <: AbstractSectionAerodynamics
    submodels <: DMSTSubmodels
end

"""
    build_streamtube_contexts(
        θ, Δθ, U_in, turbine, environment, aerodynamics, submodels
    )

Build DMST streamtube runtime contexts from grid, turbine, environment, and
aerodynamic model data.

# Arguments

- `θ`: azimuth collocation points (rad).
- `Δθ`: azimuthal quadrature weights (rad).
- `U_in`: incoming streamtube velocity or velocities used by the momentum
  balance (m/s).
- `turbine`: turbine model supplying blade geometry, kinematics, and blade
  count.
- `environment`: Environmental conditions.
- `aerodynamics`: section aerodynamics model used by each streamtube.
- `submodels::DMSTSubmodels`: Submodels that modify the DMST evaluation.

# Returns

- `StructVector{DMSTStreamtubeContext}`: One runtime context per azimuth
  collocation point.

# Notes

- Scalar inputs that are shared by all streamtubes are stored as lazy fills
  using `FillArrays.Fill`; vector inputs are kept as streamtube-varying data.
"""
function build_streamtube_contexts(
        θ, Δθ, U_in, turbine, environment, aerodynamics, submodels
    )
    z = nothing
    t = nothing

    blade = blades(turbine)
    blade_section = section(blade, z)

    sinθ = sin.(θ)
    cosθ = cos.(θ)
    abs_sinθ = abs.(sinθ)

    @inline vector_or_fill(x::AbstractVector) = x
    @inline vector_or_fill(x) = Fill(x, length(θ))

    return StructVector{DMSTStreamtubeContext}(
        map(
            vector_or_fill,
            (
                θ,
                Δθ,
                U_in,
                sinθ,
                cosθ,
                abs_sinθ,
                angular_velocity(kinematics(turbine), t),
                chord(blade, z),
                radial_position(blade, z),
                span(blade),
                velocity(environment.inflow),
                density(environment.fluid),
                viscosity(environment.fluid),
                speed_of_sound(environment.fluid),
                num_blades(turbine),
                blade_section,
                aerodynamics,
                submodels,
            )
        )
    )
end
