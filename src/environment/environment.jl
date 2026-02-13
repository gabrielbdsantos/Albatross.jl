"""
    EnvironmentConditions(; fluid, inflow)

Bundle of ambient conditions used by turbine solvers.

# Fields

- `fluid<:AbstractFluid`: Fluid thermophysical model.
- `inflow<:AbstractInflow`: Prescribed inflow model.

# Notes

This type groups the environment models passed to solver configurations.
"""
@concrete struct EnvironmentConditions
    fluid <: AbstractFluid
    inflow <: AbstractInflow
end

EnvironmentConditions(; fluid::T_fluid, inflow::T_inflow) where {
    T_fluid <: AbstractFluid, T_inflow <: AbstractInflow,
} = EnvironmentConditions(fluid, inflow)
