"""
    GormontBergDynamicStallSectionAerodynamics <: AbstractSectionAerodynamics

Berg's VAWT modification of the Gormont dynamic-stall model, following the
formulation implemented in QBlade
(https://docs.qblade.org/src/theory/aerodynamics/dynamic_stall/GOR_stall.html).

Wraps a static `base` section aerodynamics model, which is used to evaluate
`Cl`/`Cd` at the instantaneous and rate-shifted reference angles of attack.

# Fields

- `base <: AbstractSectionAerodynamics`: Static aerodynamics model (e.g.
  [`NeuralSectionAerodynamics`](@ref)) supplying static polar values.
- `aoa_prev`: Reference to the angle of attack of the previous time step
  (rad). Mutable state updated by [`advance_state!`](@ref).
- `aoa_prev0`: Initial value of `aoa_prev` (rad), restored by
  [`reset_state!`](@ref).
- `Am`: Empirical Gormont–Berg constant (–).
- `tc`: Airfoil thickness-to-chord ratio (–), used by the stall-delay
  functions `Y_L`, `Y_M`. Must be supplied explicitly; it is not derived from
  `base`/`section`.
- `aoa_zero_lift`: Zero-lift angle of attack (rad), estimated from the static
  lift polar.
- `aoa_cl_max`: Angle of attack of maximum static lift coefficient (rad).
- `aoa_cl_min`: Angle of attack of minimum static lift coefficient (rad).
 
# Notes
 
- `aoa_zero_lift`, `aoa_cl_max`, and `aoa_cl_min` are computed once at
  construction from the static polar at a reference Reynolds number.
- All angles are handled **internally in radians**. The `aoa` received by
  [`aerodynamic_coefficients`](@ref) follows the package-wide convention of
  degrees; it is converted to radians on entry, and converted back to
  degrees only when evaluating `base`.
- This model is stateful: it must be driven by streamtubes visited in
  physical azimuthal order, with [`advance_state!`](@ref) called exactly once
  per streamtube after its induction factor has converged. `solve(::DMST)`
  already does this. See the warning in [`advance_state!`](@ref) regarding
  reuse across independent `solve` calls.
- The vectorized/broadcast recomputation path used by
  `evaluate_streamtube_fields` is **not** valid for this model, since it does
  not preserve the sequential angle-of-attack history. Use 
  `evaluate_streamtube_fields_sequential` instead.
"""
@concrete struct GormontBergDynamicStallSectionAerodynamics <: AbstractSectionAerodynamics
    base <: AbstractSectionAerodynamics
    aoa_prev
    aoa_prev0
    Am
    tc
    aoa_zero_lift
    aoa_cl_max
    aoa_cl_min
end

"""
    GormontBergDynamicStallSectionAerodynamics(;
        base = NeuralSectionAerodynamics(),
        section,
        Re_ref,
        tc,
        aoa_prev = 0.0,
        Am = 6.0,
        aoa_scan = -25:0.25:25,
    )

Construct a [`GormontBergDynamicStallSectionAerodynamics`](@ref) model,
precomputing the static-polar reference angles (`aoa_zero_lift`,
`aoa_cl_max`, `aoa_cl_min`) from a scan of `base` over `aoa_scan`.

# Keyword Arguments

- `base`: Static aerodynamics model used for polar evaluation.
- `section`: Blade section used for the static polar scan.
- `Re_ref`: Reynolds number used for the static polar scan.
- `tc`: Section thickness-to-chord ratio (–). Required; supply directly since
  no accessor currently derives it from `section`/`base`.
- `aoa_prev`: Initial angle of attack (deg), converted to radians and used to
  seed the AoA history.
- `Am`: Empirical Gormont–Berg constant.
- `aoa_scan`: Angle-of-attack scan range (deg), matching `base`'s convention.
"""
function GormontBergDynamicStallSectionAerodynamics(;
        base = NeuralSectionAerodynamics(),
        section,
        Re_ref,
        tc,
        aoa_prev = 0.0,
        Am = 6.0,
        aoa_scan = -25:0.25:25,
    )
    Cl_scan = [first(aerodynamic_coefficients(base, section, α, Re_ref)) for α in aoa_scan]
    aoa_scan_rad = deg2rad.(aoa_scan)

    aoa_zero_lift = estimate_aoa_zero(aoa_scan_rad, Cl_scan)
    aoa_cl_max = aoa_scan_rad[argmax(Cl_scan)]
    aoa_cl_min = aoa_scan_rad[argmin(Cl_scan)]

    aoa0_rad = deg2rad(float(aoa_prev))
    return GormontBergDynamicStallSectionAerodynamics(
        base, Ref(aoa0_rad), aoa0_rad, Am, tc, aoa_zero_lift, aoa_cl_max, aoa_cl_min
    )
end

"""
    gormont_berg(model::GormontBergDynamicStallSectionAerodynamics, section,
        aoa, Re, U_r, c, dt)
 
Compute dynamic-stall-corrected lift and drag coefficients.

All angle arguments (`aoa`, and the model's internal reference angles) are in
radians. `Re` is evaluated at the instantaneous angle of attack; the
reference-angle evaluations reuse `Re` unchanged.

# Arguments

- `model::GormontBergDynamicStallSectionAerodynamics`
- `section::AbstractBladeSection`
- `aoa`: Instantaneous angle of attack (rad).
- `Re`: Reynolds number (–).
- `U_r`: Local relative velocity (m/s).
- `c`: Local chord (m).
- `dt`: Azimuthal time step (s).

# Returns

- `Tuple`: `(Cl_dyn, Cd_dyn)`.

# Notes
 
- The model state is only read. Call [`advance_state!`](@ref) after each time
  step to update the previous angle of attack.
"""
function gormont_berg(model::GormontBergDynamicStallSectionAerodynamics, section, aoa, Re, U_r, c, dt)
    daoa = (aoa - model.aoa_prev[]) / dt

    Tu = c / (2 * U_r)
    K1 = daoa >= 0 ? 1.0 : 0.5

    YL = 1.4 - 6.0 * (0.06 - model.tc)
    YM = 1.0 - 2.5 * (0.06 - model.tc)

    delay = sqrt(abs(Tu * daoa)) * sign(daoa)
    aoa_ref_lift = aoa - K1 * YL * delay
    aoa_ref_drag = aoa - K1 * YM * delay

    Cl_st, Cd_st = aerodynamic_coefficients(model.base, section, rad2deg(aoa), Re)
    Cl_st_ref, _ = aerodynamic_coefficients(model.base, section, rad2deg(aoa_ref_lift), Re)
    _, Cd_gb = aerodynamic_coefficients(model.base, section, rad2deg(aoa_ref_drag), Re)

    aoa0 = model.aoa_zero_lift
    Cl_gb = if abs(aoa_ref_lift - aoa0) < 1.0e-3
        Cl_st_ref
    else
        Cl_st_ref * (aoa - aoa0) / (aoa_ref_lift - aoa0)
    end

    if aoa >= aoa0
        aoa_end = aoa0 + model.Am * (model.aoa_cl_max - aoa0)
        gamma = (aoa_end - aoa) / (aoa_end - model.aoa_cl_max)
    else
        aoa_end = aoa0 + model.Am * (model.aoa_cl_min - aoa0)
        gamma = (aoa_end - aoa) / (aoa_end - model.aoa_cl_min)
    end
    gamma = clamp(gamma, 0.0, 1.0)

    Cl_dyn = Cl_st + gamma * (Cl_gb - Cl_st)
    Cd_dyn = Cd_st + gamma * (Cd_gb - Cd_st)

    return Cl_dyn, Cd_dyn
end

"""
    aerodynamic_coefficients(model::GormontBergDynamicStallSectionAerodynamics,
        section::AbstractBladeSection, aoa::Real, Re::Real; U_r, c, dt)
 
Compute dynamic-stall-corrected lift and drag coefficients.
 
Converts `aoa` to radians and delegates to `gormont_berg`.
 
# Arguments
 
- `model::GormontBergDynamicStallSectionAerodynamics`: Dynamic stall model.
- `section::AbstractBladeSection`: Blade section passed to the static model.
- `aoa::Real`: Current angle of attack (deg).
- `Re::Real`: Reynolds number (–).
 
# Keyword Arguments
 
- `U_r`: Relative flow velocity at the section (m/s).
- `c`: Chord length (m).
- `dt`: Time step (s).
 
# Returns
 
- `Tuple`: Dynamic lift and drag coefficients `(Cl, Cd)` (–).
 
# See Also
 
[`advance_state!`](@ref), [`reset_state!`](@ref).
"""
function aerodynamic_coefficients(
        model::GormontBergDynamicStallSectionAerodynamics,
        section::AbstractBladeSection,
        aoa::Real,
        Re::Real;
        U_r,
        c,
        dt,
    )
    return gormont_berg(model, section, deg2rad(aoa), Re, U_r, c, dt)
end

"""
    advance_state!(model::GormontBergDynamicStallSectionAerodynamics,
        aoa::Real)
 
Store `aoa` as the previous angle of attack of `model` in-place.
 
# Arguments
 
- `model::GormontBergDynamicStallSectionAerodynamics`: Mutated model. Only the
  stored previous angle of attack is modified.
- `aoa::Real`: Angle of attack of the completed time step (rad).
 
# Notes
 
- Unlike [`aerodynamic_coefficients`](@ref), `aoa` is in radians, matching the
  units of the stored state.
 
# See Also
 
[`reset_state!`](@ref).
"""
function advance_state!(model::GormontBergDynamicStallSectionAerodynamics, aoa::Real)
    model.aoa_prev[] = aoa
    return nothing
end

"""
    reset_state!(model::GormontBergDynamicStallSectionAerodynamics)

Reset the angle-of-attack history back to the initial `aoa_prev` supplied at
construction time in-place. Function needed to support independent solve calls.
This ensures that each power coefficient evaluation at a given TSR is 
independent of previous solve calls, allowing, for example, a power curve to 
be evaluated across a range of TSR values without solutions at one TSR 
influencing the results at another.
 
# Arguments
 
- `model::GormontBergDynamicStallSectionAerodynamics`: Mutated model. Only the
  stored previous angle of attack is modified.
 
# See Also
 
[`advance_state!`](@ref).
"""
function reset_state!(model::GormontBergDynamicStallSectionAerodynamics)
    model.aoa_prev[] = model.aoa_prev0
    return nothing
end
