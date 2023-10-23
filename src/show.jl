using UUIDs

_show_entry(io::IO, yt, m) = show(IOContext(io, :typeinfo=>eltype(yt)), m)
_string_entry(yt) = m -> sprint(_show_entry, yt, m)
function Base.show(io::IO, ::MIME"text/html", yt::AbstractYoungTableau)
    rows = YoungTableaux.rows(yt)
    class = get(io, :html_class, string("yt-", uuid1()))
    print(io, """
        <table style='border: none'>
        <style scoped>
            .$class {
                border: 1pt solid;
                width: $(100 / (isempty(rows) ? 100 : rowlength(yt)))%;
                padding: 8px;
            }
            .$class div {
                font-size: large;
                aspect-ratio: 1;
                min-width: max($(maximum(textwidth∘_string_entry(yt), yt))ch, 1em);
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
