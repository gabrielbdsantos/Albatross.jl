# """
#     LocalFlowState
#
# Local aerodynamic state seen by a blade section.
#
# This type bundles the nondimensional quantities that parameterize 2D airfoil
# aerodynamics at a given blade section ([`AbstractBladeSection`](@ref)).
#
# # Fields
#
# - `aoa`: Angle of attack (rad). Positive by the airfoil convention used by
#   the section model.
# - `Re`: Reynolds number based on local relative speed and chord (–).
# - `Ma`: Mach number based on local relative speed and speed of sound (–).
# """
# @concrete struct LocalFlowState
#     aoa
#     Re
#     Ma
# end
#
# LocalFlowState(; aoa, Re, Ma) = LocalFlowState(aoa, Re, Ma)
#
# @define_cat_methods LocalFlowState
#
# """
#     AerodynamicCoefficients
#
# Aerodynamic coefficients of a 2D blade section in airfoil axes.
#
# # Fields
#
# - `Cl`: Lift coefficient (-).
# - `Cd`: Drag coefficient (-).
# - `Cm`: Pitching-moment coefficient (-), about the reference point implied by
#   the section model (commonly quarter-chord).
#
# # Notes
#
# These coefficients are expressed in the airfoil's reference frame. Force
# coefficients in the rotor's reference frame (e.g. normal/tangential) should be
# computed separately using the local kinematics and angle of attack.
# """
# @concrete struct AerodynamicCoefficients
#     Cl
#     Cd
#     Cm
# end
#
# AerodynamicCoefficients(; Cl, Cd, Cm) = AerodynamicCoefficients(Cl, Cd, Cm)
#
# @define_cat_methods AerodynamicCoefficients

"""
    AbstractSectionAerodynamics

Abstract supertype for 2D blade section aerodynamic models.

A subtype of `AbstractSectionAerodynamics` provides a mapping from a local flow
state and a blade section description to 2D aerodynamic coefficients.

# Interface methods

- [`aerodynamic_coefficients`](@ref)
"""
abstract type AbstractSectionAerodynamics end

Base.broadcastable(m::AbstractSectionAerodynamics) = Ref(m)

"""
    aerodynamic_coefficients(
        model::AbstractSectionAerodynamics,
        section::AbstractBladeSection,
        aoa_deg,
        Re
    )

Return aerodynamic coefficients for `section` under the local flow conditions.

Concrete models must implement this method and return aerodynamic
coefficients compatible with downstream solver usage.
"""
function aerodynamic_coefficients end

"""
    NeuralSectionAerodynamics <: AbstractSectionAerodynamics

Neural-network-based 2D blade section aerodynamics model.

This model evaluates a trained network to predict section polars as a function
of airfoil shape, angle of attack, and Reynolds number.

# Fields

- `network_parameters`: Network configuration/weights descriptor.
- `n_crit`: e^N critical amplification factor used by the backend.
- `xtr_upper`: Upper-surface forced transition location (0–1).
- `xtr_lower`: Lower-surface forced transition location (0–1).
- `use_deep_stall`: Reserved flag for deep-stall / post-stall (360°) handling.

# Notes

Angles are provided to the backend in degrees. `Ma` is currently not used by
this model, and `use_deep_stall` is currently not applied in backend
evaluation. Both are retained for future extensions.
"""
@concrete struct NeuralSectionAerodynamics <: AbstractSectionAerodynamics
    network_parameters <: NNFoil.NeuralNetworkParameters
    n_crit
    xtr_upper
    xtr_lower
    use_deep_stall::Bool
end

"""
    NeuralSectionAerodynamics(;
        model_size=:xlarge,
        n_crit=9,
        xtr_upper=1,
        xtr_lower=1,
        use_deep_stall=false
    )

Construct a [`NeuralSectionAerodynamics`](@ref) model with a predefined network
size and auxiliary parameters.

# Keyword Arguments

- `model_size`: Network capacity preset (passed to `NeuralNetworkParameters`).
- `n_crit`: e^N critical amplification factor (backend-dependent).
- `xtr_upper`: Upper-surface forced transition location (0–1).
- `xtr_lower`: Lower-surface forced transition location (0–1).
- `use_deep_stall`: Reserved for future deep-stall / post-stall handling;
  currently not applied in backend evaluation.
"""
function NeuralSectionAerodynamics(;
        model_size = :xlarge, n_crit = 9, xtr_upper = 1, xtr_lower = 1,
        use_deep_stall = false
    )
    return NeuralSectionAerodynamics(
        NNFoil.NeuralNetworkParameters(; model_size),
        n_crit,
        xtr_upper,
        xtr_lower,
        use_deep_stall,
    )
end

# function aerodynamic_coefficients(
#         model::NeuralSectionAerodynamics,
#         state::LocalFlowState,
#         section::AbstractBladeSection
#     )
#     x = NNFoil.evaluate(
#         model.network_parameters,
#         shape(section),
#         rad2deg.(state.aoa),
#         state.Re;
#         n_crit = model.n_crit,
#         xtr_upper = model.xtr_upper,
#         xtr_lower = model.xtr_lower,
#     )
#     return AerodynamicCoefficients(x.CL, x.CD, x.CM)
# end
function aerodynamic_coefficients(
        model::NeuralSectionAerodynamics,
        section::AbstractBladeSection,
        aoa_deg,
        Re
    )
    x = NNFoil.evaluate(
        model.network_parameters,
        shape(section),
        aoa_deg,
        Re;
        n_crit = model.n_crit,
        xtr_upper = model.xtr_upper,
        xtr_lower = model.xtr_lower,
    )
    return x.CL, x.CD
end
