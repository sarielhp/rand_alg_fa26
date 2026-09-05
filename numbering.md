# Unified Chapter & Page Numbering Architecture (`\ChapterNumPage`)

## 1. Executive Summary & Design Principles

To maximize uniformity and eliminate repository clutter, both the **chapter number** and **starting page number** are unified into a single macro embedded directly at the top of each chapter source file:

```latex
\ChapterNumPage{4}{54}
```

### Core Tenets
1. **100% Uniformity**: Exactly one macro in each chapter file controls both chapter and page offsets.
2. **Zero Sidecar Files & Zero Junk Directories**: No `junk/` folders, no `num.tex`, and no `page_num.tex`.
3. **Complete Standalone Portability**: Any chapter `.tex` file can be shared, emailed, or compiled with only `../prefix.tex`, retaining both its assigned chapter number and its book starting page number.
4. **Milestone-Driven Synchronization**: The author updates numbers at deliberate milestones (e.g. inserting/rearranging chapters or preparing a release), avoiding Git churn during day-to-day writing.
5. **Deterministic TeX Truth**: XeLaTeX itself is the sole authority on numbers, evaluated via a 2-pass compilation of `book.tex`.

---

## 2. LaTeX Syntax & `prefix.tex` Integration

### A. In Each Chapter Source File (`04_quick_sort/quick_sort.tex`)
Standardized on its own line immediately above `\Chapter{...}`:

```latex
\ifx\bookMode\undefined%
    \input{../prefix}%
\fi

\ChapterNumPage{4}{54}
\Chapter{Analyzing QuickSort and Quick{}Select via Expectation}
```

### B. In `prefix.tex` (Standalone Mode)
In standalone mode, `\ChapterNumPage` initializes the chapter and page counters:

```latex
\ifx\bookMode\undefined
  % STANDALONE CHAPTER MODE
  \newcommand{\ChapterNumPage}[2]{%
    % #1 = Chapter Number (0 or empty if unnumbered)
    \if\relax\detokenize{#1}\relax
      \setcounter{chapter}{0}%
    \else\ifnum#1>0
      \setcounter{chapter}{\numexpr#1-1\relax}%
    \else
      \setcounter{chapter}{0}%
    \fi\fi
    % #2 = Starting Page Number
    \if\relax\detokenize{#2}\relax
      \setcounter{page}{1}%
    \else\ifnum#2>0
      \setcounter{page}{#2}%
    \else
      \setcounter{page}{1}%
    \fi\fi
  }
\fi
```

*When `\Chapter{...}` executes, it increments `chapter` from `N - 1` to `N` (e.g., 4), while pages begin at the exact book offset (e.g., 54).*

### C. In `prefix.tex` (Master Book Mode)
In book mode, `\ChapterNumPage` **must be a strict no-op** so it never interferes with natural page flow:

```latex
\ifx\bookMode\undefined
  % (Standalone mode defined above)
\else
  % MASTER BOOK MODE
  % 1. Must be a no-op so embedded numbers do not override book pagination
  \newcommand{\ChapterNumPage}[2]{}

  % 2. Track current chapter directory and filename
  \newcommand{\InputChap}[2]{%
     \def\Dir{#1}%
     \def\CurrentChapFile{#2}%
     \input{#1/#2}%
  }

  % 3. Emit machine-readable mapping directly from the TeX engine
  \renewcommand{\Chapter}[2][]{%
     \chapter[#1]{#2}%
     \typeout{CHAPTER_MAP: \Dir/\CurrentChapFile => chap: \thechapter, page: \thepage}%
  }
\fi
```

*For unnumbered chapters (e.g. `\Chapter*{...}`), `\thechapter` is reported as `0`:*
```latex
\typeout{CHAPTER_MAP: \Dir/\CurrentChapFile => chap: 0, page: \thepage}
```

---

## 3. The Synchronization Tool (`tools/sync_numbers.rb`)

The synchronization script runs XeLaTeX on `book.tex`, extracts the true chapter and page numbers from the engine, and updates `\ChapterNumPage` across the chapter source files.

### Workflow & Guardrails

```
1. PRE-FLIGHT CHECK:
   - Run `git status --porcelain`.
   - Abort if working tree has uncommitted dirty changes (isolates sync from writing edits).

2. CONVERGENCE BUILD (2 Passes):
   - Run Pass 1: `xelatex -interaction=nonstopmode book.tex`
   - Run Pass 2: `xelatex -interaction=nonstopmode book.tex`
   - If either pass fails (exit code != 0): ABORT immediately; touch zero files.
   (Two passes guarantee that TOC shifts and cross-references have fully converged).

3. EXTRACT TRUE NUMBERS:
   - Parse all `CHAPTER_MAP:` markers from the XeLaTeX log/stdout.
   - Example extracted mapping:
       01_intro/intro.tex               => chap: 1,  page: 1
       02_alias_method/alias_method.tex => chap: 2,  page: 15
       04_quick_sort/quick_sort.tex     => chap: 4,  page: 54
       58_prereq/prereq.tex             => chap: 58, page: 890
       00_preface/preface.tex           => chap: 0,  page: 5

4. DIFF & PLAN:
   - Read each chapter file on disk.
   - Match current `\ChapterNumPage{C}{P}`.
   - Identify files where C or P differs from the TeX run.
   - If 0 files changed:
       Print "All chapter and page numbers are up to date." and exit.

5. CHECKPOINT:
   - Create local Git checkpoint tag: `refs/tags/pre-sync-YYYYMMDD-HHMMSS`.

6. ATOMIC IN-PLACE REWRITE:
   - For each modified file:
     * Write updated file to `<file>.tex.tmp`.
     * Atomically rename tmp file over original (File.rename).
   - Programmatic Diff Assertion:
     * Run `git diff` on each file to verify that ONLY the `\ChapterNumPage` line changed.
     * If any other content altered: immediately abort and restore via git checkout.

7. DEDICATED GIT COMMIT:
   - Stage modified chapter files.
   - Commit: `git commit -m "Sync chapter and page numbers with book.tex [checkpoint: <tag>]"`.
   - Print summary report of all synchronized files.

8. INSTANT ROLLBACK:
   - `tools/sync_numbers.rb --revert` resets the repository to the pre-sync checkpoint tag.
```

---

## 4. Critical Edge Cases & Protections

1. **Two-Pass Convergence**: Page numbers shift when earlier chapters expand or when the Table of Contents gains pages. Running two compilation passes ensures page numbers are mathematically stable before writing.
2. **Unnumbered Chapters**: Handled by passing `0` (e.g. `\ChapterNumPage{0}{5}`), preventing TeX `\numexpr` evaluation errors.
3. **Isolated Git History**: Enforcing a clean working tree ensures author prose commits remain separate from automated number updates.
4. **Efficient Storage**: Git delta compression packs 1-line changes across 50 files into negligible disk space (< 1 KB).
5. **Standalone Snapshot Behavior**: Standalone chapter edits remain frozen at their last synchronized starting page until the next intentional book sync.
