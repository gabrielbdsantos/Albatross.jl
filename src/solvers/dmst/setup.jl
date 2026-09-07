"""
    DMSTGrid

Data type that bundles the azimuthal and spanwise grids used for DMST
computations.

# Fields

- `azimuthal<:AbstractAzimuthalGrid`: Azimuthal grid.
- `spanwise<:AbstractSpanwiseGrid`: Spanwise grid.

# See Also

[`AbstractAzimuthalGrid`](@ref), [`AbstractSpanwiseGrid`](@ref),
[`AbstractGrid`](@ref).
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

- `algorithm<:NonlinearSolve.NonlinearSolveBase.AbstractNonlinearSolveAlgorithm`:
  Nonlinear solve algorithm.
- `abstol<:Real`: Absolute tolerance for nonlinear residual convergence.
- `reltol<:Real`: Relative tolerance for nonlinear residual convergence.
- `maxiters<:Integer`: Maximum nonlinear iterations per solve stage.
- `induction_bounds<:Tuple{<:Real, <:Real}`: Allowed interval for the induction
  factor `(a_min, a_max)`.
"""
@concrete struct DMSTSolverOptions
    algorithm <: NonlinearSolve.NonlinearSolveBase.AbstractNonlinearSolveAlgorithm
    abstol <: Real
    reltol <: Real
    maxiters <: Integer
    induction_bounds <: Tuple{<:Real, <:Real}
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
- `environment<:Environment`: Environmental conditions.
- `momentum<:AbstractMomentumTheory`: Momentum/induction submodel used to
  relate induction to thrust.
- `aerodynamics<:AbstractSectionAerodynamics`: Section aerodynamics model
  returning airfoil coefficients.
- `grid<:DMSTGrid`: DMST grid definition (azimuthal and spanwise points and
  weights).
- `options<:DMSTSolverOptions`: Numerical controls for convergence tolerances,
  iteration limits, and induction bounds.
- `submodels<:DMSTSubmodels`: Submodels that modify the DMST evaluation.

# See Also

[`DMSTGrid`](@ref), [`DMSTSolverOptions`](@ref).
"""
@concrete struct DMST <: AbstractSolver
    turbine <: AbstractDarrieusTurbine
    environment <: Environment
    momentum <: AbstractMomentumTheory
    aerodynamics <: AbstractSectionAerodynamics
    grid <: DMSTGrid
    options <: DMSTSolverOptions
    submodels <: DMSTSubmodels
end

DMST(;
    turbine,
    environment,
    momentum,
    aerodynamics,
    grid,
    options = DMSTSolverOptions(),
    submodels = DMSTSubmodels(),
) = DMST(turbine, environment, momentum, aerodynamics, grid, options, submodels)
