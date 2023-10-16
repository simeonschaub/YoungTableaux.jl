using UUIDs

function Base.show(io::IO, ::MIME"text/html", yt::YoungTableau)
    (; rows) = yt
    class = string("yt", uuid1())
    print(io, """
        <table style='border: none'>
        <style scoped>
            .$class {
                border: 1pt solid;
                width: $(100 / (isempty(rows) ? 100 : length(rows[1])))%;
                padding: 8px;
            }
            .$class div {
                font-size: large;
                aspect-ratio: 1;
                min-width: max($(maximum(textwidth∘string, yt))ch, 1em);
                display: flex;
                align-items: center;
                justify-content: center;
            }
        </style>
        """)
    for row in rows
        print(io, "<tr>")
        for m in row
            print(io, "<td class=$class><div><span>", m, "</span></div></td>")
        end
        print(io, "</tr>")
    end
    print(io, "</table>")
end
