"""
    AbstractSectionAerodynamics

Abstract supertype for 2D blade section aerodynamic models.

A subtype of `AbstractSectionAerodynamics` provides a mapping from a local flow
state and a blade section description to 2D aerodynamic coefficients.

# Interface Methods

- [`aerodynamic_coefficients`](@ref)
"""
abstract type AbstractSectionAerodynamics end

Base.broadcastable(m::AbstractSectionAerodynamics) = Ref(m)

"""
    aerodynamic_coefficients(
        model::AbstractSectionAerodynamics,
        section::AbstractBladeSection,
        aoa,
        Re
    )

Return aerodynamic coefficients for `section` under the local flow conditions.

Concrete models must implement this method and return aerodynamic coefficients
compatible with downstream solver usage.
"""
function aerodynamic_coefficients end
