#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'optparse'
require 'fileutils'
require 'time'

ROOT_DIR = File.expand_path('..', __dir__)
BOOK_TEX = File.join(ROOT_DIR, 'book.tex')

class NumberSyncer
  TAG_PREFIX = 'pre-sync-'

  def initialize(options = {})
    @options = options
    @root_dir = ROOT_DIR
  end

  def run
    if @options[:revert]
      revert_sync
    else
      sync_numbers
    end
  end

  private

  def sync_numbers
    puts '=== Synchronizing Chapter & Page Numbers ==='
    check_git_clean unless @options[:force] || @options[:dry_run]

    extracted_maps = run_xelatex_passes(@options[:passes] || 2)
    plan = plan_updates(extracted_maps)

    if plan.empty?
      puts 'All chapter and page numbers are already up to date! (0 files changed)'
      return
    end

    print_plan_summary(plan)
    return if @options[:dry_run]

    tag_name = create_checkpoint_tag
    apply_updates(plan)
    commit_updates(plan, tag_name)
    puts "\nDone! To revert these changes, run: tools/sync_numbers.rb --revert"
  end

  def check_git_clean
    stdout, _, status = Open3.capture3('git', 'status', '--porcelain', chdir: @root_dir)
    unless status.success?
      warn 'Error: Unable to check git status.'
      exit 1
    end

    dirty_lines = stdout.lines.reject { |l| l =~ /^\?\?\s/ }
    return if dirty_lines.empty?

    warn 'Error: Working tree has uncommitted modifications. Please commit or stash them first.'
    warn '       (Use --force to bypass this check).'
    exit 1
  end

  def run_xelatex_passes(passes)
    log_content = ''
    passes.times do |i|
      pass_num = i + 1
      print "Running XeLaTeX on book.tex (pass #{pass_num}/#{passes})... "
      $stdout.flush

      cmd = %w[xelatex -interaction=nonstopmode book.tex]
      stdout, stderr, status = Open3.capture3(*cmd, chdir: @root_dir)
      log_content = stdout + "\n" + stderr

      unless status.success?
        puts 'FAILED!'
        print_compile_error(log_content)
        exit 1
      end
      puts 'done.'
    end

    extract_mappings(log_content)
  end

  def print_compile_error(output)
    warn "\nError: XeLaTeX compilation failed with exit status non-zero."
    warn 'Last 25 lines of log output:'
    output.lines.last(25).each { |l| warn "  #{l}" }
  end

  def extract_mappings(log_content)
    # Match: CHAPTER_MAP: 01_intro/intro.tex => chap: 1, page: 1
    pattern = /CHAPTER_MAP:\s*(\S+)\s*=>\s*chap:\s*(\d+),\s*page:\s*(\d+)/
    mappings = {}

    log_content.scan(pattern) do |rel_path, chap, page|
      # rel_path might have trailing '=>' or punctuation attached
      clean_path = rel_path.sub(/=>.*$/, '').strip
      mappings[clean_path] = { chap: chap.to_i, page: page.to_i }
    end

    if mappings.empty?
      warn 'Warning: No CHAPTER_MAP entries were found in XeLaTeX output.'
      warn 'Verify that prefix.tex emits CHAPTER_MAP during book compilation.'
      exit 1
    end

    puts "Extracted #{mappings.size} chapter mappings from XeLaTeX."
    mappings
  end

  def plan_updates(mappings)
    plan = []

    mappings.each do |rel_path, target|
      abs_path = File.join(@root_dir, rel_path)
      unless File.exist?(abs_path)
        warn "Warning: Chapter file #{rel_path} not found on disk, skipping."
        next
      end

      content = File.read(abs_path)
      current = extract_current_cnp(content)

      if current.nil?
        plan << { path: rel_path, abs: abs_path, action: :insert, target: target, current: nil }
      elsif current[:chap] != target[:chap] || current[:page] != target[:page]
        plan << { path: rel_path, abs: abs_path, action: :update, target: target, current: current }
      end
    end

    plan
  end

  def extract_current_cnp(content)
    if content =~ /^\s*\\ChapterNumPage\{([^}]*)\}\{([^}]*)\}/
      { chap: $1.strip.to_i, page: $2.strip.to_i }
    end
  end

  def print_plan_summary(plan)
    puts "\nPlanned changes (#{plan.size} files):"
    plan.each do |item|
      case item[:action]
      when :insert
        puts "  + \e[32m#{item[:path]}\e[0m: insert \\ChapterNumPage{#{item[:target][:chap]}}{#{item[:target][:page]}}"
      when :update
        old_val = "\\ChapterNumPage{#{item[:current][:chap]}}{#{item[:current][:page]}}"
        new_val = "\\ChapterNumPage{#{item[:target][:chap]}}{#{item[:target][:page]}}"
        puts "  * \e[33m#{item[:path]}\e[0m: #{old_val} -> #{new_val}"
      end
    end
  end

  def create_checkpoint_tag
    tag_name = "#{TAG_PREFIX}#{Time.now.strftime('%Y%m%d-%H%M%S')}"
    system('git', 'tag', tag_name, chdir: @root_dir)
    tag_name
  end

  def apply_updates(plan)
    plan.each do |item|
      content = File.read(item[:abs])
      new_content = update_content(content, item[:target][:chap], item[:target][:page])

      tmp_file = "#{item[:abs]}.tmp"
      File.write(tmp_file, new_content)
      File.rename(tmp_file, item[:abs])
    end
  end

  def update_content(content, chap, page)
    cnp_line = "\\ChapterNumPage{#{chap}}{#{page}}"

    if content =~ /^\s*\\ChapterNumPage\{[^}]*\}\{[^}]*\}/
      # Update existing declaration in-place
      content.sub(/^\s*\\ChapterNumPage\{[^}]*\}\{[^}]*\}/, cnp_line)
    else
      # Intelligent insertion: place immediately before \Chapter
      content.sub(/^(\s*)\\Chapter\b/) do |match|
        indent = Regexp.last_match(1)
        "#{indent}#{cnp_line}\n#{match}"
      end
    end
  end

  def commit_updates(plan, tag_name)
    files_to_add = plan.map { |item| item[:path] }
    system('git', 'add', *files_to_add, chdir: @root_dir)

    msg = "Sync chapter and page numbers with book.tex [tag: #{tag_name}]"
    system('git', 'commit', '-m', msg, chdir: @root_dir)
    puts "\nCreated checkpoint: #{tag_name}"
    puts "Committed changes for #{plan.size} chapters to git."
  end

  def revert_sync
    tags = `git tag -l "#{TAG_PREFIX}*"`.lines.map(&:strip).sort
    if tags.empty?
      puts 'No sync checkpoints found to revert.'
      exit 1
    end

    latest_tag = tags.last
    puts "Reverting to latest checkpoint tag: #{latest_tag}..."

    system('git', 'reset', '--hard', latest_tag, chdir: @root_dir)
    system('git', 'tag', '-d', latest_tag, chdir: @root_dir)
    puts "Successfully rolled back repository state and removed tag #{latest_tag}."
  end
end

def main
  options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: tools/sync_numbers.rb [options]'
    opts.on('-n', '--dry-run', 'Show planned numbering updates without modifying files') { options[:dry_run] = true }
    opts.on('-p', '--passes N', Integer, 'Number of XeLaTeX compilation passes (default: 2)') { |v| options[:passes] = v }
    opts.on('-r', '--revert', 'Revert to the latest pre-sync checkpoint') { options[:revert] = true }
    opts.on('-f', '--force', 'Bypass clean git working tree check') { options[:force] = true }
    opts.on('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
  end.parse!

  syncer = NumberSyncer.new(options)
  syncer.run
end

main if __FILE__ == $PROGRAM_NAME
