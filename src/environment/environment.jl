"""
    EnvironmentConditions

Ambient fluid and inflow conditions for rotor analyses.

# Fields

- `fluid<:AbstractFluid`: Fluid thermophysical model.
- `inflow<:AbstractInflow`: Prescribed inflow model.
"""
@concrete struct EnvironmentConditions
    fluid <: AbstractFluid
    inflow <: AbstractInflow
end

EnvironmentConditions(; fluid, inflow) = EnvironmentConditions(fluid, inflow)
