#!/usr/bin/env ruby
# frozen_string_literal: true
# ==============================================================================
# gen_svg_figures.rb
#
# Generates SVG figures from PDF figure sources across all chapters.
# Handles both single-page figures and multi-page Ipe drawings:
# - Single-page: foo.pdf -> foo.svg (and symlink foo_p1.svg -> foo.svg)
# - Multi-page:  foo.pdf -> foo_p1.svg, foo_p2.svg, ... (and symlink foo.svg -> foo_p1.svg)
# ==============================================================================

require 'etc'
require 'fileutils'
require 'open3'
require 'optparse'
require 'pathname'
require 'thread'
require 'time'

ROOT_DIR = File.expand_path('..', __dir__)

class SvgFigureGenerator
  attr_reader :options

  def initialize(options = {})
    @options = options
    @jobs = options[:jobs] || [Etc.nprocessors, 8].min
    @filters = options[:filters] || []
    @force = options[:force] || false
    @dry_run = options[:dry_run] || false
    @clean = options[:clean] || false
  end

  def run
    verify_dependencies!

    pdf_files = discover_figure_pdfs
    if pdf_files.empty?
      puts 'No PDF figures found matching criteria.'
      return
    end

    if @clean
      clean_svg_figures(pdf_files)
      return
    end

    puts '=' * 65
    puts 'Randomized Algorithms — SVG Figure Generator'
    puts '=' * 65
    puts "Root Directory: #{ROOT_DIR}"
    puts "Found PDFs:     #{pdf_files.size} figures"
    puts "Concurrency:    #{@jobs} workers"
    puts "Force rebuild:  #{@force ? 'Yes' : 'No'}"
    puts "Filters:        #{@filters.empty? ? 'All figures' : @filters.join(', ')}"
    puts '=' * 65

    process_figures(pdf_files)
  end

  private

  def verify_dependencies!
    %w[pdfinfo pdf2svg].each do |cmd|
      _, _, status = Open3.capture3('which', cmd)
      next if status.success?

      warn "Error: Required utility '#{cmd}' is not installed or not in PATH."
      exit 1
    end
  end

  def discover_figure_pdfs
    candidates = Dir.glob(File.join(ROOT_DIR, '{[0-9][0-9]_*/figs,styles}', '*.pdf')).sort

    # Exclude non-figure PDFs (like full chapter build PDFs or backup dirs)
    candidates.reject! do |f|
      rel = Pathname.new(f).relative_path_from(Pathname.new(ROOT_DIR)).to_s
      rel.start_with?('old_stuff', 'junk') || rel.include?('/refs/')
    end

    unless @filters.empty?
      candidates.select! do |f|
        @filters.any? { |flt| f.include?(flt) }
      end
    end

    candidates
  end

  def query_page_count(pdf_path)
    out, status = Open3.capture2('pdfinfo', pdf_path)
    return 1 unless status.success?

    out[/Pages:\s+(\d+)/, 1].to_i
  rescue StandardError
    1
  end

  def needs_rebuild?(pdf_path, page_count)
    return true if @force

    dir = File.dirname(pdf_path)
    stem = File.basename(pdf_path, '.pdf')
    pdf_mtime = File.mtime(pdf_path)

    base_svg = File.join(dir, "#{stem}.svg")
    return true unless File.exist?(base_svg)
    return true if File.mtime(base_svg) < pdf_mtime

    if page_count > 1
      (1..page_count).each do |p|
        p_svg = File.join(dir, "#{stem}_p#{p}.svg")
        return true unless File.exist?(p_svg)
        return true if File.mtime(p_svg) < pdf_mtime
      end
    end

    false
  end

  def clean_svg_figures(pdf_files)
    count = 0
    pdf_files.each do |pdf|
      dir = File.dirname(pdf)
      stem = File.basename(pdf, '.pdf')

      targets = Dir.glob(File.join(dir, "#{stem}*.svg"))
      targets.each do |f|
        puts "Removing #{f}" if @options[:verbose]
        FileUtils.rm_f(f) unless @dry_run
        count += 1
      end
    end
    puts "Cleaned #{count} generated SVG files/symlinks."
  end

  def convert_single_figure(pdf_path)
    dir = File.dirname(pdf_path)
    stem = File.basename(pdf_path, '.pdf')
    page_count = query_page_count(pdf_path)

    unless needs_rebuild?(pdf_path, page_count)
      return { status: :skipped, pdf: pdf_path, pages: page_count }
    end

    if @dry_run
      return { status: :dry_run, pdf: pdf_path, pages: page_count }
    end

    if page_count == 1
      out_svg = File.join(dir, "#{stem}.svg")
      cmd = ['pdf2svg', pdf_path, out_svg]
      stdout, stderr, status = Open3.capture3(*cmd)
      unless status.success?
        return { status: :error, pdf: pdf_path, error: stderr }
      end

      # Create alias symlink foo_p1.svg -> foo.svg
      p1_svg = File.join(dir, "#{stem}_p1.svg")
      FileUtils.rm_f(p1_svg)
      FileUtils.ln_s("#{stem}.svg", p1_svg)

      { status: :converted, pdf: pdf_path, pages: 1 }
    else
      # Multi-page PDF: convert all pages
      pattern = File.join(dir, "#{stem}_p%d.svg")
      cmd = ['pdf2svg', pdf_path, pattern, 'all']
      stdout, stderr, status = Open3.capture3(*cmd)
      unless status.success?
        return { status: :error, pdf: pdf_path, error: stderr }
      end

      # Create default alias foo.svg -> foo_p1.svg
      base_svg = File.join(dir, "#{stem}.svg")
      p1_svg = "#{stem}_p1.svg"
      FileUtils.rm_f(base_svg)
      FileUtils.ln_s(p1_svg, base_svg) if File.exist?(File.join(dir, p1_svg))

      { status: :converted, pdf: pdf_path, pages: page_count }
    end
  rescue StandardError => e
    { status: :error, pdf: pdf_path, error: e.message }
  end

  def process_figures(pdf_files)
    queue = Queue.new
    pdf_files.each { |f| queue << f }

    mutex = Mutex.new
    completed = 0
    total = pdf_files.size
    converted_count = 0
    skipped_count = 0
    error_count = 0
    start_time = Time.now

    workers = (1..@jobs).map do
      Thread.new do
        until queue.empty?
          pdf = begin
            queue.pop(true)
          rescue ThreadError
            nil
          end
          break unless pdf

          res = convert_single_figure(pdf)

          mutex.synchronize do
            completed += 1
            rel_path = Pathname.new(pdf).relative_path_from(Pathname.new(ROOT_DIR)).to_s
            case res[:status]
            when :converted
              converted_count += 1
              pages_str = res[:pages] > 1 ? "(#{res[:pages]} pages)" : '(1 page)'
              printf("[%2d/%2d] CONVERTED %-42s %s\n", completed, total, rel_path, pages_str)
            when :skipped
              skipped_count += 1
              printf("[%2d/%2d] UP-TO-DATE %-42s\n", completed, total, rel_path) if @options[:verbose]
            when :dry_run
              printf("[%2d/%2d] WOULD CONVERT %-38s (%d pages)\n", completed, total, rel_path, res[:pages])
            when :error
              error_count += 1
              printf("[%2d/%2d] ERROR     %-42s: %s\n", completed, total, rel_path, res[:error])
            end
          end
        end
      end
    end

    workers.each(&:join)
    elapsed = (Time.now - start_time).round(2)

    puts '=' * 65
    puts "Finished in #{elapsed}s: #{converted_count} converted, #{skipped_count} up to date, #{error_count} errors."
    puts '=' * 65
    exit 1 if error_count > 0
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {}
  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: tools/gen_svg_figures [options] [filters...]'

    opts.on('-f', '--force', 'Force re-generation of all SVGs even if up to date') do
      options[:force] = true
    end

    opts.on('-j', '--jobs N', Integer, 'Number of concurrent workers (default: 8)') do |n|
      options[:jobs] = n
    end

    opts.on('-v', '--verbose', 'Verbose progress output') do
      options[:verbose] = true
    end

    opts.on('-n', '--dry-run', 'Preview conversions without creating files') do
      options[:dry_run] = true
    end

    opts.on('--clean', 'Remove all generated SVG figures and symlinks') do
      options[:clean] = true
    end

    opts.on('-h', '--help', 'Display this help') do
      puts opts
      exit 0
    end
  end

  parser.parse!(ARGV)
  options[:filters] = ARGV

  generator = SvgFigureGenerator.new(options)
  generator.run
end
