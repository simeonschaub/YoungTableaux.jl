module YoungTableaux

export YoungTableau, schensted_insert!, rs_norecord, rs_pair, rsk_pair, Partition,
    row, rows, nrows, ncols, shape
export ≺, ≻, ≺′, ≻′

abstract type AbstractDiagram{T} end
abstract type AbstractYoungTableau{T} <: AbstractDiagram{T} end

struct YoungTableau{T} <: AbstractYoungTableau{T}
    rows::Vector{Vector{T}}
end
YoungTableau{T}() where {T} = YoungTableau(Vector{T}[])
YoungTableau() = YoungTableau{Int}()

rows((; rows)::YoungTableau) = rows
row(yt, i::Int) = rows(yt)[i]
nrows(yt) = length(rows(yt))
ncols(yt) = isempty(rows(yt)) ? 0 : length(first(rows(yt)))
ncols(yt, i::Int) = length(row(yt, i))
Base.size(yt::AbstractYoungTableau) = (nrows(yt), ncols(yt))

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

abstract type AbstractShape <: AbstractDiagram{Bool} end
abstract type AbstractPartition <: AbstractShape end

struct Partition <: AbstractPartition
    parts::Vector{Int}
end
Partition(p::Partition) = p
Partition(yt::AbstractYoungTableau) = Partition(map(length, rows(yt)))

rows((; parts)::Partition) = ((true for _ in 1:p) for p in parts)

struct PartitionOf{D <: AbstractDiagram} <: AbstractPartition
    diagram::D
end

rows((; diagram)::PartitionOf) = ((true for _ in r) for r in rows(diagram))
shape(p::AbstractPartition) = p
shape(d::AbstractDiagram) = PartitionOf(d)

struct EachIndexOf{D <: AbstractDiagram} <: AbstractYoungTableau{CartesianIndex{2}}
    diagram::D
end

function rows((; diagram)::EachIndexOf)
    rs = rows(diagram)
    return ((CartesianIndex(i, j) for j in LinearIndices(r)) for i in zip(LinearIndices(rs), rs))
end
eachindex(d::AbstractDiagram) = d

include("show.jl")
include("broadcast.jl")
include("rsk.jl")
include("interlacings.jl")

end
