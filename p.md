# Architecture for Making Chapters Independent

## 1. Objective

To provide a minimal, reliable mechanism to package or export any book chapter so that it compiles 100% standalone on any system with zero dependencies on the rest of the book repository.

---

## 2. Complete Dependency Audit for a Standalone Chapter

A single chapter depends on more than just `prefix.tex`:

1. **Preamble & Styles**: `prefix.tex` (fonts, Memoir configuration, macros, algorithm environments).
2. **QED Symbol Asset**: `shared/qed_duck.pdf` (Note: `prefix.tex` already includes an automatic fallback to `$\blacksquare$` if the PDF is missing).
3. **Bibliography**: Active BibTeX records cited by the chapter.
4. **Local Figures**: Vector drawings and graphics located in `<chapter_dir>/figs/`.
5. **CRITICAL DEPENDENCY — Theorem Fragments (`\IncFragment{...}`)**:
   - Over **20 chapters** import theorem statements from earlier lectures via `\IncFragment{...}`:
     - `14_treaps/treaps.tex` imports `Markov`
     - `16_chernoff_app/chernoff_app.tex` imports `c_h_r_0_1`, `Chernoff_simplified`, `chernoff_delta_big`
     - `28_frequence_est/frequency_est.tex` imports 9 fragments (`Chebychev`, `Chernoff_2_s`, etc.)
     - `40_vc/vc_dim.tex` imports 8 fragments (`convex_hull`, `Chebychev`, `Sauer_lemma`, etc.)
   - **If fragments are not bundled or inlined, these chapters will fail to compile standalone.**

---

## 3. Why In-Repo Duplication (`styles/` in every chapter) is an Anti-Pattern

Placing a `styles/` folder containing a copy of `prefix.tex` inside all 58 chapters in the repository creates severe maintenance issues:
- **58 Duplicate Copies**: You now have 58 copies of `prefix.tex` to maintain.
- **Instant Desync**: Tweaking a macro, font setting, or package in one chapter leaves the other 57 out of date.
- **Fragment Neglect**: Having `styles/` still does not solve the fragment dependency problem for the 20+ chapters that rely on `fragment/*.tex`.

---

## 4. The Recommended Solution: Adaptive Loading + Exporter Tool

The optimal architecture separates **in-repo development** from **standalone distribution**:

### Part 1: Adaptive Prefix Loading in Chapters
Modify the preamble of chapter files to resolve `prefix.tex` adaptively:

```latex
\ifx\bookMode\undefined
  \IfFileExists{./prefix.tex}{\input{./prefix.tex}}{%
  \IfFileExists{styles/prefix.tex}{\input{styles/prefix.tex}}{%
  \input{../prefix}}}
\fi
```

#### Why this works:
- **Inside the book repo**: Finds `../prefix.tex` as normal. No duplicate files in the repository.
- **Exported with local prefix**: Finds `./prefix.tex` or `styles/prefix.tex` automatically without changing a single line of LaTeX code.

---

### Part 2: Automated Chapter Exporter Tool (`tools/export_chapter.rb`)

Rather than manually hunting for citations, copying styles, and tracking down theorem fragments, a single automated tool creates a verified, self-contained standalone package on demand.

#### Usage
```bash
# Export chapter to a standalone directory
tools/export_chapter.rb 04_quick_sort --dest ~/Desktop/quick_sort_standalone

# Or export as a clean, ready-to-distribute ZIP archive
tools/export_chapter.rb 14_treaps --zip
```

#### What the Exporter Does Automatically:
1. **Copies Chapter Source & Figures**: Copies the `.tex` file and all assets in `figs/`.
2. **Extracts Exact Bibliography**:
   - Scans all `\cite{...}` keys inside the chapter.
   - Extracts only the matching BibTeX records into a standalone `<chapter>.bib`.
3. **Bundles or Inlines Referenced Fragments**:
   - Scans for `\IncFragment{<name>}` in the chapter.
   - Copies the required `fragment/<name>.tex` files into a local `fragment/` folder (or inlines them directly into the document), resolving the dependency.
4. **Bundles Styles**: Copies `prefix.tex` and `shared/qed_duck.pdf`.
5. **Verifies Compilation**: Runs `xelatex` on the exported bundle in an isolated temporary location, guaranteeing that the exported chapter compiles with zero errors before delivering the package.

---

## 5. Architectural Summary

| Dimension | Manual `styles/` in every repo folder | Adaptive Loading + Exporter Tool |
| :--- | :--- | :--- |
| **In-Repo Copies of `prefix.tex`** | 58 duplicate copies | **1 master copy (DRY)** |
| **Maintenance Overhead** | High (manual syncing across 58 dirs) | **Zero** |
| **Fragment Handling (`\IncFragment`)** | Broken (~20 chapters fail) | **Fully automated and bundled** |
| **Bibliography Handling** | Manual search & copy | **Automated citation extraction** |
| **Verification** | Hope it compiles | **Automated compile-check gate** |
| **Delivery** | Manual file copying | **1-command export (`--dest` or `--zip`)** |
