"""
    AbstractDMSTDiscretization

Abstract supertype for azimuthal discretization schemes used by DMST solvers.

A subtype of `AbstractDMSTDiscretization` defines how the rotor azimuthal
domain is discretized for the upstream and downstream half-rotations required
by the Double Multiple Streamtube (DMST) formulation.

This abstraction is solver-specific and does not describe geometric or
kinematic properties of the rotor.

# Interface methods

- [`num_azimuths`](@ref)
- [`upstream_deltas`](@ref)
- [`downstream_deltas`](@ref)
- [`upstream_azimuths`](@ref)
- [`downstream_azimuths`](@ref)
"""
abstract type AbstractDMSTDiscretization end

"""
    num_azimuths(discretization::AbstractDMSTDiscretization)

Return the number of azimuthal collocation points used in each half-rotation
(upstream and downstream).
"""
function num_azimuths end

"""
    upstream_deltas(discretization::AbstractDMSTDiscretization)

Return the azimuthal integration weights (rad) associated with the upstream
half-rotation collocation points.

The returned vector must have the same length as [`upstream_azimuths`](@ref)
and represents the azimuthal interval associated with each upstream collocation
point.
"""
function upstream_deltas end

"""
    downstream_deltas(discretization::AbstractDMSTDiscretization)

Return the azimuthal integration weights (rad) associated with the downstream
half-rotation collocation points.

The returned vector must have the same length as [`downstream_azimuths`](@ref)
and represents the azimuthal interval associated with each downstream
collocation point.
"""
function downstream_deltas end

"""
    upstream_azimuths(discretization::AbstractDMSTDiscretization)

Return the azimuthal collocation points (rad) associated with the upstream
half-rotation. The returned vector must span the interval [0, π).
"""
function upstream_azimuths end

"""
    downstream_azimuths(discretization::AbstractDMSTDiscretization)

Return the azimuthal collocation points (rad) associated with the downstream
half-rotation.

The returned vector must span the interval [π, 2π).
"""
function downstream_azimuths end


"""
    UniformAzimuth <: AbstractDMSTDiscretization

Uniform azimuthal discretization for DMST solvers.

The azimuthal domain is divided into equally spaced collocation points using
midpoint sampling. The upstream half-rotation spans [0, π) and the downstream
half-rotation spans [π, 2π).

# Fields

- `n`: Number of azimuthal points in each half-rotation.
- `Δθ`: Uniform azimuthal step size (rad) over the half-rotation.
- `upstream`: Vector of azimuthal collocation points (rad) in the upstream
  half-rotation.
- `downstream`: Vector of azimuthal collocation points (rad) in the downstream
  half-rotation.
"""
@concrete struct UniformAzimuth <: AbstractDMSTDiscretization
    n
    Δθ
    upstream
    downstream

    @doc """
        UniformAzimuth(n)

    Construct a uniform azimuthal discretization with `n` collocation points
    in each half-rotation.

    The collocation points are placed at the midpoints of `n` equal azimuthal
    intervals over each half-rotation.

    # Arguments

    - `n::Integer`: Number of azimuthal points in the upstream and downstream
      half-rotations.
    """
    function UniformAzimuth(n::T) where {T <: Integer}
        n > 0 || throw(ArgumentError("`n` must be a positive integer."))
        Δθ = pi / n
        upstream = LinRange(Δθ / 2, pi - Δθ / 2, n)
        downstream = upstream .+ pi

        return new{T, typeof(Δθ), typeof(upstream), typeof(downstream)}(
            n, Δθ, upstream, downstream
        )
    end
end

num_azimuths(m::UniformAzimuth) = m.n
upstream_deltas(m::UniformAzimuth) = fill(m.Δθ, m.n)
downstream_deltas(m::UniformAzimuth) = upstream_deltas(m)
upstream_azimuths(m::UniformAzimuth) = m.upstream
downstream_azimuths(m::UniformAzimuth) = m.downstream
