"""
    AbstractSpanwiseGrid <: AbstractGrid

Abstract supertype for spanwise grid definitions.

A spanwise grid discretizes the blade span coordinate (commonly `z`) over a
specified interval.

See [`AbstractGrid`](@ref) for the expected interface.
"""
abstract type AbstractSpanwiseGrid <: AbstractGrid end

"""
    UniformSpanwiseGrid <: AbstractSpanwiseGrid

Uniform, cell-centered spanwise grid.

It acts as a thin wrapper around [`AbstractGrid1D`](@ref).

# Fields

- `grid::UniformGrid1D`: Underlying one-dimensional uniform grid.

# See Also

[`AbstractSpanwiseGrid`](@ref), [`UniformGrid1D`](@ref), [`DMSTGrid`](@ref)
"""
@concrete struct UniformSpanwiseGrid <: AbstractSpanwiseGrid
    grid <: UniformGrid1D

    @doc """
        UniformSpanwiseGrid(n::Integer, (z₀, zL))

    Create a uniform, cell-centered spanwise grid over `(z₀, zL)`.
    """
    UniformSpanwiseGrid(n::Integer, (z0, zL)) = let
        g = UniformGrid1D(n, (z0, zL))
        new{typeof(g)}(g)
    end

    @doc """
        UniformSpanwiseGrid(turbine::AbstractDarrieusTurbine, n::Integer)

    Create a uniform, cell-centered spanwise grid for `turbine`.

    The span interval is taken as `(0, span(blades(turbine)))`.
    """
    UniformSpanwiseGrid(turbine::AbstractDarrieusTurbine, n) =
        UniformSpanwiseGrid(n, (0, span(blades(turbine))))
end

Base.length(m::UniformSpanwiseGrid) = length(m.grid)
bounds(m::UniformSpanwiseGrid) = bounds(m.grid)
extent(m::UniformSpanwiseGrid) = extent(m.grid)
points(m::UniformSpanwiseGrid) = points(m.grid)
weights(m::UniformSpanwiseGrid) = weights(m.grid)
