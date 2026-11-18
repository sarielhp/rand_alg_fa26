#!/usr/bin/env julia
# Regenerate from the chapter directory with julia julia/cycle-coloring.jl.
using QuickEnv
using BasicCompGeometry
using BasicCompGeometry.IpeDraw
using LaTeXStrings

output = joinpath(@__DIR__, "..", "figs", "cycle-coloring.pdf")
mkpath(dirname(output))
figure(output; keep_source=true, preview=false) do fig
    # Place each event opposite the midpoint of its edge in the other panel.
    angles = [126 - 72(i-1) for i in 1:5]
    position(cx, angle, radius) = Point(cx + radius*cosd(angle), 77 + radius*sind(angle))
    vertices = [position(75, a, 51) for a in angles]
    events = [position(240, a-36, 50) for a in angles]
    colors = [:red, :red, :blue, :red, :blue]
    for i in eachindex(angles)
        j = mod1(i + 1, 5)
        conflict = colors[i] == colors[j]
        draw_segment!(fig, vertices[i], vertices[j];
                      stroke=conflict ? :red : :black, pen=conflict ? :fat : :normal)
        draw_segment!(fig, events[i], events[j])
    end
    for i in eachindex(angles)
        color = colors[i]
        draw_circle!(fig, vertices[i], 8; stroke=color, fill=:white)
        draw_label!(fig, vertices[i], color == :red ? L"\mathrm{R}" : L"\mathrm{B}";
                    stroke=color, valign=:center)
        draw_label!(fig, position(75, angles[i], 68), latexstring("v_", i); valign=:center)

        conflict = color == colors[mod1(i+1, 5)]
        ink = conflict ? :red : :black
        draw_circle!(fig, events[i], 12; stroke=ink, fill=:white)
        conflict && draw_circle!(fig, events[i], 14; stroke=ink)
        draw_label!(fig, events[i], latexstring("B_", i); stroke=ink, valign=:center)
    end
end
