module YoungTableaux

# credits to @tkf on discourse: https://discourse.julialang.org/t/fun-one-liners/28352/57
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    open(path) do io
        lines = eachline(io)
        # skip badges in lines 2-6
        s = first(lines) * '\n' * join(Iterators.drop(lines, 5), '\n')
        replace(s, "```julia" => "```jldoctest README")
    end
end
YoungTableaux

export YoungTableau, schensted_insert!, rs_norecord, rs_pair, rsk_pair, Partition,
    SkewPartition, row, rows, nrows, ncols, shape
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

struct RowMajor{monotonic} end
RowMajor() = RowMajor{false}()
struct ColumnMajor{monotonic} end
ColumnMajor() = ColumnMajor{false}()
const AccessTrait = Union{RowMajor, ColumnMajor}
(::Type{AccessTrait})(::AbstractDiagram) = RowMajor()

Base.inv(::RowMajor{monotonic}) where {monotonic} = ColumnMajor{monotonic}()
Base.inv(::ColumnMajor{monotonic}) where {monotonic} = RowMajor{monotonic}()
monotonic(::RowMajor) = RowMajor{true}()
monotonic(::ColumnMajor) = ColumnMajor{true}()

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

rows(d::AbstractDiagram) = rows(AccessTrait(d), d)
cols(d::AbstractDiagram) = cols(AccessTrait(d), d)

rows(::RowMajor, (; rows)::YoungTableau) = rows
function row(yt, i::Int)
    r = rows(yt)
    return isassigned(r, i) ? r[i] : ()
end

function _divide_range(range::UnitRange{Int})
    a, b = first(range), last(range)
    m = a + (b - a) ÷ 2
    return a:m, m+1:b
end

function _bisect_max(f, range::UnitRange{Int}; cutoff::Val{c}=Val(16)) where {c}
    length(range) <= c && return findlast(f, range)
    a, b = _divide_range(range)
    res_b = _bisect_max(f, b; cutoff)
    return res_b === nothing ? _bisect_max(f, a; cutoff) : res_b
end

nrows(yt) = nrows(AccessTrait(yt), yt)
nrows(::RowMajor, yt) = length(rows(yt))
nrows(yt, i::Int) = nrows(AccessTrait(yt), yt, i)
function nrows(::RowMajor, yt, i::Int)
    rows = YoungTableaux.rows(yt)
    return something(_bisect_max(j -> isassigned(rows[j], i), 1:length(rows)), 0)
end

ncols(yt) = ncols(AccessTrait(yt), yt)
ncols(::RowMajor, yt) = isempty(rows(yt)) ? 0 : length(first(rows(yt)))
ncols(yt, i::Int) = ncols(AccessTrait(yt), yt, i)
ncols(::RowMajor, yt, i::Int) = length(row(yt, i))

Base.size(yt::AbstractDiagram) = (nrows(yt), ncols(yt))

Base.getindex(yt::AbstractDiagram, i::Int, j::Int) = getindex(AccessTrait(yt), yt, i, j)
function getindex(::RowMajor, yt::AbstractDiagram{T}, i::Int, j::Int) where {T}
    r = rows(yt)
    isassigned(r, i) || throw(BoundsError(yt, (i, j)))
    isassigned(first(r), j) || throw(BoundsError(yt, (i, j)))
    row = r[i]
    return get(row, j, zero(T))
end
Base.getindex(yt::AbstractDiagram, I::CartesianIndex{2}) = yt[Tuple(I)...]
Base.getindex(x::AbstractArray, y::AbstractDiagram) = Base.getindex.(Ref(x), y)
Base.getindex(x::AbstractDiagram, y::AbstractDiagram) = Base.getindex.(Ref(x), y)
Base.getindex(x::AbstractDiagram, y::AbstractArray) = Base.getindex.(Ref(x), y)

Base.IteratorSize(::AbstractDiagram) = Base.SizeUnknown()
Base.eltype(::AbstractDiagram{T}) where {T} = T
Base.iterate(yt::AbstractDiagram, st...) = iterate(AccessTrait(yt), yt, st...)
iterate(::AccessTrait, yt::AbstractDiagram, st...) = Base.iterate(Iterators.flatten(rows(yt)), st...)

rows_monotonic(d) = rows(monotonic(AccessTrait(d)), d)
function Base.:(==)(d1::AbstractDiagram, d2::AbstractDiagram)
    r1, r2 = rows_monotonic(d1), rows_monotonic(d2)
    length(r1) == length(r2) || return false
    for (row1, row2) in zip(r1, r2)
        row1 == row2 || return false
    end
    return true
end
function Base.hash(d::AbstractDiagram, seed::UInt)
    h = hash(0x038ae58442cb843d % UInt, seed)
    for r in rows_monotonic(d)
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
rows(::RowMajor, (; parts)::Partition) = mappedarray(p -> mappedarray(Returns(true), 1:p), parts)

struct PartitionOf{D <: AbstractDiagram} <: AbstractPartition
    diagram::D
end

(::Type{AccessTrait})((; diagram)::PartitionOf) = AccessTrait(diagram)
ncols((; diagram)::PartitionOf) = ncols(diagram)
ncols((; diagram)::PartitionOf, i::Int) = ncols(diagram, i)
nrows((; diagram)::PartitionOf) = nrows(diagram)
rows(::RowMajor, (; diagram)::PartitionOf) = mappedarray(r -> mappedarray(Returns(true), r), rows(diagram))
cols(::ColumnMajor, (; diagram)::PartitionOf) = mappedarray(r -> mappedarray(Returns(true), r), cols(diagram))

"""
    shape(d::AbstractDiagram)

Returns an `AbstractPartition` describing the shape of a diagram
"""
shape(d::AbstractDiagram) = PartitionOf(d)
shape(p::AbstractPartition) = p

struct EachIndexOf{D <: AbstractDiagram} <: AbstractYoungTableau{CartesianIndex{2}}
    diagram::D
end

(::Type{AccessTrait})((; diagram)::EachIndexOf) = AccessTrait(diagram)
function rows(::RowMajor, (; diagram)::EachIndexOf)
    rs = rows(diagram)
    return mappedarray(LinearIndices(rs)) do i
        mappedarray(j -> CartesianIndex(i, j), LinearIndices(rs[i]))
    end
end
function cols(::ColumnMajor, (; diagram)::EachIndexOf)
    rs = cols(diagram)
    return mappedarray(LinearIndices(rs)) do j
        mappedarray(i -> CartesianIndex(i, j), LinearIndices(rs[i]))
    end
end
Base.eachindex(d::AbstractDiagram) = EachIndexOf(d)

struct SkewPartition <: AbstractShape
    diffs::Vector{UnitRange{Int}}
end

function rows(::RowMajor, (; diffs)::SkewPartition)
    return mappedarray(diffs) do r
        mappedarray(>=(first(r)), 1:last(r))
    end
end
function Base.:(-)(p1::AbstractPartition, p2::AbstractPartition)
    n = max(nrows(p1), nrows(p2))
    diffs = map(1:n) do i
        ncols(p2, i) + 1 : ncols(p1, i)
    end
    return SkewPartition(diffs)
end

function Base.:(+)(p1::AbstractPartition, p2::AbstractPartition)
    n = max(nrows(p1), nrows(p2))
    parts = map(1:n) do i
        ncols(p1, i) + ncols(p2, i)
    end
    return Partition(parts)
end

struct ConjugateDiagram{T, D <: AbstractDiagram{T}} <: AbstractDiagram{T}
    diagram::D
end

(::Type{AccessTrait})((; diagram)::ConjugateDiagram) = inv(AccessTrait(diagram))
cols(::ColumnMajor, (; diagram)::ConjugateDiagram) = rows(diagram)
rows(::RowMajor, (; diagram)::ConjugateDiagram) = cols(diagram)

function rows(::ColumnMajor, (; diagram)::ConjugateDiagram)
    return mappedarray(1:ncols(diagram)) do j
        return mappedarray(i -> diagram[i, j], 1:nrows(diagram, j))
    end
end
# mutating and not thread safe, but should be O(n) instead of O(n log(n))
# only works if rows are accessed monotonically
function rows(::ColumnMajor{true}, (; diagram)::ConjugateDiagram)
    rows = YoungTableaux.rows(diagram)
    last_row = Ref(nrows(diagram))
    return mappedarray(1:ncols(diagram)) do j
        last_row[] = findlast(1:last_row[]) do i
            isassigned(rows[i], j)
        end
        return mappedarray(i -> diagram[i, j], 1:last_row[])
    end
end

ncols(t::AccessTrait, (; diagram)::ConjugateDiagram) = nrows(inv(t), diagram)
ncols(t::AccessTrait, (; diagram)::ConjugateDiagram, i::Int) = nrows(inv(t), diagram, i)
nrows(t::AccessTrait, (; diagram)::ConjugateDiagram) = ncols(inv(t), diagram)
nrows(t::AccessTrait, (; diagram)::ConjugateDiagram, i::Int) = ncols(inv(t), diagram, i)

Base.adjoint(d::AbstractDiagram) = ConjugateDiagram(d)
Base.adjoint((; diagram)::ConjugateDiagram) = diagram

YoungTableau(c::ConjugateDiagram) = YoungTableau(Vector.(rows(c)))
Base.conj(d::AbstractDiagram) = YoungTableau(d')

function getindex(::ColumnMajor, yt::AbstractDiagram{T}, i::Int, j::Int) where {T}
    r = cols(yt)
    isassigned(r, j) || throw(BoundsError(yt, (i, j)))
    isassigned(first(r), i) || throw(BoundsError(yt, (i, j)))
    row = r[j]
    return get(row, i, zero(T))
end

include("show.jl")
include("broadcast.jl")
include("rsk.jl")
include("interlacings.jl")

end
