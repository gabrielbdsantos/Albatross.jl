# Thermophysical properties of air at standard conditions.
const ρ_air = 1.225
const μ_air = 1.5e-5
const c_air = 343.0

"""
    AbstractFluid

Abstract supertype for thermophysical fluid models.

A subtype of `AbstractFluid` represents a material model capable of providing
thermodynamic and transport properties required by the aerodynamic solver.

# Interface methods

- [`density`](@ref)
- [`viscosity`](@ref)
- [`speed_of_sound`](@ref)
"""
abstract type AbstractFluid end

Base.broadcastable(m::AbstractFluid) = Ref(m)

"""
    density(fluid::AbstractFluid)

Return the mass density of the fluid in kg/m³.
"""
function density end

"""
    viscosity(fluid::AbstractFluid)

Return the dynamic viscosity of the fluid in Pa·s.
"""
function viscosity end

"""
    speed_of_sound(fluid::AbstractFluid)

Return the speed of sound in the fluid in m/s.
"""
function speed_of_sound end

"""
    IncompressibleFluid <: AbstractFluid

Incompressible fluid model.

This model assumes density and viscosity are uniform and independent of
temperature, pressure, or spatial location. The speed of sound is treated as
infinite.

# Fields

- `ρ`: Fluid density (kg/m³)
- `μ`: Dynamic viscosity (Pa·s)
"""
@concrete struct IncompressibleFluid <: AbstractFluid
    ρ
    μ
end

IncompressibleFluid(; ρ = ρ_air, μ = μ_air) = IncompressibleFluid(ρ, μ)

density(x::IncompressibleFluid) = x.ρ
viscosity(x::IncompressibleFluid) = x.μ
speed_of_sound(::IncompressibleFluid) = Inf

"""
    ConstantPropertyFluid <: AbstractFluid

Fluid model with uniform, time-invariant thermophysical properties.

Unlike [`IncompressibleFluid`](@ref), this model defines a finite speed of
sound, allowing simple compressibility corrections.

# Fields

- `ρ`: Fluid density (kg/m³)
- `μ`: Dynamic viscosity (Pa·s)
- `c`: Speed of sound (m/s)
"""
@concrete struct ConstantPropertyFluid <: AbstractFluid
    ρ
    μ
    c
end

ConstantPropertyFluid(; ρ = ρ_air, μ = μ_air, c = c_air) = ConstantPropertyFluid(ρ, μ, c)

density(x::ConstantPropertyFluid) = x.ρ
viscosity(x::ConstantPropertyFluid) = x.μ
speed_of_sound(x::ConstantPropertyFluid) = x.c
