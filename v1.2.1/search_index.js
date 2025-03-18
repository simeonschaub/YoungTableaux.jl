var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = YoungTableaux","category":"page"},{"location":"#YoungTableaux","page":"Home","title":"YoungTableaux","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for YoungTableaux.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [YoungTableaux]","category":"page"},{"location":"#YoungTableaux.YoungTableaux","page":"Home","title":"YoungTableaux.YoungTableaux","text":"YoungTableaux\n\nSee the demo here\n\nYoung Tableaux can be constructed as follows:\n\njulia> using YoungTableaux\n\njulia> YoungTableau([[1, 3, 4], [2, 5], [6]])\n3×3 YoungTableau{Int64}\n┌───┬───┬───┐\n│ 1 │ 3 │ 4 │\n├───┼───┼───┘\n│ 2 │ 5 │\n├───┼───┘\n│ 6 │\n└───┘\n\nAlternatively they can also be constructed from a permutation:\n\njulia> π = [4, 6, 3, 8, 1, 2, 7, 5]\n8-element Vector{Int64}:\n 4\n 6\n 3\n 8\n 1\n 2\n 7\n 5\n\njulia> P, Q = rs_pair(π)\n(YoungTableau{Int64}([[1, 2, 5], [3, 6, 7], [4, 8]]), YoungTableau{Int64}([[1, 2, 4], [3, 6, 7], [5, 8]]))\n\njulia> P\n3×3 YoungTableau{Int64}\n┌───┬───┬───┐\n│ 1 │ 2 │ 5 │\n├───┼───┼───┤\n│ 3 │ 6 │ 7 │\n├───┼───┼───┘\n│ 4 │ 8 │\n└───┴───┘\n\njulia> Q\n3×3 YoungTableau{Int64}\n┌───┬───┬───┐\n│ 1 │ 2 │ 4 │\n├───┼───┼───┤\n│ 3 │ 6 │ 7 │\n├───┼───┼───┘\n│ 5 │ 8 │\n└───┴───┘\n\nBroadcasting works just like with arrays!\n\njulia> P .+ Q\n3×3 YoungTableau{Int64}\n┌────┬────┬────┐\n│  2 │  4 │  9 │\n├────┼────┼────┤\n│  6 │ 12 │ 14 │\n├────┼────┼────┘\n│  9 │ 16 │\n└────┴────┘\n\nPartitions are just like Young Tableaux, but without entries. When iterating a partition only true is returned. Indices of the square can be computed using eachindex.\n\njulia> Partition([3, 3, 2])\n3×3 Partition\n┌───┬───┬───┐\n│   │   │   │\n├───┼───┼───┤\n│   │   │   │\n├───┼───┼───┘\n│   │   │\n└───┴───┘\n\njulia> eachindex(Partition([3, 3, 2]))\n3×3 YoungTableaux.EachIndexOf{Partition}\n┌─────┬─────┬─────┐\n│ 1,1 │ 1,2 │ 1,3 │\n├─────┼─────┼─────┤\n│ 2,1 │ 2,2 │ 2,3 │\n├─────┼─────┼─────┘\n│ 3,1 │ 3,2 │\n└─────┴─────┘\n\nThe partition corresponding to a Young Tableaux can be requested using shape, which will return a lazy wrapper:\n\njulia> shape(P)\n3×3 YoungTableaux.PartitionOf{YoungTableau{Int64}}\n┌───┬───┬───┐\n│   │   │   │\n├───┼───┼───┤\n│   │   │   │\n├───┼───┼───┘\n│   │   │\n└───┴───┘\n\nAddition and substraction work as defined in Macdonald: \"Symmetric Functions and Hall Polynomials\"\n\njulia> shape(P) - Partition([2, 1])\n3×3 SkewPartition\n┌───┬───┬───┐\n│   │   │ * │\n├───┼───┼───┤\n│   │ * │ * │\n├───┼───┼───┘\n│ * │ * │\n└───┴───┘\n\njulia> shape(P) + Partition([2, 1])\n3×5 Partition\n┌───┬───┬───┬───┬───┐\n│   │   │   │   │   │\n├───┼───┼───┼───┼───┘\n│   │   │   │   │\n├───┼───┼───┴───┘\n│   │   │\n└───┴───┘\n\nThere is also initial support for conjugating diagrams using the adjoint operator like with regular matrices. It is currently implemented lazily but this may be subject to change.\n\njulia> P'\n3×3 YoungTableaux.ConjugateDiagram{Int64, YoungTableau{Int64}}\n┌───┬───┬───┐\n│ 1 │ 3 │ 4 │\n├───┼───┼───┤\n│ 2 │ 6 │ 8 │\n├───┼───┼───┘\n│ 5 │ 7 │\n└───┴───┘\n\n\n\n\n\n","category":"module"},{"location":"#YoungTableaux.AbstractDiagram","page":"Home","title":"YoungTableaux.AbstractDiagram","text":"abstract type AbstractDiagram{T} end\n\nSupertype for any kind of object that has the shape of a Young diagram, filled or not\n\n\n\n\n\n","category":"type"},{"location":"#YoungTableaux.AbstractPartition","page":"Home","title":"YoungTableaux.AbstractPartition","text":"abstract type AbstractPartition <: AbstractShape end\n\nDescription of only the outer shape of a diagram\n\n\n\n\n\n","category":"type"},{"location":"#YoungTableaux.AbstractShape","page":"Home","title":"YoungTableaux.AbstractShape","text":"abstract type AbstractShape <: AbstractDiagram{Bool} end\n\nA diagram only describing a certain shape, potentially with holes such as a skew partition\n\n\n\n\n\n","category":"type"},{"location":"#YoungTableaux.AbstractYoungTableau","page":"Home","title":"YoungTableaux.AbstractYoungTableau","text":"abstract type AbstractYoungTableau{T} <: AbstractDiagram{T} end\n\nSupertype for any fully filled Young diagram\n\n\n\n\n\n","category":"type"},{"location":"#YoungTableaux.Partition","page":"Home","title":"YoungTableaux.Partition","text":"Partition(parts::Vector{Int})\n\nA partition with row lengths given by parts\n\n\n\n\n\n","category":"type"},{"location":"#YoungTableaux.YoungTableau","page":"Home","title":"YoungTableaux.YoungTableau","text":"YoungTableau{T}(rows::Vector{Vector{T}})\n\nVector of rows describing a (filled) Young tableau\n\n\n\n\n\n","category":"type"},{"location":"#YoungTableaux.rows","page":"Home","title":"YoungTableaux.rows","text":"rows(::AbstractDiagram)\n\nReturns an array containing all rows of a diagram. Must be implemented by any subtype of AbstractDiagram. Unfilled diagrams should return a Bool\n\n\n\n\n\n","category":"function"},{"location":"#YoungTableaux.shape-Tuple{YoungTableaux.AbstractDiagram}","page":"Home","title":"YoungTableaux.shape","text":"shape(d::AbstractDiagram)\n\nReturns an AbstractPartition describing the shape of a diagram\n\n\n\n\n\n","category":"method"}]
}
