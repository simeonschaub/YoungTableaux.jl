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
Base.size(yt::AbstractDiagram) = (nrows(yt), ncols(yt))

function Base.getindex(yt::AbstractDiagram{T}, i::Int, j::Int) where {T}
    r = rows(yt)
    isassigned(r, i) || throw(BoundsError(yt, (i, j)))
    isassigned(first(r), j) || throw(BoundsError(yt, (i, j)))
    row = r[i]
    return get(row, j, zero(T))
end
Base.getindex(yt::AbstractDiagram, I::CartesianIndex{2}) = yt[Tuple(I)...]
Base.getindex(x::AbstractArray, yt::AbstractDiagram) = getindex.(Ref(x), yt)

Base.IteratorSize(::AbstractDiagram) = Base.SizeUnknown()
Base.eltype(::AbstractDiagram{T}) where {T} = T
Base.iterate(yt::AbstractDiagram, st...) = iterate(Iterators.flatten(rows(yt)), st...)

function Base.:(==)(d1::AbstractDiagram, d2::AbstractDiagram)
    r1, r2 = rows(d1), rows(d2)
    length(r1) == length(r2) || return false
    for (row1, row2) in zip(r1, r2)
        length(row1) == length(row2) || return false
        all(Base.splat(==), zip(row1, row2)) || return false
    end
    return true
end
function Base.hash(d::AbstractDiagram, seed::UInt)
    h = hash(0x038ae58442cb843d % UInt, seed)
    for r in rows(d)
        h = hash(h, length(r) ⊻ (0x4f55546eb633569d % UInt))
        h = foldr(hash, r; init=h)
    end
    return h
end

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
    return (let r = rs[i]
        (CartesianIndex(i, j) for j in LinearIndices(r))
    end for i in LinearIndices(rs))
end
Base.eachindex(d::AbstractDiagram) = EachIndexOf(d)

include("show.jl")
include("broadcast.jl")
include("rsk.jl")
include("interlacings.jl")

end
