"""
    DMSTOutput

Container for DMST results.

All fields are typically vectors (or matrices) evaluated at the grid
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
- `Q`: Instantaneous torque (N·m).
- `P`: Instantaneous power (W).
- `Cth`: Instantaneous thrust coefficient contribution (-).
- `Cq`: Instantaneous torque coefficient (-).
- `Cp`: Instantaneous power coefficient contribution (-).

# See also

[`DMSTGrid`](@ref)
"""
@concrete struct DMSTOutput
    a; θ; U_r; aoa; Re; Ma; Cl; Cd; Ct; Cn; Th; Q; P; Cth; Cq; Cp
end

function DMSTOutput(; a, θ, U_r, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Q, P, Cth, Cq, Cp)
    return DMSTOutput(a, θ, U_r, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Q, P, Cth, Cq, Cp)
end

@define_cat_methods DMSTOutput

"""
    DMSTSolution

Structured output of a full DMST solve.

# Fields

- `upstream<:DMSTOutput`: Upstream solution.
- `downstream<:DMSTOutput`: Downstream solution.
- `integrated`: Global quantities.
- `stats<:DMSTSolveStats`: Solver diagnostics and convergence metadata.

# See also

[`DMSTOutput`](@ref), [`DMSTSolveStats`](@ref)
"""
@concrete struct DMSTSolution
    upstream <: DMSTOutput
    downstream <: DMSTOutput
    integrated
    stats <: DMSTSolveStats
end

DMSTSolution(;
    upstream,
    downstream,
    integrated = nothing,
    stats = DMSTSolveStats(),
) = DMSTSolution(upstream, downstream, integrated, stats)

# NOTE: backward-compatiable accessors on DMSTSolution
function Base.getproperty(sol::DMSTSolution, name::Symbol)
    if name in fieldnames(DMSTSolution)
        return getfield(sol, name)
    elseif name in fieldnames(DMSTOutput)
        up = getproperty(getfield(sol, :upstream), name)
        dn = getproperty(getfield(sol, :downstream), name)
        return [up; dn]
    end

    # If it reached here, this will throw an error.
    return getfield(sol, name)
end

Base.propertynames(::DMSTSolution, private::Bool = false) = (
    fieldnames(DMSTSolution)...,
    fieldnames(DMSTOutput)...,
)
