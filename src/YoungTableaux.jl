module YoungTableaux

export YoungTableau, schensted_insert!, rs_norecord, rs_pair, rsk_pair, Partition,
    row, rows, nrows, ncols, shape
export ≺, ≻, ≺′, ≻′

using MappedArrays

"""
    abstract type AbstractDiagram{T} end

Supertype for any kind of object that has the shape of a Young diagram, filled or not
"""
abstract type AbstractDiagram{T} end
"""
    abstract type AbstractYoungTableau{T} <: AbstractDiagram{T} end

Supertype for any fully filled Young diagram
"""
abstract type AbstractYoungTableau{T} <: AbstractDiagram{T} end

"""
    YoungTableau{T}(rows::Vector{Vector{T}})

Vector of rows describing a (filled) Young tableau
"""
struct YoungTableau{T} <: AbstractYoungTableau{T}
    rows::Vector{Vector{T}}
end
YoungTableau{T}() where {T} = YoungTableau(Vector{T}[])

"""
    rows(::AbstractDiagram)

Returns an array containing all rows of a diagram. Must be implemented by any subtype of
`AbstractDiagram`. Unfilled diagrams should return a `Bool`
"""
function rows end

rows((; rows)::YoungTableau) = rows
function row(yt, i::Int)
    r = rows(yt)
    return isassigned(r, i) ? r[i] : ()
end
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
Base.getindex(x::AbstractArray, y::AbstractDiagram) = getindex.(Ref(x), y)
Base.getindex(x::AbstractDiagram, y::AbstractDiagram) = getindex.(Ref(x), y)
Base.getindex(x::AbstractDiagram, y::AbstractArray) = getindex.(Ref(x), y)

Base.IteratorSize(::AbstractDiagram) = Base.SizeUnknown()
Base.eltype(::AbstractDiagram{T}) where {T} = T
Base.iterate(yt::AbstractDiagram, st...) = iterate(Iterators.flatten(rows(yt)), st...)

function Base.:(==)(d1::AbstractDiagram, d2::AbstractDiagram)
    r1, r2 = rows(d1), rows(d2)
    length(r1) == length(r2) || return false
    for (row1, row2) in zip(r1, r2)
        row1 == row2 || return false
    end
    return true
end
function Base.hash(d::AbstractDiagram, seed::UInt)
    h = hash(0x038ae58442cb843d % UInt, seed)
    for r in rows(d)
        h = hash(r, h)
    end
    return h
end

Base.copy((; rows)::YoungTableau) = YoungTableau(copy.(rows))

"""
    abstract type AbstractShape <: AbstractDiagram{Bool} end

A diagram only describing a certain shape, potentially with holes such as a skew partition
"""
abstract type AbstractShape <: AbstractDiagram{Bool} end
"""
    abstract type AbstractPartition <: AbstractShape end

Description of only the outer shape of a diagram
"""
abstract type AbstractPartition <: AbstractShape end

"""
    Partition(parts::Vector{Int})

A partition with row lengths given by `parts`
"""
struct Partition <: AbstractPartition
    parts::Vector{Int}
end
Partition(p::Partition) = p
Partition(yt::AbstractYoungTableau) = Partition(map(length, rows(yt)))

ncols((; parts)::Partition) = isempty(parts) ? 0 : first(parts)
ncols((; parts)::Partition, i::Int) = isassigned(parts, i) ? parts[i] : 0
nrows((; parts)::Partition) = length(parts)
rows((; parts)::Partition) = mappedarray(p -> mappedarray(Returns(true), 1:p), parts)

struct PartitionOf{D <: AbstractDiagram} <: AbstractPartition
    diagram::D
end

ncols((; diagram)::PartitionOf) = ncols(diagram)
ncols((; diagram)::PartitionOf, i::Int) = ncols(diagram, i)
nrows((; diagram)::PartitionOf) = nrows(diagram)
rows((; diagram)::PartitionOf) = mappedarray(r -> mappedarray(Returns(true), r), rows(diagram))

"""
    shape(d::AbstractDiagram)

Returns an `AbstractPartition` describing the shape of a diagram
"""
shape(d::AbstractDiagram) = PartitionOf(d)
shape(p::AbstractPartition) = p

struct EachIndexOf{D <: AbstractDiagram} <: AbstractYoungTableau{CartesianIndex{2}}
    diagram::D
end

function rows((; diagram)::EachIndexOf)
    rs = rows(diagram)
    return mappedarray(LinearIndices(rs)) do i
        mappedarray(j -> CartesianIndex(i, j), LinearIndices(rs[i]))
    end
end
Base.eachindex(d::AbstractDiagram) = EachIndexOf(d)

include("show.jl")
include("broadcast.jl")
include("rsk.jl")
include("interlacings.jl")

end
