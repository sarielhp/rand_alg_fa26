#!/usr/bin/env ruby
# frozen_string_literal: true
# ==============================================================================
# gen_html_all_chapters.rb
#
# Robust, parallel HTML generator for Randomized Algorithms lecture notes.
# Uses make4ht + MathJax with shared web styles and a central Table of Contents.
# ==============================================================================

require 'etc'
require 'fileutils'
require 'open3'
require 'optparse'
require 'pathname'
require 'thread'
require 'time'

ROOT_DIR    = File.expand_path('..', __dir__)
BOOK_TEX    = File.join(ROOT_DIR, 'book.tex')
STYLES_DIR  = File.join(ROOT_DIR, 'styles')
WEB_CFG     = File.join(STYLES_DIR, 'web.cfg')
WEB_CSS     = File.join(STYLES_DIR, 'web.css')
MATH_MACROS = File.join(STYLES_DIR, 'mathjax_macros.tex')
MASTER_AUX  = File.join(STYLES_DIR, 'master_labels.aux')
BOOK_AUX    = File.join(ROOT_DIR, 'junk', 'book.aux')

DEFAULT_OUTPUT_DIR = File.join(ROOT_DIR, 'html_site')

class HtmlBookBuilder
  def initialize(options = {})
    @options = options
    @output_dir = File.expand_path(options[:output_dir] || DEFAULT_OUTPUT_DIR, ROOT_DIR)
    @jobs = options[:jobs] || [Etc.nprocessors, 4].min
    @filters = options[:filters] || []
  end

  def run
    puts '=' * 60
    puts 'Randomized Algorithms — HTML Book Builder'
    puts '=' * 60
    puts "Root Directory:       #{ROOT_DIR}"
    puts "Output Directory:     #{@output_dir}"
    puts "Concurrency:          #{@jobs} workers"
    puts "Target Filters:       #{@filters.empty? ? 'All Chapters' : @filters.join(', ')}"
    puts '=' * 60

    ensure_prerequisites!
    ensure_master_labels!

    chapters = parse_chapters
    if chapters.empty?
      warn 'Error: No chapters found in book.tex'
      exit 1
    end

    master_labels = load_master_labels(chapters)

    # Always generate central TOC
    FileUtils.mkdir_p(@output_dir)
    copy_shared_assets!

    if @options[:toc_only]
      puts "\nGenerating Table of Contents..."
      generate_toc(chapters)
      puts "Done! Table of Contents written to: #{File.join(@output_dir, 'index.html')}"
      return
    end

    targets = filter_chapters(chapters, @filters)
    puts "\nCompiling #{targets.size} of #{chapters.size} chapters..."
    compile_chapters(targets, chapters, master_labels)
    copy_shared_assets!

    puts "\nUpdating Table of Contents..."
    generate_toc(chapters)

    puts '=' * 60
    puts "HTML build complete! Central TOC: file://#{@output_dir}/index.html"
    puts '=' * 60
  end

  private

  def ensure_prerequisites!
    unless File.exist?(WEB_CFG)
      warn "Warning: #{WEB_CFG} not found. Creating default web.cfg..."
      create_default_web_cfg!
    end

    unless File.exist?(MATH_MACROS)
      warn "Warning: #{MATH_MACROS} not found. Generating math macros..."
      generate_default_math_macros!
    end

    unless File.exist?(WEB_CSS)
      warn "Warning: #{WEB_CSS} not found. Creating default web.css..."
      create_default_web_css!
    end

    # Verify make4ht is available
    _, _, status = Open3.capture3('make4ht', '--version')
    unless status.success?
      warn 'Error: make4ht is not installed or not in PATH.'
      exit 1
    end
  end

  def parse_chapters
    chapters = []
    index = 0
    File.foreach(BOOK_TEX) do |line|
      if line =~ /^\s*\\InputChap\{([^}]+)\}\s*\{([^}]+)\}/
        dir = Regexp.last_match(1).strip
        file = Regexp.last_match(2).strip
        index += 1

        tex_path = File.join(ROOT_DIR, dir, file)
        title = "Chapter #{index}"
        num = index

        if File.exist?(tex_path)
          content = File.read(tex_path, encoding: 'utf-8')
          if content =~ /\\ChapterNumPage\{(\d+)\}/
            num = Regexp.last_match(1).to_i
          end
          if (raw_title = extract_chapter_title(content))
            title = raw_title
          end
        end

        chapters << {
          dir: dir,
          file: file,
          num: num,
          title: title,
          stem: File.basename(file, '.tex')
        }
      end
    end
    chapters
  end

  def extract_chapter_title(content)
    pos = content.index(/\\Chapter\*?\s*\{/)
    return nil unless pos

    open_brace = content.index('{', pos)
    return nil unless open_brace

    depth = 1
    i = open_brace + 1
    while i < content.length && depth > 0
      depth += 1 if content[i] == '{'
      depth -= 1 if content[i] == '}'
      i += 1
    end

    raw = content[(open_brace + 1)...(i - 1)]
    raw.gsub(/[{}]/, '').gsub(/\\(?:xspace|relax)/, '').strip
  end

  def extract_balanced_braces(str, start_pos)
    idx = str.index('{', start_pos)
    return nil unless idx

    depth = 1
    i = idx + 1
    while i < str.length && depth > 0
      depth += 1 if str[i] == '{'
      depth -= 1 if str[i] == '}'
      i += 1
    end
    str[(idx + 1)...(i - 1)]
  end

  def ensure_master_labels!
    if File.exist?(BOOK_AUX) && (!File.exist?(MASTER_AUX) || File.mtime(BOOK_AUX) > File.mtime(MASTER_AUX))
      aux_content = File.read(BOOK_AUX)
      labels = []
      aux_content.each_line do |line|
        labels << line if line =~ /^\\newlabel\{/
      end
      File.write(MASTER_AUX, labels.join)
    end
  end

  def load_master_labels(all_chapters)
    labels = {}
    return labels unless File.exist?(MASTER_AUX)

    chap_by_num = all_chapters.each_with_object({}) { |c, h| h[c[:num]] = c }
    current_chap = 0

    File.read(MASTER_AUX).each_line do |line|
      if line =~ /\\newlabel\{refsegment:0*(\d+)\}/
        current_chap = Regexp.last_match(1).to_i
      elsif line =~ /^\\newlabel\{([^}]+)\}/
        lbl = Regexp.last_match(1)
        next if lbl =~ /^refsegment:/

        chap_info = chap_by_num[current_chap]
        after_name = line.index('}', line.index(lbl)) + 1
        inner_block = extract_balanced_braces(line, after_name)
        clean_num = ''
        title = ''
        if inner_block
          num = extract_balanced_braces(inner_block, 0)
          clean_num = num ? num.gsub(/[{}]/, '') : ''
          # 3rd param is title
          pos2 = inner_block.index('{', inner_block.index('{', 0) + 1)
          if pos2
            pos3 = inner_block.index('{', pos2 + 1)
            title = extract_balanced_braces(inner_block, pos3) || '' if pos3
          end
        end

        info = {
          label: lbl,
          chap_num: current_chap,
          chap_dir: chap_info ? chap_info[:dir] : nil,
          num: clean_num,
          title: title.gsub(/[{}]/, '').gsub(/\\(?:xspace|relax)/, '').strip
        }
        labels[lbl] = info
        labels[lbl.gsub(':', '_')] = info
      end
    end
    if labels['theo:Chebyshev:inequality']
      cheby_info = labels['theo:Chebyshev:inequality'].dup
      labels['theo:Chebychev:inequality'] = cheby_info
      labels['theo_Chebychev_inequality'] = cheby_info
    end
    if labels['lemma:dominating:shitfs']
      shitfs_info = labels['lemma:dominating:shitfs'].dup
      labels['lemma:dominating:shifts'] = shitfs_info
      labels['lemma_dominating_shifts'] = shitfs_info
    end
    # Build alphanumeric index so variations in underscores/colons/braces match
    alpha_map = {}
    labels.each do |k, v|
      alpha = k.to_s.downcase.gsub(/[^a-z0-9]/, '')
      alpha_map[alpha] = v unless alpha.empty?
    end
    labels.merge!(alpha_map)
    labels
  end

  def filter_chapters(chapters, filters)
    return chapters if filters.empty?

    chapters.select do |chap|
      filters.any? do |f|
        chap[:dir].include?(f) || chap[:file].include?(f) || chap[:num].to_s == f
      end
    end
  end

  def copy_shared_assets!
    dest_styles = File.join(@output_dir, 'styles')
    FileUtils.mkdir_p(dest_styles)
    FileUtils.cp(WEB_CSS, File.join(dest_styles, 'web.css')) if File.exist?(WEB_CSS)
    duck_png = File.join(STYLES_DIR, 'qed_duck-.png')
    if File.exist?(duck_png)
      FileUtils.cp(duck_png, File.join(dest_styles, 'qed_duck-.png'))
      FileUtils.rm_f(duck_png)
    end
  end

  def compile_chapters(targets, all_chapters, master_labels = {})
    queue = Queue.new
    targets.each_with_index { |chap, idx| queue << [chap, idx + 1] }

    mutex = Mutex.new
    completed = 0
    total = targets.size
    start_time = Time.now

    workers = (1..@jobs).map do
      Thread.new do
        until queue.empty?
          chap, target_idx = begin
            queue.pop(true)
          rescue ThreadError
            nil
          end
          break unless chap

          t0 = Time.now
          success, log = compile_single_chapter(chap, all_chapters, master_labels)
          elapsed = (Time.now - t0).round(1)

          mutex.synchronize do
            completed += 1
            status_str = success ? 'PASS' : 'FAIL'
            printf("[%2d/%2d] %-35s ... %s (%.1fs)\n", completed, total, "#{chap[:dir]}/#{chap[:file]}", status_str, elapsed)
            unless success
              puts "  --> Error log for #{chap[:dir]}:\n#{log.lines.last(10).join}"
            end
          end
        end
      end
    end

    workers.each(&:join)
    total_elapsed = (Time.now - start_time).round(1)
    puts "\nFinished compiling #{total} chapters in #{total_elapsed}s"
  end

  def compile_single_chapter(chap, all_chapters, master_labels = {})
    chap_dir = File.join(ROOT_DIR, chap[:dir])
    out_dir  = File.join(@output_dir, chap[:dir])
    stem     = chap[:stem]

    return [false, "Directory #{chap[:dir]} not found"] unless Dir.exist?(chap_dir)

    FileUtils.mkdir_p(out_dir)

    # Run make4ht inside chapter directory
    cmd = ['make4ht', '-x', '-c', 'styles/web.cfg', '-f', 'html5', chap[:file], 'mathjax']
    stdout, stderr, status = Open3.capture3(*cmd, chdir: chap_dir)

    # Check output
    main_html = File.join(chap_dir, "#{stem}.html")
    unless File.exist?(main_html)
      clean_intermediate_files(chap_dir, stem)
      return [false, "Output #{main_html} was not created.\n#{stdout}\n#{stderr}"]
    end

    # Move generated HTML, CSS and images to out_dir
    Dir.glob(File.join(chap_dir, "#{stem}*.html")).each do |html_file|
      fname = File.basename(html_file)
      dest_name = (fname == "#{stem}.html") ? 'index.html' : fname
      FileUtils.mv(html_file, File.join(out_dir, dest_name))
    end

    css_file = File.join(chap_dir, "#{stem}.css")
    FileUtils.mv(css_file, File.join(out_dir, "#{stem}.css")) if File.exist?(css_file)

    # Copy any generated figure images in figs/
    chap_figs = File.join(chap_dir, 'figs')
    if Dir.exist?(chap_figs)
      out_figs = File.join(out_dir, 'figs')
      FileUtils.mkdir_p(out_figs)
      Dir.glob(File.join(chap_figs, '*.{png,svg,jpg,jpeg,gif}')).each do |img|
        FileUtils.cp(img, out_figs)
      end
    end

    # Extract aux labels before cleaning
    aux_candidates = [File.join(chap_dir, "#{stem}.aux"), File.join(chap_dir, 'junk', "#{stem}.aux")]
    aux_file = aux_candidates.find { |f| File.exist?(f) }
    aux_labels = {}
    if aux_file
      File.read(aux_file, encoding: 'utf-8').scan(/\\newlabel\{([^}]+)\}\{\{\\rEfLiNK\{([^}]+)\}/) do |lbl, target_id|
        aux_labels[lbl] = target_id
      end
    end

    # Clean intermediate files
    clean_intermediate_files(chap_dir, stem)

    # Post-process out_dir/index.html to inject nav & modern styling & cross-links
    post_process_html(File.join(out_dir, 'index.html'), chap, all_chapters, master_labels, aux_labels)

    [true, '']
  rescue StandardError => e
    clean_intermediate_files(chap_dir, stem) if defined?(chap_dir) && defined?(stem)
    [false, e.full_message]
  end

  def clean_intermediate_files(dir, stem)
    exts = %w[4ct 4tc idv lg xref tmp xdv aux bcf run.xml log thm idx]
    exts.each do |ext|
      pattern = File.join(dir, "#{stem}.#{ext}")
      Dir.glob(pattern).each { |f| FileUtils.rm_f(f) }
    end
    FileUtils.rm_f(File.join(dir, 'frag_probe.tmp'))
    Dir.glob(File.join(dir, 'figs', '*-*.png')).each { |f| FileUtils.rm_f(f) }
  end

  def normalize_footnotes(content)
    fn_match = content.match(/(<div\s+class=['"]footnotes['"]>)(.*?)(<\/div>)/m)
    return content unless fn_match

    pre = content[0...fn_match.begin(0)]
    fn_open = fn_match[1]
    fn_body = fn_match[2]
    fn_close = fn_match[3]
    post = content[fn_match.end(0)..-1]

    # In body, normalize footnote marks
    b_idx = 0
    pre.gsub!(%r{<span\s+class=['"]footnote-mark['"]>(.*?)</span>}m) do
      b_idx += 1
      inner = Regexp.last_match(1)
      sup_text = inner.gsub(/<[^>]+>/, '').strip
      "<span class=\"footnote-mark\"><a href=\"#fn#{b_idx}x1\" id=\"fn#{b_idx}x1-bk\"><sup class=\"textsuperscript\">#{sup_text}</sup></a></span>"
    end

    # In footnotes container, normalize asides and their back-links
    a_idx = 0
    fn_body.gsub!(%r{<aside\s+class=['"]footnotetext['"][^>]*>(.*?)</aside>}m) do
      a_idx += 1
      inner = Regexp.last_match(1)
      inner.sub!(%r{<span\s+class=['"]footnote-mark['"]>(.*?)</span>}m) do
        f_inner = Regexp.last_match(1)
        sup_text = f_inner.gsub(/<[^>]+>/, '').strip
        "<span class=\"footnote-mark\"><a href=\"#fn#{a_idx}x1-bk\"><sup class=\"textsuperscript\">#{sup_text}</sup></a></span>"
      end
      "<aside class=\"footnotetext\" id=\"fn#{a_idx}x1\" role=\"doc-footnote\">#{inner}</aside>"
    end

    "#{pre}#{fn_open}#{fn_body}#{fn_close}#{post}"
  end

  def post_process_html(html_path, current_chap, all_chapters, master_labels = {}, aux_labels = {})
    return unless File.exist?(html_path)

    content = File.read(html_path, encoding: 'utf-8')

    # Find previous and next chapters
    curr_idx = all_chapters.find_index { |c| c[:dir] == current_chap[:dir] } || 0
    prev_chap = (curr_idx > 0) ? all_chapters[curr_idx - 1] : nil
    next_chap = (curr_idx < all_chapters.size - 1) ? all_chapters[curr_idx + 1] : nil

    prev_link = prev_chap ? "<a href=\"../#{prev_chap[:dir]}/index.html\">← #{prev_chap[:num]}. #{escape_html(prev_chap[:title])}</a>" : '<span></span>'
    next_link = next_chap ? "<a href=\"../#{next_chap[:dir]}/index.html\">#{next_chap[:num]}. #{escape_html(next_chap[:title])} →</a>" : '<span></span>'
    toc_link  = '<a href="../index.html">☰ Table of Contents</a>'

    nav_bar_top = <<~HTML
      <nav class="book-nav top-nav">
        <div class="nav-prev">#{prev_link}</div>
        <div class="nav-toc">#{toc_link}</div>
        <div class="nav-next">#{next_link}</div>
      </nav>
    HTML

    nav_bar_bottom = <<~HTML
      <nav class="book-nav bottom-nav">
        <div class="nav-prev">#{prev_link}</div>
        <div class="nav-toc">#{toc_link}</div>
        <div class="nav-next">#{next_link}</div>
      </nav>
    HTML

    # Inject web.css stylesheet into head
    css_link = '<link rel="stylesheet" href="../styles/web.css" />'
    content.sub!(%r{</head>}, "  #{css_link}\n</head>") unless content.include?('styles/web.css')

    # Fix title tag
    page_title = "<title>#{current_chap[:num]}. #{escape_html(current_chap[:title])} — Randomized Algorithms</title>"
    if content =~ %r{<title>.*?</title>}
      content.sub!(%r{<title>.*?</title>}, page_title)
    else
      content.sub!(%r{<head>}, "<head>\n  #{page_title}")
    end

    # Fix relative references to styles/ assets (e.g. qed_duck-.png)
    content.gsub!(/src=(['"])styles\//, 'src=\\1../styles/')

    # Fix internal links pointing to the renamed stem file (stem.html#... -> #...)
    stem = current_chap[:file].sub(/\.tex$/, '')
    content.gsub!(/href=(['"])#{Regexp.escape(stem)}\.html#([^'"]*)\1/, 'href=\\1#\\2\\1')
    content.gsub!(/href=(['"])#{Regexp.escape(stem)}\.html\1/, 'href=\\1#\\1')

    # Unwrap redundant hyperref footnote wrapper links
    content.gsub!(/<a\s+href=['"]#Hfootnote\.\d+['"]>(.*?)<\/a>/m, '\1')

    # Fix double hash in href
    content.gsub!(/href=(['"])##+/, 'href=\\1#')

    # Flatten any nested <a> tags inside <a class="cross-ref">
    nested_a_regex = %r{<a\s+(class=['"][^'"]*cross-ref[^'"]*['"][^>]*)>(.*?)(?:<a\s+[^>]*>(.*?)</a>)(.*?)</a>}m
    while content =~ nested_a_regex
      content.gsub!(nested_a_regex) do
        attr = Regexp.last_match(1)
        pre = Regexp.last_match(2)
        inner = Regexp.last_match(3)
        post = Regexp.last_match(4)
        "<a #{attr}>#{pre}#{inner}#{post}</a>"
      end
    end

    # Normalize bidirectional footnotes (body marks <-> aside entries)
    content = normalize_footnotes(content)

    # Inject anchor for any \eqlab inside math blocks
    content.gsub!(%r[(<span\s+class=['"][^'"]*mathjax-(?:equation|align)[^'"]*['"][^>]*>.*?\\eqlab\s*\{([^}]+)\}.*?</span>)]m) do |m|
      raw_lbl = Regexp.last_match(2).strip
      sanitized = raw_lbl.gsub(/[^A-Za-z0-9\-_.]/, '_')
      "<a id=\"equation_#{sanitized}\"></a>#{m}"
    end

    sanitize_id = ->(id) { id.to_s.gsub(/[^A-Za-z0-9\-_.]/, '_') }

    # Inject anchors for labels tracked by TeX4ht in .aux (e.g. figures, tables)
    aux_labels.each do |lbl, target_id|
      sanitized = sanitize_id.call(lbl)
      pattern = /(<[^>]*\bid=['"]#{Regexp.escape(target_id)}['"][^>]*>)/
      if content =~ pattern
        content.sub!(pattern) do |elem|
          "#{elem}<a id=\"#{sanitized}\"></a><a id=\"#{lbl}\"></a>"
        end
      end
    end

    # Inject anchors for master labels belonging to this chapter (theorems, lemmas, sections, etc.)
    existing_page_ids = Set.new(content.scan(/id=['"]([^'"]+)['"]/).flatten)
    master_labels.each_value do |info|
      next unless info.is_a?(Hash) && info[:chap_dir] == current_chap[:dir]
      raw_lbl = info[:label]
      next if raw_lbl.nil? || raw_lbl.empty?
      sanitized = sanitize_id.call(raw_lbl)
      next if existing_page_ids.include?(sanitized) || existing_page_ids.include?(raw_lbl)

      num = info[:num]
      next if num.nil? || num.empty?

      keyword = case raw_lbl
                when /^theo:/ then 'Theorem'
                when /^lemma:/ then 'Lemma'
                when /^cor:/ then 'Corollary'
                when /^def:/ then 'Definition'
                when /^cl(?:m|aim):/ then 'Claim'
                when /^obs(?:ervation)?:/ then 'Observation'
                when /^exm|example:/ then 'Example'
                when /^rem:/ then 'Remark'
                when /^fact:/ then 'Fact'
                when /^fig:/ then 'Figure'
                when /^exer:/ then 'Exercise'
                when /^tedium:|^ted:/ then 'Tedium'
                when /^conj(?:ecture)?:/ then 'Conjecture'
                when /^alg(?:orithm)?:/ then 'Algorithm'
                when /^prob(?:lem)?:/ then 'Problem'
                else nil
                end

      if keyword
        pattern = /(#{keyword}[\s\u00a0]+#{Regexp.escape(num)}\b)/i
        if content =~ pattern
          content.sub!(pattern) do |m|
            existing_page_ids << sanitized
            existing_page_ids << raw_lbl
            "<a id=\"#{sanitized}\"></a><a id=\"#{raw_lbl}\"></a>#{m}"
          end
        end
      elsif raw_lbl =~ /^sec:/
        pattern = /(<h[2-6][^>]*>[\s\S]*?#{Regexp.escape(num)}\.?[\s\u00a0])/i
        if content =~ pattern
          content.sub!(pattern) do |m|
            existing_page_ids << sanitized
            existing_page_ids << raw_lbl
            "<a id=\"#{sanitized}\"></a><a id=\"#{raw_lbl}\"></a>#{m}"
          end
        end
      end
    end

    # Resolve cross-chapter reference links
    cross_ref_pattern = %r{<a\s+([^>]*\bclass=['"][^'"]*cross-ref[^'"]*['"][^>]*)href=['"]#([^'"]+)['"]([^>]*)>(.*?)</a>}m
    content.gsub!(cross_ref_pattern) do |_|
      raw_key = Regexp.last_match(2)
      inner_text = Regexp.last_match(4)

      # Clean up any nested <a> tags inside link text
      clean_text = inner_text.gsub(%r{<a\s+[^>]*>(.*?)</a>}m, '\1').strip

      # Lookup in master labels
      colon_key = raw_key.tr('_', ':')
      alpha_key = raw_key.to_s.downcase.gsub(/[^a-z0-9]/, '')
      info = master_labels[raw_key] || master_labels[colon_key] || master_labels[alpha_key]
      target_anchor = sanitize_id.call(info ? info[:label] : raw_key)

      if info && info[:chap_dir] && info[:chap_dir] != current_chap[:dir]
        target_dir = info[:chap_dir]
        target_chap_num = info[:chap_num]
        title_attr = "Chapter #{target_chap_num}"
        title_attr += ": #{escape_html(info[:title])}" if info[:title] && !info[:title].empty?
        "<a class=\"cross-ref inter-chapter\" href=\"../#{target_dir}/index.html##{target_anchor}\" title=\"#{title_attr}\">#{clean_text}</a>"
      else
        "<a class=\"cross-ref\" href=\"##{target_anchor}\">#{clean_text}</a>"
      end
    end

    # Normalize any remaining intra-page hrefs that have colons
    page_ids = Set.new(content.scan(/id=['"]([^'"]+)['"]/).flatten)
    content.gsub!(/href=(['"])#([^'"]*:[^'"]*)\1/) do |_|
      quote = Regexp.last_match(1)
      raw_id = Regexp.last_match(2)
      sanitized = sanitize_id.call(raw_id)
      if page_ids.include?(sanitized) || !page_ids.include?(raw_id)
        "href=#{quote}##{sanitized}#{quote}"
      else
        "href=#{quote}##{raw_id}#{quote}"
      end
    end

    # Wrap body content with nav bars
    if content =~ %r{<body>(.*?)</body>}m
      inner = Regexp.last_match(1)
      new_body = "<body>\n<div class=\"content-container\">\n#{nav_bar_top}\n#{inner}\n#{nav_bar_bottom}\n</div>\n</body>"
      content.sub!(%r{<body>.*?</body>}m, new_body)
    end

    File.write(html_path, content)
  end

  def generate_toc(chapters)
    toc_path = File.join(@output_dir, 'index.html')

    items_html = chapters.map do |chap|
      chap_url = "./#{chap[:dir]}/index.html"
      has_html = File.exist?(File.join(@output_dir, chap[:dir], 'index.html'))
      status_badge = has_html ? '' : ' <span class="badge-pending">PDF only</span>'

      <<~HTML
        <li class="chapter-item" data-title="#{escape_html(chap[:title]).downcase}">
          <div class="chapter-number">Chapter #{chap[:num]}</div>
          <div class="chapter-title">
            <a href="#{chap_url}">#{escape_html(chap[:title])}</a>#{status_badge}
          </div>
        </li>
      HTML
    end.join("\n")

    toc_content = <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Randomized Algorithms — Class Notes &amp; Book</title>
        <link rel="stylesheet" href="styles/web.css" />
        <style>
          .toc-header {
            text-align: center;
            padding: 2.5rem 0 1.5rem 0;
            border-bottom: 1px solid var(--border-color);
            margin-bottom: 2rem;
          }
          .toc-header h1 {
            font-size: 2.3rem;
            margin-bottom: 0.4rem;
          }
          .toc-header .author {
            font-size: 1.2rem;
            color: var(--quote-color);
            margin-bottom: 0.8rem;
          }
          .search-box {
            width: 100%;
            max-width: 480px;
            padding: 0.65rem 1rem;
            font-size: 1rem;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            background: var(--header-bg);
            color: var(--text-color);
            margin: 1rem auto 2rem auto;
            display: block;
            outline: none;
          }
          .search-box:focus {
            border-color: var(--link-color);
          }
          .chapter-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: grid;
            gap: 0.75rem;
          }
          .chapter-item {
            padding: 1rem 1.25rem;
            background: var(--header-bg);
            border: 1px solid var(--border-color);
            border-radius: 6px;
            display: flex;
            align-items: center;
            gap: 1.25rem;
            transition: transform 0.1s ease, border-color 0.1s ease;
          }
          .chapter-item:hover {
            border-color: var(--link-color);
          }
          .chapter-number {
            font-weight: 700;
            font-size: 0.95rem;
            color: var(--quote-color);
            min-width: 90px;
          }
          .chapter-title {
            font-size: 1.1rem;
            font-weight: 600;
          }
          .chapter-title a {
            color: var(--link-color);
            text-decoration: none;
          }
          .chapter-title a:hover {
            text-decoration: underline;
          }
          .badge-pending {
            font-size: 0.75rem;
            font-weight: normal;
            background: #e2e8f0;
            color: #475569;
            padding: 2px 6px;
            border-radius: 4px;
            margin-left: 8px;
          }
        </style>
      </head>
      <body>
        <div class="content-container">
          <div class="toc-header">
            <h1>Randomized Algorithms</h1>
            <div class="author">Sariel Har-Peled</div>
            <p>Lecture notes and forthcoming book on randomized algorithms and probabilistic methods.</p>
          </div>

          <input type="text" id="filterInput" class="search-box" placeholder="Filter chapters by title..." onkeyup="filterChapters()" />

          <ul class="chapter-list" id="chapterList">
            #{items_html}
          </ul>

          <footer style="text-align: center; margin-top: 3.5rem; padding-top: 1.5rem; border-top: 1px solid var(--border-color); color: var(--quote-color); font-size: 0.9rem;">
            <p>Licensed under Creative Commons Attribution-Noncommercial 3.0.</p>
          </footer>
        </div>

        <script>
          function filterChapters() {
            var input = document.getElementById('filterInput');
            var filter = input.value.toLowerCase();
            var list = document.getElementById('chapterList');
            var items = list.getElementsByTagName('li');
            for (var i = 0; i < items.length; i++) {
              var title = items[i].getAttribute('data-title') || '';
              if (title.indexOf(filter) > -1) {
                items[i].style.display = '';
              } else {
                items[i].style.display = 'none';
              }
            }
          }
        </script>
      </body>
      </html>
    HTML

    File.write(toc_path, toc_content)
  end

  def escape_html(str)
    str.to_s
       .gsub('&', '&amp;')
       .gsub('<', '&lt;')
       .gsub('>', '&gt;')
       .gsub('"', '&quot;')
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {}
  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: tools/gen_html_all_chapters [options] [filters...]'

    opts.on('-o', '--output DIR', 'Output directory (default: html_site)') do |d|
      options[:output_dir] = d
    end

    opts.on('-j', '--jobs N', Integer, 'Number of parallel workers (default: 4)') do |n|
      options[:jobs] = n
    end

    opts.on('--toc-only', 'Generate only Table of Contents index.html without compiling') do
      options[:toc_only] = true
    end

    opts.on('-h', '--help', 'Display this help') do
      puts opts
      exit 0
    end
  end

  parser.parse!(ARGV)
  options[:filters] = ARGV

  builder = HtmlBookBuilder.new(options)
  builder.run
end
