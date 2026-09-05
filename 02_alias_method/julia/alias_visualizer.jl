#!/usr/bin/env julia

using QuickEnv
using Cairo
using Colors
using Random

struct Fragment
    item_id::Int
    len::Float64
end

struct StepState
    step_num::Int
    completed_buckets::Vector{Vector{Fragment}}
    remaining_fragments::Vector{Fragment}
end

function generate_random_distribution(n::Int)
    # Pick randomly a discrete distribution of length n
    raw = rand(n) .+ 0.05
    return raw ./ sum(raw)
end

function get_distinct_colors(n::Int)
    if n == 1
        return [RGB(0.2, 0.6, 0.8)]
    end
    # Generate maximally distinct and pleasing colors
    # Use golden ratio / equidistant hue spacing in HSV space for vibrant contrast
    colors = RGB{Float64}[]
    for i in 1:n
        hue = (i - 1) * 360.0 / n
        # Slightly modulate saturation and value for adjacent harmony
        sat = 0.70 + 0.15 * (i % 2)
        val = 0.85 + 0.10 * ((i + 1) % 2)
        push!(colors, RGB(HSV(hue, sat, val)))
    end
    return colors
end

function run_alias_algorithm(p::Vector{Float64})
    n = length(p)
    target = 1.0 / n
    eps = 1e-9

    states = StepState[]

    # Step 0: Initial distribution
    init_frags = [Fragment(i, p[i]) for i in 1:n]
    push!(states, StepState(0, Vector{Fragment}[], init_frags))

    # Work queues
    S = Tuple{Int, Float64}[]
    M = Tuple{Int, Float64}[]
    L = Tuple{Int, Float64}[]

    for i in 1:n
        if p[i] < target - eps
            push!(S, (i, p[i]))
        elseif p[i] > target + eps
            push!(L, (i, p[i]))
        else
            push!(M, (i, p[i]))
        end
    end

    completed = Vector{Vector{Fragment}}()

    for step in 1:n
        if !isempty(M)
            idx, prob = popfirst!(M)
            push!(completed, [Fragment(idx, target)])
        else
            if isempty(S) || isempty(L)
                if !isempty(S)
                    idx, prob = popfirst!(S)
                    push!(completed, [Fragment(idx, target)])
                elseif !isempty(L)
                    idx, prob = popfirst!(L)
                    push!(completed, [Fragment(idx, target)])
                end
            else
                s_idx, s_prob = popfirst!(S)
                l_idx, l_prob = popfirst!(L)

                delta = target - s_prob
                push!(completed, [Fragment(s_idx, s_prob), Fragment(l_idx, delta)])

                rem_l = l_prob - delta
                if rem_l > target + eps
                    push!(L, (l_idx, rem_l))
                elseif rem_l < target - eps && rem_l > eps
                    push!(S, (l_idx, rem_l))
                elseif rem_l >= eps
                    push!(M, (l_idx, rem_l))
                end
            end
        end

        # Gather remaining fragments
        rem_frags = Fragment[]
        for (idx, prob) in S
            push!(rem_frags, Fragment(idx, prob))
        end
        for (idx, prob) in M
            push!(rem_frags, Fragment(idx, prob))
        end
        for (idx, prob) in L
            push!(rem_frags, Fragment(idx, prob))
        end

        push!(states, StepState(step, deepcopy(completed), rem_frags))
    end

    return states
end

function draw_visualization(states::Vector{StepState}, n::Int, colors::Vector{RGB{Float64}}, filename::String)
    num_steps = length(states) # n + 1
    
    # Layout geometry
    width = 960.0
    bar_height = 26.0
    row_gap = 20.0
    extra_initial_gap = row_gap  # Double space between input (step 0) and step 1
    margin_x = 40.0
    margin_y = 35.0
    
    total_height = margin_y * 2 + num_steps * bar_height + (num_steps - 1) * row_gap + extra_initial_gap
    bar_width = width - 2 * margin_x

    surface = CairoPDFSurface(filename, width, total_height)
    cr = CairoContext(surface)

    # Background
    set_source_rgb(cr, 1.0, 1.0, 1.0)
    paint(cr)

    for (row_idx, state) in enumerate(states)
        # Calculate vertical position with double gap after step 0
        if state.step_num == 0
            y = margin_y
        else
            y = margin_y + bar_height + 2 * row_gap + (state.step_num - 1) * (bar_height + row_gap)
        end

        bucket_width = bar_width / n

        if state.step_num == 0
            # Step 0: Draw initial distribution
            current_x = margin_x
            for frag in state.remaining_fragments
                w = frag.len * bar_width
                col = colors[frag.item_id]
                set_source_rgb(cr, col.r, col.g, col.b)
                rectangle(cr, current_x, y, w, bar_height)
                fill(cr)

                # Segment boundary
                set_source_rgba(cr, 0.0, 0.0, 0.0, 0.3)
                set_line_width(cr, 0.75)
                rectangle(cr, current_x, y, w, bar_height)
                stroke(cr)

                current_x += w
            end
        else
            # Step k: Draw completed buckets
            for (b_idx, bucket) in enumerate(state.completed_buckets)
                bx = margin_x + (b_idx - 1) * bucket_width
                cur_bx = bx
                for frag in bucket
                    w = (frag.len * n) * bucket_width
                    col = colors[frag.item_id]
                    set_source_rgb(cr, col.r, col.g, col.b)
                    rectangle(cr, cur_bx, y, w, bar_height)
                    fill(cr)

                    # Subtle inner fragment border
                    set_source_rgba(cr, 0.0, 0.0, 0.0, 0.25)
                    set_line_width(cr, 0.75)
                    rectangle(cr, cur_bx, y, w, bar_height)
                    stroke(cr)

                    cur_bx += w
                end
            end

            # Draw remaining unallocated pieces in the remaining bar region
            k = length(state.completed_buckets)
            rem_start_x = margin_x + k * bucket_width
            cur_rem_x = rem_start_x
            for frag in state.remaining_fragments
                w = frag.len * bar_width
                col = colors[frag.item_id]
                set_source_rgba(cr, col.r, col.g, col.b, 0.85)
                rectangle(cr, cur_rem_x, y, w, bar_height)
                fill(cr)

                set_source_rgba(cr, 0.0, 0.0, 0.0, 0.25)
                set_line_width(cr, 0.75)
                rectangle(cr, cur_rem_x, y, w, bar_height)
                stroke(cr)

                cur_rem_x += w
            end
        end

        # Draw outer bar frame
        set_source_rgb(cr, 0.25, 0.25, 0.25)
        set_line_width(cr, 1.2)
        rectangle(cr, margin_x, y, bar_width, bar_height)
        stroke(cr)

        # Draw bucket limit tick marks (small vertical lines)
        tick_protrude = 5.0
        set_source_rgb(cr, 0.0, 0.0, 0.0)
        set_line_width(cr, 1.8)
        for i in 0:n
            bx = margin_x + (i / n) * bar_width
            move_to(cr, bx, y - tick_protrude)
            line_to(cr, bx, y + bar_height + tick_protrude)
            stroke(cr)
        end

        # Thick line under the newly created bucket at each step
        if state.step_num >= 1
            k = state.step_num
            bx_start = margin_x + (k - 1) * bucket_width
            bx_end = margin_x + k * bucket_width
            underline_y = y + bar_height + 4.0

            set_source_rgb(cr, 0.0, 0.0, 0.0)
            set_line_width(cr, 3.5)
            move_to(cr, bx_start, underline_y)
            line_to(cr, bx_end, underline_y)
            stroke(cr)
        end
    end

    destroy(cr)
    finish(surface)
    println("Generated $(filename) (n=$(n), $(num_steps) rows).")
end

function main()
    n = 6
    if length(ARGS) >= 1
        n = parse(Int, ARGS[1])
    end
    
    out_file = length(ARGS) >= 2 ? ARGS[2] : "alias_progression.pdf"

    println("Running Alias Method visualization for n = $(n)...")
    p = generate_random_distribution(n)
    
    colors = get_distinct_colors(n)
    states = run_alias_algorithm(p)
    draw_visualization(states, n, colors, out_file)
end

main()
