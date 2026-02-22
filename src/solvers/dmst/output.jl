"""
    DMSTOutput

Container for DMST results.

All fields are typically vectors (or arrays) evaluated at the azimuthal
collocation points used by the DMST discretization.

# Fields

- `a`: Axial induction factor (-).
- `θ`: Azimuth angle (rad).
- `U_r`: Relative velocity magnitude at the section (m/s).
- `aoa`: Angle of attack (rad).
- `Re`: Reynolds number (-).
- `Ma`: Mach number (-).
- `Cl`: Lift coefficient (-).
- `Cd`: Drag coefficient (-).
- `Ct`: Tangential force coefficient in rotor/blade axes (-).
- `Cn`: Normal force coefficient in rotor/blade axes (-).
- `Th`: Instantaneous thrust/normal load contribution (N).
- `Cq`: Instantaneous torque coefficient (-).
- `Q`: Instantaneous torque (N·m).
- `Cth`: Instantaneous thrust coefficient contribution (-).
- `Cp`: Instantaneous power coefficient contribution (-).
"""
@concrete struct DMSTOutput
    a; θ; U_r; aoa; Re; Ma; Cl; Cd; Ct; Cn; Th; Cq; Q; Cth; Cp
end

function DMSTOutput(; a, θ, U_r, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Cq, Q, Cth, Cp)
    return DMSTOutput(a, θ, U_r, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Cq, Q, Cth, Cp)
end

@define_cat_methods DMSTOutput
