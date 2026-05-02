"""
    SteirosHultmark()

Momentum formulation that extends upon the classical Rankine--Froude actuator
disk theory by including the effect of base suction in the wake
[ayati2019doublemultiple,steiros2018drag](@cite).
"""
struct SteirosHultmark <: AbstractMomentumTheory end

wake_velocity_ratio(::SteirosHultmark, a) = (1 - a) / (1 + a)

drag_coefficient(::SteirosHultmark, a) = begin
    a <= 0.7 ?
        4 / 3 * a * (3 - a) / (1 + a) :
        0.889 - (0.0203 - (a - 0.143)^2) / 0.6427
end
