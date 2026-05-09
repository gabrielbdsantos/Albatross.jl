"""
    AbstractMomentumTheory

Abstract supertype for momentum theory formulations.

# Interface Methods

- [`wake_velocity_ratio`](@ref)
- [`drag_coefficient`](@ref)
"""
abstract type AbstractMomentumTheory end

Base.broadcastable(m::AbstractMomentumTheory) = Ref(m)

"""
    wake_velocity_ratio(model, a)

Wake axial velocity ratio as a function of the axial induction factor `a`.

# Arguments

- `model::AbstractMomentumTheory`: Momentum theory formulation.
- `a::Real`: Axial induction factor.
"""
function wake_velocity_ratio end

"""
    drag_coefficient(model, a)

Actuator-disk drag coefficient predicted by the momentum formulation `model`
for an induction factor `a`.

# Arguments

- `model::AbstractMomentumTheory`: Momentum theory formulation.
- `a::Real`: Axial induction factor.
"""
function drag_coefficient end
