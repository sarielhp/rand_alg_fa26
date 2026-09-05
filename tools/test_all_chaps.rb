#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "optparse"

ROOT_DIR = File.expand_path("..", __dir__)
BOOK_TEX = File.join(ROOT_DIR, "book.tex")

def parse_chapters
  chapters = []
  File.foreach(BOOK_TEX) do |line|
    if line =~ /\\InputChap\{([^}]+)\}\s*\{([^}]+)\}/
      chapters << { dir: $1.strip, file: $2.strip }
    end
  end
  chapters
end

def test_chapter(chap)
  chap_dir = File.join(ROOT_DIR, chap[:dir])
  tex_file = chap[:file]

  return { success: false, error: "Directory #{chap[:dir]} not found" } unless Dir.exist?(chap_dir)

  tex_path = File.join(chap_dir, tex_file)
  return { success: false, error: "File #{tex_path} not found" } unless File.exist?(tex_path)

  cmd = ["xelatex", "-interaction=nonstopmode", tex_file]
  stdout, stderr, status = Open3.capture3(*cmd, chdir: chap_dir)

  {
    success: status.success?,
    exit_code: status.exitstatus,
    error: status.success? ? nil : "Exited with #{status.exitstatus}"
  }
end

def main
  jobs = 4
  OptionParser.new do |opts|
    opts.banner = "Usage: test_all_chaps.rb [options]"
    opts.on("-j", "--jobs N", Integer, "Number of parallel jobs (default: 4)") { |v| jobs = v }
  end.parse!

  chapters = parse_chapters
  puts "Found #{chapters.size} chapters in book.tex. Running with #{jobs} workers..."

  results = []
  mutex = Mutex.new
  queue = Queue.new
  chapters.each_with_index { |chap, idx| queue << [chap, idx] }

  threads = Array.new(jobs) do
    Thread.new do
      until queue.empty?
        begin
          chap, idx = queue.pop(true)
        rescue ThreadError
          break
        end

        res = test_chapter(chap)
        mutex.synchronize do
          target = "#{chap[:dir]}/#{chap[:file]}"
          status_str = res[:success] ? "PASS" : "FAIL (#{res[:error]})"
          puts format("[%2d/%2d] %-40s ... %s", idx + 1, chapters.size, target, status_str)
          results << { chap: chap, res: res, idx: idx }
        end
      end
    end
  end

  threads.each(&:join)
  results.sort_by! { |r| r[:idx] }

  passed = results.count { |r| r[:res][:success] }
  failed = results.reject { |r| r[:res][:success] }

  puts "\n=========================================="
  puts "Results: #{passed}/#{chapters.size} passed."
  if failed.any?
    puts "Failed chapters:"
    failed.each do |f|
      puts "  - #{f[:chap][:dir]}/#{f[:chap][:file]}: #{f[:res][:error]}"
    end
    exit 1
  else
    puts "All chapters compiled successfully!"
    exit 0
  end
end

main if __FILE__ == $PROGRAM_NAME
