using UUIDs

Base.summary(io::IO, d::AbstractDiagram) = Base.array_summary(io, d, axes(d))

_show_entry(io::IO, yt, m) = print(IOContext(io, :typeinfo=>eltype(yt)), m)
_show_entry(::IO, ::AbstractPartition, ::Bool) = nothing
_show_entry(io::IO, ::AbstractShape, b::Bool) = (b && print(io, '*'); nothing)
_show_entry(io::IO, ::EachIndexOf, I::CartesianIndex{2}) = print(io, I[1], ",", I[2])
_string_entry(yt) = m -> sprint(_show_entry, yt, m)

_fill(io::IO, n::Int, c) = foreach(_ -> print(io, c), 1:n)
function mpad(io::IO, s::AbstractString, n::Int)
    w = textwidth(s)
    m = (n - w) ÷ 2
    # if uneven spaces to fill, pad left with one more space
    _fill(io, n-w-m, ' ')
    print(io, s)
    _fill(io, m, ' ')
end

function Base.show(io::IO, ::MIME"text/plain", yt::AbstractDiagram)
    rows = YoungTableaux.rows(yt)
    maxlen = get(io, :html_maxlen, maximum(textwidth∘_string_entry(yt), yt; init=1)) + 2
    itr = Iterators.Stateful(rows)

    summary(io, yt)
    isempty(itr) && return
    println(io)

    row = popfirst!(itr)
    print(io, '┌')
    for i in 1:length(row)
        _fill(io, maxlen, '─')
        print(io, i == length(row) ? '┐' : '┬')
    end

    while true
        println(io)
        print(io, '│')
        for m in row
            mpad(io, _string_entry(yt)(m), maxlen)
            print(io, '│')
        end
        println(io)

        isempty(itr) && break
        row′ = popfirst!(itr)
        l, c, r, nextlen = '├', '┼', '┤', length(row′)

        print(io, l)
        for i in 1:length(row)
            _fill(io, maxlen, '─')
            if i > nextlen
                c, r, nextlen = '┴', '┘', typemax(Int)
                if nextlen == length(row)
                    print(io, i == length(row) ? '┤' : '┼')
                    continue
                end
            end
            print(io, i == length(row) ? r : c)
        end
        row = row′
    end

    print(io, '└')
    for i in 1:length(row)
        _fill(io, maxlen, '─')
        print(io, i == length(row) ? '┘' : '┴')
    end
end

function Base.show(io::IO, ::MIME"text/html", yt::AbstractDiagram)
    rows = YoungTableaux.rows(yt)
    class = get(io, :html_class, string("yt-", uuid1()))
    maxlen = get(io, :html_maxlen, maximum(textwidth∘_string_entry(yt), yt; init=0))
    print(io, """
        <table style='border: none'>
        <style scoped>
            .$class {
                border: 1pt solid;
                width: $(100 / (isempty(rows) ? 100 : ncols(yt)))%;
                padding: 8px;
            }
            .$class div {
                font-size: large;
                aspect-ratio: 1;
                min-width: max($(maxlen)ch, 1em);
                display: flex;
                align-items: center;
                justify-content: center;
            }
        </style>
        """)
    for (i, row) in pairs(rows)
        print(io, "<tr>")
        for (j, m) in pairs(row)
            print(io, "<td id=c$i-$j class=$class><div><span>")
            _show_entry(io, yt, m)
            print(io, "</span></div></td>")
        end
        print(io, "</tr>")
    end
    print(io, "</table>")
end

using HypertextLiteral

function visualize_insert(yt, x, x_row; to_replace=nothing, delete=false)
    class = string("vis-container-", uuid1())
    class_yt = string("yt-", uuid1())
    replace = string("replace-", uuid1())
    pop = string("pop-", uuid1())
    maxlen = max(maximum(textwidth∘_string_entry(yt), yt; init=0), textwidth(_string_entry(yt)(x)))
    template = join((
        "\"$(join(
                  [fill(i > nrows(yt) ? "." : "yt", ncols(yt)); "."; i == x_row ? "x" : ". "],
                  " ",
                 ))\"" for i in 1:nrows(yt)+1),
        "\n",
    )
    translate_x = ncols(yt) - to_replace[2] + 2
    @htl """
    <style>
    @keyframes $replace {
      from {}
      to {
        transform: translateX(calc($(-100*translate_x)% - $(ncols(yt)/5 - 1)pt));
      }
    }
    @keyframes $pop {
      0% {}
      50% {transform: translateY(-100%); outline: 1pt solid;}
      100% {
        transform: translateY(100%) translateX($(100*(ncols(yt) - to_replace[2] + 2))%);
      }
    }

    .$class {
    	display: grid;
        grid-auto-columns: 1fr;
    	width: fit-content;
    	height: fit-content;
    	margin: auto;
    	margin-block-end: var(--pluto-cell-spacing);
    	margin-block-start: var(--pluto-cell-spacing);
        grid-template: $(template);
    }

    .$class #yt {
    	grid-area: yt;
    }
    .$class #yt table {
    	margin: 0;
        width: 100%;
    }
    .$class #x {
        grid-area: x;
        background-color: green;
        $(if delete
            @htl """
            animation-name: $replace;
            animation-duration: 1s;
            animation-fill-mode: forwards;
            """
        end)
        /*$(if to_replace[1] > nrows(yt)
            @htl """
            margin-top: -0.5pt;
            """
        end)*/
    }
    $(if to_replace !== nothing
        @htl """
        .$class #c$(to_replace[1])-$(to_replace[2]).$class_yt {
            background-color: darkred;
            $(if delete
                @htl """
                animation-name: $pop;
                animation-duration: 2s;
                animation-fill-mode: forwards;
                """
            end)
        }
        """
    end)
    </style>
    <div class=$class>
    <div id=yt>$(HTML(repr("text/html", yt; context=IOContext(devnull, :html_class => class_yt, :html_maxlen => maxlen))))</div>
    <div id=x class=$class_yt style="font-family: var(--julia-mono-font-stack); width: auto"><div><span>$(_string_entry(yt)(x))</span></div></div>
    </div>
    """
end
