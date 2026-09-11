# Generating the Randomized Algorithms Notes Webpage

This guide describes how to build, maintain, and verify the standalone HTML/MathJax version of the **Randomized Algorithms** lecture notes and book.

---

## 1. Quick Start

Run all commands from the repository root:

```bash
# 1. Regenerate the entire HTML site (all 58 chapters in parallel)
./tools/gen_html_all_chapters -j 8

# 2. Verify links, anchors, figures, and MathJax rendering across the site
./tools/verify_html_rendering -s
```

The master entrypoint is generated at:
- **Local file**: [html_site/index.html](file:///home/sariel/rand_alg/notes/html_site/index.html)
- **Directory**: [/home/sariel/rand_alg/notes/html_site/](file:///home/sariel/rand_alg/notes/html_site/)

---

## 2. Generation Tool: `tools/gen_html_all_chapters`

The primary generator script is [tools/gen_html_all_chapters](file:///home/sariel/rand_alg/notes/tools/gen_html_all_chapters) (implemented in Ruby at [tools/gen_html_all_chapters.rb](file:///home/sariel/rand_alg/notes/tools/gen_html_all_chapters.rb)). It runs `make4ht` using the XeLaTeX engine (`-x`), injects modern styling, normalizes footnotes, injects cross-referencing anchors, and builds a central Table of Contents.

### CLI Options

```
Usage: ./tools/gen_html_all_chapters [options] [filters...]
    -o, --output DIR                 Output directory (default: html_site)
    -j, --jobs N                     Number of parallel workers (default: 4)
        --toc-only                   Generate only Table of Contents index.html without compiling
    -h, --help                       Display help
```

### Common Workflows

#### A. Full Book Build (Parallel)
Compiles all 58 chapters concurrently with 8 worker threads and refreshes the master Table of Contents (~1.5–2 minutes total):
```bash
./tools/gen_html_all_chapters -j 8
```

#### B. Compile Specific Chapter(s)
Pass directory patterns, numbers, or stems to compile only the targeted chapters:
```bash
# By chapter number or prefix
./tools/gen_html_all_chapters 03 04 15

# By directory or filename pattern
./tools/gen_html_all_chapters talagrand rwalk
```

#### C. Refresh Table of Contents Only
If you updated chapter titles or order in book.tex and only need to update the TOC page:
```bash
./tools/gen_html_all_chapters --toc-only
```

---

## 3. Verification Tool: `tools/verify_html_rendering`

The audit suite is located at [tools/verify_html_rendering](file:///home/sariel/rand_alg/notes/tools/verify_html_rendering) (Ruby script: [tools/verify_html_rendering.rb](file:///home/sariel/rand_alg/notes/tools/verify_html_rendering.rb)). It checks:
1. **HTML & Document Structure**: Valid HTML5 tags, non-truncated content, and navigation bars.
2. **Figures & Images**: Verifies that every `<img>` file exists and has non-zero size.
3. **Internal & Cross-Chapter Links**: Tests that every intra-page anchor (`#anchor`) and inter-chapter link (`../chap/index.html#anchor`) points to an existing DOM target ID.
4. **MathJax & Macros**: Checks display/inline math pairing, macro declarations, and flags stray undefined TeX macros.

### CLI Options

```
Usage: ./tools/verify_html_rendering [options] [filters...]
    -s, --summary                    Show compact summary table
    -v, --verbose                    Print detailed breakdown of all checked elements
        --fix                        Auto-repair fixable link and asset path issues
    -h, --help                       Show help
```

### Common Verification Commands

```bash
# Compact summary table across all 58 chapters
./tools/verify_html_rendering -s

# Detailed report on specific chapters
./tools/verify_html_rendering 03 05 55

# Verbose output with issue contexts
./tools/verify_html_rendering -v 04
```

---

## 4. Architecture & Cross-Reference Handling

### Site Directory Structure

```
html_site/
├── index.html                   # Central Table of Contents & chapter directory
├── styles/
│   ├── web.css                  # Modern reader styles, typography, math spacing
│   └── qed_duck-.png            # QED tombstone graphic
├── 01_intro/
│   ├── index.html               # Compiled chapter HTML
│   └── intro.css                # Chapter-specific style declarations
├── 02_alias_method/
│   ├── index.html
│   └── figs/                    # Embedded chapter figures (.png / .svg)
└── ...                          # 58 chapters
```

### How Cross-References Work
1. **Master Label Registry**: Compiling book.tex generates `junk/book.aux` (mirrored to `styles/master_labels.aux`). This provides the single source of truth for all label names, numbering (`Theorem 3.4.1`, `Figure 4.1`), and containing chapters.
2. **Automated Anchor Injection**: During post-processing, `tools/gen_html_all_chapters.rb` scans the generated chapter HTML and automatically injects matching anchors (`<a id="theo_Markov"></a>`, `<a id="fig_quick_select"></a>`) directly onto target elements (`Theorem`, `Lemma`, `Figure`, `Definition`, `Tedium`, `Section`).
3. **Cross-Chapter Links**: References to other chapters (e.g. `\thmrefY{Markov's inequality}{Markov}`) are rewritten as direct inter-chapter hyperlinks (`../03_expectation/index.html#theo_Markov`).
4. **Fuzzy & Alphanumeric Matching**: Normalizes colons, underscores, and extra braces (e.g. `\thmref{{f:t:algebraic:graph}}` and `\lemlab{dominating:shitfs}`) without requiring edits to the manuscript `.tex` source.
