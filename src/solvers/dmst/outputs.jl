"""
    DMSTNonlinearSolution

Container for DMST nonlinear solve outputs before aerodynamic postprocessing.

# Fields

- `a_up`: Upstream induction factors at upstream azimuth collocation points
  (–).
- `a_down`: Downstream induction factors at downstream azimuth collocation
  points (–).
- `ctxs_up`: Upstream streamtube contexts used during solve.
- `ctxs_down`: Downstream streamtube contexts used during solve.
- `stats_up`: Per-streamtube nonlinear diagnostics at upstream points.
- `stats_down`: Per-streamtube nonlinear diagnostics at downstream points.

# See Also

[`solve`](@ref), [`build_streamtube_contexts`](@ref),
[`evaluate_streamtube_fields`](@ref).
"""
@concrete struct DMSTNonlinearSolution
    a_up
    a_down
    ctxs_up
    ctxs_down
    stats_up
    stats_down
end

"""
    DMSTStreamtubeFields

Aerodynamic and performance fields evaluated at streamtube collocation points.

# Fields

- `a`: Axial induction factor (–).
- `θ`: Azimuth angle (rad).
- `U_r`: Relative velocity magnitude at the section (m/s).
- `aoa`: Angle of attack (rad).
- `Re`: Reynolds number (–).
- `Ma`: Mach number (–).
- `Cl`: Lift coefficient (–).
- `Cd`: Drag coefficient (–).
- `Ct`: Tangential force coefficient in rotor/blade axes (–).
- `Cn`: Normal force coefficient in rotor/blade axes (–).
- `Th`: Instantaneous thrust/normal load contribution (N).
- `Q`: Instantaneous torque (N·m).
- `P`: Instantaneous power (W).
- `Cth`: Instantaneous thrust coefficient contribution (–).
- `Cq`: Instantaneous torque coefficient (–).
- `Cp`: Instantaneous power coefficient contribution (–).

# See Also

[`evaluate_streamtube_fields`](@ref).
"""
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
