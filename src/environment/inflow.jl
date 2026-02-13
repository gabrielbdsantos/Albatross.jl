"""
    AbstractInflow

Abstract supertype for prescribed inflow velocity fields.

An `AbstractInflow` represents the undisturbed atmospheric velocity upstream of
the turbine, prior to any induction or wake effects.

# Interface methods

- [`velocity`](@ref)
"""
abstract type AbstractInflow end

# Treats subtypes as a scalar in broadcasting.
Base.broadcastable(m::AbstractInflow) = Ref(m)

"""
    velocity(m::AbstractInflow)

Return the inflow velocity vector.

# Arguments

- `m`: A concrete subtype of [`AbstractInflow`](@ref).

# Return

A velocity vector expressed in the global reference frame (m/s).
"""
function velocity end

"""
    UniformInflow <: AbstractInflow

Spatially and temporally uniform inflow velocity.

# Fields

- `U`: Constant inflow velocity.
"""
@concrete struct UniformInflow <: AbstractInflow
    U
end

velocity(m::UniformInflow) = m.U
