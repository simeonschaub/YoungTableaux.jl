module MakieExtension

using Makie
using GeometryBasics: Rect2f, Point2f

using YoungTableaux
using YoungTableaux: AbstractShape, AbstractYoungTableau

Makie.plottype(::AbstractShape) = Poly

function Makie.convert_arguments(::Type{<:Poly}, s::AbstractShape)
    rects = Rect2f[]
    for I in eachindex(s)
        s[I] || continue
        i, j = Tuple(I)
        push!(rects, Rect2f(j - 1, i - 1, 1, 1))
    end
    return (rects,)
end

@recipe(YoungTableauPlot, yt) do scene
    Attributes(
        text_attributes = (;),
        color = :transparent,
        strokewidth = 1,
    )
end

Makie.plottype(::AbstractYoungTableau) = YoungTableauPlot

function Makie.plot!(p::YoungTableauPlot)
    yt = p[:yt]
    poly!(p, Makie.shared_attributes(p, Poly), map(shape, yt))
    text = map(yt) do yt
        map(string, yt)
    end
    positions = map(yt) do yt
        map(eachindex(yt)) do I
            Point2f(I[2] - 0.5, I[1] - 0.5)
        end
    end
    text_attributes = merge(Attributes(; align = (:center, :center)), p[:text_attributes])
    text!(p, text_attributes, positions; text)
    return p
end

end
