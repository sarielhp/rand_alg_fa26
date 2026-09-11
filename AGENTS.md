# AGENTS.md — AI Agent Guide for Randomized Algorithms Notes

This document provides essential instructions, architectural guidelines, and tooling conventions for AI coding agents operating in this repository.

---

## 1. Repository Architecture & Dual-Mode LaTeX Compilation

This repository contains the lecture notes and forthcoming book on **Randomized Algorithms** by Sariel Har-Peled.

The codebase is engineered to support **two independent modes of compilation**:
1. **Master Book Mode** (`book.tex`): Compiles all 58 chapters into a unified book PDF (`book.pdf`) with continuous pagination, unified bibliography, cross-chapter references, table of contents, and indices.
2. **Standalone Chapter Mode** (e.g. `01_intro/intro.tex`): Each chapter can be compiled independently inside its own folder into a standalone, self-contained PDF.

### Directory Layout

```
notes_test/
├── book.tex                 # Master book entrypoint (\InputChap{dir}{file})
├── AGENTS.md                # Agent instruction & architecture guide (this file)
├── numbering.md             # Detailed design of \ChapterNumPage synchronization
├── p.md                     # Proposal & design notes on style isolation
├── styles/                  # Shared style files, packages, and assets
│   ├── prefix.tex           # Universal LaTeX preamble (handles both book & standalone modes)
│   ├── qed_duck.pdf         # QED tombstone graphic
│   └── notations.sty        # Notation definitions
├── refs/                    # Master bibliography database (.bib files)
├── fragment/                # Text fragment definitions shared across chapters
├── tools/                   # Ruby automation & maintenance tool suite
│   ├── sync_chapters_info   # Symlink -> sync_numbers.rb (syncs chapter/page numbers)
│   ├── test_chapters_standalone # Symlink -> test_all_chaps.rb (runs l -no-env suite)
│   ├── clean                # Symlink -> clean_latex.rb (book.fls-based deep cleaner)
│   ├── score                # LaTeX error/warning log analyzer
│   └── detect_unused_macros.rb # Macro reference auditor
└── 01_intro/ ... 58_prereq/ # 58 individual chapter directories
```

---

## 2. Chapter Independence & `styles/` Resolution

### The `styles/` Pattern
All shared preambles and global assets live under `styles/`. To maintain clean, standalone portability without cluttering the root directory:
- Every chapter directory contains a relative symlink: `styles -> ../styles`.
- Every chapter `.tex` preamble must begin with:
  ```latex
  \makeatletter
  \def\input@path{{styles/}}
  \makeatother
  \ifx\bookMode\undefined%
      \input{prefix}%
  \fi
  ```

### Rules for Agents
- **Preserve Relative Symlinks**: Never delete or convert `styles -> ../styles` into absolute links or duplicate copies.
- **Portability Contract**: Any single chapter directory plus the top-level `styles/` directory can be packaged, emailed, or compiled anywhere on any standard TeX Live installation.
- **Graphic Assets**: Shared graphics like `qed_duck.pdf` must be loaded from `styles/` (e.g. `\includegraphics{styles/qed_duck.pdf}`).

---

## 3. Chapter and Page Numbering (`\ChapterNumPage`)

### The Unified Macro
Standalone chapter PDFs must display the exact chapter number and starting page number assigned to them within `book.tex`.

Both offsets are unified into a single macro placed immediately above `\Chapter{...}` in each chapter file:
```latex
\ChapterNumPage{4}{54}
\Chapter{Analyzing QuickSort and Quick{}Select via Expectation}
```

### Behavior Across Modes
- **Standalone Mode** (`\bookMode` undefined):
  `\ChapterNumPage{C}{P}` initializes `\setcounter{chapter}{C - 1}` and `\setcounter{page}{P}`. When `\Chapter{...}` executes, the chapter counter increments to `C` and the first page starts at `P`.
- **Book Mode** (`book.tex` defines `\def\bookMode{1}`):
  `\ChapterNumPage` is defined in `styles/prefix.tex` as a strict no-op:
  ```latex
  \newcommand{\ChapterNumPage}[2]{}
  ```
  This ensures `book.tex` maintains continuous, unperturbed chapter and page flow.

### Strict Prohibition
- **NEVER create sidecar numbering files**: Legacy files like `junk/num.tex`, `page_number.txt`, or local `junk/` directories are obsolete. Do NOT reintroduce them.

---

## 4. Automation Tools (`tools/`)

All repository scripts MUST be written in **Ruby** (`tools/*.rb`). Standalone executable scripts must use `#!/usr/bin/env ruby` and have executable permissions (`chmod +x`).

### 1. `tools/sync_chapters_info` (symlink to `tools/sync_numbers.rb`)
- **Purpose**: Synchronizes `\ChapterNumPage{C}{P}` in all 58 chapter `.tex` files with the actual chapter numbers and starting pages determined by `book.tex`.
- **How it works**:
  1. Creates an automatic Git tag checkpoint (`pre-sync-YYYYMMDD-HHMMSS`).
  2. Compiles `book.tex` (two passes of XeLaTeX) to resolve references and page numbers.
  3. Parses `CHAPTER_MAP: <dir> <file> <chap_num> <page_num>` emitted by `book.tex`.
  4. Modifies `\ChapterNumPage{...}{...}` in each chapter file in place.
- **Usage**:
  ```bash
  ./tools/sync_chapters_info          # Run synchronization
  ./tools/sync_chapters_info --dry-run # Preview changes without writing
  ./tools/sync_chapters_info --revert  # Roll back to the pre-sync Git checkpoint
  ```

### 2. `tools/test_chapters_standalone` (symlink to `tools/test_all_chaps.rb`)
- **Purpose**: Verifies that all 58 chapters compile successfully as standalone documents under strict environment variable sanitization.
- **Environment Sanitization**:
  The script neutralizes 35 TeX/LaTeX environment variables (`TEXINPUTS`, `BIBINPUTS`, `BSTINPUTS`, `TEXMFHOME`, etc.) in the runner process, injects unsetting hashes (`nil`) at child process spawn, and verifies pre-flight probes before running `l -no-env -s`.
- **Usage**:
  ```bash
  ./tools/test_chapters_standalone             # Full multi-pass test of all 58 chapters (parallel)
  ./tools/test_chapters_standalone -u          # Quick single-pass test (-u)
  ./tools/test_chapters_standalone -j 8        # Specify worker concurrency (default: 8)
  ./tools/test_chapters_standalone 01 02 vc    # Test specific chapters matching filters
  ```

### 3. `tools/clean` (symlink to `tools/clean_latex.rb`)
- **Purpose**: Deep repository cleanup. Uses `book.fls` recorder trace from XeLaTeX to identify truly accessed files versus temporary build junk.
- **Safety**: Preserves figure sources (`.ipe`, `.fig`, `.gnuplot`), style files, scripts, and chapter `.bib` files.
- **Usage**:
  ```bash
  ./tools/clean                # Compile book with -recorder and clean all temporary files
  ./tools/clean --skip-compile # Fast cleanup reusing existing book.fls
  ./tools/clean -n             # Dry-run preview
  ```

### 4. `tools/gen_pdf_all_chapters`
- **Purpose**: Compiles all chapter standalone PDFs in parallel using `l -no-env -s`, ensuring all chapter directories contain up-to-date `.pdf` files.
- **Usage**:
  ```bash
  ./tools/gen_pdf_all_chapters             # Full multi-pass compilation (parallel)
  ./tools/gen_pdf_all_chapters -u          # Fast single-pass compilation
  ./tools/gen_pdf_all_chapters -j 8        # Set concurrency (default: 8)
  ./tools/gen_pdf_all_chapters 01 02 vc    # Update specific matching chapters
  ```

### 5. `tools/post_to_webpage`
- **Purpose**: Copies compiled chapter PDFs from `notes/` to their corresponding lecture bundles in `webpage/content/lectures/`, normalizes front matter references, rebuilds the site with Hugo, and deploys it to the server.
- **Usage**:
  ```bash
  ./tools/post_to_webpage                  # Post all updated chapter PDFs to webpage & deploy
  ./tools/post_to_webpage --dry-run        # Preview changes without modifying files
  ./tools/post_to_webpage 03 04            # Post specific lectures only
  ```

---

## 5. Environment Isolation & LaTeX Compilation

### The `l` Compiler Wrapper
The primary LaTeX build driver on the system is `/home/sariel/bin/l`.

- **Environment Leakage**: The author's environment exports variables like:
  ```bash
  TEXINPUTS=/home/sariel/papers/styles//:.:../:../../:
  BIBINPUTS=/home/sariel/papers/bib:
  TEXMFHOME=/home/sariel/.texmf_2023
  ```
- **The `-no-env` Flag**: To ensure standalones compile without relying on external styles or macros from `~/papers/styles`, compile with:
  ```bash
  l -no-env document.tex
  ```
- **Testing Flag `-s` / `--score`**: Suppresses verbose terminal output and reports clean summary counts (`Errors: 0, Warnings: X`).

---

## 6. Coding & Behavioral Rules for AI Agents

1. **Scripting Language**: Always use **Ruby** for automation, testing, file manipulation, and data processing. Never create Python, Bash, or Perl scripts unless Ruby lacks necessary native bindings.
2. **Token Efficiency & Brevity**: Keep chat responses concise, terse, and direct. Omit conversational filler.
3. **Clickable Links**: In responses and artifacts, always link code symbols, tools, and files using markdown links with the `file://` scheme (e.g. `[tools/sync_chapters_info](file:///home/sariel/rand_alg/notes_test/tools/sync_chapters_info)`).
4. **Git Hygiene**:
   - Always check `git status` after operations.
   - Run `./tools/clean --skip-compile` after running standalone tests to clean up chapter PDFs and auxiliary files.
   - Do not commit generated build artifacts (`.aux`, `.log`, `.fls`, `.synctex.gz`, chapter `.pdf`s).
