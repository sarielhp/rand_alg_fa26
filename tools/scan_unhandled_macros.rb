#!/usr/bin/env ruby
# frozen_string_literal: true
# ==============================================================================
# scan_unhandled_macros.rb
#
# Audits generated HTML files to identify LaTeX macros that MathJax cannot render.
# Cross-references unhandled macros with styles/prefix.tex and individual chapter
# sources to find their original LaTeX definitions.
# ==============================================================================

require 'fileutils'
require 'json'
require 'optparse'
require 'pathname'
require 'set'

ROOT_DIR    = File.expand_path('..', __dir__)
BOOK_TEX    = File.join(ROOT_DIR, 'book.tex')
STYLES_DIR  = File.join(ROOT_DIR, 'styles')
PREFIX_TEX  = File.join(STYLES_DIR, 'prefix.tex')
MATH_MACROS = File.join(STYLES_DIR, 'mathjax_macros.tex')
DEFAULT_SITE_DIR = File.join(ROOT_DIR, 'html_site')

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
  setlength parindent savedparindent textcircled small
]).freeze

class MacroScanner
  def initialize(options = {})
    @options = options
    @site_dir = File.expand_path(options[:site_dir] || DEFAULT_SITE_DIR, ROOT_DIR)
    @top_count = options[:top] || 50
    @target_chapter = options[:chapter]
    @format = options[:format] || :text

    @defined_mathjax = load_current_mathjax_macros
    @prefix_definitions = load_definitions_from_file(PREFIX_TEX, 'styles/prefix.tex')
    @chapter_definitions = load_chapter_definitions
  end

  def run
    unless Dir.exist?(@site_dir)
      warn "Error: Site directory not found: #{@site_dir}"
      exit 1
    end

    results = scan_site
    render_report(results)
  end

  private

  def load_current_mathjax_macros
    return Set.new unless File.exist?(MATH_MACROS)

    content = File.read(MATH_MACROS, encoding: 'utf-8')
    content.scan(/\\(?:providecommand|newcommand|def)\s*\{\\([a-zA-Z]+)\}/).flatten.to_set
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

  def load_definitions_from_file(file_path, label)
    defs = {}
    return defs unless File.exist?(file_path)

    text = File.read(file_path, encoding: 'utf-8')
    pos = 0
    while (idx = text.index(/\\(?:newcommand|renewcommand|providecommand|def)\*?\s*\{\\([a-zA-Z]+)\}/, pos))
      match = Regexp.last_match
      name = match[1]
      end_cmd = match.end(0)

      rest = text[end_cmd..-1]
      args_str = ''
      if rest =~ /\A\s*(\[[^\]]*\](?:\s*\[[^\]]*\])?)/
        args_str = Regexp.last_match(1).strip
        end_cmd += Regexp.last_match(0).length
      end

      body = extract_balanced_braces(text, end_cmd) || ''
      line_num = text[0..idx].count("\n") + 1

      clean_body = body.gsub(/\s+/, ' ').strip
      defs[name] ||= {
        source: "#{label}:#{line_num}",
        args: args_str,
        body: clean_body,
        definition: "\\newcommand{\\#{name}}#{args_str}{#{clean_body}}"
      }
      pos = end_cmd + 1
    end
    defs
  end

  def load_chapter_definitions
    defs = {}
    Dir.glob(File.join(ROOT_DIR, '[0-9][0-9]_*/*.tex')).each do |tex_file|
      rel_path = Pathname.new(tex_file).relative_path_from(Pathname.new(ROOT_DIR)).to_s
      chap_defs = load_definitions_from_file(tex_file, rel_path)
      defs.merge!(chap_defs)
    end
    defs
  end

  def scan_site
    records = Hash.new do |h, k|
      h[k] = {
        count: 0,
        chapters: Hash.new(0), # chap => count
        contexts: []
      }
    end

    html_files = Dir.glob(File.join(@site_dir, '**/index.html'))
    html_files.reject! { |f| f == File.join(@site_dir, 'index.html') }

    if @target_chapter
      html_files.select! { |f| f.include?(@target_chapter) }
    end

    html_files.each do |file|
      chap_name = File.basename(File.dirname(file))
      content = File.read(file, encoding: 'utf-8')

      # Strip hidden macro preamble block(s)
      content.gsub!(%r{<div style=['"]display:none['"].*?</div>}m, '')

      # Find all LaTeX control sequences
      content.scan(/\\([a-zA-Z]+)/) do
        macro = Regexp.last_match(1)
        next if STANDARD_MATHJAX.include?(macro)
        next if LATEX_META.include?(macro)
        next if @defined_mathjax.include?(macro)

        records[macro][:count] += 1
        records[macro][:chapters][chap_name] += 1

        # Capture brief context if < 2 collected
        if records[macro][:contexts].size < 2
          pos = Regexp.last_match.begin(0)
          start_p = [pos - 25, 0].max
          end_p   = [pos + 35, content.length].min
          snippet = content[start_p..end_p].gsub(/\s+/, ' ').strip
          records[macro][:contexts] << "#{chap_name}: \"...#{snippet}...\""
        end
      end
    end

    # Enrich records with definition source info
    enriched = records.map do |macro, data|
      info = {
        macro: macro,
        count: data[:count],
        num_chapters: data[:chapters].size,
        chapters: data[:chapters],
        contexts: data[:contexts]
      }

      if @prefix_definitions[macro]
        info[:origin] = :global
        info[:source] = @prefix_definitions[macro][:source]
        info[:definition] = @prefix_definitions[macro][:definition]
      elsif @chapter_definitions[macro]
        info[:origin] = :chapter
        info[:source] = @chapter_definitions[macro][:source]
        info[:definition] = @chapter_definitions[macro][:definition]
      else
        info[:origin] = :unknown
        info[:source] = 'Not found in sources'
        info[:definition] = nil
      end

      info
    end

    enriched.sort_by { |item| -item[:count] }
  end

  def render_report(items)
    if @options[:json]
      puts JSON.pretty_generate(items)
      return
    end

    total_occurrences = items.sum { |i| i[:count] }
    global_count = items.count { |i| i[:origin] == :global }
    chapter_count = items.count { |i| i[:origin] == :chapter }
    unknown_count = items.count { |i| i[:origin] == :unknown }

    puts '=' * 80
    puts 'Unhandled LaTeX Macros Audit Report'
    puts '=' * 80
    puts "Site Directory:        #{@site_dir}"
    puts "Total Unique Macros:   #{items.size}"
    puts "Total Occurrences:     #{total_occurrences}"
    puts "  - In prefix.tex:     #{global_count} (can be added directly to mathjax_macros.tex)"
    puts "  - In chapter .tex:   #{chapter_count} (chapter-local macros)"
    puts "  - Unknown/Other:     #{unknown_count} (likely special fonts or TeX internals)"
    puts '=' * 80
    puts

    limit = @options[:all] ? items.size : [@top_count, items.size].min
    display_items = items.first(limit)

    printf("%-20s | %-6s | %-8s | %-16s | %s\n", 'Macro', 'Count', 'Chapters', 'Origin', 'Definition / Source')
    puts '-' * 80

    display_items.each do |item|
      origin_str = case item[:origin]
                   when :global  then 'Global (prefix)'
                   when :chapter then 'Chapter-local'
                   else 'Unknown'
                   end

      def_str = item[:definition] ? item[:definition][0..50] : item[:source]
      printf("\\%-19s | %6d | %8d | %-16s | %s\n", item[:macro], item[:count], item[:num_chapters], origin_str, def_str)

      if @options[:verbose] && !item[:contexts].empty?
        item[:contexts].each { |c| puts "    Context: #{c}" }
      end
    end

    if limit < items.size
      puts "\n... and #{items.size - limit} more macros. (Use --all to display all)"
    end

    if @options[:output_file]
      write_markdown_file(@options[:output_file], items)
      puts "\nDetailed Markdown report written to: #{@options[:output_file]}"
    end
  end

  def write_markdown_file(path, items)
    md = []
    md << '# Unhandled LaTeX Macros Audit Report'
    md << ''
    md << "| Macro | Occurrences | Chapters | Category | Source Definition |"
    md << "| :--- | :--- | :--- | :--- | :--- |"

    items.each do |item|
      category = case item[:origin]
                 when :global  then 'Global (`styles/prefix.tex`)'
                 when :chapter then "Local (`#{item[:source]}`)"
                 else 'Unknown'
                 end
      def_code = item[:definition] ? "`#{item[:definition].gsub('|', '\\|')}`" : "*None*"
      md << "| `\\#{item[:macro]}` | #{item[:count]} | #{item[:num_chapters]} | #{category} | #{def_code} |"
    end

    File.write(path, md.join("\n") + "\n")
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {}
  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: tools/scan_unhandled_macros [options]'

    opts.on('-s', '--site-dir DIR', 'Directory of generated HTML site (default: html_site)') do |d|
      options[:site_dir] = d
    end

    opts.on('-n', '--top N', Integer, 'Number of top macros to show (default: 50)') do |n|
      options[:top] = n
    end

    opts.on('-a', '--all', 'Show all unhandled macros') do
      options[:all] = true
    end

    opts.on('-c', '--chapter CHAP', 'Filter by chapter (e.g. 02_alias_method)') do |c|
      options[:chapter] = c
    end

    opts.on('-v', '--verbose', 'Show context snippets for each macro') do
      options[:verbose] = true
    end

    opts.on('-j', '--json', 'Output report in JSON format') do
      options[:json] = true
    end

    opts.on('-o', '--output FILE', 'Export full Markdown report to file') do |f|
      options[:output_file] = f
    end

    opts.on('-h', '--help', 'Display this help message') do
      puts opts
      exit 0
    end
  end

  parser.parse!(ARGV)
  scanner = MacroScanner.new(options)
  scanner.run
end
