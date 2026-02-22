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
