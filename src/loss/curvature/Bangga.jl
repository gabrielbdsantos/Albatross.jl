@concrete struct Bangga <: AbstractCurvatureCorrection end

aoa_correction(::Bangga, omega, r, m, c, alphap, Ur) = begin
    z = m/c
    -Base.atan(omega*z*c*cos(alphap), omega*(r+z*c*sin(alphap)))
end

aoa_correction(::Nothing, omega, r, m, c, alphap, Ur) = 0
