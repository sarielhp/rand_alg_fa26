#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "json"
require "csv"
require "set"

ROOT_DIR = File.expand_path("..", __dir__)
PREFIX_TEX = File.join(ROOT_DIR, "styles/prefix_latex.tex")

class MacroUsageCounter
  MacroInfo = Struct.new(
    :name,
    :def_file,
    :def_line,
    :total_count,
    :chapter_count,
    :chapters,
    :used_in_defs,
    keyword_init: true
  )

  def initialize(options = {})
    @options = options
    @macros = {}
    @chapter_files = {}
    @results = []
  end

  def run
    collect_defined_macros
    collect_corpus_files
    count_usages

    sort_results
    if @options[:json]
      print_json
    elsif @options[:csv]
      print_csv
    else
      print_table
    end
  end

  private

  def collect_defined_macros
    files_to_scan = [PREFIX_TEX]
    if @options[:include_chapter_defs]
      files_to_scan += Dir.glob(File.join(ROOT_DIR, "[0-9][0-9]_*/*.tex"))
    end

    files_to_scan.each do |f|
      next unless File.exist?(f)
      rel_f = f.sub(ROOT_DIR + "/", "")
      lines = File.readlines(f)
      i = 0
      while i < lines.size
        line = lines[i]
        if line =~ /^\s*%/
          i += 1
          next
        end

        if line =~ /\\(?:newcommand\*?|providecommand\*?|renewcommand\*?|DeclareMathOperator\*?)\s*(?:\{\s*\\([a-zA-Z@]+)\s*\}|\\([a-zA-Z@]+)\b)/
          name = $1 || $2
          register_macro(name, rel_f, i + 1)
        elsif line =~ /^\\(?:def|gdef)\s*\\([a-zA-Z@]+)\b/
          name = $1
          register_macro(name, rel_f, i + 1)
        end
        i += 1
      end
    end
  end

  def register_macro(name, file, line)
    return if name.nil? || name.empty?
    return if @macros.key?(name) # keep primary definition
    @macros[name] = { file: file, line: line }
  end

  def collect_corpus_files
    patterns = [
      File.join(ROOT_DIR, "[0-9][0-9]_*/**/*.tex"),
      File.join(ROOT_DIR, "fragment/*.tex"),
      File.join(ROOT_DIR, "book.tex")
    ]

    files = Dir.glob(patterns).reject do |f|
      f.include?("/junk/") || f.include?("/backup/") ||
        f.include?("/old/") || f.include?("/old_stuff/") ||
        f.include?("/refs/") || f.include?("/orig/") ||
        f.include?("/ai_notes/") || f.end_with?(".bak")
    end.sort

    files.each do |f|
      rel = f.sub(ROOT_DIR + "/", "")
      chap = if rel.start_with?("fragment/")
               "fragment"
             elsif rel == "book.tex"
               "book"
             else
               rel.split("/").first
             end
      @chapter_files[chap] ||= []
      @chapter_files[chap] << f
    end
  end

  # Strips comments while preserving escaped percentage signs (\%)
  def strip_comments(text)
    clean_lines = text.lines.map do |line|
      # Mask escaped \%
      masked = line.gsub(/\\%/, "\x00")
      if (comment_pos = masked.index("%"))
        masked = masked[0...comment_pos]
      end
      masked.gsub("\x00", "\\%")
    end
    clean_lines.join("\n")
  end

  # Mask macro definition sites so a macro's own definition is not counted as an invocation
  def mask_definitions(text)
    result = text.dup
    # Mask \newcommand{\foo}, \def\foo, etc.
    result.gsub!(/\\(?:newcommand\*?|providecommand\*?|renewcommand\*?|DeclareMathOperator\*?)\s*(?:\{\s*\\([a-zA-Z@]+)\s*\}|\\([a-zA-Z@]+)\b)/) do
      "\\#{$~[0].split.first} {\\__MASKED__}"
    end
    result.gsub!(/^\\(?:def|gdef)\s*\\([a-zA-Z@]+)\b/) do
      "\\def\\__MASKED__"
    end
    result
  end

  def count_usages
    # Pre-process chapter texts: strip comments and mask definition sites
    cleaned_corpus = {}
    @chapter_files.each do |chap, file_list|
      combined = file_list.map { |f| mask_definitions(strip_comments(File.read(f))) }.join("\n")
      # Extract all TeX control sequence tokens in this chapter
      tokens = Hash.new(0)
      combined.scan(/\\([a-zA-Z@]+)/) do |m|
        tokens[m[0]] += 1
      end
      cleaned_corpus[chap] = tokens
    end

    # Check usages inside definitions in styles/prefix_latex.tex
    prefix_text = File.read(PREFIX_TEX)
    prefix_clean = mask_definitions(strip_comments(prefix_text))
    prefix_tokens = Hash.new(0)
    prefix_clean.scan(/\\([a-zA-Z@]+)/) do |m|
      prefix_tokens[m[0]] += 1
    end

    @macros.each do |name, info|
      total = 0
      chaps_used = []

      cleaned_corpus.each do |chap, tokens|
        cnt = tokens[name] || 0
        if cnt > 0
          total += cnt
          chaps_used << chap
        end
      end

      used_in_prefix = prefix_tokens[name] || 0

      @results << MacroInfo.new(
        name: name,
        def_file: info[:file],
        def_line: info[:line],
        total_count: total,
        chapter_count: chaps_used.reject { |c| c == "fragment" || c == "book" }.size,
        chapters: chaps_used.sort,
        used_in_defs: used_in_prefix
      )
    end
  end

  def sort_results
    case @options[:sort]
    when "name"
      @results.sort_by!(&:name)
    when "chapters"
      @results.sort_by! { |r| [-r.chapter_count, -r.total_count, r.name] }
    else # "count"
      @results.sort_by! { |r| [-r.total_count, -r.chapter_count, r.name] }
    end

    if @options[:zero_only]
      @results.select! { |r| r.total_count == 0 && r.used_in_defs == 0 }
    elsif @options[:max_count]
      @results.select! { |r| r.total_count <= @options[:max_count] }
    elsif @options[:min_count]
      @results.select! { |r| r.total_count >= @options[:min_count] }
    end
  end

  def print_table
    puts "=" * 90
    puts " LaTeX Macro Usage Frequency Report"
    puts "=" * 90
    puts " Total Defined Macros Analyzed : #{@macros.size}"
    puts " Macros with 0 Usages (Dead)   : #{@results.count { |r| r.total_count == 0 && r.used_in_defs == 0 }}"
    puts " Macros used in 1 Chapter      : #{@results.count { |r| r.chapter_count == 1 }}"
    puts " Macros used in 2-5 Chapters   : #{@results.count { |r| r.chapter_count >= 2 && r.chapter_count <= 5 }}"
    puts " Macros used in 6+ Chapters    : #{@results.count { |r| r.chapter_count >= 6 }}"
    puts "=" * 90 + "\n\n"

    puts format("%-28s  %7s  %8s  %7s  %-20s  %s", "Macro", "Total", "Chapters", "InDefs", "Defined At", "Sample Chapters")
    puts "-" * 90

    @results.each do |r|
      chap_str = r.chapters.first(4).join(", ")
      chap_str += ", ..." if r.chapters.size > 4
      chap_str = "-" if r.chapters.empty?

      def_loc = "#{File.basename(r.def_file)}:L#{r.def_line}"
      puts format("\\%-27s  %7d  %8d  %7d  %-20s  %s", r.name, r.total_count, r.chapter_count, r.used_in_defs, def_loc, chap_str)
    end
  end

  def print_json
    payload = @results.map do |r|
      {
        macro: r.name,
        total_invocations: r.total_count,
        chapter_count: r.chapter_count,
        used_in_definitions: r.used_in_defs,
        defined_at: { file: r.def_file, line: r.def_line },
        chapters_used: r.chapters
      }
    end
    puts JSON.pretty_generate(payload)
  end

  def print_csv
    puts CSV.generate { |csv|
      csv << ["Macro", "Total_Uses", "Chapter_Count", "In_Definitions", "Def_File", "Def_Line", "Chapters"]
      @results.each do |r|
        csv << [r.name, r.total_count, r.chapter_count, r.used_in_defs, r.def_file, r.def_line, r.chapters.join(";")]
      end
    }
  end
end

options = {
  sort: "count",
  include_chapter_defs: true,
  zero_only: false,
  max_count: nil,
  min_count: nil,
  json: false,
  csv: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: count_macro_usage.rb [options]"
  opts.on("--sort TYPE", %w[count chapters name], "Sort by: count (default), chapters, name") { |t| options[:sort] = t }
  opts.on("--zero", "Show only macros with 0 usages") { options[:zero_only] = true }
  opts.on("--rare N", Integer, "Show only macros used at most N times") { |n| options[:max_count] = n }
  opts.on("--common N", Integer, "Show only macros used at least N times") { |n| options[:min_count] = n }
  opts.on("--prefix-only", "Only analyze macros defined in prefix_latex.tex") { options[:include_chapter_defs] = false }
  opts.on("--json", "Output in JSON format") { options[:json] = true }
  opts.on("--csv", "Output in CSV format") { options[:csv] = true }
  opts.on("-h", "--help", "Show help") do
    puts opts
    exit
  end
end.parse!

MacroUsageCounter.new(options).run if __FILE__ == $PROGRAM_NAME
