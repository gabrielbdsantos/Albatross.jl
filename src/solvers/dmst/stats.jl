"""
    DMSTSolveStats

Diagnostics for one streamtube nonlinear solve.

# Fields

- `converged<:Bool`: Whether the nonlinear solve converged.
- `residual<:Real`: Final nonlinear residual.
- `num_iters<:Integer`: Number of nonlinear iterations performed.
- `elapsed_time<:Real`: Wall-clock solve time in seconds.

# Notes

- In `solve(::DMST)`, these records are stored per streamtube for upstream and
  downstream passes.
- `solve(::DMST)` currently does not assign `elapsed_time` values.
"""
@concrete struct DMSTSolveStats
    converged <: Bool
    residual <: Real
    num_iters <: Integer
    elapsed_time <: Real
end

DMSTSolveStats() = DMSTSolveStats(false, Inf, 0, 0.0)
