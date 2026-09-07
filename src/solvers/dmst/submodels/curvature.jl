"""
    AbstractCurvatureCorrection

Abstract supertype for curvature correction models used by the DMST solver.

# Interface Methods

- [`aoa_correction`](@ref)
"""
abstract type AbstractCurvatureCorrection end

Base.broadcastable(m::AbstractCurvatureCorrection) = Ref(m)

"""
    aoa_correction(model, ω, r, m, c, αₚ, U_r)

Compute the curvature-induced correction to the local angle of attack (rad).

# Arguments

- `model::Union{AbstractCurvatureCorrection,Nothing}`: Curvature correction
  formulation.
- `ω::Real`: Rotor angular velocity (rad/s).
- `r::Real`: Radial position of the section reference point (m).
- `m::Real`: Chordwise coordinate of the section reference point (m).
- `c::Real`: Section chord (m).
- `αₚ::Real`: Local geometric pitch angle (rad).
- `U_r::Real`: Relative flow speed at the section (m/s).
"""
function aoa_correction end

aoa_correction(::Nothing, ω, r, m, c, αₚ, U_r) = 0


"""
    Bangga()

Bangga curvature correction model for the local angle of attack
[bangga2019improved](@cite).
"""
struct Bangga <: AbstractCurvatureCorrection end

aoa_correction(::Bangga, ω, r, m, c, αₚ, U_r) =
    -atan(ω * m * cos(αₚ), ω * (r + m * sin(αₚ)))


"""
    Goude()

Goude curvature correction model for the local angle of attack
[dyachuk2015simulating](@cite).
"""
struct Goude <: AbstractCurvatureCorrection end

aoa_correction(::Goude, ω, r, m, c, αₚ, U_r) = ω * (m - c / 4) / U_r
