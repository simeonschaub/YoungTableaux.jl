struct Partition <: AbstractYoungTableau{Bool}
    parts::Vector{Int}
end
Partition(p::Partition) = p
Partition(yt::AbstractYoungTableau) = Partition(map(length, rows(yt)))

rows((; parts)::Partition) = ((true for _ in 1:p) for p in parts)
_show_entry(::IO, ::Partition, b::Bool) = @assert b

abstract type AbstractInterlacing end
let ops = [:≺, :≻, :≺′, :≻′]
    types = Symbol.(:_, ops)
    for (op, typ) in zip(ops, types)
        @eval struct $typ <: AbstractInterlacing
            global const $op = $typ.instance
        end
        @eval Base.show(io::IO, ::$typ) = print(io, $(string(op)))
        latex_name = replace(string(op), '≺' => "\\prec", '≻' => "\\succ", '′' => "'")
        @eval Base.show(io::IO, ::MIME"text/latex", ::$typ) = print(io, $latex_name)
    end
    @eval const ElementaryInterlacing = Union{$(types...)}
end

function (≻)(λ::Partition, μ::Partition)
    prev = typemax(Int)
    for (λᵢ, μᵢ) in zip(λ.parts, μ.parts)
        prev ≥ λᵢ ≥ μᵢ || return false
        prev = μᵢ
    end
    return true
end
λ::Partition ≺ μ::Partition = μ ≻ λ

function (≻′)(λ::Partition, μ::Partition)
    for (λᵢ, μᵢ) in zip(λ.parts, μ.parts)
        0 ≤ λᵢ - μᵢ ≤ 1 || return false
    end
    return true
end
λ::Partition ≺′ μ::Partition = μ ≻′ λ

struct ComposedInterlacing{T<:Tuple{Vararg{ElementaryInterlacing}}} <: AbstractInterlacing
    ops::T
end
Base.show(io::IO, op::ComposedInterlacing) = (print(io, "("); join(io, op.ops, ") * ("); print(io, ")"))
function Base.show(io::IO, ::MIME"text/latex", (; ops)::ComposedInterlacing)
    print(io, "(")
    for (i, op) in pairs(ops)
        show(io, MIME("text/latex"), op)
        i < length(ops) && print(io, ", ")
    end
    print(io, ")")
end

Base.:*(op1::ComposedInterlacing, op2::ComposedInterlacing) = ComposedInterlacing((op1.ops..., op2.ops...))
Base.convert(::Type{ComposedInterlacing}, op::ElementaryInterlacing) = ComposedInterlacing((op,))
Base.:*(op1::AbstractInterlacing, op2::AbstractInterlacing) = *(convert.(ComposedInterlacing, (op1, op2))...)
Base.:^(op::AbstractInterlacing, n::Int) = n == 0 ? ComposedInterlacing(()) : foldl(*, (op for _ in 1:n))
