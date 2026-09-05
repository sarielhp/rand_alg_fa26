#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "json"
require "fileutils"
require "open3"
require "set"

ROOT_DIR = File.expand_path("..", __dir__)
PREFIX_TEX = File.join(ROOT_DIR, "prefix.tex")

# Candidates for notation/macro pruning start at the absorbed definitions section.
START_LINE_PATTERN = /Definitions absorbed from sbook\.sty/

# Infrastructure macros that should never be removed even if not directly referenced in text
PROTECTED_MACROS = Set.new(%w[
  qedsymbol myqedsymbol QED qedsign qedsignBig
  IfColorMath IfPrinterVer Mh
  AlgorithmI
  CancelColor CCancel
  eqlab figlab seclab thmlab lemlab corlab remlab defne deflab exerlab clmlab itemlab alglab obslab
  IncludeGraphics TwoFigures TwoFiguresBase ThreeFigures ThreeFiguresExt
  StandAloneMode BookMode File RootFile InputChap InputExt
  Chapter ChapterPrefix ChapterGen ChapterEnd RealChapterEndInner
  fragment IncFragment FragmentName FragWritePrefix FragOutHandle FragProbeOut
  FragProbeIn FragProbeSecret FragReadSecret FragReadSecretClean InJunkDir
  deflabel Quote QuoteOpen QuoteClose QuoteWrite SaveIndent RestoreIndent
  setheadingcolor mysectionstyle FragmentSave
  delX newX chgY remX SpellIgnore
  True False TRUE FALSE
  bibindent setsecnumformat
]).freeze

class MacroDetector
  MacroDef = Struct.new(:name, :start_line, :end_line, :raw_text, :type, keyword_init: true)

  def initialize(options = {})
    @options = options
    @prefix_content = File.read(PREFIX_TEX)
    lines = @prefix_content.lines
    line_idx = lines.find_index { |l| l =~ START_LINE_PATTERN }
    @start_line = line_idx ? line_idx + 1 : 527
    @definitions = []
    @defs_by_name = Hash.new { |h, k| h[k] = [] }
    @corpus_files = []
    @macro_counts = Hash.new(0)
    @prefix_dependencies = Hash.new { |h, k| h[k] = Set.new }
    @direct_used = Set.new
    @active_macros = Set.new
  end

  def run
    collect_corpus_files
    extract_definitions
    analyze_usages_and_dependencies
    resolve_transitive_dependencies

    all_names = @defs_by_name.keys
    unused_names = all_names.reject do |name|
      PROTECTED_MACROS.include?(name) || @active_macros.include?(name)
    end

    unused_defs = unused_names.flat_map { |name| @defs_by_name[name] }.sort_by(&:start_line)

    if @options[:json]
      export_json(unused_names, unused_defs)
    elsif @options[:comment_out]
      apply_comment_out(unused_defs)
      verify_compilation if @options[:verify]
    else
      print_report(unused_names, unused_defs)
    end
  end

  private

  def collect_corpus_files
    patterns = [
      File.join(ROOT_DIR, "[0-9][0-9]_*/**/*.tex"),
      File.join(ROOT_DIR, "fragment/*.tex"),
      File.join(ROOT_DIR, "shared/**/*.tex"),
      File.join(ROOT_DIR, "book.tex"),
      File.join(ROOT_DIR, "*.bib")
    ]
    @corpus_files = Dir.glob(patterns).reject do |f|
      f.include?("/junk/") || f.include?("/old/") || f.end_with?(".bak")
    end
  end

  def extract_definitions
    lines = @prefix_content.lines
    i = @start_line - 1

    while i < lines.size
      line = lines[i]
      stripped = line.strip

      if stripped.start_with?("%")
        i += 1
        next
      end

      name = nil
      type = nil

      if line =~ /\\(?:newcommand\*?|providecommand\*?|renewcommand\*?|DeclareMathOperator\*?|DeclareRobustCommand\*?)\s*(?:\{\s*\\([a-zA-Z@]+)\s*\}|\\([a-zA-Z@]+)\b)/
        name = $1 || $2
        type = :command
      elsif line =~ /\\(?:NewDocumentCommand|DeclareDocumentCommand|RenewDocumentCommand)\s*\{\s*\\([a-zA-Z@]+)\s*\}/
        name = $1
        type = :doccommand
      elsif line =~ /^\\(?:def|gdef|edef|xdef)\s*\\([a-zA-Z@]+)\b/
        name = $1
        type = :def
      end

      if name
        start_line = i + 1
        open_braces = line.count("{") - line.count("}")
        raw_lines = [line]
        curr = i
        while open_braces > 0 && curr + 1 < lines.size
          curr += 1
          raw_lines << lines[curr]
          open_braces += lines[curr].count("{") - lines[curr].count("}")
        end
        end_line = curr + 1
        i = curr

        macro_def = MacroDef.new(
          name: name,
          start_line: start_line,
          end_line: end_line,
          raw_text: raw_lines.join,
          type: type
        )
        @definitions << macro_def
        @defs_by_name[name] << macro_def
      end
      i += 1
    end
  end

  def analyze_usages_and_dependencies
    lines = @prefix_content.lines
    corpus_texts = @corpus_files.map { |f| File.read(f) }

    # 1. Check preamble usages (lines 1..@start_line-1)
    preamble_text = lines[0...@start_line - 1].join

    # 2. Check non-definition prefix usages
    masked_prefix = lines.dup
    @definitions.each do |d|
      (d.start_line..d.end_line).each do |l|
        masked_prefix[l - 1] = "\n"
      end
    end
    prefix_non_def_text = masked_prefix.join

    all_names = @defs_by_name.keys
    name_set = all_names.to_set

    # Find direct usages
    all_names.each do |name|
      pat = Regexp.new("\\\\#{Regexp.escape(name)}(?![a-zA-Z@])")
      cnt = 0
      corpus_texts.each do |text|
        cnt += text.scan(pat).size
      end
      @macro_counts[name] = cnt

      if cnt > 0 || preamble_text =~ pat || prefix_non_def_text =~ pat
        @direct_used << name
      end
    end

    # Build dependencies inside definitions
    @definitions.each do |d|
      body = d.raw_text
      body.scan(/\\([a-zA-Z@]+)/) do |match|
        target = match[0]
        if name_set.include?(target) && target != d.name
          @prefix_dependencies[d.name] << target
        end
      end
    end
  end

  def resolve_transitive_dependencies
    @active_macros = @direct_used.dup
    queue = @direct_used.to_a

    until queue.empty?
      curr = queue.shift
      deps = @prefix_dependencies[curr] || []
      deps.each do |dep|
        unless @active_macros.include?(dep)
          @active_macros << dep
          queue << dep
        end
      end
    end
  end

  def print_report(unused_names, unused_defs)
    puts "================================================================="
    puts " Automated LaTeX Macro Audit Report for prefix.tex"
    puts "================================================================="
    puts " Definitions analyzed (lines #{@start_line}+) : #{@definitions.size}"
    puts " Unique macros defined                 : #{@defs_by_name.size}"
    puts " Active macros (used in corpus/deps)   : #{@active_macros.size}"
    puts " Protected infrastructure macros       : #{PROTECTED_MACROS.size}"
    puts " Detected UNUSED macros                : #{unused_names.size} (#{unused_defs.size} definitions)"
    puts "=================================================================\n"

    puts format("%-5s  %-30s  %-8s  %s", "Line", "Macro Name", "Type", "Snippet")
    puts "-" * 80
    unused_defs.each do |m|
      snippet = m.raw_text.strip.gsub(/\s+/, " ")[0..45]
      puts format("L%-4d  \\%-29s  %-8s  %s", m.start_line, m.name, m.type, snippet)
    end
    puts "\nTo comment out these #{unused_names.size} macros automatically, run with: --comment-out"
    puts "To also run verification builds, run with: --comment-out --verify"
  end

  def export_json(unused_names, unused_defs)
    data = {
      total_definitions: @definitions.size,
      unique_macros: @defs_by_name.size,
      active_count: @active_macros.size,
      unused_count: unused_names.size,
      unused_definitions_count: unused_defs.size,
      unused_macros: unused_defs.map do |m|
        {
          name: m.name,
          start_line: m.start_line,
          end_line: m.end_line,
          type: m.type,
          definition: m.raw_text.strip
        }
      end
    }
    puts JSON.pretty_generate(data)
  end

  def apply_comment_out(unused_defs)
    unused_lines = Set.new
    unused_defs.each do |m|
      (m.start_line..m.end_line).each { |l| unused_lines << l }
    end

    lines = @prefix_content.lines
    new_lines = lines.map.with_index do |line, idx|
      line_num = idx + 1
      if unused_lines.include?(line_num)
        "% [UNUSED-MACRO] #{line}"
      else
        line
      end
    end

    backup_path = File.join(ROOT_DIR, "old_stuff/backup/prefix_before_macro_prune.tex")
    File.write(backup_path, @prefix_content)
    puts "Created backup at #{backup_path}"

    File.write(PREFIX_TEX, new_lines.join)
    puts "Successfully commented out #{unused_defs.size} definitions for unused macros in prefix.tex"
  end

  def verify_compilation
    puts "\n--- Verifying compilation across all chapters and full book ---"

    # Step 1: Quick test on chapter 1
    puts "1/3: Quick test on 01_intro/intro.tex ..."
    cmd_intro = ["xelatex", "-interaction=nonstopmode", "intro.tex"]
    stdout, stderr, status = Open3.capture3(*cmd_intro, chdir: File.join(ROOT_DIR, "01_intro"))
    unless status.success?
      warn "ERROR: intro.tex failed compilation! Reverting prefix.tex..."
      puts stdout.lines.last(30).join
      File.write(PREFIX_TEX, @prefix_content)
      exit 1
    end
    puts "     01_intro passed!"

    # Step 2: All 58 chapters
    test_script = File.join(ROOT_DIR, "tools/test_all_chaps.rb")
    puts "2/3: Running all chapters: #{test_script} -j 4 ..."
    chaps_ok = system("#{test_script} -j 4")
    unless chaps_ok
      warn "ERROR: Chapters compilation failed after pruning macros! Reverting prefix.tex..."
      File.write(PREFIX_TEX, @prefix_content)
      exit 1
    end

    # Step 3: Full book
    puts "3/3: Compiling full book (xelatex book.tex) ..."
    cmd_book = ["xelatex", "-interaction=nonstopmode", "book.tex"]
    stdout, stderr, status = Open3.capture3(*cmd_book, chdir: ROOT_DIR)
    unless status.success?
      warn "ERROR: Full book compilation failed after pruning macros! Reverting prefix.tex..."
      puts stdout.lines.last(30).join
      File.write(PREFIX_TEX, @prefix_content)
      exit 1
    end

    puts "\nVERIFICATION SUCCESSFUL: 58/58 chapters and book.tex compile cleanly!"
  end
end

options = { json: false, comment_out: false, verify: false }
OptionParser.new do |opts|
  opts.banner = "Usage: detect_unused_macros.rb [options]"
  opts.on("--json", "Output results in JSON format") { options[:json] = true }
  opts.on("--comment-out", "Comment out unused macros in prefix.tex with backup") { options[:comment_out] = true }
  opts.on("--verify", "Automatically verify all chapters and book compile after changes") { options[:verify] = true }
end.parse!

MacroDetector.new(options).run if __FILE__ == $PROGRAM_NAME
