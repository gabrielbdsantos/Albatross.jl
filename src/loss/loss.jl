@concrete struct LossModels
    curvature <: Union{AbstractCurvatureCorrection, Nothing}
end

LossModels(; curvature = nothing) = LossModels(curvature)
