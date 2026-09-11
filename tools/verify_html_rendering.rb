#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# tools/verify_html_rendering.rb
#
# Comprehensive HTML & MathJax Rendering Verification Tool
# Audits the generated HTML site across all 58 chapters:
#   1. Chapter coverage & HTML structure sanity
#   2. Embedded images & figures existence and validity
#   3. Navigation, internal anchors, and inter-page links
#   4. MathJax macro declarations & math environment pairing
#   5. Stray unhandled LaTeX macros or TeX error leakages
#   6. Central Table of Contents integrity
#
# Usage:
#   ./tools/verify_html_rendering                # Full audit of all chapters
#   ./tools/verify_html_rendering -s             # Compact summary table
#   ./tools/verify_html_rendering -v             # Verbose details with snippets
#   ./tools/verify_html_rendering 01 02 talagrand# Check specific chapters
#   ./tools/verify_html_rendering --fix          # Auto-repair known path/link issues
# ==============================================================================

require 'fileutils'
require 'optparse'
require 'set'

class HtmlVerifier
  ROOT_DIR = File.expand_path('..', __dir__)
  SITE_DIR = File.join(ROOT_DIR, 'html_site')
  BOOK_TEX = File.join(ROOT_DIR, 'book.tex')
  MACROS_TEX = File.join(ROOT_DIR, 'styles', 'mathjax_macros.tex')
  PREFIX_TEX = File.join(ROOT_DIR, 'styles', 'prefix.tex')

  # Terminal colors
  RESET  = "\e[0m"
  BOLD   = "\e[1m"
  RED    = "\e[31m"
  GREEN  = "\e[32m"
  YELLOW = "\e[33m"
  BLUE   = "\e[34m"
  CYAN   = "\e[36m"
  GRAY   = "\e[90m"

  # Standard symbols and operators supported natively by MathJax
  STANDARD_MATHJAX = Set.new(%w[
    alpha beta gamma delta epsilon varepsilon zeta eta theta vartheta iota kappa lambda mu nu xi pi varpi rho varrho sigma varsigma tau upsilon phi varphi chi psi omega
    Gamma Delta Theta Lambda Xi Pi Sigma Upsilon Phi Psi Omega
    sin cos tan sec csc cot arcsin arccos arctan sinh cosh tanh coth log ln exp det gcd hom inf sup ker deg dim min max lim liminf limsup arg Pr
    sum prod coprod int iint iiint oint partial infty forall exists nexists in notin ni subset subseteq supset supseteq cap cup setminus sqsubset sqsubseteq sqsupset sqsupseteq sqcap sqcup land lor neg lnot wedge vee top bot emptyset varnothing aleph hbar imath jmath ell wp Re Im nabla surd angle
    leq geq le ge neq ne equiv sim simeq approx cong asymp doteq propto models perp mid parallel bowtie prec preceq succ succeq ll gg
    leftarrow rightarrow leftrightarrow Leftarrow Rightarrow Leftrightarrow mapsto to gets uparrow downarrow updownarrow nearrow searrow swarrow nwarrow longleftarrow longrightarrow longleftrightarrow iff implies
    ldots cdots vdots ddots quad qquad colon
    left right bigl bigr Bigl Bigr biggl biggr Biggl Biggr langle rangle lbrace rbrace vert Vert lceil rceil lfloor rfloor
    mathbf mathit mathrm mathsf mathtt mathcal mathbb mathfrak text textbf textit textrm hat bar tilde vec dot ddot acute grave check breve overline underline overbrace underbrace widehat widetilde
    begin end frac cfrac sqrt binom stackrel substack phantom hphantom vphantom tag label ref eqref pmod bmod over atop choose newline times pm mp div ast star circ bullet cdot
    cases matrix pmatrix bmatrix Bmatrix vmatrix Vmatrix align alignat gather multline array equation split
    displaystyle textstyle scriptstyle scriptscriptstyle middle dfrac tfrac overset underset smash triangle
    bigcap bigcup bigsqcup bigvee bigwedge bigodot bigoplus bigotimes biguplus
    eqref hspace vspace strut overrightarrow underrightarrow
    big Big bigg Bigg bigm Bigm dots mathop mathrel mathbin mathord mathopen mathclose mathpunct
    nolimits limits not oplus ominus otimes oslash odot mod bmod pmod nonumber ensuremath
    uproot nsubseteq displaybreak Longleftrightarrow Longleftarrow Longrightarrow
    textcolor textsf textsc emph bfseries ttfamily
  ]).freeze

  # Meta LaTeX commands that should not be treated as missing math symbols
  LATEX_META = Set.new(%w[
    providecommand newcommand renewcommand def DeclareRobustCommand DeclareDocumentCommand
    relax xspace special makeatletter makeatother pageref input inputatpath
    hfill index rule shortintertext noindent subsubsection part addcomma space
    allowdisplaybreaks allowbreak columncolor multicolumn cr rowcolor cellcolor
    scalebox hbox vcenter RecordedWidth settowidth qedsymbol myqedsymbol texorpdfstring
    setlength parindent savedparindent textcircled small document
  ]).freeze

  def initialize(options = {})
    @verbose = options[:verbose] || false
    @summary_only = options[:summary_only] || false
    @auto_fix = options[:auto_fix] || false
    @filters = options[:filters] || []
    @known_macros = load_known_macros
  end

  def run
    puts "#{BOLD}================================================================================#{RESET}"
    puts "#{BOLD}Randomized Algorithms — HTML Rendering Verification Suite#{RESET}"
    puts "#{BOLD}================================================================================#{RESET}"
    puts "Site Directory: #{SITE_DIR}"
    puts "Filters:        #{@filters.empty? ? '(all chapters)' : @filters.join(', ')}"
    puts "Mode:           #{@verbose ? 'Verbose' : (@summary_only ? 'Summary' : 'Standard')}"
    puts "#{BOLD}================================================================================#{RESET}\n"

    unless Dir.exist?(SITE_DIR)
      puts "#{RED}ERROR: Site directory '#{SITE_DIR}' does not exist. Run tools/gen_html_all_chapters first.#{RESET}"
      return 1
    end

    chapters = parse_book_chapters
    targets = filter_chapters(chapters)

    if targets.empty?
      puts "#{YELLOW}No chapters matched filters: #{@filters.join(', ')}#{RESET}"
      return 0
    end

    # Auto-repair pass if requested
    if @auto_fix
      puts "#{CYAN}Running auto-repair pass on target chapters...#{RESET}"
      targets.each { |chap| auto_fix_chapter(chap) }
      puts
    end

    # Verify Table of Contents
    toc_results = verify_toc(chapters)

    # Verify each chapter
    results = targets.map { |chap| verify_chapter(chap, chapters) }

    # Print reporting
    print_results(toc_results, results)

    # Exit code: 0 if no fatal errors, 1 otherwise
    has_errors = results.any? { |r| r[:errors].any? } || toc_results[:errors].any?
    has_errors ? 1 : 0
  end

  private

  def parse_book_chapters
    unless File.exist?(BOOK_TEX)
      puts "#{RED}Error: book.tex not found at #{BOOK_TEX}#{RESET}"
      return []
    end

    content = File.read(BOOK_TEX)
    chapters = []
    num = 1

    content.scan(/\\InputChap\{([^}]+)\}\s*\{([^}]+)\}/) do |dir, file|
      chap_path = File.join(ROOT_DIR, dir, file)
      title = File.exist?(chap_path) ? extract_chapter_title(File.read(chap_path)) : nil
      title ||= dir.sub(/^\d+_/, '').gsub('_', ' ').capitalize

      chapters << {
        dir: dir,
        file: file,
        stem: File.basename(file, '.tex'),
        num: num,
        title: title
      }
      num += 1
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
    while depth > 0 && i < content.length
      depth += 1 if content[i] == '{'
      depth -= 1 if content[i] == '}'
      i += 1
    end

    raw = content[(open_brace + 1)...(i - 1)]
    raw.gsub(/[{}]/, '').gsub(/\\(?:xspace|relax)/, '').strip
  end

  def filter_chapters(chapters)
    return chapters if @filters.empty?

    chapters.select do |chap|
      @filters.any? do |f|
        chap[:dir].include?(f) || chap[:file].include?(f) || chap[:num].to_s == f
      end
    end
  end

  def load_known_macros
    known = STANDARD_MATHJAX.dup
    known.merge(LATEX_META)

    # Load defined macros from mathjax_macros.tex
    if File.exist?(MACROS_TEX)
      File.read(MACROS_TEX).scan(/\\(?:providecommand|newcommand|def)\*?\s*(?:\{\\([a-zA-Z@]+)\}|\\([a-zA-Z@]+))/).flatten.compact.each do |m|
        known << m
      end
    end

    # Also load definitions from prefix.tex
    if File.exist?(PREFIX_TEX)
      File.read(PREFIX_TEX).scan(/\\(?:newcommand|def|DeclareMathOperator)\*?\s*(?:\{\\([a-zA-Z@]+)\}|\\([a-zA-Z@]+))/).flatten.compact.each do |m|
        known << m
      end
    end

    known
  end

  def auto_fix_chapter(chap)
    html_path = File.join(SITE_DIR, chap[:dir], 'index.html')
    return unless File.exist?(html_path)

    content = File.read(html_path)
    orig = content.dup
    stem = chap[:stem]

    # Fix relative paths to shared styles assets
    content.gsub!(/src=(['"])styles\//, 'src=\1../styles/')

    # Fix internal anchor references pointing to stem.html#...
    content.gsub!(/href=(['"])#{Regexp.escape(stem)}\.html#([^'"]*)\1/, 'href=\1#\2\1')
    content.gsub!(/href=(['"])#{Regexp.escape(stem)}\.html\1/, 'href=\1#\1')

    # Unwrap redundant hyperref footnote wrapper links
    content.gsub!(/<a\s+href=['"]#Hfootnote\.\d+['"]>(.*?)<\/a>/m, '\1')

    if content != orig
      File.write(html_path, content)
      puts "  Fixed paths/links in #{chap[:dir]}/index.html"
    end
  end

  def verify_toc(chapters)
    result = { file: 'index.html', errors: [], warnings: [], chap_count: 0 }
    toc_path = File.join(SITE_DIR, 'index.html')

    unless File.exist?(toc_path)
      result[:errors] << 'TOC file index.html is missing in html_site/'
      return result
    end

    content = File.read(toc_path)
    result[:warnings] << 'TOC HTML file is unusually small (< 2KB)' if content.bytesize < 2048

    # Check that all chapters are linked
    chapters.each do |chap|
      expected_link = "./#{chap[:dir]}/index.html"
      unless content.include?(expected_link)
        result[:errors] << "TOC missing link to chapter #{chap[:num]} (#{chap[:dir]})"
      end
    end

    # Check for broken links in TOC
    content.scan(/<a\s+[^>]*href=["\x27]([^"\x27#]+)["\x27]/i).each do |(href)|
      next if href =~ /^(?:https?|ftp|mailto):/
      target = File.expand_path(href, SITE_DIR)
      unless File.exist?(target)
        result[:errors] << "TOC has broken link to #{href}"
      end
    end

    result
  end

  def verify_chapter(chap, all_chapters)
    dir_path = File.join(SITE_DIR, chap[:dir])
    html_path = File.join(dir_path, 'index.html')

    res = {
      chap: chap,
      errors: [],
      warnings: [],
      images_checked: 0,
      links_checked: 0,
      math_blocks_checked: 0
    }

    unless Dir.exist?(dir_path)
      res[:errors] << "Chapter directory html_site/#{chap[:dir]} does not exist"
      return res
    end

    unless File.exist?(html_path)
      res[:errors] << "index.html missing in html_site/#{chap[:dir]}"
      return res
    end

    content = File.read(html_path, encoding: 'utf-8')

    # 1. Structural Sanity
    if content.bytesize < 2048
      res[:errors] << "File size is suspiciously small (#{content.bytesize} bytes) - likely truncated build"
    end
    res[:errors] << 'Missing <!DOCTYPE html>' unless content.include?('<!DOCTYPE html>')
    res[:errors] << 'Missing </html> closing tag (truncated)' unless content.include?('</html>')
    res[:errors] << 'Missing </body> closing tag' unless content.include?('</body>')
    res[:warnings] << 'Missing styles/web.css stylesheet link' unless content.include?('styles/web.css')
    res[:warnings] << 'Missing top navigation bar' unless content.include?('top-nav')
    res[:warnings] << 'Missing bottom navigation bar' unless content.include?('bottom-nav')

    # 2. TeX Leakages and Fatal Error Markers
    if content =~ /--- TeX4ht (?:error|warning) ---/
      res[:errors] << 'Contains raw TeX4ht error/warning output'
    end
    if content =~ /LaTeX Error:|Emergency stop|Fatal error:/
      res[:errors] << 'Contains raw LaTeX compiler error messages'
    end
    if content =~ />\s*\?\?\s*</ || content =~ />\s*\[\?\]\s*</
      res[:warnings] << 'Contains unresolved reference placeholders (?? or [?])'
    end

    # 3. Image Verification
    content.scan(/<img\s+[^>]*src=["\x27]([^"\x27]+)["\x27]/i).each do |(src)|
      res[:images_checked] += 1
      img_full = File.expand_path(src, dir_path)
      if !File.exist?(img_full)
        res[:errors] << "Missing image file: #{src}"
      elsif File.size(img_full) == 0
        res[:errors] << "Zero-byte image file: #{src}"
      end
    end

    # 4. Anchor & Link Verification
    existing_ids = Set.new(content.scan(/id=["\x27]([^"\x27]+)["\x27]/).flatten)
    existing_ids.merge(content.scan(/name=["\x27]([^"\x27]+)["\x27]/).flatten)

    # Check intra-page anchors
    content.scan(/<a\s+[^>]*href=["\x27]#([^"\x27]+)["\x27]/i).each do |(target_id)|
      res[:links_checked] += 1
      unless existing_ids.include?(target_id)
        res[:errors] << "Broken intra-page anchor: ##{target_id}"
      end
    end

    # Check relative links to other files/anchors
    content.scan(/<a\s+[^>]*href=["\x27]([^"\x27#]+)(?:#([^"\x27]+))?["\x27]/i).each do |href, anchor|
      next if href =~ /^(?:https?|ftp|mailto):/
      res[:links_checked] += 1

      if href == "#{chap[:stem]}.html"
        res[:errors] << "Stale reference to renamed stem file: #{href}"
        next
      end

      target_file = File.expand_path(href, dir_path)
      if !File.exist?(target_file)
        # Check if it's an arXiv / DOI relative false-positive in bib
        if href =~ /^(?:math\/\d+|arxiv|\d+\.\d+)/i
          res[:warnings] << "External bib link missing URL scheme: #{href}"
        else
          res[:errors] << "Broken relative link to missing file: #{href}"
        end
      elsif anchor
        target_content = File.read(target_file)
        target_ids = Set.new(target_content.scan(/id=["\x27]([^"\x27]+)["\x27]/).flatten)
        target_ids.merge(target_content.scan(/name=["\x27]([^"\x27]+)["\x27]/).flatten)
        unless target_ids.include?(anchor)
          res[:errors] << "Broken cross-page anchor: #{href}##{anchor}"
        end
      end
    end

    # 5. MathJax Macro Declarations & Math Blocks
    res[:warnings] << 'Missing MathJax macro configuration block' unless content.include?('display:none')

    # Strip hidden macro preamble block before auditing body math and environments
    body_content = content.gsub(%r{<div style=['"]display:none['"].*?</div>}m, '')

    # Environment pairing check
    open_envs = body_content.scan(/\\begin\{([a-zA-Z*]+)\}/).flatten
    close_envs = body_content.scan(/\\end\{([a-zA-Z*]+)\}/).flatten
    open_counts = Hash.new(0)
    close_counts = Hash.new(0)
    open_envs.each { |e| open_counts[e] += 1 }
    close_envs.each { |e| close_counts[e] += 1 }

    (open_counts.keys | close_counts.keys).each do |env|
      diff = open_counts[env] - close_counts[env]
      if diff != 0
        res[:errors] << "Mismatched math environment \\begin{#{env}} (#{open_counts[env]}) vs \\end{#{env}} (#{close_counts[env]})"
      end
    end

    # MathJax formulas audit for unhandled macros
    math_pattern = /(?:\\\((.+?)\\\)|\\\[(.+?)\\\]|<span class=['"]mathjax-inline['"]>\\?\((.+?)\\?\)<\/span>|<(?:div|span) class=['"]mathjax-env[^'"]*['"]>\\begin\{.+?\}(.+?)\\end\{.+?\}<\/(?:div|span)>)/m
    body_content.scan(math_pattern) do |m1, m2, m3, m4|
      block = m1 || m2 || m3 || m4
      next unless block

      res[:math_blocks_checked] += 1

      # Check for unknown macros
      block.scan(/\\([a-zA-Z@]+)/) do |(cmd)|
        next if @known_macros.include?(cmd)
        res[:errors] << "Unhandled macro in math mode: \\#{cmd}"
      end
    end

    res[:errors].uniq!
    res[:warnings].uniq!
    res
  end

  def print_results(toc_results, results)
    total_chaps = results.size
    passed_chaps = results.count { |r| r[:errors].empty? && r[:warnings].empty? }
    warn_chaps = results.count { |r| r[:errors].empty? && r[:warnings].any? }
    failed_chaps = results.count { |r| r[:errors].any? }

    total_images = results.sum { |r| r[:images_checked] }
    total_links  = results.sum { |r| r[:links_checked] }
    total_math   = results.sum { |r| r[:math_blocks_checked] }
    total_errors = results.sum { |r| r[:errors].size } + toc_results[:errors].size
    total_warns  = results.sum { |r| r[:warnings].size } + toc_results[:warnings].size

    # Table Header
    puts "#{BOLD}%-4s | %-22s | %-8s | %-6s | %-7s | %-7s | %s#{RESET}" % [
      '#', 'Chapter', 'Status', 'Images', 'Links', 'Math', 'Issues'
    ]
    puts '-' * 80

    results.each do |r|
      c = r[:chap]
      chap_label = "#{c[:num]}. #{c[:dir]}"
      chap_label = chap_label[0..21] if chap_label.length > 22

      status_str = if r[:errors].any?
                     "#{RED}FAIL#{RESET}"
                   elsif r[:warnings].any?
                     "#{YELLOW}WARN#{RESET}"
                   else
                     "#{GREEN}PASS#{RESET}"
                   end

      issues_summary = []
      issues_summary << "#{r[:errors].size} err" if r[:errors].any?
      issues_summary << "#{r[:warnings].size} warn" if r[:warnings].any?
      issues_str = issues_summary.empty? ? "#{GRAY}ok#{RESET}" : issues_summary.join(', ')

      puts "%-4d | %-22s | %-17s | %-6d | %-7d | %-7d | %s" % [
        c[:num],
        chap_label,
        status_str,
        r[:images_checked],
        r[:links_checked],
        r[:math_blocks_checked],
        issues_str
      ]

      if @verbose || (!@summary_only && (r[:errors].any? || r[:warnings].any?))
        r[:errors].each do |err|
          puts "     #{RED}✖ [ERROR]#{RESET} #{err}"
        end
        r[:warnings].each do |w|
          puts "     #{YELLOW}▲ [WARN]#{RESET}  #{w}"
        end
      end
    end

    puts '-' * 80
    if toc_results[:errors].any? || toc_results[:warnings].any?
      puts "\nTable of Contents (index.html):"
      toc_results[:errors].each { |e| puts "  #{RED}✖ [ERROR]#{RESET} #{e}" }
      toc_results[:warnings].each { |w| puts "  #{YELLOW}▲ [WARN]#{RESET} #{w}" }
    end

    # Final Summary Box
    puts "\n#{BOLD}================================================================================#{RESET}"
    puts "#{BOLD}Verification Summary#{RESET}"
    puts "#{BOLD}================================================================================#{RESET}"
    puts "Total Chapters:        #{total_chaps}"
    puts "  - #{GREEN}Passed Cleanly:      #{passed_chaps}#{RESET}"
    puts "  - #{YELLOW}Passed with Warnings:#{warn_chaps}#{RESET}"
    puts "  - #{RED}Failed:              #{failed_chaps}#{RESET}"
    puts "Verified Elements:"
    puts "  - Images / Figures:  #{total_images} checked"
    puts "  - Links & Anchors:   #{total_links} checked"
    puts "  - Math Expressions:  #{total_math} checked"
    puts "Issue Totals:          #{total_errors == 0 ? GREEN : RED}#{total_errors} Errors#{RESET}, #{total_warns == 0 ? GREEN : YELLOW}#{total_warns} Warnings#{RESET}"
    puts "#{BOLD}================================================================================#{RESET}"

    if total_errors == 0
      puts "#{GREEN}✔ All HTML pages and rendering assets verified successfully!#{RESET}"
    else
      puts "#{RED}✖ Verification encountered #{total_errors} error(s). Please review the log above.#{RESET}"
    end
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options] [filters...]"

  opts.on('-v', '--verbose', 'Print detailed breakdown of all checked elements') do
    options[:verbose] = true
  end

  opts.on('-s', '--summary', 'Show compact summary table only') do
    options[:summary_only] = true
  end

  opts.on('--fix', 'Auto-repair fixable link and asset path issues') do
    options[:auto_fix] = true
  end

  opts.on('-h', '--help', 'Show this help message') do
    puts opts
    exit 0
  end
end.parse!

options[:filters] = ARGV
verifier = HtmlVerifier.new(options)
exit verifier.run
