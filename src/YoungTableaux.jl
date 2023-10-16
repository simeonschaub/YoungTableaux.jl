module YoungTableaux

export YoungTableau, rows

abstract type AbstractYoungTableau{T} end

struct YoungTableau <: AbstractYoungTableau{Int}
    rows::Vector{Vector{Int}}
end
YoungTableau() = YoungTableau(Vector{Int}[])

rows((; rows)::YoungTableau) = rows

function Base.size(yt::AbstractYoungTableau)
    r = rows(yt)
    return length(r), isempty(r) ? 0 : length(first(r))
end
function Base.getindex(yt::AbstractYoungTableau{T}, i::Int, j::Int) where {T}
    r = rows(yt)
    isassigned(r, i) || throw(BoundsError(yt, (i, j)))
    isassigned(first(r), j) || throw(BoundsError(yt, (i, j)))
    row = r[i]
    return get(row, j, zero(T))
end
Base.IteratorSize(::AbstractYoungTableau) = Base.SizeUnknown()
Base.eltype(::AbstractYoungTableau{T}) where {T} = T
Base.iterate(yt::AbstractYoungTableau, st...) = iterate(Iterators.flatten(rows(yt)), st...)

end
