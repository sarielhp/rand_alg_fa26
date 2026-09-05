#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'optparse'
require 'pathname'

options = {
  tex_file: nil,
  dest_dir: 'duplicate',
  dry_run: false,
  verbose: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on('-t', '--tex FILE', 'Path to tex file to search (default: books.tex or book.tex)') do |v|
    options[:tex_file] = v
  end

  opts.on('-d', '--dest DIR', 'Destination directory for unreferenced directories (default: duplicate)') do |v|
    options[:dest_dir] = v
  end

  opts.on('-n', '--dry-run', 'Perform a trial run with no changes made') do
    options[:dry_run] = true
  end

  opts.on('-v', '--verbose', 'Enable verbose output') do
    options[:verbose] = true
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit 0
  end
end.parse!

# Resolve tex file: use specified, or find books.tex / book.tex
tex_file = options[:tex_file]
if tex_file.nil?
  tex_file = if File.file?('books.tex')
               'books.tex'
             elsif File.file?('book.tex')
               'book.tex'
             else
               'books.tex' # fallback default
             end
end

unless File.file?(tex_file)
  warn "Error: LaTeX file '#{tex_file}' not found."
  exit 1
end

dest_dir = options[:dest_dir]
dry_run = options[:dry_run]
verbose = options[:verbose]

# Read content of LaTeX file
tex_content = File.read(tex_file)

# Scan entries matching %02d_<text> pattern
# Matches directory names with exactly 2 leading digits followed by '_' and text
matching_dirs = Dir.children('.')
                   .select { |entry| File.directory?(entry) && entry =~ /\A\d{2}_.+/ }
                   .reject { |entry| entry == dest_dir }
                   .sort

if matching_dirs.empty?
  puts 'No matching directories found with format %02d_<text>/'
  exit 0
end

puts "Found #{matching_dirs.size} directory/directories matching '%02d_<text>/'."
puts "Checking against '#{tex_file}'..."
puts 'Dry run mode active - no directories will actually be moved.' if dry_run
puts '-' * 60

moved_count = 0
kept_count = 0

matching_dirs.each do |dir|
  # Check if directory name (without trailing slash) appears in tex file
  if tex_content.include?(dir)
    kept_count += 1
    puts "  [KEPT] #{dir} (found in #{tex_file})" if verbose
  else
    moved_count += 1
    target_path = File.join(dest_dir, dir)
    if dry_run
      puts "  [WOULD MOVE] #{dir} -> #{target_path}"
    else
      FileUtils.mkdir_p(dest_dir) unless Dir.exist?(dest_dir)
      if File.exist?(target_path)
        warn "  [WARNING] Target already exists: #{target_path}. Skipping."
      else
        FileUtils.mv(dir, target_path)
        puts "  [MOVED] #{dir} -> #{target_path}"
      end
    end
  end
end

puts '-' * 60
puts "Summary: #{matching_dirs.size} scanned | #{kept_count} kept | #{moved_count} #{dry_run ? 'would be moved' : 'moved to ' + dest_dir + '/'}"
