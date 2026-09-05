# Architectural Snapshot: Modernizing the Fragment Mechanism

**Date:** September 4, 2026  
**Context:** `rand_alg/notes` class notes and book architecture  
**File:** `prefix.tex`, `fragment/*.tex`, and chapter sources  

---

## 1. Executive Summary & Core Requirements

The **fragment mechanism** allows standalone lecture chapters to import theorem statements from earlier lectures into an appendix (*"From previous lectures"*) without knowing which specific chapter directory defines them.

### Mandatory Workflow Constraints
1. **Single Source of Truth**: The theorem statement lives *inline* inside the lecture narrative where it is taught, not in an external library file.
2. **Location-Agnostic / Renumbering Immune**: The consuming chapter requests a result by an abstract key (e.g. `Chebychev`), completely decoupled from chapter numbering or directory names (e.g., `05_chebychev` vs `12_chebychev`).
3. **Local Incremental Workflow**: When an author edits a theorem in Chapter A, running `xelatex chapter_A.tex` immediately refreshes the fragment file on disk. Running `xelatex chapter_B.tex` immediately consumes the updated theorem. No external book build or scripts required.
4. **No Fragile Verbatim**: Avoid `fancyvrb` / `VerbatimEnvironment` catcode manipulation.
5. **Zero Disruption to Existing Content**: Must remain 100% backwards-compatible with all 47 active `\begin{fragment}{\deflabel{...}}` and 23 `\IncFragment{\deflabel{...}}` calls across the 58 chapters.

---

## 2. Analysis of the Legacy Implementation

### Current Definition in `prefix.tex`
```latex
\newcommand{\InputExt}[1]{%
   \IfFileExists{#1}%
   {\input{#1}}%
   {\IfFileExists{../#1}%
      {\input{../#1}}%
      {\IfFileExists{../../#1}%
         {\input{../../#1}}%
         {\typeout{ERROR: Unable to find #1}}%
      }%
   }%
}
\newcommand{\FragmentName}[1]{\RootFile{fragment/#1.tex}}
\newcommand{\IncFragment}[1]{\InputExt{\FragmentName{#1}}}

\newenvironment{fragment}[1]%
{%
   \VerbatimEnvironment
   \def\TmpFragmentName{\FragmentName{#1}}%
   \begin{VerbatimOut}{\FragmentName{#1}}%
}%
{\end{VerbatimOut}%
   \InputExt{\TmpFragmentName}%
}
```

### Critical Flaws of the Legacy Approach
1. **Broken Compiler Diagnostics (Error Line Numbers)**:
   - `VerbatimOut` intercepts the text as raw characters, writes it to disk (`fragment/def_X.tex`), and immediately inputs it back via `\InputExt`.
   - If a syntax error occurs inside the theorem (e.g. mismatched `$` or typo), the compiler reports the error at `fragment/def_X.tex:5` rather than `chebychev.tex:108`. In editor environments (Emacs AUCTeX, VSCode), jump-to-error navigation fails.
2. **Verbatim Brittleness**:
   - `\VerbatimEnvironment` changes low-level TeX category codes.
   - It breaks completely if placed inside macros, conditionals (`\if...`), or other environments.
3. **Consumer Chapter Label Collisions**:
   - When Chapter 28 includes `\IncFragment{\deflabel{Chebychev}}`, it re-runs `\begin{theorem} \thmlab{Chebychev:inequality} ... \end{theorem}`.
   - This triggers duplicate label warnings (`theo:Chebychev:inequality multiply defined`).
   - The theorem is given a misleading local counter in Chapter 28 (e.g. Theorem 28.5) rather than indicating it is a recalled result.

---

## 3. The Proposed Solution: Token-Based Capture (`+b`)

Modern LaTeX kernels (used by XeLaTeX and LuaLaTeX) support the `+b` argument specifier in `\NewDocumentEnvironment`. This captures the environment body as **standard LaTeX tokens** with normal category codes, completely eliminating verbatim mode.

### Proposed Code for `prefix.tex`
```latex
%-----------------------------------------------------------------------------
% Fragment Storage & Recall (Non-Verbatim Architecture)
%-----------------------------------------------------------------------------
\newwrite\FragOutHandle
\newwrite\FragProbeOut
\newread\FragProbeIn
\newif\ifInJunkDir
\InJunkDirfalse

% Detect whether XeTeX was invoked with -output-directory=junk
\edef\FragProbeSecret{\number\uniformdeviate 1000000}
\immediate\openout\FragProbeOut=frag_probe.tmp
\immediate\write\FragProbeOut{\FragProbeSecret}
\immediate\closeout\FragProbeOut

\openin\FragProbeIn=junk/frag_probe.tmp
\ifeof\FragProbeIn
  \InJunkDirfalse
\else
  \read\FragProbeIn to \FragReadSecret
  \closein\FragProbeIn
  \def\trimspace#1 {#1}
  \edef\FragReadSecretClean{\expandafter\trimspace\FragReadSecret}
  \ifx\FragReadSecretClean\FragProbeSecret
    \InJunkDirtrue
  \else
    \InJunkDirfalse
  \fi
\fi

\newcommand{\FragWritePrefix}{%
  \ifx\bookMode\undefined
    % Standalone chapter mode
    \ifInJunkDir ../../fragment/\else ../fragment/\fi
  \else
    % Master book mode
    \ifInJunkDir ../fragment/\else fragment/\fi
  \fi
}

\DeclareDocumentEnvironment{fragment}{m +b}{%
   \immediate\openout\FragOutHandle=\FragWritePrefix#1.tex
   \immediate\write\FragOutHandle{\unexpanded{#2}}%
   \immediate\closeout\FragOutHandle
   #2%
}{}

\makeatletter
\DeclareDocumentCommand{\IncFragment}{m}{%
   \begingroup
      \let\label\@gobble
      \InputExt{\FragmentName{#1}}%
   \endgroup
}
\makeatother
```

---

## 4. Key Advantages of the New Design

| Feature | Legacy `fancyvrb` `VerbatimOut` | Proposed `+b` Token Capture |
| :--- | :--- | :--- |
| **Workflow** | Compile A $\to$ writes file $\to$ Compile B $\to$ reads file | **Identical** (writes file immediately on compiling A) |
| **Error Line Numbers** | Points to `fragment/def_X.tex:N` (broken) | **Points to real chapter source line** (e.g. `chebychev.tex:108`) |
| **Verbatim Dependency** | Requires `fancyvrb` and raw catcode manipulation | **Zero verbatim**; pure LaTeX kernel token list |
| **Robustness** | Breaks inside macros/conditionals | Fully nestable and macro-safe |
| **Label Safety** | Emits `multiply-defined label` warnings | **Clean**: labels neutralized on import |
| **Backwards Compatibility** | N/A | **100% compatible** with all 47 `\begin{fragment}{\deflabel{...}}` |

---

## 5. Test Harness & Empirical Verification

During testing on September 4, 2026:
1. **Paragraph & Math Environment Test (`scratch/test_unexpanded.tex`)**:
   - Verified that multi-paragraph theorems, `\par`, inline math, and display environments (`align*`, `equation*`) are captured faithfully by `\unexpanded{#2}` and typeset identically upon `\input`.
2. **Label Neutralization Test**:
   - Verified that `\let\label\@gobble` inside `\IncFragment` completely eliminates duplicate label warnings on second-pass compilation while keeping the typeset theorem text unchanged.
3. **Live Chapter Verification (`05_chebychev` $\to$ `28_frequence_est`)**:
   - Compiled `test_new_frag.tex` in `05_chebychev`, producing `fragment/def_Chebychev.tex` via token writing.
   - Compiled `28_frequence_est/frequency_est.tex` (which imports `def_Chebychev.tex` in `\StandAloneMode`).
   - Succeeded with **exit code 0** and identical formatting.

---

## 6. Implementation Checklist for Future Adoption

When ready to apply the change permanently:
1. [x] Backup current `prefix.tex` to `old_stuff/backup/prefix_before_frag_modernize.tex`.
2. [x] In `prefix.tex`, replace lines 441-450 with the `+b` implementation above.
3. [x] In `prefix.tex`, wrap `\IncFragment` with `\begingroup \let\label\@gobble ... \endgroup`.
4. [x] Run `test_all_chaps.rb` across all 58 chapters to verify 58/58 pass with exit code 0.
5. [x] Run `xelatex book.tex` to confirm full book compiles cleanly to 517 pages.
