"""
    DMSTStreamtubeContext

Precomputed runtime data for one DMST streamtube collocation point.

# Fields

- `θ`: azimuth collocation point (rad).
- `Δθ`: azimuthal quadrature weight (rad).
- `U_in`: incoming streamtube velocity used by the momentum balance (m/s).
- `sinθ`: cached `sin(θ)` (–).
- `cosθ`: cached `cos(θ)` (–).
- `abs_sinθ`: cached `abs(sin(θ))` (–).
- `ω`: rotor angular velocity (rad/s).
- `c`: blade chord (m).
- `R`: blade radial position (m).
- `H`: blade span (m).
- `U_inf`: free-stream inflow velocity (m/s).
- `ρ`: fluid density (kg/m³).
- `μ`: fluid dynamic viscosity (Pa·s).
- `c_sound`: fluid speed of sound (m/s).
- `B`: number of turbine blades (–).
- `section`: blade section used for local aerodynamic evaluation.
- `aerodynamics`: section aerodynamics model.
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
    c_sound

    B

    section <: AbstractBladeSection
    aerodynamics <: AbstractSectionAerodynamics
end

"""
    build_streamtube_contexts(θ, Δθ, U_in, turbine, environment, aerodynamics)

Build DMST streamtube runtime contexts from grid, turbine, environment, and
aerodynamic model data.

# Arguments

- `θ`: azimuth collocation points (rad).
- `Δθ`: azimuthal quadrature weights (rad).
- `U_in`: incoming streamtube velocity or velocities used by the momentum
  balance (m/s).
- `turbine`: turbine model supplying blade geometry, kinematics, and blade
  count.
- `environment`: environmental conditions supplying inflow and fluid
  properties.
- `aerodynamics`: section aerodynamics model used by each streamtube.

# Returns

- `StructVector{DMSTStreamtubeContext}`: One runtime context per azimuth
  collocation point.

# Notes

- Scalar inputs that are shared by all streamtubes are stored as lazy fills
  using `FillArrays.Fill`; vector inputs are kept as streamtube-varying data.
"""
function build_streamtube_contexts(θ, Δθ, U_in, turbine, environment, aerodynamics)
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
                radial_pos(blade, z),
                span(blade),
                velocity(environment.inflow),
                density(environment.fluid),
                viscosity(environment.fluid),
                speed_of_sound(environment.fluid),
                num_blades(turbine),
                blade_section,
                aerodynamics,
            )
        )
    )
end
