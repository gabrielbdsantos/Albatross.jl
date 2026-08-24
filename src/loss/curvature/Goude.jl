@concrete struct Goude <: AbstractCurvatureCorrection end

aoa_correction(::Goude, omega, r, m, c, alphap, Ur) = begin
    z = (m/c-0.5)
    (omega*z*c)/Ur+(omega*c)/(4*Ur)
end
