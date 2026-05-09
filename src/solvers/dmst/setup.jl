"""
    DMSTGrid

Data type that bundles the azimuthal and spanwise grids used for DMST
computations.

# Fields

- `azimuthal <: AbstractAzimuthalGrid`: Azimuthal grid.
- `spanwise <: AbstractSpanwiseGrid`: Spanwise grid.

# See Also

[`AbstractAzimuthalGrid`](@ref), [`AbstractSpanwiseGrid`](@ref),
[`AbstractGrid`](@ref)
"""
@concrete struct DMSTGrid
    azimuthal <: AbstractAzimuthalGrid
    spanwise <: AbstractSpanwiseGrid
end

DMSTGrid(; azimuthal, spanwise) = DMSTGrid(azimuthal, spanwise)

"""
    DMSTSolverOptions

Numerical controls for the nonlinear solver in DMST.

# Fields

- `algorithm`: Nonlinear solve algorithm.
- `abstol`: Absolute tolerance for nonlinear residual convergence.
- `reltol`: Relative tolerance for nonlinear residual convergence.
- `maxiters`: Maximum nonlinear iterations per solve stage.
- `solution_bounds`: Allowed induction-factor interval `(u_min, u_max)`.
"""
@concrete struct DMSTSolverOptions
    algorithm <: NonlinearSolve.NonlinearSolveBase.AbstractNonlinearSolveAlgorithm
    abstol <: Real
    reltol <: Real
    maxiters <: Integer
    solution_bounds <: Tuple{<:Real, <:Real}
end

DMSTSolverOptions(;
    algorithm = NonlinearSolve.SimpleBroyden(),
    abstol = 1.0e-8,
    reltol = 1.0e-8,
    maxiters = 100,
    induction_bounds = (-Inf, Inf),
) = DMSTSolverOptions(algorithm, abstol, reltol, maxiters, induction_bounds)

"""
    DMST <: AbstractSolver

Double-Multiple Streamtube (DMST) solver for Darrieus-type VAWTs.

`DMST` combines a turbine model, environmental conditions, a momentum/induction
model, a section aerodynamics model, and an azimuthal discretization method to
compute local loads and performance quantities over the upstream and downstream
half-rotations.

!!! note "Current limitations"

    The current `solve(::DMST)` implementation assumes a simplified
    turbine/blade representation and will be generalized as the geometry
    interfaces mature.

# Fields

- `turbine<:AbstractDarrieusTurbine`: Darrieus turbine model to be solved.
- `environment<:EnvironmentConditions`: Ambient/environmental conditions (fluid
  and inflow).
- `momentum<:AbstractMomentumTheory`: Momentum/induction submodel used to
  relate induction to thrust.
- `aerodynamics<:AbstractSectionAerodynamics`: Section aerodynamics model
  returning airfoil coefficients.
- `grid<:DMSTGrid`: DMST grid definition (azimuthal and spanwise points and
  weights).
- `options<:DMSTSolverOptions`: Numerical controls for convergence tolerances,
  iteration limits, and induction bounds.

# See Also

[`DMSTGrid`](@ref), [`DMSTSolverOptions`](@ref)
"""
@concrete struct DMST <: AbstractSolver
    turbine <: AbstractDarrieusTurbine
    environment <: EnvironmentConditions
    momentum <: AbstractMomentumTheory
    aerodynamics <: AbstractSectionAerodynamics
    grid <: DMSTGrid
    options <: DMSTSolverOptions
end

DMST(;
    turbine, environment, momentum, aerodynamics, grid, options = DMSTSolverOptions()
) = DMST(turbine, environment, momentum, aerodynamics, grid, options)
