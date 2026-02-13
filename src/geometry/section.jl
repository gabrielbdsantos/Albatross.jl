"""
    AbstractBladeSection

Abstract supertype for blade section geometry descriptions.

# Interface methods

- [`shape`](@ref)
- [`chord`](@ref)
- [`ref_point`](@ref)
- [`radial_pos`](@ref)
- [`span_pos`](@ref)
- [`pitch`](@ref)
"""
abstract type AbstractBladeSection end

"""
    shape(section::AbstractBladeSection)

Return the airfoil or section shape descriptor associated with the blade
section.
"""
function shape end

"""
    chord(section::AbstractBladeSection)

Return the chord length of the blade section (m).
"""
function chord end

"""
    ref_point(section::AbstractBladeSection)

Return the reference point of the blade section in the local section reference
frame.
"""
function ref_point end

"""
    radial_pos(section::AbstractBladeSection)

Return the radial position of the section reference point measured from the
rotor axis (m).
"""
function radial_pos end

"""
    span_pos(section::AbstractBladeSection)

Return the spanwise position of the section reference point along the blade
(m).
"""
function span_pos end

"""
    pitch(section::AbstractBladeSection)

Return the local geometric pitch angle of the section about the spanwise axis
(rad).
"""
function pitch end

"""
    BladeSection <: AbstractBladeSection

Geometric description of a blade cross-section.

# Fields

- `shape`: Airfoil or section shape descriptor associated with the blade
  section.
- `chord`: Section chord length (m).
- `ref_point`: Reference point of the section in the local section reference
  frame (usually the quarter-chord point).
- `r`: Radial position of the section reference point measured from the rotor
  axis (m).
- `z`: Spanwise position of the section reference point along the blade (m).
- `pitch`: Local geometric pitch angle of the section about the spanwise axis
  (rad).

!!! warning "Temporary placement fields"

    The fields `r`, `z`, and `pitch` represent mounting and placement
    parameters. They are included here for convenience for straight-bladed
    rotors and may be moved to a dedicated blade-geometry description in future
    extensions.
"""
@concrete struct BladeSection <: AbstractBladeSection
    shape
    chord
    ref_point
    r
    z
    pitch
end

BladeSection(; shape, chord, ref_point, r, z, pitch) =
    BladeSection(shape, chord, ref_point, r, z, pitch)

shape(s::BladeSection) = s.shape
chord(s::BladeSection) = s.chord
ref_point(s::BladeSection) = s.ref_point
radial_pos(s::BladeSection) = s.r
span_pos(s::BladeSection) = s.z
pitch(s::BladeSection) = s.pitch
