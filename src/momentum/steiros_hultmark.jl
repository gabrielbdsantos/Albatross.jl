"""
    SteirosHultmark()

Momentum formulation that extends upon the classical Rankine--Froude actuator
disk theory by including the effect of base suction in the wake.

# References

1. A. A. Ayati, K. Steiros, M. A. Miller, S. Duvvuri, and M. Hultmark, "**A
   double-multiple streamtube model for vertical axis wind turbines of
   arbitrary rotor loading**," Wind Energ. Sci., vol. 4, no. 4, pp.
   653–662, Dec. 2019, doi: 10.5194/wes-4-653-2019.

2. K. Steiros and M. Hultmark, "**Drag on flat plates of arbitrary
   porosity**," J. Fluid Mech., vol. 853, p. R3, Oct. 2018, doi:
   10.1017/jfm.2018.621.
"""
struct SteirosHultmark <: AbstractMomentumTheory end

wake_velocity_ratio(::SteirosHultmark, a) = (1 - a) / (1 + a)

drag_coefficient(::SteirosHultmark, a) = begin
    a <= 0.7 ?
        4 / 3 * a * (3 - a) / (1 + a) :
        0.899 - (0.0203 - (a - 0.143)^2) / 0.6427
end
