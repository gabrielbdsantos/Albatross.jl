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
    DMSTOptions

Numerical controls for the DMST solver.

# Fields

- `abstol`: Absolute tolerance for nonlinear residual convergence.
- `reltol`: Relative tolerance for nonlinear residual convergence.
- `maxiters`: Maximum nonlinear iterations per solve stage.
- `induction_bounds`: Allowed induction-factor interval `(a_min, a_max)`.
- `damping`: Generic damping/relaxation factor (0, 1].
- `enable_coupling`: Enable upstream/downstream outer coupling iterations.
- `coupling_maxiters`: Max outer iterations for upstream/downstream coupling.
- `coupling_tol`: Absolute tolerance for coupling convergence.
"""
@concrete struct DMSTOptions
    abstol <: Real
    reltol <: Real
    maxiters <: Integer
    induction_bounds <: Tuple{<:Real, <:Real}
    damping <: Real
    enable_coupling <: Bool
    coupling_maxiters <: Integer
    coupling_tol <: Real
end

DMSTOptions(;
    abstol = 1.0e-8,
    reltol = 1.0e-8,
    maxiters = 100,
    induction_bounds = (-Inf, Inf),
    damping = 1.0,
    enable_coupling = false,
    coupling_maxiters = 1,
    coupling_tol = 1.0e-8,
) = DMSTOptions(
    abstol, reltol, maxiters, induction_bounds, damping, enable_coupling,
    coupling_maxiters, coupling_tol
)

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
- `environment<:EnvironmentConditions`: Ambient/environmental conditions
    (fluid and inflow).
- `momentum<:AbstractMomentumTheory`: Momentum/induction submodel used to
  relate induction to thrust.
- `aerodynamics<:AbstractSectionAerodynamics`: Section aerodynamics model
  returning airfoil coefficients.
- `grid<:DMSTGrid`: DMST grid definition (azimuthal and spanwise points and
    weights).
- `options<:DMSTOptions`: Numerical controls for convergence tolerances,
    iteration limits, induction bounds, damping, and coupling settings.

# See also

[`DMSTGrid`](@ref), [`DMSTOptions`](@ref)
"""
@concrete struct DMST <: AbstractSolver
    turbine <: AbstractDarrieusTurbine
    environment <: EnvironmentConditions
    momentum <: AbstractMomentumTheory
    aerodynamics <: AbstractSectionAerodynamics
    grid <: DMSTGrid
    options <: DMSTOptions
end

DMST(;
    turbine, environment, momentum, aerodynamics, grid, options = DMSTOptions()
) = DMST(turbine, environment, momentum, aerodynamics, grid, options)

"""
    DMSTPassSolveStats

Diagnostics for a DMST nonlinear half-pass solution.

# Fields

- `converged`: Whether the nonlinear solve converged.
- `num_iters`: Number of nonlinear iterations performed.
- `residual_norm`: Final scalar residual norm.
- `elapsed_time`: Wall-clock time spent in this pass solve (in seconds).
"""
@concrete struct DMSTPassSolveStats
    converged <: Bool
    num_iters <: Integer
    residual_norm <: Real
    elapsed_time <: Real
end

DMSTPassSolveStats(;
    converged = false,
    num_iters = 0,
    residual_norm = Inf,
    elapsed_time = 0.0,
) = DMSTPassSolveStats(converged, num_iters, residual_norm, elapsed_time)

"""
    DMSTSolveStats

Diagnostics for a complete DMST nonlinear solve.

# Fields

- `upstream<:DMSTPassSolveStats`: Upstream pass diagnostic.
- `downstream<:DMSTPassSolveStats`: Downstream pass diagnostic.
- `coupling_iters`: Number of outer upstream/downstream coupling iterations.
- `coupling_residual`: Final coupling residual norm.
- `coupling_converged`: Whether coupling loop convergence was reached.
- `elapsed_time`: Total wall-clock time for the full DMST solve (in seconds).

# See also

[`DMSTPassSolveStats`](@ref)
"""
@concrete struct DMSTSolveStats
    upstream <: DMSTPassSolveStats
    downstream <: DMSTPassSolveStats
    coupling_iters <: Integer
    coupling_residual <: Real
    coupling_converged <: Bool
    elapsed_time <: Real
end

DMSTSolveStats(;
    upstream = DMSTPassSolveStats(),
    downstream = DMSTPassSolveStats(),
    coupling_iters = 0,
    coupling_residual = Inf,
    coupling_converged = false,
    elapsed_time = 0.0,
) = DMSTSolveStats(
    upstream, downstream, coupling_iters, coupling_residual,
    coupling_converged, elapsed_time,
)

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

"""
    DMSTSolution

Structured output of a full DMST solve.

# Fields

- `upstream<:DMSTOutput`: Upstream solution.
- `downstream<:DMSTOutput`: Downstream solution.
- `integrated`: Global quantities.
- `stats<:DMSTSolveStats`: Solver diagnostics and convergence metadata.

# See also

[`DMSTOutput`](@ref), [`DMSTSolveStats`](@ref)
"""
@concrete struct DMSTSolution
    upstream <: DMSTOutput
    downstream <: DMSTOutput
    integrated
    stats <: DMSTSolveStats
end

DMSTSolution(;
    upstream,
    downstream,
    integrated = nothing,
    stats = DMSTSolveStats(),
) = DMSTSolution(upstream, downstream, integrated, stats)

# NOTE: backward-compat accessors on DMSTSolution
const _DMST_OUTPUT_KEYS = fieldnames(DMSTOutput)

function Base.getproperty(sol::DMSTSolution, name::Symbol)
    if name in fieldnames(DMSTSolution)
        return getfield(sol, name)
    elseif name in _DMST_OUTPUT_KEYS
        up = getproperty(getfield(sol, :upstream), name)
        dn = getproperty(getfield(sol, :downstream), name)
        return [up; dn]
    end

    # If it reached here, this will throw an error.
    return getfield(sol, name)
end

Base.propertynames(::DMSTSolution, private::Bool = false) = (
    fieldnames(DMSTSolution)...,
    _DMST_OUTPUT_KEYS...,
)
