#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "fileutils"
require "open3"

ROOT_DIR = File.expand_path("..", __dir__)

class MhStripper
  def initialize(options = {})
    @options = options
    @modified_files = 0
    @total_mh_removed = 0
    @changes = []
  end

  def run
    target_files = collect_target_files
    puts "Scanning #{target_files.size} LaTeX source files for \\Mh{...} in macro definitions..."

    target_files.each do |f|
      process_file(f)
    end

    print_summary

    if @options[:write] && @total_mh_removed > 0
      if @options[:sync_html]
        sync_html_macros
      end
      if @options[:verify]
        verify_builds
      end
    end
  end

  private

  def collect_target_files
    prefix_files = [
      File.join(ROOT_DIR, "styles/prefix_latex.tex"),
      File.join(ROOT_DIR, "styles/prefix_lwarp.tex"),
      File.join(ROOT_DIR, "styles/mathjax_macros.tex")
    ].select { |f| File.exist?(f) }

    chapter_files = Dir.glob(File.join(ROOT_DIR, "[0-9][0-9]_*/**/*.tex")).reject do |f|
      f.include?("/junk/") || f.include?("/backup/") ||
        f.include?("/old/") || f.include?("/old_stuff/") ||
        f.include?("/refs/") || f.include?("/orig/") ||
        f.include?("/ai_notes/") || f.end_with?(".bak")
    end

    (prefix_files + chapter_files.sort)
  end

  def strip_mh(text)
    result = text.dup
    loop do
      idx = result.index(/\\Mh\s*\{/)
      break unless idx

      open_idx = result.index("{", idx)
      curr = open_idx + 1
      depth = 1
      len = result.length

      while curr < len && depth > 0
        char = result[curr]
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
        inner = result[(open_idx + 1)...(curr - 1)]
        result = result[0...idx] + inner + (result[curr..-1] || "")
      else
        break
      end
    end
    result
  end

  def process_file(file_path)
    rel_path = file_path.sub(ROOT_DIR + "/", "")
    content = File.read(file_path)
    lines = content.lines
    modified = false
    i = 0
    file_changes = []

    while i < lines.size
      line = lines[i]
      stripped = line.strip

      # Check if line initiates a macro definition
      if stripped =~ /\\(?:newcommand\*?|providecommand\*?|renewcommand\*?|def|gdef)\s*(?:\{\s*\\([a-zA-Z@]+)\s*\}|\\([a-zA-Z@]+)\b)/
        name = $1 || $2

        # Exclude the actual definition/let of \Mh itself
        if name == "Mh"
          i += 1
          next
        end

        s = i
        open_b = line.count("{") - line.count("}")
        while open_b > 0 && i + 1 < lines.size
          i += 1
          open_b += lines[i].count("{") - lines[i].count("}")
        end

        raw_def = lines[s..i].join
        if raw_def.include?("\\Mh{")
          new_def = strip_mh(raw_def)
          count = raw_def.scan(/\\Mh\s*\{/).size

          file_changes << {
            line: s + 1,
            macro: name,
            count: count,
            old: raw_def.strip,
            new: new_def.strip
          }

          lines[s..i] = new_def.lines
          i = s + new_def.lines.size - 1
          modified = true
          @total_mh_removed += count
        end
      end
      i += 1
    end

    return unless modified

    @modified_files += 1
    @changes << { file: rel_path, full_path: file_path, changes: file_changes, new_content: lines.join }

    if @options[:write]
      backup_file(file_path) if @options[:backup]
      File.write(file_path, lines.join)
    end
  end

  def backup_file(file_path)
    backup_dir = File.join(ROOT_DIR, "old_stuff/backup/strip_mh_#{Time.now.strftime('%Y%m%d_%H%M%S')}")
    FileUtils.mkdir_p(backup_dir)
    dest = File.join(backup_dir, File.basename(file_path))
    FileUtils.cp(file_path, dest)
  end

  def print_summary
    puts "\n" + "=" * 80
    puts " \\Mh{...} Removal Analysis Summary"
    puts "=" * 80
    puts " Files with \\Mh in macro definitions : #{@modified_files}"
    puts " Total \\Mh{...} instances found       : #{@total_mh_removed}"
    mode = @options[:write] ? "APPLIED (In-place written to disk)" : "DRY-RUN (No files modified)"
    puts " Mode                                 : #{mode}"
    puts "=" * 80 + "\n\n"

    @changes.each do |fc|
      puts "[#{fc[:file]}] (#{fc[:changes].size} macro definitions modified):"
      fc[:changes].each do |c|
        puts format("  L%-4d \\%-20s (-%d \\Mh):", c[:line], c[:macro], c[:count])
        puts "    - #{c[:old].gsub(/\s+/, ' ')[0..80]}"
        puts "    + #{c[:new].gsub(/\s+/, ' ')[0..80]}"
      end
      puts ""
    end

    unless @options[:write]
      puts "To apply these changes, run with: -w (or --write)"
      puts "To also verify compilation, run with: -w --verify"
    end
  end

  def sync_html_macros
    script = File.join(ROOT_DIR, "tools/organize_html_and_macros.rb")
    if File.exist?(script)
      puts "\n--- Updating MathJax / HTML macro dictionary ---"
      system("ruby", script)
    end
  end

  def verify_builds
    puts "\n--- Verifying standalone chapters & master book builds ---"
    test_script = File.join(ROOT_DIR, "tools/test_chapters_standalone")
    chaps_ok = system(test_script, "-u", "-j", "8")
    unless chaps_ok
      warn "ERROR: Standalone chapters compilation failed after stripping \\Mh!"
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

options = { write: false, backup: false, verify: false, sync_html: true }
OptionParser.new do |opts|
  opts.banner = "Usage: strip_mh_from_macros.rb [options]"
  opts.on("-w", "--write", "Apply changes in-place to files") { options[:write] = true }
  opts.on("-b", "--backup", "Create backups before writing") { options[:backup] = true }
  opts.on("--verify", "Verify compilation of standalone chapters and book after writing") { options[:verify] = true }
  opts.on("--[no-]sync-html", "Recompile MathJax and HTML macros after writing (default: true)") { |s| options[:sync_html] = s }
  opts.on("-h", "--help", "Show help") do
    puts opts
    exit
  end
end.parse!

MhStripper.new(options).run if __FILE__ == $PROGRAM_NAME
