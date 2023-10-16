using Base.Broadcast: BroadcastStyle, Broadcasted, DefaultArrayStyle, DefaultMatrixStyle
struct YoungTableauStyle <: BroadcastStyle end

Broadcast.BroadcastStyle(::Type{<:YoungTableau}) = YoungTableauStyle()
Broadcast.BroadcastStyle(::YoungTableauStyle, ::Broadcast.DefaultArrayStyle{0}) = YoungTableauStyle()
Broadcast.BroadcastStyle(::YoungTableauStyle, ::Broadcast.DefaultMatrixStyle) = DefaultMatrixStyle()

Base.broadcastable(yt::YoungTableau) = yt

function _row((; f, args, axes)::Broadcasted{YoungTableauStyle}, i)
    args′ = map(args) do arg
        arg isa AbstractYoungTableau ? row(arg, i) : arg
    end
    return Broadcasted(f, args′)
end
row(bc::Broadcasted{YoungTableauStyle}, i::Int) = _row(Broadcast.flatten(bc), i)
function rows(bc::Broadcasted{YoungTableauStyle})
    bc = Broadcast.flatten(bc)
    return (row(bc, i) for i in axes(bc)[1])
end
function Base.similar(bc::Broadcasted{YoungTableauStyle}, ::Type{T}, dims::NTuple{2,Base.OneTo}) where {T}
    return YoungTableau{T}([Vector{T}(undef, size(r)...) for r in rows(bc)])
end
function Base.copyto!(yt::AbstractYoungTableau, bc::Broadcasted{YoungTableauStyle})
    for (dest, src) in zip(rows(yt), rows(bc))
        copyto!(dest, src)
    end
    return yt
end
function Base.copyto!(yt::AbstractYoungTableau, bc::Broadcasted{Broadcast.DefaultArrayStyle{0}})
    for dest in rows(yt)
        copyto!(dest, bc)
    end
    return yt
end

