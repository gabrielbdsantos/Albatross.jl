"""
    AbstractBladeSection

Abstract supertype for blade section geometry descriptions.

# Interface Methods

- [`shape`](@ref)
- [`chord`](@ref)
- [`reference_point`](@ref)
- [`radial_position`](@ref)
- [`spanwise_position`](@ref)
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
    reference_point(section::AbstractBladeSection)

Return the reference point of the blade section in the local section reference
frame.
"""
function reference_point end

"""
    radial_position(section::AbstractBladeSection)

Return the radial position of the section reference point measured from the
rotor axis (m).
"""
function radial_position end

"""
    spanwise_position(section::AbstractBladeSection)

Return the spanwise position of the section reference point along the blade
(m).
"""
function spanwise_position end

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
- `reference_point`: Reference point of the section in the local section
  reference frame (usually the quarter-chord point).
- `radial_position`: Radial position of the section reference point measured
  from the rotor axis (m).
- `spanwise_position`: Spanwise position of the section reference point along
  the blade (m).
- `pitch`: Local geometric pitch angle of the section about the spanwise axis
  (rad).

!!! warning "Temporary placement fields"

    The fields `radial_position`, `spanwise_position`, and `pitch` represent
    mounting and placement parameters. They are included here for convenience
    for straight-bladed rotors and may be moved to a dedicated blade-geometry
    description in future extensions.
"""
@concrete struct BladeSection <: AbstractBladeSection
    shape
    chord
    reference_point
    radial_position
    spanwise_position
    pitch
end

BladeSection(; shape, chord, reference_point, radial_position, spanwise_position, pitch) =
    BladeSection(shape, chord, reference_point, radial_position, spanwise_position, pitch)

shape(s::BladeSection) = s.shape
chord(s::BladeSection) = s.chord
reference_point(s::BladeSection) = s.reference_point
radial_position(s::BladeSection) = s.radial_position
spanwise_position(s::BladeSection) = s.spanwise_position
pitch(s::BladeSection) = s.pitch
