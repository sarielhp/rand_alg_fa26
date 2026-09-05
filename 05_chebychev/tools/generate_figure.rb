#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

fig_name = ARGV[0] || 'inverse_estimation'
figs_dir = File.expand_path('../figs', __dir__)
FileUtils.mkdir_p(figs_dir)

base_ipe_path = '/home/sariel/papers/styles/ipe/default.ipe'
unless File.exist?(base_ipe_path)
  warn "Error: Base Ipe template #{base_ipe_path} not found"
  exit 1
end

template = File.read(base_ipe_path)

# 1. Configure Ipe layout and stylesheet
# Set bbox="cropbox" in info tag to eliminate outer margins
template = template.sub(/<info\b([^>]*)\/>/) { %Q{<info#{$1} bbox="cropbox"/>} }

# Insert 8in page style (576 x 504 pt canvas with auto-cropping)
style_8in = %Q{<ipestyle name="8in page style">\n<layout paper="576 504" origin="0 0" frame="576 504" crop="yes"/>\n</ipestyle>}
template = template.sub(/<\/ipestyle>\s*<page>/m) { "</ipestyle>\n" + style_8in + "\n<page>" }

# Enhanced preamble matching lecture note notations
template = template.sub(%r{<preamble>.*?</preamble>}m) { %Q{<preamble>\n\\usepackage{amsmath,amssymb}\n\\def\\ipeMode{TRUE}\n\\def\\Sample{\\mathsf{R}}\n</preamble>} }

# Coordinate definitions (all elements kept clean and balanced)
u_x1   = 110.0
u_x2   = 470.0
u_y1   = 220.0
u_y2   = 238.0
u_ymid = (u_y1 + u_y2) / 2.0

x_k    = 290.0
x_rmin = 230.0
x_rplus= 350.0
x_g    = 180.0
x_h    = 400.0

r_x1   = 150.0
r_x2   = 430.0
r_y1   = 82.0
r_y2   = 100.0
r_ymid = (r_y1 + r_y2) / 2.0

x_lmin = 245.0
x_lplus= 335.0

# 2. Build clean, notation-only Ipe XML
page_xml = <<~XML
<page>
<layer name="background"/>
<layer name="intervals"/>
<layer name="axes"/>
<layer name="arrows"/>
<layer name="labels"/>
<view layers="background intervals axes arrows labels" active="labels"/>

<!-- ========================================================= -->
<!-- 1. SOURCE DOMAIN: Universe U                             -->
<!-- ========================================================= -->

<!-- Domain Label -->
<text layer="labels" pos="95 #{u_ymid}" stroke="black" type="label" size="LARGE" halign="right" valign="center">$U$</text>

<!-- Outer bounds g and h region in U -->
<path layer="intervals" stroke="darkred" fill="mistyrose" pen="thin" dash="dashed">
#{x_g} #{u_y1} m
#{x_h} #{u_y1} l
#{x_h} #{u_y2} l
#{x_g} #{u_y2} l
h
</path>

<!-- Confidence Interval I = [r_-, r_+] in U -->
<path layer="intervals" stroke="darkgreen" fill="lightgreen" pen="heavier">
#{x_rmin} #{u_y1} m
#{x_rplus} #{u_y1} l
#{x_rplus} #{u_y2} l
#{x_rmin} #{u_y2} l
h
</path>

<!-- Universe U Bar outline -->
<path layer="axes" stroke="black" pen="heavier">
#{u_x1} #{u_y1} m
#{u_x2} #{u_y1} l
#{u_x2} #{u_y2} l
#{u_x1} #{u_y2} l
h
</path>

<!-- Rank 1 and n labels -->
<text layer="labels" pos="#{u_x1} #{u_y1 - 12}" stroke="gray2" type="label" size="small" halign="center">$1$</text>
<text layer="labels" pos="#{u_x2} #{u_y1 - 12}" stroke="gray2" type="label" size="small" halign="center">$n$</text>

<!-- Extreme ranks g and h -->
<path layer="axes" stroke="darkred" pen="heavier" dash="dashed">
#{x_g} #{u_y1 - 3} m
#{x_g} #{u_y2 + 3} l
</path>
<text layer="labels" pos="#{x_g} #{u_y1 - 12}" stroke="darkred" type="label" size="normal" halign="center">$g$</text>

<path layer="axes" stroke="darkred" pen="heavier" dash="dashed">
#{x_h} #{u_y1 - 3} m
#{x_h} #{u_y2 + 3} l
</path>
<text layer="labels" pos="#{x_h} #{u_y1 - 12}" stroke="darkred" type="label" size="normal" halign="center">$h$</text>

<!-- Interval endpoints r_- and r_+ in U -->
<path layer="axes" stroke="darkgreen" pen="fat">
#{x_rmin} #{u_y1 - 3} m
#{x_rmin} #{u_y2 + 3} l
</path>
<text layer="labels" pos="#{x_rmin} #{u_y2 + 6}" stroke="darkgreen" type="label" size="normal" halign="center">$r_-$</text>

<path layer="axes" stroke="darkgreen" pen="fat">
#{x_rplus} #{u_y1 - 3} m
#{x_rplus} #{u_y2 + 3} l
</path>
<text layer="labels" pos="#{x_rplus} #{u_y2 + 6}" stroke="darkgreen" type="label" size="normal" halign="center">$r_+$</text>

<!-- Target element s_k in U -->
<path layer="axes" stroke="darkblue" pen="ultrafat">
#{x_k} #{u_y1 - 3} m
#{x_k} #{u_y2 + 3} l
</path>
<use layer="axes" name="mark/disk(sx)" pos="#{x_k} #{u_ymid}" size="large" stroke="darkblue" fill="darkblue"/>
<text layer="labels" pos="#{x_k} #{u_y2 + 6}" stroke="darkblue" type="label" size="normal" halign="center">$s_k$</text>

<!-- Dimension line for Interval I in U -->
<path layer="arrows" stroke="darkgreen" pen="heavier" arrow="pointed/normal" rarrow="pointed/normal">
#{x_rmin} 206 m
#{x_rplus} 206 l
</path>
<text layer="labels" pos="#{x_k} 195" stroke="darkgreen" type="label" size="small" halign="center">$I = [r_-, r_+]$</text>


<!-- ========================================================= -->
<!-- 2. SAMPLE DOMAIN: Sample R                               -->
<!-- ========================================================= -->

<!-- Domain Label -->
<text layer="labels" pos="135 #{r_ymid}" stroke="black" type="label" size="LARGE" halign="right" valign="center">$\\Sample$</text>

<!-- Chebyshev window in R -->
<path layer="intervals" stroke="darkgreen" fill="lightgreen" pen="heavier">
#{x_lmin} #{r_y1} m
#{x_lplus} #{r_y1} l
#{x_lplus} #{r_y2} l
#{x_lmin} #{r_y2} l
h
</path>

<!-- R Bar outline -->
<path layer="axes" stroke="black" pen="heavier">
#{r_x1} #{r_y1} m
#{r_x2} #{r_y1} l
#{r_x2} #{r_y2} l
#{r_x1} #{r_y2} l
h
</path>

<!-- Endpoints rank 1 and m -->
<text layer="labels" pos="#{r_x1} #{r_y1 - 12}" stroke="gray2" type="label" size="small" halign="center">$1$</text>
<text layer="labels" pos="#{r_x2} #{r_y1 - 12}" stroke="gray2" type="label" size="small" halign="center">$m$</text>

<!-- Expected rank mu in R -->
<path layer="axes" stroke="darkblue" pen="fat" dash="dashed">
#{x_k} #{r_y1 - 2} m
#{x_k} #{r_y2 + 2} l
</path>
<use layer="axes" name="mark/disk(sx)" pos="#{x_k} #{r_ymid}" size="normal" stroke="darkblue" fill="darkblue"/>
<text layer="labels" pos="#{x_k} #{r_y1 - 12}" stroke="darkblue" type="label" size="normal" halign="center">$\\mu$</text>

<!-- Pivots in R -->
<path layer="axes" stroke="darkgreen" pen="fat">
#{x_lmin} #{r_y1 - 2} m
#{x_lmin} #{r_y2 + 2} l
</path>
<use layer="axes" name="mark/disk(sx)" pos="#{x_lmin} #{r_ymid}" size="large" stroke="darkgreen" fill="darkgreen"/>
<text layer="labels" pos="#{x_lmin} #{r_y1 - 12}" stroke="darkgreen" type="label" size="small" halign="center">$\\ell_-$</text>
<text layer="labels" pos="#{x_lmin} #{r_y1 - 24}" stroke="darkgreen" type="label" size="normal" halign="center">$r_-$</text>

<path layer="axes" stroke="darkgreen" pen="fat">
#{x_lplus} #{r_y1 - 2} m
#{x_lplus} #{r_y2 + 2} l
</path>
<use layer="axes" name="mark/disk(sx)" pos="#{x_lplus} #{r_ymid}" size="large" stroke="darkgreen" fill="darkgreen"/>
<text layer="labels" pos="#{x_lplus} #{r_y1 - 12}" stroke="darkgreen" type="label" size="small" halign="center">$\\ell_+$</text>
<text layer="labels" pos="#{x_lplus} #{r_y1 - 24}" stroke="darkgreen" type="label" size="normal" halign="center">$r_+$</text>

<!-- Chebyshev sample fluctuation band dimension -->
<path layer="arrows" stroke="darkgreen" pen="normal" arrow="pointed/normal" rarrow="pointed/normal">
#{x_lmin} 46 m
#{x_lplus} 46 l
</path>
<text layer="labels" pos="#{x_k} 34" stroke="darkgreen" type="label" size="tiny" halign="center">$\\pm t\\sqrt{m}/2$</text>


<!-- ========================================================= -->
<!-- 3. INTER-DOMAIN RELATIONS: Lifting & Sampling             -->
<!-- ========================================================= -->

<!-- Vertical alignment dotted line -->
<path layer="arrows" stroke="darkblue" pen="thin" dash="dotted">
#{x_k} #{r_y2} m
#{x_k} 185 l
</path>

<!-- Lifting arrows from R up to U -->
<path layer="arrows" stroke="darkgreen" pen="fat" dash="dashed" arrow="pointed/normal">
#{x_lmin} #{r_y2 + 2} m
#{x_rmin} #{u_y1 - 2} l
</path>

<path layer="arrows" stroke="darkgreen" pen="fat" dash="dashed" arrow="pointed/normal">
#{x_lplus} #{r_y2 + 2} m
#{x_rplus} #{u_y1 - 2} l
</path>

<!-- Sampling Arrow on left -->
<path layer="arrows" stroke="blue" pen="fat" arrow="pointed/normal">
100 #{u_y1 - 4} m
75 160
140 #{r_y2 + 4} c
</path>

</page>
XML

full_ipe = template.sub(%r{<page>.*?</page>}m) { page_xml }
ipe_file = File.join(figs_dir, "#{fig_name}.ipe")
pdf_file = File.join(figs_dir, "#{fig_name}.pdf")
tex_file = File.join(figs_dir, "#{fig_name}_fig.tex")

# Write .ipe file
File.write(ipe_file, full_ipe)
puts "Wrote #{ipe_file}"

# Compile to PDF using ipetoipe
system("ipetoipe -pdf #{ipe_file} #{pdf_file}")
puts "Compiled #{pdf_file}"

# 3. Generate LaTeX fragment with concise 2-3 line caption
latex_fragment = <<~LATEX
\\begin{figure}[t]
    \\centering
    \\IncludeGraphics{\\File{figs/#{fig_name}}}
    \\caption{Inverse estimation via sampling: Sample pivots $r_-,
      r_+ \\in \\Sample$ are chosen around the expected rank $\\mu$,
      bracketing the rank-$k$ element $s_k$ in the interval $I = [r_-,
      r_+]$ in $U$. See \\lemref{good:interval} for details.}
    \\figlab{inverse:estimation}
\\end{figure}
LATEX

File.write(tex_file, latex_fragment)
puts "Wrote #{tex_file}"
