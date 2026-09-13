#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "json"

ROOT_DIR = File.expand_path("..", __dir__)

class ChapterMacroExtractor
  MacroLoc = Struct.new(
    :file,
    :rel_path,
    :start_line,
    :end_line,
    :command,
    :name,
    :args,
    :body,
    :raw_text,
    keyword_init: true
  )

  def initialize(options = {})
    @options = options
    @locations = []
  end

  def run
    collect_and_parse
    if @options[:json]
      print_json
    else
      print_report
    end
  end

  private

  def collect_and_parse
    patterns = [
      File.join(ROOT_DIR, "[0-9][0-9]_*/**/*.tex")
    ]

    files = Dir.glob(patterns).reject do |f|
      f.include?("/junk/") || f.include?("/backup/") ||
        f.include?("/old/") || f.include?("/old_stuff/") ||
        f.include?("/refs/") || f.include?("/orig/") ||
        f.include?("/ai_notes/") || f.end_with?(".bak")
    end.sort

    files.each { |f| parse_file(f) }
  end

  def parse_file(file_path)
    lines = File.readlines(file_path)
    rel_path = file_path.sub(ROOT_DIR + "/", "")
    i = 0

    while i < lines.size
      line = lines[i]
      stripped = line.strip

      # Skip whole-line comments
      if stripped.start_with?("%")
        i += 1
        next
      end

      # Match \newcommand(*) or \providecommand(*)
      # Handles both \newcommand{\foo} and \newcommand\foo
      if line =~ /\\(newcommand\*?|providecommand\*?)\s*(?:\{\s*\\([a-zA-Z@]+)\s*\}|\\([a-zA-Z@]+)\b)/
        cmd = $1
        name = $2 || $3
        start_line = i + 1

        # Count brace depth to capture multiline definitions
        open_braces = line.count("{") - line.count("}")
        raw_lines = [line]
        curr = i

        while open_braces > 0 && curr + 1 < lines.size
          curr += 1
          raw_lines << lines[curr]
          open_braces += lines[curr].count("{") - lines[curr].count("}")
        end

        end_line = curr + 1
        raw_text = raw_lines.join
        i = curr

        # Parse arguments count if present e.g. [2][default]
        args_count = 0
        if raw_text =~ /\\(?:newcommand\*?|providecommand\*?)\s*(?:\{\s*\\[a-zA-Z@]+\s*\}|\\[a-zA-Z@]+\b)\s*\[(\d+)\]/
          args_count = $1.to_i
        end

        @locations << MacroLoc.new(
          file: file_path,
          rel_path: rel_path,
          start_line: start_line,
          end_line: end_line,
          command: cmd,
          name: name,
          args: args_count,
          raw_text: raw_text.strip
        )
      end
      i += 1
    end
  end

  def is_body_macro?(loc)
    # Check if definition is a lemma/theorem/clause body to keep in chapter
    return true if loc.name =~ /^(?:Lemma|Theorem|Claim|Fact|Proof|TalagrandBody|NotCCCMode|CCCMode)/
    return true if loc.raw_text.length > 120 && loc.raw_text =~ /[a-z]{3,}\s+[a-z]{3,}\s+[a-z]{3,}/
    false
  end

  def print_report
    shorthands = @locations.reject { |l| is_body_macro?(l) }
    bodies = @locations.select { |l| is_body_macro?(l) }

    puts "================================================================="
    puts " Chapter-Defined Macros Audit Report"
    puts "================================================================="
    puts " Total definitions found in chapters       : #{@locations.size}"
    puts " True shorthand commands (to move)         : #{shorthands.size}"
    puts " Lemma / text bodies (to keep in-place)    : #{bodies.size}"
    puts " Chapters containing definitions           : #{@locations.map { |l| l.rel_path.split('/').first }.uniq.size}"
    puts "=================================================================\n\n"

    target_list = if @options[:shorthands]
                    shorthands
                  elsif @options[:bodies]
                    bodies
                  else
                    @locations
                  end

    by_chapter = target_list.group_by { |l| l.rel_path.split("/").first }

    by_chapter.keys.sort.each do |chap|
      locs = by_chapter[chap]
      puts "Chapter #{chap} (#{locs.size} definitions):"
      puts "-" * 80
      locs.each do |l|
        range = l.start_line == l.end_line ? "L#{l.start_line}" : "L#{l.start_line}-L#{l.end_line}"
        cat = is_body_macro?(l) ? "[BODY]" : "[SHORTHAND]"
        snippet = l.raw_text.gsub(/\s+/, " ")
        snippet = snippet.length > 65 ? "#{snippet[0..62]}..." : snippet
        puts format("  %-12s  %-11s  \\%-20s  [%s]  %s", range, cat, l.name, l.command, snippet)
      end
      puts ""
    end
  end

  def print_json
    payload = @locations.map do |l|
      {
        file: l.file,
        relative_path: l.rel_path,
        start_line: l.start_line,
        end_line: l.end_line,
        command: l.command,
        name: l.name,
        is_body: is_body_macro?(l),
        arguments: l.args,
        raw_text: l.raw_text
      }
    end
    puts JSON.pretty_generate(payload)
  end
end

options = { json: false, shorthands: false, bodies: false }
OptionParser.new do |opts|
  opts.banner = "Usage: extract_chapter_macros.rb [options]"
  opts.on("--shorthands", "Show only true shorthand command macros") { options[:shorthands] = true }
  opts.on("--bodies", "Show only lemma/theorem body macros") { options[:bodies] = true }
  opts.on("--json", "Output findings in JSON format") { options[:json] = true }
  opts.on("-h", "--help", "Show help") do
    puts opts
    exit
  end
end.parse!

ChapterMacroExtractor.new(options).run if __FILE__ == $PROGRAM_NAME
