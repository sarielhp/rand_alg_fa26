#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "fileutils"
require "open3"

ROOT_DIR = File.expand_path("..", __dir__)

class EmphiReplacer
  def initialize(options = {})
    @options = options
    @total_replaced = 0
    @modified_files = []
  end

  def run
    files = collect_files
    puts "Scanning #{files.size} LaTeX files for \\emphi{...}..."

    files.each do |f|
      process_file(f)
    end

    print_summary

    if @options[:write] && @total_replaced > 0 && @options[:verify]
      verify_builds
    end
  end

  private

  def collect_files
    patterns = [
      File.join(ROOT_DIR, "[0-9][0-9]_*/*.tex"),
      File.join(ROOT_DIR, "fragment/*.tex"),
      File.join(ROOT_DIR, "book.tex")
    ]

    Dir.glob(patterns).reject do |f|
      f.include?("/junk/") || f.include?("/backup/") ||
        f.include?("/old/") || f.include?("/old_stuff/") ||
        f.include?("/refs/") || f.include?("/orig/") ||
        f.include?("/ai_notes/") || f.end_with?(".bak")
    end.sort
  end

  def replace_emphi_in_text(text)
    result = []
    pos = 0
    len = text.length
    count = 0
    snippets = []

    while pos < len
      idx = text.index(/\\emphi\s*\{/, pos)
      unless idx
        result << text[pos..-1]
        break
      end

      result << text[pos...idx]
      open_idx = text.index("{", idx)
      curr = open_idx + 1
      depth = 1

      while curr < len && depth > 0
        char = text[curr]
        if char == "{"
          depth += 1
        elsif char == "}"
          depth -= 1
        elsif char == "\\"
          curr += 1
        end
        curr += 1
      end

      if depth == 0
        inner = text[(open_idx + 1)...(curr - 1)]
        replacement = "\\emphOnly{#{inner}}\\index{#{inner}}"
        result << replacement
        snippets << { old: text[idx...curr], new: replacement }
        count += 1
        pos = curr
      else
        # Unbalanced braces safety fallback
        result << text[idx...curr]
        pos = curr
      end
    end

    [result.join, count, snippets]
  end

  def process_file(file_path)
    rel_path = file_path.sub(ROOT_DIR + "/", "")
    content = File.read(file_path)

    new_content, count, snippets = replace_emphi_in_text(content)
    return if count == 0

    @total_replaced += count
    @modified_files << { file: rel_path, full_path: file_path, count: count, snippets: snippets }

    if @options[:write]
      backup_file(file_path) if @options[:backup]
      File.write(file_path, new_content)
    end
  end

  def backup_file(file_path)
    backup_dir = File.join(ROOT_DIR, "old_stuff/backup/replace_emphi_#{Time.now.strftime('%Y%m%d_%H%M%S')}")
    FileUtils.mkdir_p(backup_dir)
    dest = File.join(backup_dir, File.basename(file_path))
    FileUtils.cp(file_path, dest)
  end

  def print_summary
    puts "\n" + "=" * 80
    puts " \\emphi{XXX} -> \\emphOnly{XXX}\\index{XXX} Replacement Summary"
    puts "=" * 80
    puts " Files containing \\emphi{...} : #{@modified_files.size}"
    puts " Total occurrences to replace : #{@total_replaced}"
    mode = @options[:write] ? "APPLIED (Files updated on disk)" : "DRY-RUN (Preview mode only)"
    puts " Execution Mode               : #{mode}"
    puts "=" * 80 + "\n\n"

    @modified_files.each do |mf|
      puts format("%-45s : %2d occurrences", mf[:file], mf[:count])
      # Show first 2 snippets as examples
      mf[:snippets].first(2).each do |s|
        old_str = s[:old].gsub(/\s+/, " ")
        old_str = old_str.length > 70 ? "#{old_str[0..67]}..." : old_str
        new_str = s[:new].gsub(/\s+/, " ")
        new_str = new_str.length > 70 ? "#{new_str[0..67]}..." : new_str
        puts "    - #{old_str}"
        puts "    + #{new_str}"
      end
      puts "    ..." if mf[:snippets].size > 2
      puts ""
    end

    unless @options[:write]
      puts "To apply the replacements across all files, run with: -w (or --write)"
      puts "To also verify compilation after applying, run with: -w --verify"
    end
  end

  def verify_builds
    puts "\n--- Verifying standalone chapters & master book builds ---"
    test_script = File.join(ROOT_DIR, "tools/test_chapters_standalone")
    chaps_ok = system(test_script, "-u", "-j", "8")
    unless chaps_ok
      warn "ERROR: Standalone chapters compilation failed after replacing \\emphi!"
      exit 1
    end
    puts "     All standalone chapters passed!"

    stdout, stderr, status = Open3.capture3("l", "--no-env", "-s", "-u", "book.tex", chdir: ROOT_DIR)
    unless status.success?
      warn "ERROR: Master book compilation failed!"
      puts stdout
      puts stderr
      exit 1
    end
    puts "     Master book passed!"
    puts "\nVerification clean: All tests passed!"
  end
end

options = { write: false, backup: false, verify: false }
OptionParser.new do |opts|
  opts.banner = "Usage: replace_emphi.rb [options]"
  opts.on("-w", "--write", "Apply replacements in-place to files") { options[:write] = true }
  opts.on("-b", "--backup", "Create backups before writing") { options[:backup] = true }
  opts.on("--verify", "Verify standalone chapters and master book compile after changes") { options[:verify] = true }
  opts.on("-h", "--help", "Show help") do
    puts opts
    exit
  end
end.parse!

EmphiReplacer.new(options).run if __FILE__ == $PROGRAM_NAME
