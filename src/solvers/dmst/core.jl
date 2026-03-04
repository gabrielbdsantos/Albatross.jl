"""
    DMSTGrid

Data type that bundles the azimuthal and spanwise grids used for DMST
computations.

# Fields

- `azimuthal <: AbstractAzimuthalGrid`: azimuthal grid
- `spanwise <: AbstractSpanwiseGrid`: spanwise grid

# See also

[`AbstractAzimuthalGrid`](@ref), [`AbstractSpanwiseGrid`](@ref),
[`AbstractGrid`](@ref)
"""
@concrete struct DMSTGrid
    azimuthal <: AbstractAzimuthalGrid
    spanwise <: AbstractSpanwiseGrid
end

DMSTGrid(; azimuthal, spanwise) = DMSTGrid(azimuthal, spanwise)

"""
    DMST <: AbstractSolver

Double-Multiple Streamtube (DMST) solver for Darrieus-type VAWTs.

`DMST` combines a turbine model, environmental conditions, a momentum/induction
model, a section aerodynamics model, and an azimuthal discretization method to
compute local loads and performance quantities over the upstream and downstream
half-rotations.

# Fields

- `turbine<:AbstractDarrieusTurbine`: Darrieus turbine model to be solved.
- `environment<:EnvironmentConditions`: Ambient/environmental conditions
    (fluid and inflow).
- `momentum<:AbstractMomentumTheory`: Momentum/induction submodel used to
  relate induction to thrust.
- `aerodynamics<:AbstractSectionAerodynamics`: Section aerodynamics model
  returning airfoil coefficients.
- `grid<:DMSTGrid`: DMST grid definition (azimuthal and spanwise points and
    weights).

!!! note "Current limitations"

    The current `solve(::DMST)` implementation assumes a simplified
    turbine/blade representation and will be generalized as the geometry
    interfaces mature.
"""
@concrete struct DMST <: AbstractSolver
    turbine <: AbstractDarrieusTurbine
    environment <: EnvironmentConditions
    momentum <: AbstractMomentumTheory
    aerodynamics <: AbstractSectionAerodynamics
    grid <: DMSTGrid
end

function DMST(;
        turbine::T_turbine,
        environment::T_environment,
        momentum::T_momentum,
        aerodynamics::T_aerodynamics,
        grid::T_grid,
    ) where {
        T_turbine <: AbstractDarrieusTurbine,
        T_environment <: EnvironmentConditions,
        T_momentum <: AbstractMomentumTheory,
        T_aerodynamics <: AbstractSectionAerodynamics,
        T_grid <: DMSTGrid,
    }
    return DMST(turbine, environment, momentum, aerodynamics, grid)
end

"""
    DMSTOutput

Container for DMST results.

All fields are typically vectors (or matrices) evaluated at the grid
collocation points used by the DMST discretization.

# Fields

- `a`: Axial induction factor (-).
- `θ`: Azimuth angle (rad).
- `U_r`: Relative velocity magnitude at the section (m/s).
- `aoa`: Angle of attack (rad).
- `Re`: Reynolds number (-).
- `Ma`: Mach number (-).
- `Cl`: Lift coefficient (-).
- `Cd`: Drag coefficient (-).
- `Ct`: Tangential force coefficient in rotor/blade axes (-).
- `Cn`: Normal force coefficient in rotor/blade axes (-).
- `Th`: Instantaneous thrust/normal load contribution (N).
- `Cq`: Instantaneous torque coefficient (-).
- `Q`: Instantaneous torque (N·m).
- `Cth`: Instantaneous thrust coefficient contribution (-).
- `Cp`: Instantaneous power coefficient contribution (-).

# See also

[`DMSTGrid`](@ref)
"""
@concrete struct DMSTOutput
    a; θ; U_r; aoa; Re; Ma; Cl; Cd; Ct; Cn; Th; Cq; Q; Cth; Cp
end

function DMSTOutput(; a, θ, U_r, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Cq, Q, Cth, Cp)
    return DMSTOutput(a, θ, U_r, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Cq, Q, Cth, Cp)
end

@define_cat_methods DMSTOutput
