"""
    AbstractAzimuthalGrid <: AbstractGrid

Abstract supertype for azimuthal grid definitions.

An azimuthal grid discretizes rotor azimuth over a full revolution. In many
cases, it is common to split the revolution into upstream and downstream
half-cycles.

Concrete implementations should clearly document:

- the azimuth convention (direction and zero reference),
- if and how upstream/downstream are defined.

See [`AbstractGrid`](@ref) for the expected interface.
"""
abstract type AbstractAzimuthalGrid <: AbstractGrid end

"""
    UniformAzimuthalGrid <: AbstractAzimuthalGrid

Uniform, cell-centered azimuthal grid with upstream/downstream halves.
Both halves use `n` equally-sized cells, so the full grid has `2n` points.

# Fields

- `upstream::UniformGrid1D`: Uniform grid over `(ψ₀, ψ₀ + π)`.
- `downstream::UniformGrid1D`: Uniform grid over `(ψ₀ + π, ψ₀ + 2π)`.

# See Also

[`AbstractAzimuthalGrid`](@ref), [`DMSTGrid`](@ref)
"""
@concrete struct UniformAzimuthalGrid <: AbstractAzimuthalGrid
    upstream <: UniformGrid1D
    downstream <: UniformGrid1D

    @doc """
        UniformAzimuthalGrid(n; ψ₀=0)

    Create a uniform, cell-centered azimuthal grid over `(ψ₀, ψ₀ + 2π)`.

    Each half-cycle has `n` cells, so the full grid has `2n` points.
    The quadrature weights are constant with `Δψ = π/n`.

    # Arguments

    - `n::Integer`: Number of cells per half-cycle (must be positive).

    # Keyword Arguments

    - `ψ₀::Real`: Azimuth at the start of the upstream half-cycle.
    """
    function UniformAzimuthalGrid(n::T; ψ₀::Real = 0) where {T <: Integer}
        up = UniformGrid1D(n, (ψ₀, ψ₀ + pi))
        dn = UniformGrid1D(n, (ψ₀ + pi, ψ₀ + 2pi))

        return new{typeof(up), typeof(dn)}(up, dn)
    end
end

Base.length(m::UniformAzimuthalGrid) = 2 * length(m.upstream)
bounds(m::UniformAzimuthalGrid) = (first(m.upstream.bounds), last(m.downstream.bounds))
extent(::UniformAzimuthalGrid) = 2pi
points(m::UniformAzimuthalGrid) = let ψ₀ = first(m.upstream.bounds), Δψ = m.upstream.Δx
    LinRange(ψ₀ + Δψ / 2, (ψ₀ + 2pi) - Δψ / 2, length(m))
end
weights(m::UniformAzimuthalGrid) = Fill(m.upstream.Δx, length(m))
