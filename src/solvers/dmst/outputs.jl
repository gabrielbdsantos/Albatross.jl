# """
#     DMSTStreamtubeOutput
#
# Container for streamtube output data.
#
# Fields are typically vectors (or matrices) evaluated at the grid collocation
# points used by the DMST discretization.
#
# # Fields
#
# - `a`: Axial induction factor (-).
# - `θ`: Azimuth angle (rad).
# - `U_r`: Relative velocity magnitude at the section (m/s).
# - `aoa`: Angle of attack (rad).
# - `Re`: Reynolds number (-).
# - `Ma`: Mach number (-).
# - `Cl`: Lift coefficient (-).
# - `Cd`: Drag coefficient (-).
# - `Ct`: Tangential force coefficient in rotor/blade axes (-).
# - `Cn`: Normal force coefficient in rotor/blade axes (-).
# - `Th`: Instantaneous thrust/normal load contribution (N).
# - `Q`: Instantaneous torque (N·m).
# - `P`: Instantaneous power (W).
# - `Cth`: Instantaneous thrust coefficient contribution (-).
# - `Cq`: Instantaneous torque coefficient (-).
# - `Cp`: Instantaneous power coefficient contribution (-).
#
# # See also
#
# [`DMSTSolution`](@ref)
# """
# @concrete struct DMSTStreamtubeOutput
#     a; θ; U_r; aoa; Re; Ma; Cl; Cd; Ct; Cn; Th; Q; P; Cth; Cq; Cp
# end
#
# DMSTStreamtubeOutput(;
#     a, θ, U_r, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Q, P, Cth, Cq, Cp
# ) = DMSTStreamtubeOutput(
#     a, θ, U_r, aoa, Re, Ma, Cl, Cd, Ct, Cn, Th, Q, P, Cth, Cq, Cp
# )
#
# @define_cat_methods DMSTStreamtubeOutput
#
# """
#     DMSTSolution
#
# Structured output of a full DMST solve.
#
# # Fields
#
# - `upstream<:DMSTStreamtubeOutput`: Upstream solution.
# - `downstream<:DMSTStreamtubeOutput`: Downstream solution.
# - `integrated`: Global quantities.
# - `stats<:DMSTSolveStats`: Solver diagnostics and convergence metadata.
#
# # See also
#
# [`DMSTStreamtubeOutput`](@ref), [`DMSTSolveStats`](@ref)
# """
# @concrete struct DMSTSolution
#     upstream <: DMSTStreamtubeOutput
#     downstream <: DMSTStreamtubeOutput
#     integrated
#     stats <: DMSTSolveStats
# end
#
# DMSTSolution(;
#     upstream,
#     downstream,
#     integrated = nothing,
#     stats = DMSTSolveStats(),
# ) = DMSTSolution(upstream, downstream, integrated, stats)
#
# # NOTE: backward-compatiable accessors on DMSTSolution
# function Base.getproperty(sol::DMSTSolution, name::Symbol)
#     if name in fieldnames(DMSTSolution)
#         return getfield(sol, name)
#     elseif name in fieldnames(DMSTStreamtubeOutput)
#         up = getproperty(getfield(sol, :upstream), name)
#         dn = getproperty(getfield(sol, :downstream), name)
#         return [up; dn]
#     end
#
#     # If it reached here, this will throw an error.
#     return getfield(sol, name)
# end
#
# Base.propertynames(::DMSTSolution, private::Bool = false) = (
#     fieldnames(DMSTSolution)...,
#     fieldnames(DMSTStreamtubeOutput)...,
# )

@concrete struct DMSTNonlinearSolution
    a_up
    a_down
    ctx_up
    ctx_down
    stats_up
    stats_down
end

@concrete struct DMSTStreamtubeFields
    a
    θ
    U_r
    aoa
    Re
    Ma
    Cl
    Cd
    Ct
    Cn
    Th
    Q
    P
    Cth
    Cq
    Cp
end
