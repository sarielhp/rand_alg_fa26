#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'optparse'

ROOT_DIR = File.expand_path('..', __dir__)

class DeflabelRemover
  DEFAULT_EXCLUDES = [
    %r{\Astyles/},
    %r{\bold_stuff/},
    %r{/backup/},
    %r{/disaster/},
    %r{\A\.git/}
  ].freeze

  def initialize(options = {}, targets = [])
    @options = options
    @targets = targets
    @root_dir = ROOT_DIR
  end

  def run
    files = find_tex_files
    if files.empty?
      puts 'No matching .tex files found.'
      return
    end

    total_files_changed = 0
    total_replacements = 0

    files.each do |file|
      rel_path = file.sub(%r{\A#{Regexp.escape(@root_dir)}/}, '')
      content = File.read(file)

      next unless content.include?('\deflabel')

      new_content, count = process_content(content)
      next if count.zero? || new_content == content

      total_files_changed += 1
      total_replacements += count

      if @options[:verbose]
        puts "\n=== #{rel_path} (#{count} replacements) ==="
        show_diff(content, new_content)
      else
        puts "#{rel_path}: #{count} replacements"
      end

      unless @options[:dry_run]
        File.write(file, new_content)
      end
    end

    mode_str = @options[:dry_run] ? ' (dry-run, no files modified)' : ''
    puts "\nFinished! #{total_replacements} occurrences replaced across #{total_files_changed} files#{mode_str}."
  end

  private

  def find_tex_files
    if @targets.empty?
      all_tex = Dir.glob(File.join(@root_dir, '**', '*.tex'), File::FNM_DOTMATCH)
      all_tex.reject! { |f| should_exclude?(f) } unless @options[:all]
      all_tex.sort
    else
      files = []
      @targets.each do |target|
        full_path = File.expand_path(target, @root_dir)
        if File.directory?(full_path)
          found = Dir.glob(File.join(full_path, '**', '*.tex'), File::FNM_DOTMATCH)
          found.reject! { |f| should_exclude?(f) } unless @options[:all]
          files.concat(found)
        elsif File.file?(full_path) && full_path.end_with?('.tex')
          files << full_path
        else
          warn "Warning: #{target} is not a valid .tex file or directory."
        end
      end
      files.uniq.sort
    end
  end

  def should_exclude?(file_path)
    rel_path = file_path.sub(%r{\A#{Regexp.escape(@root_dir)}/}, '')
    DEFAULT_EXCLUDES.any? { |pattern| rel_path =~ pattern }
  end

  def process_content(text)
    count = 0

    # 1. Normalize \begin{fragment}{\deflabel{...}} -> \begin{fragment}{...}
    updated = text.gsub(/\\begin\{fragment\}\s*\{\s*\\deflabel\{([^{}]+)\}\s*\}/) do
      count += 1
      "\\begin{fragment}{#{$1.strip}}"
    end

    # 2. Normalize \IncFragment{\deflabel{...}} -> \IncFragment{...}
    updated = updated.gsub(/\\IncFragment\s*\{\s*\\deflabel\{([^{}]+)\}\s*\}/) do
      count += 1
      "\\IncFragment{#{$1.strip}}"
    end

    # 3. Handle any remaining \deflabel{...} (e.g. comments, partial fragments)
    updated = updated.gsub(/\\deflabel\{([^{}]+)\}/) do
      count += 1
      $1.strip
    end

    [updated, count]
  end

  def show_diff(original, modified)
    orig_lines = original.lines
    mod_lines = modified.lines
    orig_lines.each_with_index do |line, idx|
      next if line == mod_lines[idx]

      puts "  Line #{idx + 1}:"
      puts "    - #{line.strip}"
      puts "    + #{mod_lines[idx].strip}"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {
    dry_run: false,
    verbose: false,
    all: false
  }

  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: tools/remove_deflabel.rb [options] [path1 path2 ...]'

    opts.on('-n', '--dry-run', 'Show what would be changed without modifying files') do
      options[:dry_run] = true
    end

    opts.on('-v', '--verbose', 'Show line-by-line diffs for each change') do
      options[:verbose] = true
    end

    opts.on('-a', '--all', 'Include backup and disaster directories (default: excluded)') do
      options[:all] = true
    end

    opts.on('-h', '--help', 'Show this help message') do
      puts opts
      exit
    end
  end

  parser.parse!(ARGV)
  DeflabelRemover.new(options, ARGV).run
end
