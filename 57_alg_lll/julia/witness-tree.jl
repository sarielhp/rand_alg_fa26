#!/usr/bin/env julia
# Regenerate from the chapter directory with julia julia/witness-tree.jl.
using QuickEnv
using BasicCompGeometry
using BasicCompGeometry.IpeDraw
using LaTeXStrings

output = joinpath(@__DIR__, "..", "figs", "witness-tree.pdf")
mkpath(dirname(output))
figure(output; keep_source=true, preview=false) do fig
    columns = (22, 65, 139)
    for (x, title) in zip(columns, (L"i", L"L(i)", L"\mathrm{Entries\ read}"))
        draw_label!(fig, x, 122, title)
    end
    draw_segment!(fig, 11, 117, 179, 117)
    events = (L"B", L"A", L"D", L"A", L"C")
    entries = (L"Y^{(0)}", L"X^{(0)}", L"Z^{(0)}", L"X^{(1)}", L"X^{(2)},\,Y^{(1)}")
    for i in eachindex(events)
        y = 120 - 19i
        for (x, value) in zip(columns, (string(i), events[i], entries[i]))
            draw_label!(fig, x, y, value)
        end
    end

    draw_label!(fig, 270, 122, L"\tau(5)")
    draw_segment!(fig, 263, 94, 237, 77)
    draw_segment!(fig, 277, 94, 303, 77)
    draw_segment!(fig, 230, 58, 230, 39)
    for (x, y, event) in ((270, 99, L"C_{5}"), (230, 64, L"A_{4}"),
                          (310, 64, L"B_{1}"), (230, 25, L"A_{2}"))
        draw_label!(fig, x, y, event)
    end
end
