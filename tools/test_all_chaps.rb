#!/usr/bin/env ruby
# frozen_string_literal: true

require "etc"
require "open3"
require "optparse"
require "time"

ROOT_DIR = File.expand_path("..", __dir__)
BOOK_TEX = File.join(ROOT_DIR, "book.tex")

LATEX_ENV_VARS = %w[
  BIBINPUTS
  BSTINPUTS
  TEXINPUTS
  PDFTEXINPUTS
  XETEXINPUTS
  LUATEXINPUTS
  LUAINPUTS
  BBLINPUTS
  TEXMFOUTPUT
  TEXFORMATS
  TEXFONTS
  TFMFONTS
  T1FONTS
  OFMFONTS
  AFMFONTS
  TTFONTS
  OPENTYPEFONTS
  MFINPUTS
  MPINPUTS
  TEXPICTS
  TEXDOCS
  TEXSOURCES
  TEXPOOL
  INDEXSTYLE
  BIBTEX_PREFIX
  LATEXOPTS
  LATEXOPTIONS
  PDFBIN
  PDFBINONLY
  LATEX_ENGINE
  TEXMFHOME
  TEXMFCNF
  TEXMFCONFIG
  TEXMFVAR
  TEXMFCACHE
].freeze

def sanitize_environment!
  wiped = []
  LATEX_ENV_VARS.each do |var|
    if ENV.key?(var)
      wiped << "#{var}=#{ENV[var]}"
      ENV.delete(var)
    end
  end
  ENV.keys.each do |key|
    if key =~ /\A(?:TEX|BIB|BST|LUA|MF|MP)INPUTS/i || key =~ /\ATEXMF/i
      wiped << "#{key}=#{ENV[key]}" unless wiped.any? { |w| w.start_with?("#{key}=") }
      ENV.delete(key)
    end
  end
  wiped
end

def spawn_env_hash
  hash = LATEX_ENV_VARS.each_with_object({}) { |v, h| h[v] = nil }
  ENV.keys.each do |k|
    hash[k] = nil if k =~ /\A(?:TEX|BIB|BST|LUA|MF|MP)INPUTS/i || k =~ /\ATEXMF/i
  end
  hash
end

def verify_sanitization!(clean_env)
  probe_keys = %w[TEXINPUTS BIBINPUTS BSTINPUTS TEXMFHOME TEXMFCNF]
  probe_cmd = probe_keys.map { |k| "#{k}:[$#{k}]" }.join(" ")
  out, _, st = Open3.capture3(clean_env, "bash", "-c", "echo #{probe_cmd}")
  expected = probe_keys.map { |k| "#{k}:[]" }.join(" ")
  unless st.success? && out.strip == expected
    warn "ERROR: Environment variable sanitation verification failed! Got: #{out.strip}"
    exit 1
  end
  true
end

def parse_chapters
  chapters = []
  File.foreach(BOOK_TEX) do |line|
    if line =~ /^\s*\\InputChap\{([^}]+)\}\s*\{([^}]+)\}/
      chapters << { dir: $1.strip, file: $2.strip }
    end
  end
  chapters
end

def filter_chapters(chapters, filters)
  return chapters if filters.empty?

  chapters.select do |chap|
    filters.any? do |f|
      chap[:dir].include?(f) || chap[:file].include?(f)
    end
  end
end

def build_l_command(chap, options)
  cmd = ["l", "-no-env", "-s"]
  cmd << "-u" if options[:quick]
  cmd += ["-e", options[:engine]] if options[:engine]
  cmd << chap[:file]
  cmd
end

def test_chapter(chap, options, clean_env)
  chap_dir = File.join(ROOT_DIR, chap[:dir])
  tex_file = chap[:file]

  return { success: false, error: "Directory #{chap[:dir]} not found", elapsed: 0.0 } unless Dir.exist?(chap_dir)

  tex_path = File.join(chap_dir, tex_file)
  return { success: false, error: "File #{tex_path} not found", elapsed: 0.0 } unless File.exist?(tex_path)

  cmd = build_l_command(chap, options)
  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  stdout, stderr, status = Open3.capture3(clean_env, *cmd, chdir: chap_dir)
  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0

  errors = 0
  warnings = 0
  if stdout =~ /Errors:\s*(\d+),\s*Warnings:\s*(\d+)/i
    errors = $1.to_i
    warnings = $2.to_i
  end

  success = status.success? && errors.zero?
  err_msg = nil
  unless success
    err_msg = if errors > 0
                "#{errors} LaTeX error(s), #{warnings} warning(s)"
              else
                "Exited with code #{status.exitstatus}"
              end
    err_log = File.join(chap_dir, "junk", "err_xelatex")
    if File.exist?(err_log)
      log_tail = File.readlines(err_log).last(15).map(&:chomp).join("\n")
      err_msg += "\n    Last log lines:\n    " + log_tail.gsub("\n", "\n    ")
    end
  end

  {
    success: success,
    exit_code: status.exitstatus,
    errors: errors,
    warnings: warnings,
    elapsed: elapsed,
    error: err_msg,
    stdout: stdout,
    stderr: stderr
  }
end

def run_suite(chapters, options)
  wiped = sanitize_environment!
  clean_env = spawn_env_hash
  verify_sanitization!(clean_env)

  puts "=" * 60
  puts "Standalone LaTeX Test Suite"
  puts "=" * 60
  puts "Environment Sanitization:"
  puts "  - #{LATEX_ENV_VARS.size} TeX/LaTeX/Kpathsea variables neutralized in runner and child processes."
  if wiped.any?
    puts "  - Wiped from caller environment: #{wiped.map { |w| w.split('=').first }.join(', ')}"
  end
  puts "  - Verified child spawn environment: TEXINPUTS, BIBINPUTS, BSTINPUTS, TEXMFHOME are empty/unset."
  puts "Execution:"
  puts "  - Compiler command: #{options[:quick] ? 'l -no-env -s -u' : 'l -no-env -s'}"
  puts "  - Concurrency: #{options[:jobs]} parallel workers"
  puts "  - Target Chapters: #{chapters.size}"
  puts "=" * 60
  puts ""

  results = []
  mutex = Mutex.new
  queue = Queue.new
  chapters.each_with_index { |chap, idx| queue << [chap, idx] }

  t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  threads = Array.new(options[:jobs]) do
    Thread.new do
      until queue.empty?
        begin
          chap, idx = queue.pop(true)
        rescue ThreadError
          break
        end

        res = test_chapter(chap, options, clean_env)
        mutex.synchronize do
          target = "#{chap[:dir]}/#{chap[:file]}"
          time_str = format("[%.1fs]", res[:elapsed])
          if res[:success]
            warn_str = res[:warnings] > 0 ? "#{res[:warnings]} warn" : "clean"
            status_str = format("PASS (%s) %s", warn_str, time_str)
          else
            status_str = format("FAIL (%s) %s", res[:error], time_str)
          end
          puts format("[%2d/%2d] %-42s ... %s", idx + 1, chapters.size, target, status_str)
          results << { chap: chap, res: res, idx: idx }
        end
      end
    end
  end

  threads.each(&:join)
  total_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t_start
  results.sort_by! { |r| r[:idx] }

  passed = results.count { |r| r[:res][:success] }
  failed = results.reject { |r| r[:res][:success] }

  puts "\n" + ("=" * 60)
  puts "Standalone Verification Summary:"
  puts format("  Total Chapters:  %d", chapters.size)
  puts format("  Passed:          %d", passed)
  puts format("  Failed:          %d", failed.size)
  puts format("  Total Time:      %.2fs", total_time)
  puts ("=" * 60)

  if failed.any?
    puts "\nFailed chapters:"
    failed.each do |f|
      puts "  - #{f[:chap][:dir]}/#{f[:chap][:file]}:"
      puts "    #{f[:res][:error]}"
    end
    exit 1
  else
    puts "\nAll #{chapters.size} chapters compiled successfully as standalones with sanitized environment!"
    exit 0
  end
end

def main
  options = {
    jobs: [Etc.nprocessors, 8].min,
    quick: false,
    engine: nil
  }

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: test_all_chaps.rb [options] [chapter_filter ...]"
    opts.separator ""
    opts.separator "Options:"
    opts.on("-j", "--jobs N", Integer, "Number of parallel jobs (default: #{options[:jobs]})") { |v| options[:jobs] = v }
    opts.on("-u", "--quick", "Run single-pass compilation (-u) for faster checks") { options[:quick] = true }
    opts.on("-f", "--full", "Run full multi-pass compilation with bib/biber (default)") { options[:quick] = false }
    opts.on("-e", "--engine ENGINE", String, "LaTeX engine override (passed to l)") { |v| options[:engine] = v }
    opts.on("-h", "--help", "Show this help message") do
      puts opts
      exit 0
    end
  end

  filters = parser.parse(ARGV)
  chapters = filter_chapters(parse_chapters, filters)

  if chapters.empty?
    warn "No matching chapters found."
    exit 1
  end

  run_suite(chapters, options)
end

main if __FILE__ == $PROGRAM_NAME
