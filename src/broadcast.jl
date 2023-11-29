using Base.Broadcast: BroadcastStyle, Broadcasted, DefaultArrayStyle, DefaultMatrixStyle
struct DiagramStyle <: BroadcastStyle end

Broadcast.BroadcastStyle(::Type{<:AbstractDiagram}) = DiagramStyle()
Broadcast.BroadcastStyle(::DiagramStyle, ::Broadcast.DefaultArrayStyle{0}) = DiagramStyle()
Broadcast.BroadcastStyle(::DiagramStyle, ::Broadcast.DefaultMatrixStyle) = DefaultMatrixStyle()

Base.broadcastable(yt::AbstractDiagram) = yt

(::Type{AccessTrait})(::Broadcasted{DiagramStyle}) = RowMajor()
function _row((; f, args, axes)::Broadcasted{DiagramStyle}, i)
    args′ = map(args) do arg
        arg isa AbstractDiagram ? row(arg, i) : arg
    end
    return Broadcasted(f, args′)
end
row(::AccessTrait, bc::Broadcasted{DiagramStyle}, i::Int) = _row(Broadcast.flatten(bc), i)
function rows(::AccessTrait, bc::Broadcasted{DiagramStyle})
    bc = Broadcast.flatten(bc)
    return mappedarray(i -> row(AccessTrait(bc), bc, i), axes(bc)[1])
end
function Base.similar(bc::Broadcasted{DiagramStyle}, ::Type{T}, dims::NTuple{2,Base.OneTo}) where {T}
    return YoungTableau{T}([Vector{T}(undef, size(r)...) for r in rows_monotonic(bc)])
end
function Base.copyto!(yt::AbstractDiagram, bc::Broadcasted{DiagramStyle})
    for (dest, src) in zip(rows_monotonic(yt), rows_monotonic(bc))
        copyto!(dest, src)
    end
    return yt
end
function Base.copyto!(yt::AbstractDiagram, bc::Broadcasted{Broadcast.DefaultArrayStyle{0}})
    for dest in rows_monotonic(yt)
        copyto!(dest, bc)
    end
    return yt
end

