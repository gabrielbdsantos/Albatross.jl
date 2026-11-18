"""
    @define_cat_methods T

Define `Base.cat`, `Base.vcat`, and `Base.hcat` methods for type `T`.
"""
macro define_cat_methods(T)
    Tesc = esc(T)

    return quote
        Base.cat(a::$Tesc, b::$Tesc; kwargs...) = $Tesc(;
            (
                f => Base.cat(getfield(a, f), getfield(b, f); kwargs...)
                    for f in fieldnames($Tesc)
            )...
        )
        Base.vcat(a::$Tesc, b::$Tesc) = Base.cat(a, b; dims = 1)
        Base.hcat(a::$Tesc, b::$Tesc) = Base.cat(a, b; dims = 2)
    end
end

"""
    estimate_aoa_zero(aoa, Cl)

Estimate the zero-lift angle of attack from a static `Cl(aoa)` polar scan.

Finds the sign change of `Cl` closest to `Cl = 0` and linearly interpolates
between the two bracketing points. `aoa` and `Cl` must be given as vectors of
equal length, ordered by increasing `aoa`. The units of the returned angle
match the units of `aoa`.
"""
function estimate_aoa_zero(aoa, Cl)
    i = findfirst(
        k -> (Cl[k] <= 0 <= Cl[k + 1]) || (Cl[k + 1] <= 0 <= Cl[k]),
        1:(length(Cl) - 1)
    )
    isnothing(i) && throw(
        ArgumentError("could not bracket a zero-lift crossing in the supplied polar scan")
    )

    a1, a2 = aoa[i], aoa[i + 1]
    c1, c2 = Cl[i], Cl[i + 1]
    return a1 + (0 - c1) * (a2 - a1) / (c2 - c1)
end
