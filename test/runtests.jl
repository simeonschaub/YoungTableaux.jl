using YoungTableaux
using Test, TestItems


@testitem "basic functionality" begin
    π = [4, 6, 3, 8, 1, 2, 7, 5]
    P, Q = YoungTableaux.rs_pair(π)
    P′, Q′ = YoungTableau{Int64}([[1, 2, 5], [3, 6, 7], [4, 8]]), YoungTableau{Int64}([[1, 2, 4], [3, 6, 7], [5, 8]])

    @test P == P′
    @test hash(P) == hash(P′)

    @test nrows(P) == 3
    @test ncols(P) == 3
    @test ncols(P, 3) == 2
    @test collect(P) == [1, 2, 5, 3, 6, 7, 4, 8]

    @test shape(P) == Partition([3, 3, 2])
    @test hash(shape(P)) == hash(Partition([3, 3, 2]))

    @test eachindex(P) == eachindex(shape(P′))

    @test occursin("<table", repr("text/html", P))
end
