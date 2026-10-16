#!/usr/bin/env ruby
# frozen_string_literal: true

# Regenerate from any directory: ruby /path/to/27_streaming/tools/thinning_merge_tree.rb
# Needs Ipe (ipetoipe), XeLaTeX, and the manuscript's New Computer Modern fonts.
require 'cgi'
require 'fileutils'
require 'tmpdir'

INPUTS = [[5, 6].freeze, [1, 7].freeze, [2, 8].freeze, [3, 4].freeze].freeze
LEAF_X = [30, 110, 220, 300].freeze
HEADER = <<~'XML'
  <?xml version="1.0"?>
  <!DOCTYPE ipe SYSTEM "ipe.dtd">
  <ipe version="70218" creator="thinning_merge_tree.rb">
  <info tex="xetex" bbox="cropbox"/>
  <preamble>
  \usepackage{fontspec,unicode-math,cancel,xcolor}
  \setmainfont{NewCM10-Book.otf}
  \setmathfont{NewCMMath-Book.otf}
  \newcommand{\kept}[1]{\textcolor{blue}{#1}}
  </preamble>
  <ipestyle name="thinning">
  <layout paper="330 210" origin="0 0" frame="330 210" crop="yes"/>
  <symbol name="arrow/normal(spx)">
  <path fill="sym-stroke">0 0 m -1 0.35 l -1 -0.35 l h</path>
  </symbol>
  <arrowsize name="normal" value="4"/>
  <pen name="normal" value="0.6"/>
  <textsize name="normal" value="\large"/>
  <textsize name="small" value="\normalsize"/>
  </ipestyle>
  <page>
  <layer name="tree"/>
  <view layers="tree" active="tree"/>
XML

def label(x, y, latex, size: 'normal')
  <<~XML
    <text layer="tree" pos="#{x} #{y}" stroke="black" type="label"
      halign="center" valign="center" size="#{size}">#{CGI.escapeHTML(latex)}</text>
  XML
end

def arrow(start_point, end_point)
  <<~XML
    <path layer="tree" stroke="black" pen="normal" arrow="normal/normal">
    #{start_point.join(' ')} m #{end_point.join(' ')} l
    </path>
  XML
end

def merge_node(x, y, merged)
  entries = merged.each_with_index.map do |value, index|
    index.even? ? "\\cancel{#{value}}" : "\\kept{#{value}}"
  end
  retained = merged.each_slice(2).map(&:last)
  label(x, y, "$[#{entries.join(',')}]$", size: 'small') +
    arrow([x, y - 11], [x, y - 17]) +
    label(x, y - 28, "$\\kept{[#{retained.join(',')}]}$")
end

first_merges = INPUTS.each_slice(2).map { |left, right| (left + right).sort }
summaries = first_merges.map { |merged| merged.each_slice(2).map(&:last) }
last_merge = summaries.flatten.sort
output = last_merge.each_slice(2).map(&:last)
raise 'Incorrect merge example' unless output == [5, 8] && INPUTS.flatten.sort == (1..8).to_a

document = +HEADER
INPUTS.each_with_index do |values, index|
  document << label(LEAF_X[index], 195, "$[#{values.join(',')}]$")
end
document << arrow([30, 183], [54, 151])
document << arrow([110, 183], [86, 151])
document << arrow([220, 183], [244, 151])
document << arrow([300, 183], [276, 151])
document << merge_node(70, 138, first_merges[0])
document << merge_node(260, 138, first_merges[1])
document << arrow([70, 98], [148, 61])
document << arrow([260, 98], [182, 61])
document << merge_node(165, 48, last_merge)
document << "</page>\n</ipe>\n"

output_dir = File.expand_path('../figs', __dir__)
FileUtils.mkdir_p(output_dir)
ipe_path = File.join(output_dir, 'thinning_merge_tree.ipe')
pdf_path = File.join(output_dir, 'thinning_merge_tree.pdf')
File.write(ipe_path, document)
Dir.mktmpdir('thinning-ipe-') do |scratch|
  success = system({ 'IPELATEXDIR' => scratch }, 'ipetoipe', '-pdf', '-export', ipe_path, pdf_path)
  log_path = File.join(scratch, 'ipetemp.log')
  warn File.read(log_path) if !success && File.file?(log_path)
  abort 'Ipe PDF export failed' unless success && File.size?(pdf_path)
end
puts "Generated #{ipe_path} and #{pdf_path}"
