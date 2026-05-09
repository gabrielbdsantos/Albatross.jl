"""
    AbstractGrid

Abstract supertype for grid definitions.

A grid defines a finite set of cell-centered collocation points on an interval,
together with quadrature weights associated with each point.

# Interface Methods

- `Base.length(grid)`: Number of points.
- [`bounds`](@ref): Lower/upper bounds of the grid domain.
- [`extent`](@ref): Domain length.
- [`points`](@ref): Vector of point locations (typically cell centers).
- [`weights`](@ref): Vector of quadrature weights (typically cell widths).

The conventions for whether points represent nodes or cell-centers are
grid-specific and must be documented by each concrete grid type.
"""
abstract type AbstractGrid end

"""
    AbstractGrid1D <: AbstractGrid

Abstract supertype for one-dimensional grid definitions.

See [`AbstractGrid`](@ref) for the expected interface.
"""
abstract type AbstractGrid1D <: AbstractGrid end

"""
    bounds(grid)

Return lower and upper bounds of the grid domain.
"""
function bounds end

"""
    extent(grid)

Return the domain length covered by `grid`.
"""
function extent end

"""
    points(grid)

Return collocation point locations used by `grid`.
"""
function points end

"""
    weights(grid)

Return quadrature weights associated with `points(grid)`.
"""
function weights end

"""
    UniformGrid1D <: AbstractGrid1D

Uniform, cell-centered one-dimensional grid over `bounds = (x0, xL)`.

The interval `(x0, xL)` is divided into `n` equal cells of width
`Δx = (xL - x0)/n`. The collocation points are the `n` cell centers
`xᵢ = x₀ + (i - 1/2)Δx, i = 1:n` and the quadrature weights are constant and
equal to `Δx`.

# Fields

- `n`: Number of points.
- `Δx`: Uniform cell width.
- `bounds`: Interval endpoints.

# See Also

[`points`](@ref), [`weights`](@ref), [`bounds`](@ref), [`extent`](@ref)
"""
@concrete struct UniformGrid1D <: AbstractGrid1D
    n
    Δx
    bounds

    """
        UniformGrid1D(n, bounds)

    Create a uniform, cell-centered grid over the interval `bounds = (x0, xL)`
    by dividing it into `n` equal cells.

    # Arguments

    - `n::Integer`: Number of points (must be positive).
    - `bounds::Tuple{<:Real, <:Real}`: Interval endpoints `(x0, xL)` with
      `xL > x0`.

    # Throws

    - `ArgumentError` if `xL ≤ x0` or `n ≤ 0`.
    """
    function UniformGrid1D(n::T, bounds::Tuple{<:Real, <:Real}) where {T <: Integer}
        x0, xL = bounds
        L = xL - x0
        L > 0 || throw(ArgumentError("The grid length should be greater than zero."))
        n > 0 || throw(ArgumentError("`n` must be a positive integer."))

        Δx = L / n
        return new{typeof(n), typeof(Δx), typeof(bounds)}(n, Δx, bounds)
    end
end

Base.length(m::UniformGrid1D) = m.n
bounds(m::UniformGrid1D) = m.bounds
extent(m::UniformGrid1D) = last(m.bounds) - first(m.bounds)
points(m::UniformGrid1D) = let (x0, xL) = m.bounds
    LinRange(x0 + m.Δx / 2, xL - m.Δx / 2, length(m))
end
weights(m::UniformGrid1D) = Fill(m.Δx, length(m))
