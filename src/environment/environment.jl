"""
    Environment

Environmental conditions for rotor analyses.

# Fields

- `fluid<:AbstractFluid`: Fluid thermophysical model.
- `inflow<:AbstractInflow`: Prescribed inflow model.
"""
@concrete struct Environment
    fluid <: AbstractFluid
    inflow <: AbstractInflow
end

Environment(; fluid, inflow) = Environment(fluid, inflow)
