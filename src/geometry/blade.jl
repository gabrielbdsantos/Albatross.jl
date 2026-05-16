"""
    AbstractBladeGeometry

Abstract supertype for blade geometry models.

A subtype of `AbstractBladeGeometry` defines how blade sections are arranged
along the blade span and provides access to the corresponding blade section
geometry at a given spanwise coordinate.

# Interface Methods

- [`section`](@ref)
- [`span`](@ref)
"""
abstract type AbstractBladeGeometry end

Base.broadcastable(m::AbstractBladeGeometry) = Ref(m)

# Required interface
# ---------------------------------------------------------------------
"""
    section(b::AbstractBladeGeometry, z)

Return the blade section geometry at spanwise coordinate `z`.
"""
function section end

"""
    span(b::AbstractBladeGeometry)

Return the total blade span (m).
"""
function span end

# Convenience geometry queries forwarded to the section
# ---------------------------------------------------------------------
"""
    shape(b::AbstractBladeGeometry, z)

Return the section shape descriptor at spanwise coordinate `z`.
"""
shape(b::AbstractBladeGeometry, z) = shape(section(b, z))

"""
    chord(b::AbstractBladeGeometry, z)

Return the section chord length at spanwise coordinate `z` (m).
"""
chord(b::AbstractBladeGeometry, z) = chord(section(b, z))


"""
    ref_point(b::AbstractBladeGeometry, z)

Return the section reference point in the local section reference frame.
"""
ref_point(b::AbstractBladeGeometry, z) = ref_point(section(b, z))

"""
    radial_pos(b::AbstractBladeGeometry, z)

Return the radial position of the section reference point measured from the
rotor axis at spanwise coordinate `z` (m).
"""
radial_pos(b::AbstractBladeGeometry, z) = radial_pos(section(b, z))

"""
    span_pos(b::AbstractBladeGeometry, z)

Return the spanwise position of the section reference point (m).

For many geometries this will be identical to the query coordinate `z`.
"""
span_pos(b::AbstractBladeGeometry, z) = span_pos(section(b, z))

"""
    pitch(b::AbstractBladeGeometry, z)

Return the local geometric pitch angle of the section about the spanwise axis
at spanwise coordinate `z` (rad).
"""
pitch(b::AbstractBladeGeometry, z) = pitch(section(b, z))


# Implementations
# -----------------------------------------------------
"""
    UniformStraightBlade <: AbstractBladeGeometry

Straight blade geometry with a single, uniform blade section along the entire
span.

# Fields

- `section<:AbstractBladeSection`: Blade section geometry used for the entire
  blade.
- `span`: Total blade span (m).
"""
@concrete struct UniformStraightBlade <: AbstractBladeGeometry
    section <: AbstractBladeSection
    span
end

UniformStraightBlade(; section::AbstractBladeSection, span) =
    UniformStraightBlade(section, span)

section(b::UniformStraightBlade, _) = b.section
span(b::UniformStraightBlade) = b.span
