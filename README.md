# YoungTableaux

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://simeonschaub.github.io/YoungTableaux.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://simeonschaub.github.io/YoungTableaux.jl/dev/)
[![Build Status](https://github.com/simeonschaub/YoungTableaux.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/simeonschaub/YoungTableaux.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/simeonschaub/YoungTableaux.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/simeonschaub/YoungTableaux.jl)

See the demo [here](https://simeonschaub.github.io/YoungTableaux.jl/notebooks/notebooks/demo1.html)

Young Tableaux can be constructed as follows:

```jldoctest
julia> using YoungTableaux

julia> YoungTableau([[1, 3, 4], [2, 5], [6]])
3×3 YoungTableau{Int64}
┌───┬───┬───┐
│ 1 │ 3 │ 4 │
├───┼───┼───┘
│ 2 │ 5 │
├───┼───┘
│ 6 │
└───┘
```

Alternatively they can also be constructed from a permutation:

```jldoctest
julia> π = [4, 6, 3, 8, 1, 2, 7, 5]
8-element Vector{Int64}:
 4
 6
 3
 8
 1
 2
 7
 5

julia> P, Q = rs_pair(π)
(YoungTableau{Int64}([[1, 2, 5], [3, 6, 7], [4, 8]]), YoungTableau{Int64}([[1, 2, 4], [3, 6, 7], [5, 8]]))

julia> P
3×3 YoungTableau{Int64}
┌───┬───┬───┐
│ 1 │ 2 │ 5 │
├───┼───┼───┤
│ 3 │ 6 │ 7 │
├───┼───┼───┘
│ 4 │ 8 │
└───┴───┘

julia> Q
3×3 YoungTableau{Int64}
┌───┬───┬───┐
│ 1 │ 2 │ 4 │
├───┼───┼───┤
│ 3 │ 6 │ 7 │
├───┼───┼───┘
│ 5 │ 8 │
└───┴───┘
```

Broadcasting works just like with arrays!

```jldoctest
julia> P .+ Q
3×3 YoungTableau{Int64}
┌────┬────┬────┐
│  2 │  4 │  9 │
├────┼────┼────┤
│  6 │ 12 │ 14 │
├────┼────┼────┘
│  9 │ 16 │
└────┴────┘
```

Partitions are just like Young Tableaux, but without entries. When iterating a
partition only `true` is returned. Indices of the square can be computed using
`eachindex`.

```jldoctest
julia> Partition([3, 3, 2])
3×3 Partition
┌───┬───┬───┐
│   │   │   │
├───┼───┼───┤
│   │   │   │
├───┼───┼───┘
│   │   │
└───┴───┘

julia> eachindex(Partition([3, 3, 2]))
3×3 YoungTableaux.EachIndexOf{Partition}
┌─────┬─────┬─────┐
│ 1,1 │ 1,2 │ 1,3 │
├─────┼─────┼─────┤
│ 2,1 │ 2,2 │ 2,3 │
├─────┼─────┼─────┘
│ 3,1 │ 3,2 │
└─────┴─────┘
```

The partition corresponding to a Young Tableaux can be requested using
`shape`, which will return a lazy wrapper:

```jldoctest
julia> shape(P)
3×3 PartitionOf{YoungTableau{Int64}}
┌───┬───┬───┐
│   │   │   │
├───┼───┼───┤
│   │   │   │
├───┼───┼───┘
│   │   │
└───┴───┘
```

Addition and substraction work as defined in Macdonald: "Symmetric Functions
and Hall Polynomials"

```jldoctest
julia> shape(P) - Partition([2, 1])
3×3 SkewPartition
┌───┬───┬───┐
│   │   │ * │
├───┼───┼───┤
│   │ * │ * │
├───┼───┼───┘
│ * │ * │
└───┴───┘

julia> shape(P) + Partition([2, 1])
3×5 Partition
┌───┬───┬───┬───┬───┐
│   │   │   │   │   │
├───┼───┼───┼───┼───┘
│   │   │   │   │
├───┼───┼───┴───┘
│   │   │
└───┴───┘
```
