"""
    NeuralSectionAerodynamics <: AbstractSectionAerodynamics

Neural-network-based 2D blade section aerodynamics model.

This model evaluates a trained network to predict section polars as a function
of airfoil shape, angle of attack, and Reynolds number.

# Fields

- `network_parameters<:NNFoil.NeuralNetworkParameters`: Pretrained network
  weights, biases, and scaled-input distribution statistics.
- `cache<:NNFoil.NeuralNetworkCache`: Preallocated network workspace buffers
  used by in-place evaluations.
- `n_crit`: Critical amplification factor (`e^N`) used by the backend.
- `xtr_upper`: Upper-surface forced transition location (0–1).
- `xtr_lower`: Lower-surface forced transition location (0–1).
- `use_deep_stall`: Reserved flag for deep-stall / post-stall (360°) handling.

# Notes

- Angles are provided to the backend in degrees.
- Scalar coefficient evaluation updates `cache` before running the network.
- `Ma` is currently not used by this model, and `use_deep_stall` is currently
  not applied in backend evaluation. Both are retained for future extensions.
"""
@concrete struct NeuralSectionAerodynamics <: AbstractSectionAerodynamics
    network_parameters <: NNFoil.NeuralNetworkParameters
    cache <: NNFoil.NeuralNetworkCache
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
- `n_crit`: Critical amplification factor (`e^N`; backend-dependent).
- `xtr_upper`: Upper-surface forced transition location (0–1).
- `xtr_lower`: Lower-surface forced transition location (0–1).
- `use_deep_stall`: Reserved for future deep-stall / post-stall handling;
  currently not applied in backend evaluation.
"""
function NeuralSectionAerodynamics(;
        model_size = :xlarge, n_crit = 9, xtr_upper = 1, xtr_lower = 1,
        use_deep_stall = false
    )
    network_parameters = NNFoil.NeuralNetworkParameters(; model_size)

    return NeuralSectionAerodynamics(
        network_parameters,
        NNFoil.NeuralNetworkCache(network_parameters, Vector{Float64}(undef, 25)),
        n_crit,
        xtr_upper,
        xtr_lower,
        use_deep_stall,
    )
end

"""
    aerodynamic_coefficients(model::NeuralSectionAerodynamics,
        section::AbstractBladeSection, aoa, Re)

Compute lift and drag coefficients using NNFoil for the current local flow
state and section geometry.

# Arguments

- `model::NeuralSectionAerodynamics`: Neural section aerodynamics model.
- `section::AbstractBladeSection`: Blade section providing airfoil shape.
- `aoa`: Scalar or batched angles of attack in degrees.
- `Re`: Scalar or batched Reynolds numbers.

# Returns

- `Tuple`: `(CL, CD)` lift and drag coefficients. Scalar inputs return scalar
  coefficients; vector inputs return arrays matching the input batch.

# Notes

- Scalar inputs update `model.cache` in place before evaluating the network.
- Vector inputs are evaluated out of place for compatibility with
  ForwardDiff.jl.
"""
function aerodynamic_coefficients(
        model::NeuralSectionAerodynamics,
        section::AbstractBladeSection,
        aoa::Real,
        Re::Real
    )
    NNFoil.update_features!(
        model.cache,
        shape(section),
        aoa,
        Re,
        model.n_crit,
        model.xtr_upper,
        model.xtr_lower
    )
    NNFoil.evaluate!(model.cache)
    return only(model.cache.outputs.CL), only(model.cache.outputs.CD)
end

function aerodynamic_coefficients(
        model::NeuralSectionAerodynamics,
        section::AbstractBladeSection,
        aoa::AbstractVector{<:Real},
        Re::AbstractVector{<:Real}
    )
    x = NNFoil.evaluate(
        model.network_parameters,
        shape(section),
        aoa,
        Re;
        n_crit = model.n_crit,
        xtr_upper = model.xtr_upper,
        xtr_lower = model.xtr_lower,
    )
    return x.CL, x.CD
end

aerodynamic_coefficients(
    model::AbstractVector{<:NeuralSectionAerodynamics},
    section::AbstractVector{<:AbstractBladeSection},
    aoa,
    Re
) = aerodynamic_coefficients(first(model), first(section), aoa, Re)
