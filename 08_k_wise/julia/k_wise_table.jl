#!/usr/bin/env julia

# =============================================================================
# Pairwise / k-Wise Independence Truth Table Generator
#
# Generates the truth table for the 2^k - 1 pairwise independent random variables
# constructed from k independent random bits via parity (XOR) combinations.
#
# For each row i in 1:(2^k - 1), the binary representation of i gives the
# values of the k basis bits (b_1, ..., b_k).
#
# For each column c in 1:(2^k - 1), the cell value is the XOR of all initial
# bits j where the j-th bit in the binary representation of c is 1:
#   Y_c(i) = ⨁_{j: bit(c, j) == 1} b_j(i) = count_ones(i & c) % 2
# =============================================================================

using QuickEnv
using PrettyTables
using Printf

"""
    to_subscript(n::Integer) -> String

Convert an integer to Unicode subscript characters (e.g. 12 -> "₁₂").
"""
function to_subscript(n::Integer)
    subscripts = ("₀", "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉")
    return join(subscripts[Int(d - '0') + 1] for d in string(n))
end

"""
    format_heading(c::Integer, k::Integer; style::Symbol=:xor) -> String

Generate a compact heading for column `c`, indicating which of the `k` initial
bits are being XORed together.

Supported styles:
- `:xor` (default): "1", "2", "1⊕2", "3", "1⊕3", "2⊕3", "1⊕2⊕3"
- `:compact` / `:digits`: "1", "2", "12", "3", "13", "23", "123"
- `:vars`: "b₁", "b₂", "b₁⊕b₂", "b₃", "b₁⊕b₃", "b₂⊕b₃", "b₁⊕b₂⊕b₃"
"""
function format_heading(c::Integer, k::Integer; style::Symbol=:xor)
    active_bits = [j for j in 1:k if ((c >> (j - 1)) & 1) == 1]

    if style == :compact || style == :digits
        return join(active_bits)
    elseif style == :vars
        return join(["b" * to_subscript(j) for j in active_bits], "⊕")
    else
        return join(active_bits, "⊕")
    end
end

"""
    latex_heading(c::Integer, k::Integer; style::Symbol=:xor, xor_op::String=raw"\\oplus") -> String

Generate a LaTeX-formatted math formula for column `c`.
"""
function latex_heading(c::Integer, k::Integer; style::Symbol=:xor, xor_op::String=raw"\oplus")
    active_bits = [j for j in 1:k if ((c >> (j - 1)) & 1) == 1]

    if style == :compact || style == :digits
        return join(active_bits)
    elseif style == :vars
        return join(["b_{$j}" for j in active_bits], " $xor_op ")
    else
        return join([string(j) for j in active_bits], " $xor_op ")
    end
end

"""
    build_table(k::Integer; style::Symbol=:xor, split_bits::Bool=false,
                include_zero::Bool=false, two_tier::Bool=false)

Construct column headers and data matrix for terminal/Markdown output.
"""
function build_table(k::Integer; style::Symbol=:xor, split_bits::Bool=false,
                     include_zero::Bool=false, two_tier::Bool=false)
    t = (1 << k) - 1
    row_range = include_zero ? (0:t) : (1:t)
    num_rows = length(row_range)

    col_headings = [format_heading(c, k; style=style) for c in 1:t]

    if split_bits
        bit_headers = ["b" * to_subscript(j) for j in 1:k]
        if two_tier
            headers = [
                ["i", bit_headers..., ["c=$c" for c in 1:t]...],
                ["", ["" for _ in 1:k]..., col_headings...]
            ]
        else
            headers = ["i", bit_headers..., col_headings...]
        end

        data = Matrix{Any}(undef, num_rows, 1 + k + t)
        for (r_idx, i) in enumerate(row_range)
            data[r_idx, 1] = i
            for j in 1:k
                data[r_idx, 1 + j] = (i >> (j - 1)) & 1
            end
            for c in 1:t
                data[r_idx, 1 + k + c] = count_ones(i & c) % 2
            end
        end
    else
        bit_str_header = "bits (" * join(["b" * to_subscript(j) for j in k:-1:1]) * ")"
        if two_tier
            headers = [
                ["i", "bits", ["c=$c" for c in 1:t]...],
                ["", bit_str_header, col_headings...]
            ]
        else
            headers = ["i", "bits", col_headings...]
        end

        data = Matrix{Any}(undef, num_rows, 2 + t)
        for (r_idx, i) in enumerate(row_range)
            data[r_idx, 1] = i
            data[r_idx, 2] = string(i, base=2, pad=k)
            for c in 1:t
                data[r_idx, 2 + c] = count_ones(i & c) % 2
            end
        end
    end

    return headers, data
end

"""
    generate_latex_table(k::Integer; style::Symbol=:xor, split_bits::Bool=false,
                         include_zero::Bool=false, two_tier::Bool=false,
                         standalone::Bool=false, xor_op::String=raw"\\oplus",
                         header_color::String="gray!16", alt_color::String="gray!6",
                         caption::Union{String, Nothing}=nothing,
                         label::Union{String, Nothing}=nothing) -> String

Generate a modern, publication-grade LaTeX table adhering to `booktabs` and `colortbl` standards.
Features:
- Booktabs rules (\\toprule, \\midrule, \\bottomrule)
- Zero rule gaps for colortbl backgrounds (\\aboverulesep=0pt, \\belowrulesep=0pt)
- Alternating zebra row shading
- Proper math-mode formatting throughout
- Clear visual grouping separating basis bits from pairwise independent columns
"""
function generate_latex_table(
    k::Integer;
    style::Symbol=:xor,
    split_bits::Bool=false,
    include_zero::Bool=false,
    two_tier::Bool=false,
    standalone::Bool=false,
    xor_op::String=raw"\oplus",
    header_color::String="gray!16",
    alt_color::String="gray!6",
    caption::Union{String, Nothing}=nothing,
    label::Union{String, Nothing}=nothing
)
    t = (1 << k) - 1
    row_range = include_zero ? (0:t) : (1:t)

    buf = IOBuffer()

    if standalone
        println(buf, raw"\documentclass[11pt]{article}")
        println(buf, raw"\usepackage[margin=1in]{geometry}")
        println(buf, raw"\usepackage{booktabs}")
        println(buf, raw"\usepackage[table,dvipsnames]{xcolor}")
        println(buf, raw"\usepackage{amsmath}")
        println(buf, "")
        println(buf, raw"\begin{document}")
    end

    println(buf, raw"\begin{table}[htbp]")
    println(buf, raw"\centering")
    println(buf, raw"\setlength{\aboverulesep}{0pt}")
    println(buf, raw"\setlength{\belowrulesep}{0pt}")
    println(buf, raw"\setlength{\extrarowheight}{3pt}")

    # Column specifications:
    # Use @{\quad} padding and @{\hspace{1.5em}} between input sample bits and outputs
    col_spec = if split_bits
        "@{\\quad} r *{$k}{c} @{\\hspace{1.5em}} *{$t}{c} @{\\quad}"
    else
        "@{\\quad} r c @{\\hspace{1.5em}} *{$t}{c} @{\\quad}"
    end

    println(buf, "\\begin{tabular}{$col_spec}")
    println(buf, raw"\toprule")
    println(buf, "\\rowcolor{$header_color}")

    y_headers = ["\$Y_{$c}\$" for c in 1:t]
    xor_headers = ["\$" * latex_heading(c, k; style=style, xor_op=xor_op) * "\$" for c in 1:t]

    if split_bits
        bit_headers = ["\$b_{$j}\$" for j in 1:k]
        if two_tier
            println(buf, "\$i\$ & " * join(bit_headers, " & ") * " & " * join(y_headers, " & ") * " \\\\")
            println(buf, "\\rowcolor{$header_color}")
            empty_cells = join([raw"\multicolumn{1}{c}{}" for _ in 1:k], " & ")
            println(buf, "\\multicolumn{1}{c}{} & " * empty_cells * " & " * join(xor_headers, " & ") * " \\\\")
        else
            println(buf, "\$i\$ & " * join(bit_headers, " & ") * " & " * join(xor_headers, " & ") * " \\\\")
        end
    else
        bit_str_sub = "\\mathtt{(b_{$k} \\dots b_1)}"
        if two_tier
            println(buf, "\$i\$ & \\text{bits} & " * join(y_headers, " & ") * " \\\\")
            println(buf, "\\rowcolor{$header_color}")
            println(buf, "\\multicolumn{1}{c}{} & \$$bit_str_sub\$ & " * join(xor_headers, " & ") * " \\\\")
        else
            println(buf, "\$i\$ & \\text{bits} & " * join(xor_headers, " & ") * " \\\\")
        end
    end

    println(buf, raw"\midrule")

    for (r_idx, i) in enumerate(row_range)
        color = (r_idx % 2 == 1) ? raw"\rowcolor{white}" : "\\rowcolor{$alt_color}"
        println(buf, color)

        row_cells = String["\$$i\$"]
        if split_bits
            for j in 1:k
                push!(row_cells, "\$" * string((i >> (j - 1)) & 1) * "\$")
            end
        else
            push!(row_cells, "\\texttt{" * string(i, base=2, pad=k) * "}")
        end

        for c in 1:t
            val = count_ones(i & c) % 2
            push!(row_cells, "\$$val\$")
        end

        println(buf, join(row_cells, " & ") * " \\\\")
    end

    println(buf, raw"\bottomrule")
    println(buf, raw"\end{tabular}")

    cap_text = caption !== nothing ? caption : "Truth table of \$2^k - 1 = $t\$ pairwise independent random bits constructed from \$k=$k\$ independent bits."
    lbl_text = label !== nothing ? label : "tbl:pairwise_k$k"
    println(buf, "\\caption{$cap_text}")
    println(buf, "\\label{$lbl_text}")
    println(buf, raw"\end{table}")

    if standalone
        println(buf, raw"\end{document}")
    end

    return String(take!(buf))
end

function print_help()
    println("""
Usage: k_wise_table.jl [OPTIONS] [k]

Generate truth table for 2^k - 1 pairwise independent bits from k initial bits.

Arguments:
  k                     Number of initial bits (positive integer).
                        If omitted, will prompt for input from stdin.

General Options:
  -c, --compact         Use compact digit-only headings (e.g. "12", "123").
  -v, --vars            Use variable notation (e.g. "b₁⊕b₂" or "b₁⊕b₂").
  -2, --two-tier        Display 2-row header: column index c/Y_c and XOR formula.
  -s, --split-bits      Display initial k bits as separate individual columns.
  -0, --zero            Include row 0 (i = 0 ... 2^k - 1).
  -m, --markdown        Output as a Markdown table.
  -a, --ascii           Use simple ASCII borders instead of Unicode.
  -h, --help            Display this help message.

LaTeX Options:
  -l, --latex           Output as a modern LaTeX table (using booktabs & colortbl).
      --standalone      Wrap LaTeX table in a compilable document template.
      --xor-op <op>     LaTeX operator for XOR (default: "\\oplus", e.g. "\\otimes").
      --color-header <c> Background color for header row (default: "gray!16").
      --color-alt <c>   Background color for alternating rows (default: "gray!6").
      --caption <text>  Custom caption for the LaTeX table.
      --label <tag>     Custom label for the LaTeX table.

Examples:
  ./k_wise_table.jl 3
  ./k_wise_table.jl 3 --latex
  ./k_wise_table.jl 3 --latex --two-tier
  ./k_wise_table.jl 3 --latex --standalone > table.tex && l table.tex
  ./k_wise_table.jl 4 -s --compact
  echo 3 | ./k_wise_table.jl
""")
end

function main()
    args = copy(ARGS)

    k::Union{Int, Nothing} = nothing
    style = :xor
    split_bits = false
    include_zero = false
    two_tier = false
    backend = :text
    table_format = nothing

    # LaTeX specific settings
    standalone = false
    xor_op = raw"\oplus"
    header_color = "gray!16"
    alt_color = "gray!6"
    caption::Union{String, Nothing} = nothing
    label::Union{String, Nothing} = nothing

    i = 1
    while i <= length(args)
        arg = args[i]
        if arg in ("-h", "--help")
            print_help()
            return
        elseif arg in ("-c", "--compact")
            style = :compact
        elseif arg in ("-v", "--vars")
            style = :vars
        elseif arg in ("-2", "--two-tier")
            two_tier = true
        elseif arg in ("-s", "--split-bits")
            split_bits = true
        elseif arg in ("-0", "--zero")
            include_zero = true
        elseif arg in ("-l", "--latex")
            backend = :latex
        elseif arg in ("-m", "--markdown")
            backend = :markdown
        elseif arg in ("-a", "--ascii")
            table_format = TextTableFormat(borders=text_table_borders__simple)
        elseif arg == "--standalone"
            standalone = true
            backend = :latex
        elseif arg == "--xor-op"
            i += 1
            if i > length(args)
                println(stderr, "Error: --xor-op requires an argument.")
                exit(1)
            end
            xor_op = args[i]
        elseif arg == "--color-header"
            i += 1
            if i > length(args)
                println(stderr, "Error: --color-header requires a color string.")
                exit(1)
            end
            header_color = args[i]
        elseif arg == "--color-alt"
            i += 1
            if i > length(args)
                println(stderr, "Error: --color-alt requires a color string.")
                exit(1)
            end
            alt_color = args[i]
        elseif arg == "--caption"
            i += 1
            if i > length(args)
                println(stderr, "Error: --caption requires an argument.")
                exit(1)
            end
            caption = args[i]
        elseif arg == "--label"
            i += 1
            if i > length(args)
                println(stderr, "Error: --label requires an argument.")
                exit(1)
            end
            label = args[i]
        elseif startswith(arg, "-")
            println(stderr, "Error: Unknown option '$arg'. Use -h or --help for usage.")
            exit(1)
        else
            if k === nothing
                val = tryparse(Int, arg)
                if val === nothing || val < 1
                    println(stderr, "Error: k must be a positive integer, got '$arg'.")
                    exit(1)
                end
                k = val
            else
                println(stderr, "Error: Unexpected positional argument '$arg'.")
                exit(1)
            end
        end
        i += 1
    end

    if k === nothing
        if isa(stdin, Base.TTY)
            print("Enter number of bits k: ")
            flush(stdout)
        end
        line = readline()
        if isempty(strip(line))
            println(stderr, "Error: No input provided for k.")
            exit(1)
        end
        val = tryparse(Int, strip(line))
        if val === nothing || val < 1
            println(stderr, "Error: k must be a positive integer, got '$(strip(line))'.")
            exit(1)
        end
        k = val
    end

    if backend == :latex
        latex_str = generate_latex_table(
            k;
            style=style,
            split_bits=split_bits,
            include_zero=include_zero,
            two_tier=two_tier,
            standalone=standalone,
            xor_op=xor_op,
            header_color=header_color,
            alt_color=alt_color,
            caption=caption,
            label=label
        )
        println(latex_str)
        return
    end

    headers, data = build_table(
        k;
        style=style,
        split_bits=split_bits,
        include_zero=include_zero,
        two_tier=two_tier
    )

    if backend == :text
        kwargs = Dict{Symbol, Any}(:column_labels => headers)
        if table_format !== nothing
            kwargs[:table_format] = table_format
        end
        pretty_table(data; kwargs...)
    else
        pretty_table(data; backend=backend, column_labels=headers)
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
