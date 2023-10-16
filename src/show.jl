function Base.show(io::IO, ::MIME"text/html", (; rows)::YoungTableau)
    class = string("yt", uuid1())
    print(io, """
        <table style='border: none'>
        <style scoped>
            .$class {
                border: 1pt solid;
                width: $(100 / (isempty(rows) ? 100 : length(rows[1])))%;
                padding: 4px;
            }
            .$class div {
                aspect-ratio: 1;
                text-align: center;
                font-size: large;
            }
        </style>
        """)
    for row in rows
        print(io, "<tr>")
        for m in row
            print(io, "<td class=$class><div>", m, "</div></td>")
        end
        print(io, "</tr>")
    end
    print(io, "</table>")
end
