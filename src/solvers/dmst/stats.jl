"""
    DMSTSolveStats

Diagnostics for a complete DMST nonlinear solve.

# Fields

- `converged`: Whether the nonlinear solve converged.
- `residual`: Final residual.
- `num_iters`: Number of nonlinear iterations performed.
- `elapsed_time`: Wall-clock time spent in this solve (in seconds).
"""
@concrete struct DMSTSolveStats
    converged <: Bool
    residual <: Real
    num_iters <: Integer
    elapsed_time <: Real
end
