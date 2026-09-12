#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# tools/lwrap — Run LuaLaTeX in nonstopmode with lwarp HTML settings
#
# Usage:
#   tools/lwrap [options] <file.tex | chapter_dir | chapter_number>
#
# Examples:
#   tools/lwrap 23_two_choices/two_choices.tex
#   tools/lwrap 23
#   tools/lwrap book.tex
#   tools/lwrap book_html.tex
#   cd 01_intro && ../tools/lwrap intro.tex
# ==============================================================================

require 'fileutils'
require 'open3'
require 'optparse'
require 'pathname'

ROOT_DIR = File.expand_path('..', __dir__)
BOOK_TEX = File.join(ROOT_DIR, 'book.tex')

options = {
  interaction: 'nonstopmode',
  clean: false,
  quiet: false,
  score: false
}

opt_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: tools/lwrap [options] <file.tex | dir | chapter_num>'

  opts.on('-c', '--clean', 'Remove auxiliary files before compilation') do
    options[:clean] = true
  end

  opts.on('-q', '--quiet', 'Suppress LaTeX stdout output, only show errors') do
    options[:quiet] = true
  end

  opts.on('-s', '--score', 'Show concise score of errors and warnings') do
    options[:score] = true
  end

  opts.on('-h', '--help', 'Show this help message') do
    puts opts
    exit 0
  end
end

args = opt_parser.parse!(ARGV)
target = args.shift

# ------------------------------------------------------------------------------
# Resolve target file and working directory
# ------------------------------------------------------------------------------
def resolve_target(target, root_dir)
  if target.nil? || target.empty?
    candidates = Dir.glob('*.tex').reject { |f| f.end_with?('_html.tex') || f.start_with?('test_') }
    if candidates.size == 1
      return File.expand_path(candidates.first)
    elsif File.exist?('book.tex')
      return File.expand_path('book.tex')
    else
      warn "Error: No file specified and multiple or no .tex files found in current directory."
      exit 1
    end
  end

  # Check if target is an exact existing file path
  return File.expand_path(target) if File.file?(target)
  return File.expand_path("#{target}.tex") if File.file?("#{target}.tex")

  # Check relative to root_dir
  root_target = File.join(root_dir, target)
  return File.expand_path(root_target) if File.file?(root_target)
  return File.expand_path("#{root_target}.tex") if File.file?("#{root_target}.tex")

  # Check if target is a directory
  target_dir = File.directory?(target) ? target : (File.directory?(root_target) ? root_target : nil)
  if target_dir
    tex_files = Dir.glob(File.join(target_dir, '*.tex')).reject { |f| f.end_with?('_html.tex') || File.basename(f).start_with?('test_') }
    if tex_files.size == 1
      return File.expand_path(tex_files.first)
    elsif tex_files.any?
      dir_base = File.basename(target_dir).sub(/^\d+_/, '')
      matched = tex_files.find { |f| File.basename(f, '.tex') == dir_base }
      return File.expand_path(matched) if matched
      return File.expand_path(tex_files.first)
    end
  end

  # Try chapter number matching (e.g. "23" -> "23_two_choices/two_choices.tex")
  if target =~ /\A\d+\z/
    prefix = sprintf('%02d_', target.to_i)
    matching_dirs = Dir.glob(File.join(root_dir, "#{prefix}*")).select { |d| File.directory?(d) }
    if matching_dirs.size == 1
      d = matching_dirs.first
      tex_files = Dir.glob(File.join(d, '*.tex')).reject { |f| f.end_with?('_html.tex') }
      return File.expand_path(tex_files.first) if tex_files.any?
    end
  end

  # Search across chapter dirs matching target substring
  matching_dirs = Dir.glob(File.join(root_dir, "*#{target}*")).select { |d| File.directory?(d) }
  if matching_dirs.size == 1
    d = matching_dirs.first
    tex_files = Dir.glob(File.join(d, '*.tex')).reject { |f| f.end_with?('_html.tex') }
    return File.expand_path(tex_files.first) if tex_files.any?
  end

  warn "Error: Unable to resolve LaTeX target: #{target}"
  exit 1
end

target_file = resolve_target(target, ROOT_DIR)
work_dir = File.dirname(target_file)
tex_basename = File.basename(target_file)
base_name = File.basename(target_file, '.tex')

# Determine BaseJobname
base_jobname = if base_name == 'book' || base_name == 'book_html'
                 'book'
               else
                 base_name
               end

# Clean if requested
if options[:clean]
  Dir.chdir(work_dir) do
    exts = %w[.aux .log .out .toc .sidetoc .idx .ind .ilg .bcf .bbl .blg .run.xml .fls .cut]
    exts.each do |ext|
      FileUtils.rm_f("#{base_name}#{ext}")
      FileUtils.rm_f("#{base_jobname}#{ext}")
    end
  end
end

# Build LuaLaTeX invocation
latex_code = if tex_basename == 'book_html.tex'
               '\def\warpMode{1}\input{book_html.tex}'
             else
               "\\PassOptionsToPackage{warpHTML,BaseJobname=#{base_jobname}}{lwarp}\\def\\warpMode{1}\\input{#{tex_basename}}"
             end

cmd = [
  'lualatex',
  "-interaction=#{options[:interaction]}",
  latex_code
]

puts "==> Running lwarp in: #{work_dir}"
puts "==> Target: #{tex_basename} (BaseJobname=#{base_jobname})"
puts "==> Command: #{cmd.first} #{cmd[1]} '#{latex_code}'"
puts "-------------------------------------------------------------------------------"

exit_code = 0
Dir.chdir(work_dir) do
  if options[:quiet] || options[:score]
    t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    output, status = Open3.capture2e(*cmd)
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0
    exit_code = status.exitstatus || 0

    errors = output.lines.grep(/^! /)
    warnings = output.lines.grep(/Warning:/i)

    if options[:score]
      status_str = (exit_code == 0 && errors.empty?) ? "PASS" : "FAIL"
      puts "[#{status_str}] #{tex_basename} -> Errors: #{errors.size}, Warnings: #{warnings.size} (#{elapsed.round(2)}s)"
      if exit_code != 0 || !errors.empty?
        puts "\nFirst errors:"
        puts errors.first(10)
      end
    elsif options[:quiet]
      if exit_code != 0 || !errors.empty?
        puts output
        warn "\n[!] Compilation failed with #{errors.size} error(s) (exit code: #{exit_code})."
      else
        puts "[OK] Compilation succeeded in #{elapsed.round(2)}s."
      end
    end
  else
    system(*cmd)
    exit_code = $?.exitstatus || 0
  end
end

exit exit_code
