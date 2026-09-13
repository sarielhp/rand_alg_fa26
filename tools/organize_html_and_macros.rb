#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"

ROOT_DIR = File.expand_path("..", __dir__)
HTML_DIR = File.join(ROOT_DIR, "html")
STYLES_DIR = File.join(ROOT_DIR, "styles")

def extract_macros_from(text)
  macros = {}
  pos = 0
  len = text.length

  while pos < len
    idx = text.index(/\\(?:newcommand|renewcommand|providecommand|def|DeclareMathOperator)\*?\s*[\{\\]/, pos)
    break unless idx

    slice = text[idx..-1]
    if slice =~ /\A\\(?:newcommand|renewcommand|providecommand)\*?\s*\{\\([a-zA-Z0-9]+)\}(\[(\d+)\])?(\[([^\]]*)\])?\s*\{/
      name = $1
      args = $3 ? $3.to_i : 0
      opt = $5
      m_end = $~.end(0)
      depth = 1
      curr = idx + m_end
      while curr < len && depth > 0
        char = text[curr]
        if char == "{"
          depth += 1
        elsif char == "}"
          depth -= 1
        elsif char == "\\"
          curr += 1
        end
        curr += 1
      end
      body = text[(idx + m_end)...(curr - 1)].strip
      macros[name] = { args: args, opt: opt, body: body }
      pos = curr
    elsif slice =~ /\A\\DeclareMathOperator\*?\s*\{\\([a-zA-Z0-9]+)\}\s*\{([^}]+)\}/
      name = $1
      macros[name] = { args: 0, opt: nil, body: "\\operatorname{#{$2}}" }
      pos = idx + $~.end(0)
    elsif slice =~ /\A\\def\s*\\([a-zA-Z0-9]+)\s*\{/
      name = $1
      m_end = $~.end(0)
      depth = 1
      curr = idx + m_end
      while curr < len && depth > 0
        char = text[curr]
        if char == "{"
          depth += 1
        elsif char == "}"
          depth -= 1
        elsif char == "\\"
          curr += 1
        end
        curr += 1
      end
      body = text[(idx + m_end)...(curr - 1)].strip
      macros[name] = { args: 0, opt: nil, body: body }
      pos = curr
    else
      pos = idx + 1
    end
  end
  macros
end

# 1. Ensure html/ exists
FileUtils.mkdir_p(HTML_DIR)

# 2. Move *.html, *.sidetoc, book-images.txt into html/
html_files = Dir.glob(File.join(ROOT_DIR, "*.html"))
puts "Moving #{html_files.size} HTML files to #{HTML_DIR}..."
html_files.each do |f|
  dest = File.join(HTML_DIR, File.basename(f))
  FileUtils.mv(f, dest)
end

%w[book.sidetoc book_html.sidetoc book-images.txt].each do |f|
  src = File.join(ROOT_DIR, f)
  FileUtils.mv(src, File.join(HTML_DIR, f)) if File.exist?(src)
end

# Copy / link lwarp.css
FileUtils.cp(File.join(STYLES_DIR, "lwarp.css"), File.join(HTML_DIR, "lwarp.css")) if File.exist?(File.join(STYLES_DIR, "lwarp.css"))
FileUtils.rm_f(File.join(ROOT_DIR, "lwarp.css"))

# Clean up cut files in root
Dir.glob(File.join(ROOT_DIR, "*.cut")).each { |f| FileUtils.rm_f(f) }

# 3. Create symlinks in html/ for assets
Dir.chdir(HTML_DIR) do
  # styles -> ../styles
  FileUtils.ln_sf("../styles", "styles") unless File.exist?("styles")

  # Link all chapter folders: 01_intro -> ../01_intro
  Dir.glob(File.join(ROOT_DIR, "[0-9][0-9]_*")).each do |chap_dir|
    next unless File.directory?(chap_dir)
    base = File.basename(chap_dir)
    FileUtils.ln_sf("../#{base}", base) unless File.exist?(base)
  end

  # Link book-images if present in root
  FileUtils.ln_sf("../book-images", "book-images") if Dir.exist?(File.join(ROOT_DIR, "book-images")) && !File.exist?("book-images")
end

# 4. Build macro dictionary
all_raw_macros = {}
Dir.glob(File.join(ROOT_DIR, "{styles/*.tex,*/*.tex,fragment/*.tex}")).each do |f|
  m = extract_macros_from(File.read(f))
  all_raw_macros.merge!(m)
end

mj_macros = {
  # unicode-math & basic compatibility
  "symbf" => ["\\mathbf{#1}", 1],
  "symbb" => ["\\mathbb{#1}", 1],
  "symcal" => ["\\mathcal{#1}", 1],
  "symsf" => ["\\mathsf{#1}", 1],
  "symtt" => ["\\mathtt{#1}", 1],
  "symit" => ["\\mathit{#1}", 1],
  "symup" => ["{#1}", 1],
  "mleft" => "\\left",
  "mright" => "\\right",
  "llbracket" => "\\unicode{x27E6}",
  "rrbracket" => "\\unicode{x27E7}",
  "xspace" => "",
  "emphOnly" => ["\\textbf{\\emph{#1}}", 1],
  "emphi" => ["\\emph{#1}", 1],
  "Algorithm" => ["\\mathrm{#1}", 1],
  "Term" => ["\\textsf{#1}", 1],
  "CodeComment" => ["\\texttt{#1}", 1],
  "blacksquare" => "\\blacksquare",
  "ds" => "\\displaystyle",
  "ts" => "\\hspace{0.6pt}",
  "EQ" => "\\mathrel{\\;\\;=\\;\\;}",
  "LEQ" => "\\mathrel{\\;\\;\\leq\\;\\;}",
  "GEQ" => "\\mathrel{\\;\\;\\geq\\;\\;}",
  "LT" => "\\mathrel{\\;\\;<\\;\\;}",
  "GT" => "\\mathrel{\\;\\;>\\;\\;}",
  "MakeBig" => ""
}

all_raw_macros.each do |name, info|
  next if mj_macros.key?(name)
  body = info[:body]
  # Remove comments and newlines
  body = body.gsub(/%[^\n]*/, " ").gsub(/\s+/, " ").strip
  # Remove index and label calls
  body = body.gsub(/\\index\{[^{}]*\}/, "")
  body = body.gsub(/\\label\{[^{}]*\}/, "")
  # Skip definitions with document structures
  next if body =~ /\\begin\{(?:minipage|tabbing|program|exercise|center)/ || body =~ /\\end\{document\}/
  next if body =~ /\\(?:epigraph|printbibliography|realchapter|chapterend)/i

  if info[:args] == 0
    mj_macros[name] = body
  elsif info[:opt]
    mj_macros[name] = [body, info[:args], info[:opt]]
  else
    mj_macros[name] = [body, info[:args]]
  end
end

puts "Compiled #{mj_macros.size} MathJax macros."
json_str = JSON.pretty_generate(mj_macros)
File.write(File.join(STYLES_DIR, "mathjax_macros.json"), json_str)

# 5. Update styles/lwarp_mathjax.txt with the macro block
mathjax_txt_path = File.join(STYLES_DIR, "lwarp_mathjax.txt")
mathjax_txt = File.read(mathjax_txt_path)
macros_indent = JSON.pretty_generate(mj_macros).lines.map { |l| "    " + l }.join.strip

new_tex_block = <<~JS.strip
    tags: "ams",
        tagformat: {
            number: function (n) {
                if(MathJax.config.subequations==0)
                    return(MathJax.config.section + n);
                else
                    return(MathJax.config.section + String.fromCharCode(96+n));
            },
        },
    macros: #{macros_indent}
JS

if mathjax_txt =~ /tags:\s*"ams",\s*tagformat:\s*\{.*?\},/m
  mathjax_txt.sub!(/tags:\s*"ams",\s*tagformat:\s*\{.*?\},/m) { new_tex_block }
  File.write(mathjax_txt_path, mathjax_txt)
  puts "Updated #{mathjax_txt_path}"
end

# 6. Update all HTML files in html/
target_htmls = Dir.glob(File.join(HTML_DIR, "*.html"))
puts "Injecting macros into #{target_htmls.size} HTML files in html/..."
target_htmls.each do |hfile|
  c = File.read(hfile)
  if c =~ /tags:\s*"ams",\s*tagformat:\s*\{.*?\},(?:\s*macros:\s*\{.*?\})?/m
    c.sub!(/tags:\s*"ams",\s*tagformat:\s*\{.*?\},/m) { new_tex_block }
    File.write(hfile, c)
  end
end

puts "Done! All HTML files moved to html/ and connected with MathJax macros."
