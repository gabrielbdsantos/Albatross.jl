"""
    StreamtubeSolveStats

Diagnostics for a half-pass nonlinear solution.

# Fields

- `converged`: Whether the nonlinear solve converged.
- `num_iters`: Number of nonlinear iterations performed.
- `residual`: Final residual.
- `elapsed_time`: Wall-clock time spent in this solve (in seconds).
"""
@concrete struct StreamtubeSolveStats
    converged
    residual
    num_iters
    elapsed_time

    StreamtubeSolveStats(n::Int) = StreamtubeSolveStats(
        falses(n), fill(Inf, n), zeros(Int, n), zeros(n)
    )
end

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
"""
@concrete struct DMSTSolveStats
    upstream <: StreamtubeSolveStats
    downstream <: StreamtubeSolveStats
    coupling_iters <: Integer
    coupling_residual <: Real
    coupling_converged <: Bool
    elapsed_time <: Real
end

DMSTSolveStats(;
    upstream,
    downstream,
    coupling_iters = 0,
    coupling_residual = Inf,
    coupling_converged = false,
    elapsed_time = 0.0,
) = DMSTSolveStats(
    upstream, downstream, coupling_iters, coupling_residual,
    coupling_converged, elapsed_time,
)
