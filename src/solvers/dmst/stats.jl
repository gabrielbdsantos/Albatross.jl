abstract type AbstractStreamtubeSolveStats end

"""
    CoupledStreamtubeSolveStats

Diagnostics for a coupled DMST nonlinear solution.

# Fields

- `converged`: Whether the nonlinear solve converged.
- `num_iters`: Number of nonlinear iterations performed.
- `residual`: Final residual.
- `elapsed_time`: Wall-clock time spent in this solve (in seconds).
"""
@concrete struct CoupledStreamtubeSolveStats <: AbstractStreamtubeSolveStats
    converged <: Bool
    num_iters <: Integer
    residual <: Real
    elapsed_time <: Real
end

CoupledStreamtubeSolveStats(;
    converged = false,
    num_iters = 0,
    residual = Inf,
    elapsed_time = 0.0,
) = CoupledStreamtubeSolveStats(converged, num_iters, residual, elapsed_time)

"""
    UncoupledStreamtubeSolveStats

Diagnostics for an uncoupled DMST nonlinear solution.

# Fields

- `converged`: Whether the nonlinear solve converged.
- `num_iters`: Number of nonlinear iterations performed.
- `residual`: Final residual.
- `elapsed_time`: Wall-clock time spent in each streamtube solve (in seconds).
"""
@concrete struct UncoupledStreamtubeSolveStats <: AbstractStreamtubeSolveStats
    converged <: AbstractVector{<:Bool}
    residual <: AbstractVector{<:Real}
    num_iters <: AbstractVector{<:Integer}
    elapsed_time <: AbstractVector{<:Real}
end

UncoupledStreamtubeSolveStats(n) = UncoupledStreamtubeSolveStats(
    falses(n), fill(Inf, n), zeros(Int, n), zeros(n)
)

"""
    DMSTSolveStats

Diagnostics for a complete DMST nonlinear solve.

# Fields

- `upstream<:AbstractStreamtubeSolveStats`: Upstream pass diagnostic.
- `downstream<:AbstractStreamtubeSolveStats`: Downstream pass diagnostic.
- `coupling_iters`: Number of outer upstream/downstream coupling iterations.
- `coupling_residual`: Final coupling residual norm.
- `coupling_converged`: Whether coupling loop convergence was reached.
- `elapsed_time`: Total wall-clock time for the full DMST solve (in seconds).

# See also

[`AbstractStreamtubeSolveStats`](@ref)
"""
@concrete struct DMSTSolveStats
    upstream <: AbstractStreamtubeSolveStats
    downstream <: AbstractStreamtubeSolveStats
    coupling_iters <: Integer
    coupling_residual <: Real
    coupling_converged <: Bool
    elapsed_time <: Real
end

DMSTSolveStats(;
    upstream = CoupledStreamtubeSolveStats(),
    downstream = CoupledStreamtubeSolveStats(),
    coupling_iters = 0,
    coupling_residual = Inf,
    coupling_converged = false,
    elapsed_time = 0.0,
) = DMSTSolveStats(
    upstream, downstream, coupling_iters, coupling_residual,
    coupling_converged, elapsed_time,
)
