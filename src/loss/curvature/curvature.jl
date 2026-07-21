abstract type AbstractCurvatureCorrection end
Base.broadcastable(m::AbstractCurvatureCorrection) = Ref(m)
function aoa_correction end
