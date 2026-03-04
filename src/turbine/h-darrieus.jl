"""
    UniformBladeHDarrieus <: AbstractDarrieusTurbine

H-Darrieus vertical-axis wind turbine model with identical blades.

This turbine model represents a straight-bladed (H-type) Darrieus rotor in
which all blades share the same blade geometry and section layout. The blade
geometry is replicated `num_blades` times and distributed uniformly in azimuth.

Rotor motion is prescribed through a rotor-kinematics model and is independent
of aerodynamic loading.

# Fields

- `blade`: Blade geometry model describing the spanwise layout and section
  geometry of a single blade.
- `kinematics`: Rotor kinematics model prescribing the angular motion of the
  rotor.
- `num_blades`: Number of blades in the rotor.
"""
@concrete struct UniformBladeHDarrieus <: AbstractDarrieusTurbine
    blade <: AbstractBladeGeometry
    kinematics <: AbstractRotorKinematics
    num_blades
end

UniformBladeHDarrieus(;
    blade::AbstractBladeGeometry,
    kinematics::AbstractRotorKinematics,
    num_blades
) = UniformBladeHDarrieus(blade, kinematics, num_blades)

num_blades(t::UniformBladeHDarrieus) = t.num_blades
kinematics(t::UniformBladeHDarrieus) = t.kinematics

# NOTE: UniformBladeHDarrieus assumes identical blades, so this returns a
# single representative blade geometry for now.
blades(t::UniformBladeHDarrieus) = t.blade

function swept_area(t::UniformBladeHDarrieus)
    z = nothing
    blade = blades(t)
    H = span(blade)
    R = radial_pos(section(blade, z))

    return H * 2R
end
