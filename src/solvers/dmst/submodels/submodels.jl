include("curvature.jl")

"""
    DMSTSubmodels

A set of submodels that modify the DMST evaluation.

# Fields

- `curvature<:Union{AbstractCurvatureCorrection,Nothing}`: Curvature correction
  applied to the local angle of attack, or `nothing` to disable curvature
  correction.
"""
@concrete struct DMSTSubmodels
    curvature <: Union{AbstractCurvatureCorrection, Nothing}
end

DMSTSubmodels(; curvature = nothing) = DMSTSubmodels(curvature)
