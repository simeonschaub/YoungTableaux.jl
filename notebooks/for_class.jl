### A Pluto.jl notebook ###
# v0.19.29

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 4db253c8-6c3c-11ee-2921-45f9793427aa
begin
	using Revise
	let p=dirname(pwd())
		p in LOAD_PATH || @show pushfirst!(LOAD_PATH, p)
	end
	using YoungTableaux: YoungTableaux, YoungTableau, rows
end

# ╔═╡ 50401b76-6c95-48c9-8ce6-a96281e911ff
using HypertextLiteral, AbstractPlutoDingetjes.Bonds

# ╔═╡ ef2fac57-ff72-400a-bc18-2e4eadafac11
s = uppercase("juliarules")

# ╔═╡ 2626db42-96cb-49c6-ab26-8053fa7fab66
x = [1,3,3,2,2,1,2]

# ╔═╡ 877b720b-b96d-4316-b0d2-8cb65aef6304
name = uppercase("richardpstanley")

# ╔═╡ f78d304e-9bc6-41cd-8cd4-62b88215ff19
begin
	log!(::Nothing, _...) = nothing
	log!(x, rows, (i, j), k) = push!(x, (YoungTableau(copy.(rows)), (i, j), k))
	sublog!(::Nothing) = nothing
	sublog!(x) = (y = Any[]; push!(x, y); y)
end

# ╔═╡ 0acd1cda-9a65-4730-a451-6369dfbb92f8
function schensted_insert!(rows, k, i=1; log=nothing)
	if i > length(rows)
		log!(log, rows, (i, 1), k)
		return push!(rows, [k]), i
	end
	row = rows[i]
	for (j, m) in pairs(row)
		k < m || continue
		log!(log, rows, (i, j), k)
		row[j] = k
		return schensted_insert!(rows, m, i+1; log)
	end
	log!(log, rows, (i, lastindex(row)+1), k)
	push!(row, k)
	return rows, i
end

# ╔═╡ 47e58152-f784-40e6-9616-eb7d31fa606c
function rs_pair(j; log=nothing)
    T = eltype(j)
	P, Q = Vector{eltype(j)}[], Vector{Int}[]
	for (n, k) in enumerate(j)
		P, i = schensted_insert!(P, k; log=sublog!(log))
		Q, _i = schensted_insert!(Q, n, i)
		@assert i == _i
	end
	return YoungTableau(P), YoungTableau(Q)
end

# ╔═╡ 74b9394b-c57b-4d47-ac2e-0925cb46fac1
rs_pair(x)

# ╔═╡ 65cbdc74-cec1-48cd-ae6a-a0cd5fca424e
P, Q = rs_pair(name)

# ╔═╡ 4e1a8c4a-b7bd-4e4d-a3ba-5b9493bfe769
('A':'Z')[Q]

# ╔═╡ d29210b7-f3fd-4a66-997a-9f19373290ec
begin
	_STEPS = Any[]
	rs_pair(s; log=_STEPS)
	STEPS = [(idx, x) for (idx, y) in enumerate(_STEPS) for x in y]
end;

# ╔═╡ ed00d350-b394-4db9-ad7a-c0a9db65b6a6
begin
	struct SeekingSlider
		r::StepRange{Int, Int}
		default::Int
	end
	function Base.show(io::IO, ::MIME"text/html", (; r, default)::SeekingSlider)
		print(io, @htl("""
		<span>
		<input $((id="f", type="button", value="<<"))/>
		<input $((id="m", type="button", value="<"))/>
		<input $((id="s", type="range", min=r.start, max=r.stop, step=r.step)) style="vertical-align: middle"/>
		<input $((id="p", type="button", value=">"))/>
		<input $((id="l", type="button", value=">>"))/>
		<span id="t" style="margin-left: 1em">$default</span>

		<script>
		const span = currentScript.parentElement
		const slider = span.querySelector("#s")

		function get() {
			return slider.value
		}
		function set(val){
		    val = Math.min(Math.max(val, $(r.start)), $(r.stop));
			slider.value = val
			span.querySelector("#t").textContent = val
			span.value = val
			span.dispatchEvent(new CustomEvent("input"))
		}

		span.querySelector("#f").onclick = () => set($(r.start))
		span.querySelector("#l").onclick = () => set($(r.stop))
		span.querySelector("#m").onclick = () => set(+get() - $(r.step))
		span.querySelector("#p").onclick = () => set(+get() + $(r.step))
		slider.oninput = () => set(get())
		set($default)
		</script>
		</span>
		"""))
	end
	Base.get((; default)::SeekingSlider) = default
	Bonds.initial_value((; default)::SeekingSlider) = default
	Bonds.possible_values((; r)::SeekingSlider) = r
end

# ╔═╡ b4fcb4ce-5474-49e5-81c6-0cf6a2024643
@bind i SeekingSlider(eachindex(STEPS), 1)

# ╔═╡ e3c074b4-7d4e-4a02-8d14-ffdc54439ecb
let (idx, (yt, to_replace, x)) = STEPS[i]
	@htl """
	$(YoungTableaux.visualize_insert(yt, x, to_replace[1]; to_replace, delete=true))
	<br>
	$(YoungTableau([collect(' '^idx * s[idx+1:end])]))
	"""
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractPlutoDingetjes = "6e696c72-6542-2067-7265-42206c756150"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Revise = "295af30f-e4ad-537b-8983-00126c2a3abe"

[compat]
AbstractPlutoDingetjes = "~1.2.0"
HypertextLiteral = "~0.9.4"
Revise = "~3.5.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "323ccf76ee7a069c5bb2c179cca5c435b16a867f"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "c0216e792f518b39b22212127d4a84dc31e4e386"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.5"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0592b1810613d1c95eeebcd22dc11fba186c2a57"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.26"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "60168780555f3e663c536500aa790b6368adc02a"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.3.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "609c26951d80551620241c3d7090c71a73da75ab"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.6"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═ef2fac57-ff72-400a-bc18-2e4eadafac11
# ╠═b4fcb4ce-5474-49e5-81c6-0cf6a2024643
# ╠═e3c074b4-7d4e-4a02-8d14-ffdc54439ecb
# ╠═0acd1cda-9a65-4730-a451-6369dfbb92f8
# ╠═47e58152-f784-40e6-9616-eb7d31fa606c
# ╠═2626db42-96cb-49c6-ab26-8053fa7fab66
# ╠═74b9394b-c57b-4d47-ac2e-0925cb46fac1
# ╠═877b720b-b96d-4316-b0d2-8cb65aef6304
# ╠═65cbdc74-cec1-48cd-ae6a-a0cd5fca424e
# ╠═4e1a8c4a-b7bd-4e4d-a3ba-5b9493bfe769
# ╠═d29210b7-f3fd-4a66-997a-9f19373290ec
# ╠═f78d304e-9bc6-41cd-8cd4-62b88215ff19
# ╠═4db253c8-6c3c-11ee-2921-45f9793427aa
# ╠═50401b76-6c95-48c9-8ce6-a96281e911ff
# ╠═ed00d350-b394-4db9-ad7a-c0a9db65b6a6
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
