"""
    RankineFroude()

Momentum formulation that builds upon the classical Rankine--Froude actuator
disk theory [ayati2019doublemultiple](@cite).
"""
struct RankineFroude <: AbstractMomentumTheory end

wake_velocity_ratio(::RankineFroude, a) = 1 - 2 * a

thrust_coefficient(::RankineFroude, a) = begin
    a <= 0.4 ?
        4 * a * (1 - a) :
        0.889 - (0.0203 - (a - 0.143)^2) / 0.6427
end
