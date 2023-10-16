module YoungTableaux

export YoungTableau, schensted_insert!, rs_norecord, rs_pair, rsk_pair, Partition
export ≺, ≻, ≺′, ≻′

abstract type AbstractYoungTableau{T} end

struct YoungTableau{T} <: AbstractYoungTableau{T}
    rows::Vector{Vector{T}}
end
YoungTableau{T}() where {T} = YoungTableau(Vector{T}[])
YoungTableau() = YoungTableau{Int}()

rows((; rows)::YoungTableau) = rows
row(yt, i::Int) = rows(yt)[i]
nrows(yt) = length(rows(yt))
rowlength(yt) = isempty(rows(yt)) ? 0 : length(first(rows(yt)))
Base.size(yt::AbstractYoungTableau) = (nrows(yt), rowlength(yt))

function Base.getindex(yt::AbstractYoungTableau{T}, i::Int, j::Int) where {T}
    r = rows(yt)
    isassigned(r, i) || throw(BoundsError(yt, (i, j)))
    isassigned(first(r), j) || throw(BoundsError(yt, (i, j)))
    row = r[i]
    return get(row, j, zero(T))
end
Base.getindex(yt::AbstractYoungTableau, I::CartesianIndex{2}) = yt[Tuple(I)...]
Base.getindex(x::AbstractArray, yt::AbstractYoungTableau) = getindex.(Ref(x), yt)

Base.IteratorSize(::AbstractYoungTableau) = Base.SizeUnknown()
Base.eltype(::AbstractYoungTableau{T}) where {T} = T
Base.iterate(yt::AbstractYoungTableau, st...) = iterate(Iterators.flatten(rows(yt)), st...)

Base.copy((; rows)::YoungTableau) = YoungTableau(copy.(rows))

include("show.jl")
include("partitions.jl")
include("broadcast.jl")
include("rsk.jl")

end
