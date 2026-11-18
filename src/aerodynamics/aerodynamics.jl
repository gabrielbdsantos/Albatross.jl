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

# Arguments
 
- `model::AbstractSectionAerodynamics`: Section aerodynamics model.
- `section::AbstractBladeSection`: Blade section description.
- `aoa`: Angle of attack (deg).
- `Re`: Reynolds number (–).
 
# Keyword Arguments
 
- `kwargs...`: Model-specific flow-state inputs, for example the relative
  velocity `U_r` (m/s), chord `c` (m), and time step `dt` (s) required by
  dynamic stall models.
 
# Returns
 
- `Tuple`: Lift and drag coefficients `(Cl, Cd)` (–).
 
# Notes
 
- The fallback method for models that do not accept keyword arguments
  discards `kwargs...` and calls the method without them.
- When vectors of models and sections are given, only their first elements
  are used and `kwargs...` is discarded.
"""
function aerodynamic_coefficients end

aerodynamic_coefficients(
    model::AbstractVector{<:AbstractSectionAerodynamics},
    section::AbstractVector{<:AbstractBladeSection},
    aoa,
    Re;
    kwargs...
) = aerodynamic_coefficients(first(model), first(section), aoa, Re)

aerodynamic_coefficients(
    model::AbstractSectionAerodynamics, section::AbstractBladeSection, aoa, Re; kwargs...
) = aerodynamic_coefficients(model, section, aoa, Re)

"""
    advance_state!(model::AbstractSectionAerodynamics, aoa)
 
Update the internal state of `model` in-place after a completed time step.
 
Stateful models extend it to store the data needed by the next call to 
[`aerodynamic_coefficients`](@ref).

Static/stateless models do not need to implement this; the default is a
no-op.

# Arguments
 
- `model::AbstractSectionAerodynamics`: Model whose state is mutated.
- `aoa`: Angle of attack of the completed time step. Units follow the
  convention of the concrete model.
 
# See Also
 
[`reset_state!`](@ref).
"""
advance_state!(::AbstractSectionAerodynamics, aoa) = nothing

"""
    reset_state!(model::AbstractSectionAerodynamics)
 
Restore the internal state of `model` to its initial values in-place.
 
Stateful models extend it to undo the effect of [`advance_state!`](@ref). 
Static/stateless models do not need to implement this; the default is a no-op.

Used by [`evaluate_streamtube_fields_sequential`](@ref) to replay a converged
[`DMSTNonlinearSolution`](@ref) from a clean state.

# Arguments
 
- `model::AbstractSectionAerodynamics`: Model whose state is mutated.
 
# See Also
 
[`advance_state!`](@ref).
"""
reset_state!(::AbstractSectionAerodynamics) = nothing
