"""
    RankineFroude()

Momentum formulation that builds upon the classical Rankine--Froude actuator
disk theory.

# References

1. A. A. Ayati, K. Steiros, M. A. Miller, S. Duvvuri, and M. Hultmark, "**A
   double-multiple streamtube model for vertical axis wind turbines of
   arbitrary rotor loading**," Wind Energ. Sci., vol. 4, no. 4, pp.
   653–662, Dec. 2019, doi: 10.5194/wes-4-653-2019.
"""
struct RankineFroude <: AbstractMomentumTheory end

wake_velocity_ratio(::RankineFroude, a) = 1 - 2 * a

drag_coefficient(::RankineFroude, a) = begin
    a <= 0.4 ?
        (4 * a * (1 - a)) :
        (0.899 - (0.0203 - (a - 0.143)^2) / 0.6427)
end
