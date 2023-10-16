function _rs_insert!(rows, k, i=1)
	i > length(rows) && return push!(rows, [k]), i
	row = rows[i]
	for (j, m) in pairs(row)
		k < m || continue
		row[j] = k
		return _rs_insert!(rows, m, i+1)
	end
	push!(row, k)
	return rows, i
end

function rs_insert!(yt::YT, k, i=1) where {YT<:AbstractYoungTableau}
    r, i = _rs_insert!(rows(yt), k, i)
    return YT(r), i
end

construct_youngtableau(σ) = foldl(first∘rs_insert!, σ; init=YoungTableau{eltype(x)}())
function construct_pq(x)
    T = eltype(x)
	P, Q = YoungTableau{T}(), YoungTableau{T}()
	for (n, k) in enumerate(x)
		P, i = rs_insert!(P, k)
		Q, _i = rs_insert!(Q, n, i)
		@assert i == _i
	end
	return P, Q
end
