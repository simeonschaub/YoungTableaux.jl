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

rs_norecord(σ) = foldl(first∘schensted_insert!, σ; init=YoungTableau{eltype(σ)}())
function rs_pair(x)
    T = eltype(x)
	P, Q = YoungTableau{T}(), YoungTableau{T}()
	for (n, k) in enumerate(x)
		P, i = schensted_insert!(P, k)
		Q, _i = schensted_insert!(Q, n, i)
		@assert i == _i
	end
	return P, Q
end
