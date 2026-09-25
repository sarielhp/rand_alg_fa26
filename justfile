# Root directory and invocation directory
root_dir := justfile_directory()
inv_dir := invocation_directory()

# Compile the current chapter (if inside a chapter directory) or master book (if at root)
default *args:
    #!/usr/bin/env ruby
    require 'pathname'

    root_dir = "{{root_dir}}"
    inv_dir = "{{inv_dir}}"
    rel_path = Pathname.new(inv_dir).relative_path_from(Pathname.new(root_dir)).to_s

    # Invocation from repository root
    if rel_path == '.'
      puts "==> [Root] Syncing fragments and compiling book.tex..."
      sync_bin = File.join(root_dir, 'tools', 'sync_fragments')
      system(sync_bin) || exit(1)
      exec('l', 'book.tex', *ARGV)
    end

    # Check for invocation from a subdirectory of a chapter directory
    parts = rel_path.split(File::SEPARATOR)
    if parts.size > 1
      abort "ERROR: 'just' cannot be run from a subdirectory ('#{rel_path}'). Please run directly from the chapter directory ('#{parts.first}')."
    end

    chap_dir = parts.first
    stem = chap_dir.sub(/\A\d+_/, '')

    # 1. Invoke fragment sync script from root
    sync_bin = File.join(root_dir, 'tools', 'sync_fragments')
    unless system(sync_bin)
      abort "ERROR: Fragment synchronization failed. Aborting compilation."
    end

    # 2. Resolve target .tex file in the chapter directory
    all_tex = Dir.glob(File.join(inv_dir, '*.tex')).map { |f| File.basename(f) }
    non_prefix = all_tex.reject { |f| f == 'prefix.tex' }

    # Rule 1: Unique file that matches the directory name
    matching = non_prefix.select { |f| f == "#{stem}.tex" || f == "#{chap_dir}.tex" }
    target = nil

    if matching.size == 1
      target = matching.first
    elsif non_prefix.size == 1
      # Rule 2: Unique latex file in this directory that is not prefix.tex
      target = non_prefix.first
    else
      # Rule 3: Otherwise, stop with an error
      if non_prefix.empty?
        abort "ERROR: No suitable .tex file found in '#{chap_dir}'."
      else
        abort "ERROR: Ambiguous .tex files in '#{chap_dir}' (#{non_prefix.join(', ')}). Cannot determine unique chapter file."
      end
    end

    # 3. Run l on the resolved file in the chapter directory
    Dir.chdir(inv_dir)
    puts "==> Compiling #{chap_dir}/#{target}..."
    exec('l', target, *ARGV)

# Compile master book (with automatic fragment sync)
book *args:
    @./tools/sync_fragments
    l book.tex {{args}}

# Synchronize LaTeX fragments into fragment/
fragments *args:
    ./tools/sync_fragments {{args}}

# Synchronize chapter and page numbers (\ChapterNumPage) across all chapters
sync-numbers *args:
    ./tools/sync_chapters_info {{args}}

# Synchronize both fragments and chapter numbers
sync: fragments sync-numbers

# Clean build artifacts using book.fls (skip recompilation by default)
clean flags="--skip-compile":
    ./tools/clean {{flags}}

# Deep clean (recompile with -recorder then clean all junk)
clean-deep:
    ./tools/clean

# Run standalone compilation tests across chapters (default: fast single pass)
test *args="-u":
    ./tools/test_chapters_standalone {{args}}

# Compile standalone PDFs for all or specified chapters
pdfs *chaps:
    ./tools/gen_pdf_all_chapters {{chaps}}

# Audit unused LaTeX macros across the codebase
audit-macros:
    ./tools/detect_unused_macros.rb
