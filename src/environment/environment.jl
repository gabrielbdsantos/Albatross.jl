"""
    EnvironmentConditions

# Fields

- `fluid<:AbstractFluid`: Fluid thermophysical model.
- `inflow<:AbstractInflow`: Prescribed inflow model.
"""
@concrete struct EnvironmentConditions
    fluid <: AbstractFluid
    inflow <: AbstractInflow
end

EnvironmentConditions(; fluid, inflow) = EnvironmentConditions(fluid, inflow)
