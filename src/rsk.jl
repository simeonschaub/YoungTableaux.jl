function _schensted_insert!(rows, k, i=1)
	i > length(rows) && return push!(rows, [k]), i
	row = rows[i]
	for (j, m) in pairs(row)
		k < m || continue
		row[j] = k
		return _schensted_insert!(rows, m, i+1)
	end
	push!(row, k)
	return rows, i
end

function schensted_insert!(yt::YT, k, i=1) where {YT<:AbstractYoungTableau}
    r, i = _schensted_insert!(rows(yt), k, i)
    return YT(r), i
end

rs_norecord(j) = foldl(first∘schensted_insert!, j; init=YoungTableau{eltype(j)}())
function rs_pair(j)
    T = eltype(j)
	P, Q = YoungTableau{T}(), YoungTableau{T}()
	for (n, k) in enumerate(j)
		P, i = schensted_insert!(P, k)
		Q, _i = schensted_insert!(Q, n, i)
		@assert i == _i
	end
	return P, Q
end

function rsk_pair(i, j)
	P, Q = rs_pair(j)
	broadcast!(k -> i[k], Q, Q)
	return P, Q
end

function twoline_array(A::AbstractMatrix{<:Integer})
	i, j = Int[], Int[]
	for I in Iterators.flatten(eachrow(CartesianIndices(A)))
		for _ in 1:A[I]
			push!(i, I[1])
			push!(j, I[2])
		end
	end
	return i, j
end
rsk_pair(A::AbstractMatrix{<:Integer}) = rsk_pair(twoline_array(A)...)
