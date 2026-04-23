"""
    AbstractInflow

Abstract supertype for prescribed inflow velocity fields.

An `AbstractInflow` represents the undisturbed atmospheric velocity upstream of
the turbine, prior to any induction or wake effects.

# Interface methods

- [`velocity`](@ref)
"""
abstract type AbstractInflow end

Base.broadcastable(m::AbstractInflow) = Ref(m)

"""
    velocity(m::AbstractInflow)

Compute the streamwise inflow velocity (m/s).

# Arguments

- `m`: A concrete subtype of [`AbstractInflow`](@ref).

# Returns

The streamwise inflow velocity expressed in the global reference frame.
"""
function velocity end

"""
    UniformInflow <: AbstractInflow

Spatially and temporally uniform streamwise inflow velocity.

# Fields

- `U`: Constant streamwise inflow velocity.
"""
@concrete struct UniformInflow <: AbstractInflow
    U
end

velocity(m::UniformInflow) = m.U
