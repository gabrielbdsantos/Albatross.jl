"""
    AbstractTurbine

Abstract supertype for wind turbine system models.

A subtype of `AbstractTurbine` represents the geometric and structural
configuration of a wind turbine (rotor geometry, blade geometry, and
kinematics).

# Interface Methods

- [`num_blades`](@ref)
- [`kinematics`](@ref)
- [`blades`](@ref)
- [`swept_area`](@ref)
"""
abstract type AbstractTurbine end

"""
    AbstractDarrieusTurbine <: AbstractTurbine

Abstract supertype for Darrieus-type vertical-axis wind turbine models.

A subtype of `AbstractDarrieusTurbine` represents turbines whose rotor consists
of one or more lift-driven blades rotating about a vertical axis, as in
classical Darrieus and H-rotor configurations.
"""
abstract type AbstractDarrieusTurbine <: AbstractTurbine end

Base.broadcastable(m::AbstractDarrieusTurbine) = Ref(m)

"""
    num_blades(turbine::AbstractTurbine)

Return the number of blades in the turbine rotor.
"""
function num_blades end

"""
    kinematics(turbine::AbstractTurbine)

Return the rotor kinematics model (a subtype of
[`AbstractRotorKinematics`](@ref)) associated with the turbine.
"""
function kinematics end

"""
    blades(turbine::AbstractTurbine)

Return the blade-geometry models associated with the turbine.

The returned value may be either:

- a single [`AbstractBladeGeometry`](@ref), representing a uniform rotor where
  all blades share the same geometry, or
- a vector/collection of [`AbstractBladeGeometry`](@ref), with one geometry per
  blade.

When a single geometry is returned, [`num_blades(turbine)`](@ref) defines how
many identical blades are represented by that geometry.
"""
function blades end

"""
    swept_area(turbine::AbstractTurbine)

Return the swept area of `turbine`.
"""
function swept_area end
