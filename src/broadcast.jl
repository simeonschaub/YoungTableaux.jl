using Base.Broadcast: BroadcastStyle, Broadcasted, DefaultArrayStyle, DefaultMatrixStyle
struct DiagramStyle <: BroadcastStyle end

Broadcast.BroadcastStyle(::Type{<:AbstractDiagram}) = DiagramStyle()
Broadcast.BroadcastStyle(::DiagramStyle, ::Broadcast.DefaultArrayStyle{0}) = DiagramStyle()
Broadcast.BroadcastStyle(::DiagramStyle, ::Broadcast.DefaultMatrixStyle) = DefaultMatrixStyle()

Base.broadcastable(yt::AbstractDiagram) = yt

function _row((; f, args, axes)::Broadcasted{DiagramStyle}, i)
    args′ = map(args) do arg
        arg isa AbstractDiagram ? row(arg, i) : arg
    end
    return Broadcasted(f, args′)
end
row(bc::Broadcasted{DiagramStyle}, i::Int) = _row(Broadcast.flatten(bc), i)
function rows(bc::Broadcasted{DiagramStyle})
    bc = Broadcast.flatten(bc)
    return (row(bc, i) for i in axes(bc)[1])
end
function Base.similar(bc::Broadcasted{DiagramStyle}, ::Type{T}, dims::NTuple{2,Base.OneTo}) where {T}
    return YoungTableau{T}([Vector{T}(undef, size(r)...) for r in rows(bc)])
end
function Base.copyto!(yt::AbstractDiagram, bc::Broadcasted{DiagramStyle})
    for (dest, src) in zip(rows(yt), rows(bc))
        copyto!(dest, src)
    end
    return yt
end
function Base.copyto!(yt::AbstractDiagram, bc::Broadcasted{Broadcast.DefaultArrayStyle{0}})
    for dest in rows(yt)
        copyto!(dest, bc)
    end
    return yt
end

