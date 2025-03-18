using YoungTableaux
using Test, TestItems, TestItemRunner

@run_package_tests verbose=true

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

    @test occursin("┼", repr("text/plain", P))
    @test occursin("<table", repr("text/html", P))
end


@testitem "broadcasting" begin
    π = [4, 6, 3, 8, 1, 2, 7, 5]
    P, Q = YoungTableaux.rs_pair(π)
    P′, Q′ = YoungTableau{Int64}([[1, 2, 5], [3, 6, 7], [4, 8]]), YoungTableau{Int64}([[1, 2, 4], [3, 6, 7], [5, 8]])

    @test P .+ 1 == YoungTableau{Int64}([[2, 3, 6], [4, 7, 8], [5, 9]])
    @test 1 .* P .+ 0 == P′

    P_mat = zeros(3, 3) .+ P
    @test P_mat == [1 2 5; 3 6 7; 4 8 0]

    P′′ = copy(P)
    P′′ .= 0
    @test all(iszero, P′′)
    P′′ .= P
    @test P′′ == P′
    P′′ .+= P
    @test P′′ == 2 .* P′

    @test P' .+ P == P .+ P'
end

@testitem "adjoint" begin
    using Random

    P, Q = rs_pair(randperm(100000))
    @test issorted(length.(rows(P')), rev=true)
    @test length(reduce(vcat, rows(P'))) == 100000

    @test rows(YoungTableaux.ColumnMajor{true}(), P') == rows(P')
end

@testitem "RSK" begin
    π = [4, 6, 3, 8, 1, 2, 7, 5]
    @test rs_pair(π) == rsk_pair(eachindex(π), π)

    P, Q = rsk_pair("112233", "121324")
    P′, Q′ = YoungTableau{Char}([['1', '1', '2', '4'], ['2', '3']]), YoungTableau{Char}([['1', '1', '2', '3'], ['2', '3']])
end

@testitem "doctests" begin
    using Documenter

    DocMeta.setdocmeta!(YoungTableaux, :DocTestSetup, :(using YoungTableaux); recursive=true)
    doctest(YoungTableaux)
end
