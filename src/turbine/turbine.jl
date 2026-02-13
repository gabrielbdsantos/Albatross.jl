"""
    AbstractTurbine

Abstract supertype for wind turbine system models.

A subtype of `AbstractTurbine` represents the geometric and structural
configuration of a wind turbine (rotor geometry, blade geometry, and
kinematics).
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

# Treats subtypes as a scalar in broadcasting.
Base.broadcastable(m::AbstractDarrieusTurbine) = Ref(m)

"""
    num_blades(turbine::AbstractTurbine)

Return the number of blades in the turbine rotor.
"""
function num_blades end

"""
    kinematics(turbine::AbstractTurbine) -> AbstractRotorKinematics

Return the rotor kinematics model associated with the turbine.
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
