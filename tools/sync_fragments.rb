#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'optparse'
require 'pathname'
require 'set'

# Synchronizes LaTeX fragments from chapter source files into the fragment/ directory.
#
# - Scans chapters for \begin{fragment}{<name>} ... \end{fragment}.
# - Ignores auxiliary, backup, review, and junk directories and files.
# - Detects duplicate definitions:
#     * Same directory: warns/complains about redundant draft definitions and uses canonical file.
#     * Different directories: halts immediately with fatal error.
# - Compares content before writing to preserve file modification times (mtimes).
# - Automatically prunes obsolete def_*.tex files from fragment/.
class FragmentSync
  ROOT_DIR = File.expand_path('..', __dir__).freeze
  FRAGMENT_DIR = File.join(ROOT_DIR, 'fragment').freeze
  BOOK_TEX = File.join(ROOT_DIR, 'book.tex').freeze

  IGNORE_DIR_PATTERNS = %r{/(?:junk|bak|backup|old|orig|disaster|not_done|\.auctex-auto)(?:/|\z)}.freeze
  IGNORE_FILE_PATTERNS = /_review(?:ed)?\.tex\z/.freeze

  FRAGMENT_REGEX = /^[ \t]*\\begin\{fragment\}\{([^}]+)\}\s*\n(.*?)^[ \t]*\\end\{fragment\}/m.freeze
  INC_FRAGMENT_REGEX = /^[ \t]*\\IncFragment\{([^}]+)\}/.freeze

  FragmentOccurrence = Struct.new(:raw_key, :norm_key, :body, :file, :rel_file, :dir, :canonical, keyword_init: true)

  def initialize(options = {})
    @options = options
    @book_chapters = load_book_chapters
    @occurrences = []
    @stats = { written: 0, unchanged: 0, pruned: 0, warnings: 0 }
    @fatal_errors = []
  end

  def run
    collect_fragments
    validate_duplicates!

    if @fatal_errors.any?
      report_fatal_errors
      return false
    end

    active_fragments = select_active_fragments
    validate_includes!(active_fragments.keys.to_set)

    sync_to_disk(active_fragments)
    print_summary
    true
  end

  private

  def load_book_chapters
    chapters = {}
    return chapters unless File.exist?(BOOK_TEX)

    File.foreach(BOOK_TEX) do |line|
      next unless line =~ /^\s*\\InputChap\{([^}]+)\}\s*\{([^}]+)\}/

      chapters[$1.strip] = $2.strip
    end
    chapters
  end

  def collect_fragments
    candidate_files = find_candidate_files
    candidate_files.each do |file|
      scan_file(file)
    end
  end

  def find_candidate_files
    all_files = Dir.glob(File.join(ROOT_DIR, '{[0-9]*,styles}/**/*.tex')) + [BOOK_TEX]

    all_files.select do |path|
      next false if path.start_with?(FRAGMENT_DIR)
      next false if path =~ IGNORE_DIR_PATTERNS
      next false if path =~ IGNORE_FILE_PATTERNS

      # Exclude nested chapter directories (e.g. 47_expanders/44_expanders/...)
      rel = Pathname.new(path).relative_path_from(Pathname.new(ROOT_DIR)).to_s
      parts = rel.split(File::SEPARATOR)
      next false if parts.size > 2 && parts.first =~ /\A\d+_/

      File.file?(path)
    end.sort
  end

  def scan_file(path)
    content = File.read(path)
    return unless content.include?('\begin{fragment}')

    dir_name = File.basename(File.dirname(path))
    rel_file = Pathname.new(path).relative_path_from(Pathname.new(ROOT_DIR)).to_s
    canonical = canonical_file?(path, dir_name)

    content.scan(FRAGMENT_REGEX) do |raw_key, body|
      norm = normalize_key(raw_key)
      @occurrences << FragmentOccurrence.new(
        raw_key: raw_key.strip,
        norm_key: norm,
        body: body.strip + "\n",
        file: path,
        rel_file: rel_file,
        dir: dir_name,
        canonical: canonical
      )
    end
  end

  def canonical_file?(path, dir_name)
    file_base = File.basename(path, '.tex')
    return true if file_base == 'book'

    # Check 1: Matches directory name without numeric prefix
    stem = dir_name.sub(/\A\d+_/, '')
    return true if file_base == stem || file_base == dir_name

    # Check 2: Matches canonical input file listed in book.tex
    return true if @book_chapters[dir_name] == File.basename(path)

    false
  end

  def normalize_key(raw_key)
    clean = raw_key.strip
    clean = clean.sub(/\\deflabel\{([^}]+)\}/, '\1').strip
    clean = clean.sub(/\Adef_/, '')
    clean
  end

  def validate_duplicates!
    by_key = @occurrences.group_by(&:norm_key)

    by_key.each do |norm_key, occs|
      next if occs.size <= 1

      by_dir = occs.group_by(&:dir)
      if by_dir.size > 1
        record_cross_directory_collision(norm_key, occs)
      else
        handle_same_dir_duplicates(norm_key, by_dir.keys.first, occs)
      end
    end
  end

  def record_cross_directory_collision(norm_key, occs)
    locs = occs.map { |o| "  - #{o.rel_file} (dir: #{o.dir})" }.join("\n")
    @fatal_errors << <<~MSG
      FATAL: Fragment '#{norm_key}' is defined across MULTIPLE DIFFERENT DIRECTORIES:
      #{locs}
      Different chapters cannot define the same fragment name.
    MSG
  end

  def handle_same_dir_duplicates(norm_key, dir, occs)
    bodies = occs.map(&:body).uniq
    files = occs.map(&:rel_file).join(', ')

    if bodies.size > 1
      record_conflicting_same_dir(norm_key, dir, files)
      return
    end

    warn_redundant_same_dir(norm_key, dir, files)
  end

  def record_conflicting_same_dir(norm_key, dir, files)
    @stats[:warnings] += 1
    msg = "WARNING: Fragment '#{norm_key}' defined in multiple files with CONFLICTING bodies in '#{dir}': #{files}"
    warn "[CONFLICT] #{msg}"
    return unless @options[:strict]

    @fatal_errors << "Strict mode failure: Conflicting definitions for '#{norm_key}' in '#{dir}'."
  end

  def warn_redundant_same_dir(norm_key, dir, files)
    @stats[:warnings] += 1
    return if @options[:quiet]

    warn "[DUPLICATE] Fragment '#{norm_key}' defined in multiple files in '#{dir}' (bodies match): #{files}"
  end

  def report_fatal_errors
    warn "\n================================================================================"
    warn "FRAGMENT SYNCHRONIZATION ABORTED DUE TO FATAL COLLISIONS:"
    warn "================================================================================"
    @fatal_errors.each { |err| warn err }
    warn "Please resolve these naming conflicts before building.\n"
  end

  def select_active_fragments
    active = {}
    by_key = @occurrences.group_by(&:norm_key)

    by_key.each do |norm_key, occs|
      chosen = occs.find(&:canonical) || occs.first
      active[norm_key] = chosen
    end

    active
  end

  def validate_includes!(active_keys)
    find_candidate_files.each do |file|
      content = File.read(file)
      next unless content.include?('\IncFragment')

      rel_file = Pathname.new(file).relative_path_from(Pathname.new(ROOT_DIR)).to_s
      content.scan(INC_FRAGMENT_REGEX) do |raw_match|
        check_single_include(raw_match.first, rel_file, active_keys)
      end
    end
  end

  def check_single_include(raw_key, rel_file, active_keys)
    norm = normalize_key(raw_key)
    return if active_keys.include?(norm)

    @stats[:warnings] += 1
    suggestion = find_key_suggestion(norm, active_keys)
    hint = suggestion ? " (did you mean '#{suggestion}'?)" : ''
    warn "[MISSING FRAGMENT] #{rel_file} includes '\\IncFragment{#{raw_key}}', but fragment '#{norm}' is not defined#{hint}"
  end

  def find_key_suggestion(target, keys)
    ci = keys.find { |k| k.casecmp?(target) }
    return ci if ci

    cu = keys.find { |k| k.tr(':', '_') == target.tr(':', '_') }
    return cu if cu

    nil
  end

  def sync_to_disk(active_fragments)
    FileUtils.mkdir_p(FRAGMENT_DIR) unless @options[:dry_run]
    active_filenames = Set.new

    active_fragments.each do |norm_key, occ|
      filename = "def_#{norm_key}.tex"
      active_filenames << filename
      write_fragment_if_changed(filename, occ)
    end

    prune_obsolete_fragments(active_filenames)
  end

  def write_fragment_if_changed(filename, occ)
    target_path = File.join(FRAGMENT_DIR, filename)

    if File.exist?(target_path) && File.read(target_path) == occ.body
      @stats[:unchanged] += 1
      return
    end

    if @options[:dry_run]
      action = File.exist?(target_path) ? 'Would update' : 'Would create'
      puts "[DRY RUN] #{action} #{filename} (from #{occ.rel_file})" unless @options[:quiet]
    else
      File.write(target_path, occ.body)
      puts "[WRITE] #{filename} (from #{occ.rel_file})" unless @options[:quiet]
    end
    @stats[:written] += 1
  end

  def prune_obsolete_fragments(active_filenames)
    return unless Dir.exist?(FRAGMENT_DIR)

    existing = Dir.glob(File.join(FRAGMENT_DIR, 'def_*.tex')).map { |p| File.basename(p) }
    stale = existing.reject { |f| active_filenames.include?(f) }

    stale.each do |filename|
      target_path = File.join(FRAGMENT_DIR, filename)
      if @options[:dry_run]
        puts "[DRY RUN] Would prune obsolete fragment #{filename}" unless @options[:quiet]
      else
        File.delete(target_path)
        puts "[PRUNE] Removed obsolete fragment #{filename}" unless @options[:quiet]
      end
      @stats[:pruned] += 1
    end
  end

  def print_summary
    return if @options[:quiet] && @stats[:written].zero? && @stats[:pruned].zero?

    mode = @options[:dry_run] ? ' [DRY RUN]' : ''
    puts "\n--- Fragment Sync Summary#{mode} ---"
    puts "Total fragments scanned:  #{@occurrences.size}"
    puts "Active unique fragments:  #{select_active_fragments.size}"
    puts "Files written/updated:    #{@stats[:written]}"
    puts "Files unchanged (cached): #{@stats[:unchanged]}"
    puts "Obsolete files pruned:    #{@stats[:pruned]}"
    puts "Warnings encountered:     #{@stats[:warnings]}"
    puts '--------------------------------------'
  end
end

def parse_cli_options
  options = { dry_run: false, quiet: false, strict: false }

  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: tools/sync_fragments [options]'
    opts.on('-n', '--dry-run', 'Preview changes without modifying fragment/ directory') do
      options[:dry_run] = true
    end
    opts.on('-q', '--quiet', 'Suppress unchanged output and redundant warnings') do
      options[:quiet] = true
    end
    opts.on('-s', '--strict', 'Treat same-directory conflicting definitions as fatal errors') do
      options[:strict] = true
    end
    opts.on('-h', '--help', 'Show this help message') do
      puts opts
      exit 0
    end
  end

  parser.parse!(ARGV)
  options
end

if __FILE__ == $PROGRAM_NAME
  options = parse_cli_options
  syncer = FragmentSync.new(options)
  success = syncer.run
  exit(success ? 0 : 1)
end
