#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "json"
require "fileutils"
require "open3"
require "set"

ROOT_DIR = File.expand_path("..", __dir__)
PREFIX_TEX = File.join(ROOT_DIR, "styles", "prefix_latex.tex")
PREFIX_LWARP_TEX = File.join(ROOT_DIR, "styles", "prefix_lwarp.tex")

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
  StandAloneMode BookMode File RootFile InputChap InputExt ChapterNumPage
  Chapter ChapterPrefix ChapterGen ChapterEnd RealChapterEndInner
  fragment IncFragment FragmentName FragWritePrefix FragOutHandle FragProbeOut
  FragProbeIn FragProbeSecret FragReadSecret FragReadSecretClean InJunkDir
  deflabel Quote QuoteOpen QuoteClose QuoteWrite SaveIndent RestoreIndent
  setheadingcolor mysectionstyle FragmentSave
  delX newX chgY remX SpellIgnore
  True False TRUE FALSE
  bibindent setsecnumformat snark
  savesymbol restoresymbol
]).freeze

class MacroDetector
  MacroDef = Struct.new(:name, :start_line, :end_line, :raw_text, :type, keyword_init: true)

  def initialize(options = {})
    @options = options
    @prefix_content = File.read(PREFIX_TEX)
    lines = @prefix_content.lines
    line_idx = lines.find_index { |l| l =~ START_LINE_PATTERN }
    @start_line = line_idx ? line_idx + 1 : 602
    @definitions = []
    @defs_by_name = Hash.new { |h, k| h[k] = [] }
    @corpus_files = []
    @macro_counts = Hash.new(0)
    @corpus_usage = Hash.new { |h, k| h[k] = Hash.new(0) }
    @prefix_dependencies = Hash.new { |h, k| h[k] = Set.new }
    @propagated_usage = Hash.new { |h, k| h[k] = Hash.new(0) }
    @direct_used = Set.new
    @active_macros = Set.new
    @dead_macros = []
    @single_chap_macros = Hash.new { |h, k| h[k] = [] }
    @multi_chap_macros = []
  end

  def run
    collect_corpus_files
    extract_definitions
    analyze_usages_and_dependencies
    resolve_transitive_dependencies
    classify_macros

    if @options[:json]
      export_json
    elsif @options[:prune_dead]
      apply_prune_dead
      verify_compilation if @options[:verify]
    elsif @options[:localize]
      apply_localization(@options[:localize])
      verify_compilation if @options[:verify]
    elsif @options[:localize_all]
      apply_localization_all
      verify_compilation if @options[:verify]
    else
      print_report
    end
  end

  private

  def collect_corpus_files
    patterns = [
      File.join(ROOT_DIR, "[0-9][0-9]_*/**/*.tex"),
      File.join(ROOT_DIR, "fragment/*.tex"),
      File.join(ROOT_DIR, "book.tex"),
      File.join(ROOT_DIR, "*.bib")
    ]
    @corpus_files = Dir.glob(patterns).reject do |f|
      f.include?("/junk/") || f.include?("/old/") || f.include?("/old_stuff/") ||
        f.include?("/backup/") || f.end_with?(".bak")
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
    corpus_entries = @corpus_files.map { |f| [f, File.read(f)] }

    preamble_text = lines[0...@start_line - 1].join

    all_names = @defs_by_name.keys
    name_set = all_names.to_set

    all_names.each do |name|
      pat = Regexp.new("\\\\#{Regexp.escape(name)}(?![a-zA-Z@])")
      cnt = 0
      corpus_entries.each do |fname, text|
        matches = text.scan(pat).size
        if matches > 0
          cnt += matches
          rel = fname.sub(ROOT_DIR + "/", "")
          src = if rel.start_with?("fragment/")
                  "fragment"
                elsif rel == "book.tex"
                  "book"
                else
                  rel.split("/").first
                end
          @corpus_usage[name][src] += matches
        end
      end
      @macro_counts[name] = cnt

      if cnt > 0 || preamble_text =~ pat
        @direct_used << name
      end
    end

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

    @corpus_usage.each do |m, src_hash|
      src_hash.each do |src, cnt|
        @propagated_usage[m][src] += cnt
      end
    end

    changed = true
    while changed
      changed = false
      @defs_by_name.keys.each do |m|
        (@prefix_dependencies[m] || []).each do |dep|
          @propagated_usage[m].each do |src, cnt|
            if @propagated_usage[dep][src] == 0
              @propagated_usage[dep][src] = cnt
              changed = true
            end
          end
        end
      end
    end
  end

  def classify_macros
    @defs_by_name.keys.each do |name|
      next if PROTECTED_MACROS.include?(name)
      srcs = @propagated_usage[name].keys
      if srcs.empty?
        @dead_macros << name
      elsif srcs.size == 1 && srcs.first != "fragment" && srcs.first != "book"
        chap = srcs.first
        @single_chap_macros[chap] << name
      else
        @multi_chap_macros << name
      end
    end
  end

  def print_report
    total_single = @single_chap_macros.values.sum(&:size)
    puts "================================================================="
    puts " Automated LaTeX Macro Audit Report for styles/prefix_latex.tex"
    puts "================================================================="
    puts " Definitions analyzed (lines #{@start_line}+) : #{@definitions.size}"
    puts " Unique macro names defined            : #{@defs_by_name.size}"
    puts " Protected infrastructure macros       : #{PROTECTED_MACROS.size}"
    puts " Truly DEAD macros (0 uses)            : #{@dead_macros.size}"
    puts " SINGLE-CHAPTER macros (only 1 chap)   : #{total_single}"
    puts " MULTI-CHAPTER / Shared macros         : #{@multi_chap_macros.size}"
    puts "=================================================================\n"

    if @dead_macros.any?
      puts "Dead Macros (#{@dead_macros.size}):"
      @dead_macros.sort.each do |m|
        d = @defs_by_name[m].first
        puts format("  L%-4d  \\%-25s  %s", d.start_line, m, d.raw_text.strip.gsub(/\s+/, " ")[0..45])
      end
      puts ""
    end

    if @options[:audit]
      puts "Single-Chapter Macros by Chapter (#{total_single} total):"
      @single_chap_macros.keys.sort.each do |chap|
        list = @single_chap_macros[chap].sort
        puts "  #{chap} (#{list.size} macros):"
        list.each do |m|
          d = @defs_by_name[m].first
          puts format("    \\%-25s (L%-4d): %s", m, d.start_line, d.raw_text.strip.gsub(/\s+/, " ")[0..45])
        end
      end
      puts ""
    else
      puts "Single-Chapter Macro Counts by Chapter (run with --audit for details):"
      @single_chap_macros.keys.sort.each do |chap|
        puts format("  %-25s : %2d macros", chap, @single_chap_macros[chap].size)
      end
      puts ""
    end

    puts "Actions available:"
    puts "  --prune-dead              : Comment out / remove dead macros"
    puts "  --localize <chap_dir>     : Move macros for <chap_dir> into its chapter file"
    puts "  --localize-all            : Move all single-chapter macros into their respective files"
    puts "  --verify                  : Run compilation verification"
  end

  def export_json
    total_single = @single_chap_macros.values.sum(&:size)
    data = {
      total_definitions: @definitions.size,
      unique_macros: @defs_by_name.size,
      protected_count: PROTECTED_MACROS.size,
      dead_count: @dead_macros.size,
      single_chapter_count: total_single,
      multi_chapter_count: @multi_chap_macros.size,
      dead_macros: @dead_macros.sort,
      single_chapter_macros: @single_chap_macros.transform_values(&:sort)
    }
    puts JSON.pretty_generate(data)
  end

  def apply_prune_dead
    if @dead_macros.empty?
      puts "No dead macros found to prune."
      return
    end

    backup_path = File.join(ROOT_DIR, "old_stuff/backup/prefix_before_prune_dead_#{Time.now.strftime('%Y%m%d_%H%M%S')}.tex")
    FileUtils.mkdir_p(File.dirname(backup_path))
    FileUtils.cp(PREFIX_TEX, backup_path)
    puts "Created backup at #{backup_path}"

    lines = File.readlines(PREFIX_TEX)
    dead_lines = Set.new
    @dead_macros.each do |m|
      @defs_by_name[m].each do |d|
        (d.start_line..d.end_line).each { |l| dead_lines << l }
      end
    end

    new_lines = lines.map.with_index do |line, idx|
      line_num = idx + 1
      dead_lines.include?(line_num) ? "% [DEAD-MACRO] #{line}" : line
    end

    File.write(PREFIX_TEX, new_lines.join)
    puts "Successfully commented out #{@dead_macros.size} dead macros in #{PREFIX_TEX}"

    if File.exist?(PREFIX_LWARP_TEX)
      sync_to_lwarp(@dead_macros)
    end
  end

  def sync_to_lwarp(macro_names)
    lwarp_lines = File.readlines(PREFIX_LWARP_TEX)
    names_set = macro_names.to_set
    modified = false
    i = 0
    while i < lwarp_lines.size
      line = lwarp_lines[i]
      if line =~ /\\(?:newcommand\*?|providecommand\*?|def)\s*(?:\{\s*\\([a-zA-Z@]+)\s*\}|\\([a-zA-Z@]+)\b)/
        name = $1 || $2
        if names_set.include?(name)
          lwarp_lines[i] = "% [DEAD-MACRO] #{line}"
          modified = true
        end
      end
      i += 1
    end
    File.write(PREFIX_LWARP_TEX, lwarp_lines.join) if modified
    puts "Synchronized dead macros in #{PREFIX_LWARP_TEX}"
  end

  def apply_localization(chap_dir)
    macros = @single_chap_macros[chap_dir]
    if macros.nil? || macros.empty?
      puts "No single-chapter macros found for #{chap_dir}."
      return
    end

    chap_files = Dir.glob(File.join(ROOT_DIR, chap_dir, "*.tex")).reject { |f| f.include?("/junk/") }
    main_chap_file = chap_files.find { |f| File.basename(f, ".tex") == chap_dir.sub(/^\d+_/, "") } || chap_files.first
    unless main_chap_file && File.exist?(main_chap_file)
      warn "ERROR: Could not find main chapter tex file in #{chap_dir}"
      return
    end

    defs_text = []
    macros.sort.each do |m|
      @defs_by_name[m].each do |d|
        raw = d.raw_text.strip
        if raw =~ /\\DeclareMathOperator\*?\s*\{\s*\\([a-zA-Z@]+)\s*\}\s*\{([^}]+)\}/
          raw = "\\providecommand{\\#{$1}}{\\operatorname{#{$2}}}"
        end
        defs_text << raw
      end
    end

    insert_macros_into_chapter(main_chap_file, defs_text)
    remove_macros_from_prefix(macros)
    puts "Localized #{macros.size} macros into #{chap_dir}/#{File.basename(main_chap_file)}"
  end

  def insert_macros_into_chapter(chap_file, defs_text)
    content = File.read(chap_file)
    block = "\n%------------------------------------------------------------------\n" \
            "% Chapter-local notations\n" \
            "%------------------------------------------------------------------\n" +
            defs_text.join("\n") + "\n\n"

    if content =~ /(\\ChapterGen\{\}.*?\n)/m
      content.sub!($1, "#{$1}#{block}")
    elsif content =~ /(\\Chapter\{.*?\}.*?\n)/m
      content.sub!($1, "#{$1}#{block}")
    else
      content = block + content
    end
    File.write(chap_file, content)
  end

  def remove_macros_from_prefix(macro_names)
    names_set = macro_names.to_set
    [PREFIX_TEX, PREFIX_LWARP_TEX].each do |pfile|
      next unless File.exist?(pfile)
      lines = File.readlines(pfile)
      out = []
      i = 0
      while i < lines.size
        line = lines[i]
        if line =~ /\\(?:newcommand\*?|providecommand\*?|renewcommand\*?|DeclareMathOperator\*?|def)\s*(?:\{\s*\\([a-zA-Z@]+)\s*\}|\\([a-zA-Z@]+)\b)/
          name = $1 || $2
          if names_set.include?(name)
            open_b = line.count("{") - line.count("}")
            while open_b > 0 && i + 1 < lines.size
              i += 1
              open_b += lines[i].count("{") - lines[i].count("}")
            end
            i += 1
            next
          end
        end
        out << line
        i += 1
      end
      File.write(pfile, out.join)
    end
  end

  def apply_localization_all
    backup_path = File.join(ROOT_DIR, "old_stuff/backup/prefix_before_localize_all_#{Time.now.strftime('%Y%m%d_%H%M%S')}.tex")
    FileUtils.mkdir_p(File.dirname(backup_path))
    FileUtils.cp(PREFIX_TEX, backup_path)
    puts "Created backup at #{backup_path}"

    all_localized_macros = []
    @single_chap_macros.keys.sort.each do |chap_dir|
      macros = @single_chap_macros[chap_dir]
      next if macros.nil? || macros.empty?

      chap_files = Dir.glob(File.join(ROOT_DIR, chap_dir, "*.tex")).reject { |f| f.include?("/junk/") }
      main_chap_file = chap_files.find { |f| File.basename(f, ".tex") == chap_dir.sub(/^\d+_/, "") } || chap_files.first
      next unless main_chap_file && File.exist?(main_chap_file)

      defs_text = []
      macros.sort.each do |m|
        @defs_by_name[m].each do |d|
          raw = d.raw_text.strip
          if raw =~ /\\DeclareMathOperator\*?\s*\{\s*\\([a-zA-Z@]+)\s*\}\s*\{([^}]+)\}/
            raw = "\\providecommand{\\#{$1}}{\\operatorname{#{$2}}}"
          end
          defs_text << raw
        end
      end

      insert_macros_into_chapter(main_chap_file, defs_text)
      all_localized_macros.concat(macros)
      puts "  [#{chap_dir}] Localized #{macros.size} macros into #{File.basename(main_chap_file)}"
    end

    remove_macros_from_prefix(all_localized_macros)
    puts "\nRemoved #{all_localized_macros.size} localized macro definitions from prefix files."
  end

  def verify_compilation
    puts "\n--- Verifying compilation across standalone chapters and full book ---"

    puts "1/2: Running fast standalone tests (tools/test_chapters_standalone -u -j 8) ..."
    test_script = File.join(ROOT_DIR, "tools/test_chapters_standalone")
    chaps_ok = system(test_script, "-u", "-j", "8")
    unless chaps_ok
      warn "ERROR: Standalone chapters compilation failed!"
      exit 1
    end
    puts "     All standalone chapters passed!"

    puts "2/2: Compiling master book (l -no-env -s book.tex) ..."
    stdout, stderr, status = Open3.capture3("l", "--no-env", "-s", "book.tex", chdir: ROOT_DIR)
    unless status.success?
      warn "ERROR: Master book compilation failed!"
      puts stdout
      puts stderr
      exit 1
    end
    puts "     Master book passed!"

    puts "\nVERIFICATION COMPLETE: All tests passed cleanly!"
  end
end

options = { json: false, audit: false, prune_dead: false, localize: nil, localize_all: false, verify: false }
OptionParser.new do |opts|
  opts.banner = "Usage: detect_unused_macros.rb [options]"
  opts.on("--audit", "Print detailed single-chapter macro report grouped by chapter") { options[:audit] = true }
  opts.on("--json", "Output results in JSON format") { options[:json] = true }
  opts.on("--prune-dead", "Comment out dead macros in prefix files") { options[:prune_dead] = true }
  opts.on("--localize DIR", "Move single-chapter macros for DIR into its chapter file") { |d| options[:localize] = d }
  opts.on("--localize-all", "Move all single-chapter macros into their respective chapter files") { options[:localize_all] = true }
  opts.on("--verify", "Automatically verify standalone and book builds compile") { options[:verify] = true }
end.parse!

MacroDetector.new(options).run if __FILE__ == $PROGRAM_NAME
