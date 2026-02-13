"""
    AbstractRotorKinematics

Abstract supertype for *prescribed* rotor kinematic models.

A subtype of `AbstractRotorKinematics` defines the rotational kinematics of the
rotor independently of aerodynamic loads, inertia, or control dynamics.

# Interface methods

- [`angular_velocity`](@ref)
"""
abstract type AbstractRotorKinematics end

"""
    angular_velocity(kinematics::AbstractRotorKinematics, t)

Return the rotor angular velocity at time `t`.

# Arguments

- `kinematics`: Rotor kinematics model.
- `t`: Time (s).

# Returns

Rotor angular velocity (rad/s).
"""
function angular_velocity end

"""
    ConstantAngularVelocity <: AbstractRotorKinematics

Prescribed constant rotor angular velocity.

# Fields

- `ω`: Constant angular velocity (rad/s).
"""
@concrete struct ConstantAngularVelocity <: AbstractRotorKinematics
    ω
end

ConstantAngularVelocity(; ω) = ConstantAngularVelocity(ω)

angular_velocity(m::ConstantAngularVelocity, _) = m.ω
