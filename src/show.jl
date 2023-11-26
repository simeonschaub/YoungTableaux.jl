using UUIDs

_show_entry(io::IO, yt, m) = print(IOContext(io, :typeinfo=>eltype(yt)), m)
_show_entry(::IO, ::AbstractShape, ::Bool) = nothing
_string_entry(yt) = m -> sprint(_show_entry, yt, m)

function Base.show(io::IO, ::MIME"text/html", yt::AbstractYoungTableau)
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
