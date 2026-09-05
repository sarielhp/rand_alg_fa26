# Manuscript Review Report: Chebychev, Sampling and Selection

## 1. Executive Summary

- **Overall Quality Assessment**: This chapter is an exceptionally clear, pedagogical introduction to Chebyshev's inequality and its application to randomized estimation and selection. The narrative progresses logically from first principles (motivating the second moment on Rademacher sums) to Chebyshev's inequality, empirical estimation via sampling, and finally a Floyd--Rivest-style randomized selection algorithm achieving expected $1.5n + O(n^{3/4} \log n)$ comparisons.
- **Core Strengths**: 
  - Strong conceptual progression: proving the moment inequality for $\sum X_i$ before introducing the general theorem makes Chebyshev feel intuitive rather than arbitrary.
  - Practical algorithmic payoff: applying confidence intervals to prune candidate elements for selection is an inspiring, concrete demonstration of probability in algorithm design.
  - The coin-flipping optimization in Lemma 3.3 that saves $0.5n$ comparisons is elegant and well-explained.
- **Primary Revision Priorities**:
  1. **Repair Mathematical Typos in Example 1.3**: The example contained a phantom variable $T_i$ (should be $Y_i$) and a mathematically impossible relation $\Ex{Y^2} = \Var{Y} + \Ex{Y^2}$ (missing parentheses, should be $(\Ex{Y})^2$).
  2. **Correct Indexing Bug in Sampling Setup**: In Section 2, the sample sum was written as $Y = \sum_{i=1}^m \propertyX{r_1}$ (referencing $r_1$ repeatedly) instead of $\propertyX{r_i}$.
  3. **Include the Omitted Figure**: A dedicated Ipe figure `figs/inverse_estimation_fig.tex` (generated via `tools/generate_figure.rb`) was already present in the repository and tested in `test_fig_compile.tex`, but omitted from the chapter text. Including it in Section 3.1.1 anchors the rank-interval intuition.
  4. **Harmonize Notation and Fix Algorithm Variables**: In Section 3.2, the pivot $r_-$ was mistyped as $r_i$ in two places, and the denominator exponent was written as $m^{3/8}$ instead of $n^{3/8}$ (since $m = n^{3/4}$). In Section 2, the estimator was briefly called $\beta$ before switching to $Z$.
  5. **Resolve Huge Overfull Hboxes**: Aligned displays in Section 2 and Section 3.1 had overfull boxes exceeding 100pt and 55pt respectively; splitting them across lines restores clean typography.

---

## 2. Mathematical Rigor & Technical Critique

- **Theorems, Proofs & Claims**:
  - **Lemma 1.1**: The lemma stated a strict inequality $\Prob{|\sum X_i| > t\sqrt{n}} < 1/t^2$, whereas Markov's inequality yields $\leq 1/t^2$. Furthermore, the hypothesis $t > 0$ was implicit and has now been explicitly stated.
  - **Example 1.3**:
    - Line 157 had $\Var{Y} = \sum_{i=1}^m \Var{T_i}$, where $T_i$ was a phantom symbol. Corrected to $\Var{Y_i}$.
    - Line 161 had $\Ex{Y^2} = \Var{Y} + \Ex{Y^2}$, which implies $\Var{Y} = 0$. Corrected to $\Var{Y} + (\Ex{Y})^2$.
  - **Section 2 (Estimation)**:
    - Line 193 defined $Y = \sum_{i=1}^m \propertyX{r_1}$. Corrected to $\sum_{i=1}^m \propertyX{r_i}$.
    - Line 194 introduced $\beta = (n/m)Y$, while Lemma 2.1 and its proof consistently use $Z = (n/m)Y$. Unified to $Z$.
  - **Lemma 3.1 (Inverse Estimation Bound)**:
    - In Part (B), the upper bound was written as $\cardin{[r_-, r_+] \cap U} \leq h - g + 1 = 6n/m + 2t n/\sqrt{m}$. Excluding ranks $\{1, \dots, g\}$ and $\{h+1, \dots, n\}$ leaves ranks $\{g+1, \dots, h\}$, which comprises exactly $h - g$ elements (the $+1$ was an extraneous fencepost addition that was subsequently dropped in the same line).
  - **Section 3.2.1 (Selection Algorithm Failures & Boundary Handling)**:
    - Ranks $r_-$ and $r_+$: When $k = \cardin{S_<}$, the rank-$k$ element is exactly $r_-$; when $k = \cardin{S_<} + \cardin{S_m} + 1$, the rank-$k$ element is exactly $r_+$. Only when $\cardin{S_<} < k \leq \cardin{S_<} + \cardin{S_m}$ does the algorithm recurse/sort inside $S_m$. This boundary condition has been clarified.
  - **Success Probability Consistency (Section 3.2.2 & Theorem 3.4)**:
    - Lemma 3.1 establishes that the interval is good with probability $\geq 1 - 3/t^2$. With $t = \ceil{n^{1/8}}$, this is $1 - 3/n^{1/4}$ (or $1 - O(n^{-1/4})$). The draft claimed $1 - 1/n^{1/4}$. Updated to $1 - 3/n^{1/4}$.
- **Edge Cases & Notation**:
  - **Rank boundaries**: In Lemma 3.1, if $k$ is very small or very close to $n$, the computed indices $\ell_-$ or $\ell_+$ may fall outside $\{1, \dots, m\}$. Annotated with a remark that $\ell_- < 1 \implies r_- = -\infty$ (or $\min(U)$) and $\ell_+ > m \implies r_+ = +\infty$ (or $\max(U)$).
  - **Naming consistency**: Transliteration alternates between "Chebyshev" (Section 1 title, Theorem 1.2 header) and "Chebychev" (Chapter title, Subsection 1.2, theorem label). Flagged for author consistency.

---

## 3. Pedagogical & Presentation Evaluation

- **Intuition & Motivation**:
  - The intuitive lead-in (calculating $\Ex{Y}$ and $\Ex{Y^2}$ for symmetric random walks) is an exemplary pedagogical device.
  - Subsection 3.1.1 ("Inverse estimation -- intuition") clearly explains the duality between estimating counts of items below a threshold and inverting that relation to bracket the rank-$k$ element.
  - In Subsection 3.1.1, $g$ and $h$ were defined twice in immediate succession with slightly differing rounding representations (first with $-2n/m$, then with $\ceil{\dots}$). Annotated to harmonize the presentation.
- **Visuals & Diagram Integration**:
  - `figs/inverse_estimation_fig.tex` depicts the dual axes of sample rank and universe rank with confidence intervals $[r_-, r_+]$. Incorporating this figure into Subsection 3.1.1 resolves a noticeable visual gap.
- **Language & Typography**:
  - Fixed multiple punctuation anomalies (periods inside sentences: `u_n. and we want`, `u. and zero`).
  - Corrected colloquial phrasing: "how the input looks like" $\to$ "what the input looks like".
  - Standardized mathematical grammar: "The variable $Y$ is a binomial distribution" $\to$ "The random variable $Y$ follows a binomial distribution".

---

## 4. Compilation & Linting Diagnostics

- **LaTeX Engine**: `xelatex` (TeX Live 2026 on Linux, OpenType NewComputerModern)
- **Bibliography Tool**: `biblatex` / Standalone chapter mode (Empty bib warning suppressed)
- **Compilation Status**: **PASS — 0 Errors, 0 Warnings, 0 Overfull/Underfull boxes**
  - Generated output: `chebychev_reviewed.pdf` (10 pages)
- **Overfull `\hbox` Diagnostics**:
  - **Line 91 in original (Proof of Lemma 1.1)**: Split with `align*`, **Resolved (0pt)**.
  - **Lines 108–110 (Variance definition)**: Displayed equation with `equation*`, **Resolved (0pt)**.
  - **Example 1.3 (Binomial distribution)**: Clean line break before `where`, **Resolved (0pt)**.
  - **Proof of Lemma 2.1**: Equation chain in `equation*` and `align*`, **Resolved (0pt)**.
  - **Section 3 Heading**: Line break `\\` added to section heading with optional short title, **Resolved (0pt)**.
  - **Lemma 3.1 Part (B)**: Displayed equation and split `align*` line, **Resolved (0pt)**.
  - **Figure 1 (Inverse estimation graphic)**: Scaled graphic with `[width=0.95\linewidth]`, **Resolved (0pt)**.
  - **Section 3.1.1 (Intuition)**: Converted wide inline equations to `equation*`, **Resolved (0pt)**.
  - **Section 3.2.2 (Analysis)**: Word-level track changes and line break, **Resolved (0pt)**.
  - **Lemma 3.3 Statement**: Separated set identifiers `$S_<$, $S_m$, and $S_>$`, **Resolved (0pt)**.
- **chktex Findings**: Cleaned all manuscript-level warnings. Shared preamble warnings (`unicode-math` overwrites, TS1 font substitutions, empty bibliography, and standalone external hyperref) cleanly handled.

---

## 5. Section-by-Section Review

| Section | Status | Key Observations & Recommendations |
| :--- | :--- | :--- |
| **Title & Epigraph** | Pass | Quoted humor effectively sets up predictable notification. Transliteration note added regarding "Chebyshev" vs "Chebychev". |
| **1.1 Example: A better inequality via moments** | Pass (with edits) | Made $t > 0$ explicit, fixed strict inequality to $\leq$, and split display equation to eliminate $10.4\,\text{pt}$ overfull box. |
| **1.2 Chebyshev's inequality** | Pass (with edits) | Theorem and proof are solid. Example 1.3 repaired: eliminated phantom $T_i$ and impossible $\Ex{Y^2} = \Var{Y} + \Ex{Y^2}$. |
| **2. Estimation via sampling** | Pass (with edits) | Fixed summation index $r_1 \to r_i$, unified estimator notation $\beta \to Z$, repaired run-on punctuation, and eliminated $108\,\text{pt}$ overfull equation. |
| **3.1 Inverse estimation** | Pass (with edits) | Clarified sorted-sample rank deduction $\ell_- < Y < \ell_+ \implies r_- \leq s_k \leq r_+$; repaired $55.7\,\text{pt}$ overfull equation; corrected fencepost count $h-g+1 \to h-g$; noted boundary clamping for $\ell_- < 1$ and $\ell_+ > m$. |
| **3.1.1 Inverse estimation -- intuition** | Pass (with edits) | Integrated previously unreferenced figure `figs/inverse_estimation_fig.tex`; added noun "intervals"; flagged redundant double-definition of $g, h$. |
| **3.2.1 Randomized selection: The algorithm** | Pass (with edits) | Fixed $r_i \to r_-$; corrected denominator exponent $m^{3/8} \to n^{3/8}$; added exact return cases for $k = |S_<|$ and $k = |S_<| + |S_m| + 1$. |
| **3.2.2 Analysis & Improved Comparisons** | Pass (with edits) | Fixed success probability from $1 - 1/n^{1/4}$ to $1 - 3/n^{1/4}$ (consistent with Lemma 3.1); polished grammatical agreements; added note on per-round vs overall sorting comparisons. |

---

## 6. Detailed Editing Log

### Section 1: Chebyshev's inequality & Moments Example
- **Line 36**:
  - *Original Excerpt*: "with probability half for each value, for $i=1,\ldots, n$ (all picked independently)."
  - *Type*: Prose & Academic Style
  - *Annotated Change*: `\chgY{with probability half for each value}{each with probability $1/2$}` ... `\chgY{(all picked independently)}{(mutually independent)}`
  - *Rationale*: Idiomatic mathematical formulation.
- **Lines 75–76 (Lemma 1.1)**:
  - *Original Excerpt*: "$\Prob{ \cardin{\sum_i X_i} > t \sqrt{n}}  < 1/t^2$."
  - *Type*: Mathematical Correction
  - *Annotated Change*: `\newX{For any $t > 0$,}` ... `$\Prob{ \cardin{\sum_i X_i} \geq t \sqrt{n}} \leq 1/t^2$. \remX{...}`
  - *Rationale*: Requires $t > 0$. Markov's inequality establishes non-strict inequality $\leq 1/t^2$.
- **Lines 81–92 (Proof of Lemma 1.1)**:
  - *Original Excerpt*: Single-line unaligned display equation.
  - *Type*: LaTeX Fix & Overfull Box Repair
  - *Annotated Change*: Split across two aligned lines in `align*`.
  - *Rationale*: Eliminates $10.4\,\text{pt}$ overfull hbox.
- **Lines 150–162 (Example 1.3)**:
  - *Original Excerpt*: "The variable $Y$ is a binomial distribution with probability $p$, and $m$ samples."
  - *Type*: Mathematical & Terminological Precision
  - *Annotated Change*: `The \chgY{variable}{random variable} $Y$ \chgY{is}{has} a binomial distribution with probability $p$, and $m$ \chgY{samples}{trials}. \remX{...}`
  - *Rationale*: A random variable follows or possesses a distribution; it is not the distribution itself.
- **Line 158 (Example 1.3)**:
  - *Original Excerpt*: "$\smash{\sum_{i=1}^m \Var{T_i}} = m p (1-p)$"
  - *Type*: Mathematical Bug Fix
  - *Annotated Change*: `\smash{\sum_{i=1}^m \Var{Y_i}} = m p (1-p). \remX{Corrected typo: Original text had $\Var{T_i}$ instead of $\Var{Y_i}$.}`
  - *Rationale*: Variables are named $Y_i$; $T_i$ was a phantom symbol.
- **Line 163 (Example 1.3)**:
  - *Original Excerpt*: "$\Ex{\smash{Y^2}} = \Var{Y} + \Ex{Y^2} = m p (1-p) + m^2 p^2$."
  - *Type*: Mathematical Bug Fix
  - *Annotated Change*: `$\Ex{\smash{Y^2}} = \Var{Y} + \pth{\Ex{Y}}^2 = m p (1-p) + m^2 p^2$. \remX{...}`
  - *Rationale*: $\Ex{Y^2} = \Var{Y} + \Ex{Y^2} \implies \Var{Y} = 0$. The second term must be $(\Ex{Y})^2$.

### Section 2: Estimation via sampling
- **Lines 179–188**:
  - *Original Excerpt*: "randomized algorithms, is that they sample the world; that is, learn how the input looks like... a set of $U$ of $n$ objects $u_1, \ldots, u_n$. and we want... element $u$. and zero otherwise."
  - *Type*: Low-Level Grammar & Punctuation
  - *Annotated Change*: `\chgY{algorithms, is that they sample the world; that is, learn how the input looks like}{algorithms is that they sample the world---that is, learn what the input looks like}` ... `\chgY{a set of $U$ of $n$ objects $u_1, \ldots, u_n$. and we want}{a set $U$ of $n$ objects $u_1, \ldots, u_n$, and we want}` ... `\chgY{$u$. and zero}{$u$, and $0$}`
  - *Rationale*: Fixed comma splices, erroneous mid-sentence periods, and ungrammatical idioms.
- **Line 193**:
  - *Original Excerpt*: "$Y = \sum_{i=1}^m \propertyX{r_1}$."
  - *Type*: Index Typo / Critical Bug
  - *Annotated Change*: `$Y = \sum_{i=1}^m \propertyX{r_i}$. \remX{Corrected index: Original text had $\propertyX{r_1}$ inside the summation.}`
  - *Rationale*: Summing $r_1$ yields $m \cdot \propertyX{r_1}$; must sum over index $i$.
- **Line 194**:
  - *Original Excerpt*: "The estimate for $\numC$ is $\beta = (n/m) Y$. It is natural to ask how far is $\beta$ from the true value $\numC$."
  - *Type*: Notation Harmonization & Word Order
  - *Annotated Change*: `\chgY{$\beta = (n/m) Y$. It is natural to ask how far is $\beta$ from}{$Z = (n/m) Y$. It is natural to ask how far $Z$ is from}`
  - *Rationale*: Lemma 2.1 and proof denote the estimate as $Z$, not $\beta$. Indirect question word order corrected.
- **Lines 273–289 (Proof of Lemma 2.1)**:
  - *Original Excerpt*: 4-term chain on a single line of `align*`.
  - *Type*: LaTeX Fix & Overfull Box Repair
  - *Annotated Change*: Aligned across separate lines with `\\&`.
  - *Rationale*: Eliminates a massive $107.98\,\text{pt}$ overfull hbox.

### Section 3: Randomized selection
- **Lines 303–304**:
  - *Original Excerpt*: "number in $U$ -- that is $\EBRY{U}{i}$ is the number of \emphi{rank} $i$ in $U$."
  - *Type*: Typography
  - *Annotated Change*: `\chgY{-- that is}{---that is,}`
  - *Rationale*: Em-dash typography and comma.
- **Line 337 (Lemma 3.1 Proof)**:
  - *Original Excerpt*: Direct definition of $r_-$ and $r_+$.
  - *Type*: Edge-Case Annotation
  - *Annotated Change*: `\remX{Boundary condition: If $\ell_- < 1$, we set $r_- = -\infty$ (or the minimum element of $U$); similarly, if $\ell_+ > m$, we set $r_+ = +\infty$ (or the maximum element of $U$).}`
  - *Rationale*: Identifies missing base case when $k$ is near 1 or $n$.
- **Line 348 (Lemma 3.1 Proof)**:
  - *Original Excerpt*: "In particular, if this happens, then $r_- \leq \EBRY{U}{k} \leq r_+$."
  - *Type*: Pedagogical Step
  - *Annotated Change*: `\newX{since $\Sample$ is sorted and $\ell_- < Y < \ell_+$, we have}`
  - *Rationale*: Connects the rank $Y$ of $\EBRY{U}{k}$ in $\Sample$ to the bracketed array indices.
- **Lines 362–372 (Lemma 3.1 Proof)**:
  - *Original Excerpt*: Long single-line equation for $(g/n)m + t\sqrt{m}/2 < \ell_-$.
  - *Type*: LaTeX Fix & Overfull Box Repair
  - *Annotated Change*: Split across aligned lines in `align*`.
  - *Rationale*: Eliminates $55.7\,\text{pt}$ overfull hbox.
- **Line 380 (Lemma 3.1 Proof)**:
  - *Original Excerpt*: "$\cardin{[r_-, r_+] \cap U} \leq h-g + 1 = 6 \frac{n}{m} + 2t \frac{n}{\sqrt{m}}$"
  - *Type*: Mathematical Fencepost Correction
  - *Annotated Change*: `\cardin{[r_-, r_+] \cap U} \leq \chgY{h-g + 1}{h-g} = 6 \frac{n}{m} + 2t \frac{n}{\sqrt{m}} \leq 8 \frac{tn}{\sqrt{m}}. \remX{...}`
  - *Rationale*: The excluded ranks are $\{1,\dots,g\}$ and $\{h+1,\dots,n\}$, leaving candidate ranks $\{g+1,\dots,h\}$, which contains $h-g$ elements. The $+1$ was an accidental addition dropped in the same step.
- **Line 390 (Subsection 3.1.1)**:
  - *Original Excerpt*: Text-only intuition section without diagram.
  - *Type*: Visual Pedagogical Enhancement
  - *Annotated Change*: `\newX{\input{\File{figs/inverse_estimation_fig}}} \remX{...}`
  - *Rationale*: Includes the orphaned figure already prepared in the workspace.
- **Line 458 (Subsection 3.1.1)**:
  - *Original Excerpt*: "the three confidence $\Interval(g), \Interval(k)$ and $\Interval(h)$ do not intersect."
  - *Type*: Missing Word
  - *Annotated Change*: `the three confidence \newX{intervals} $\Interval(g), \Interval(k)$ and $\Interval(h)$ do not intersect.`
  - *Rationale*: Grammatical completeness.
- **Line 486 & 488 (Subsection 3.2.1)**:
  - *Original Excerpt*: "$\EBRY{S}{k} \in [r_i, r_{+}]$" and "$S \cap (r_i, r_+)$"
  - *Type*: Typo / Variable Collision
  - *Annotated Change*: Replaced $r_i$ with $r_-$ in both places (`\remX{...}`).
  - *Rationale*: $r_i$ is undefined; the lower pivot is $r_-$.
- **Line 492 (Subsection 3.2.1)**:
  - *Original Excerpt*: "$O(n^{1/8} n / m^{3/8}) = O(n^{3/4})$"
  - *Type*: Mathematical / Typographic Typo
  - *Annotated Change*: Replaced $m^{3/8}$ with $n^{3/8}$ (`\remX{...}`).
  - *Rationale*: Since $m = \ceil{n^{3/4}}$, $\sqrt{m} = n^{3/8}$. Writing $m^{3/8}$ was a slip mixing $m$ and $n$.
- **Lines 512–516 (Subsection 3.2.1)**:
  - *Original Excerpt*: "Otherwise, the algorithm need to compute the element of rank $k - \cardin{S_<}$ in the set $S_m$..."
  - *Type*: Algorithmic Boundary Precision
  - *Annotated Change*: `\newX{if $k = \cardin{S_<}$, the algorithm returns $r_-$; if $k = \cardin{S_<} + \cardin{S_m} + 1$, it returns $r_+$. Otherwise, $\cardin{S_<} < k \leq \cardin{S_<} + \cardin{S_m}$, and} the algorithm \chgY{need to}{needs to} ...`
  - *Rationale*: If $k$ coincides with the rank of $r_-$ or $r_+$, sorting $S_m$ is unnecessary (and $k - |S_<| = 0$ is an invalid rank within $S_m$).
- **Lines 521 & 567 (Subsection 3.2.2 & Theorem 3.4)**:
  - *Original Excerpt*: "by probability $\geq 1-1/n^{1/4}$, we succeeded in" and "probability of success $\geq 1 - 1/n^{1/4}$"
  - *Type*: Mathematical Accuracy
  - *Annotated Change*: `\chgY{by probability $\geq 1-1/n^{1 /4}$, we succeeded in}{with probability $\geq 1-3/n^{1 /4}$, we succeed on}` and `$p \geq 1 - 3/n^{1/4}$`
  - *Rationale*: In Lemma 3.1, the success probability is $1 - 3/t^2$. With $t = n^{1/8}$, this yields $1 - 3/n^{1/4}$.
- **Lines 537–562 (Lemma 3.3)**:
  - *Original Excerpt*: "If a number of is in $S_<$ ... comparing it $r_-$ ... whether they are in ... expected numbers of comparisons ... linearity of expectations"
  - *Type*: Low-Level Grammar & Agreement
  - *Annotated Change*: `\chgY{number of is}{number is}`, `\chgY{comparing it $r_-$}{comparing it to $r_-$}`, `\chgY{whether they are}{whether it is}`, `\chgY{numbers}{number}`, `\chgY{expectations}{expectation}`
  - *Rationale*: Multiple grammatical and prepositional cleanups.
- **Lines 568–574 (Theorem 3.4 Proof)**:
  - *Original Excerpt*: "till success is $\leq 1/p \leq 1+ 2/n^{1/4}$. As such, the expected number... $\Ex{X \cdot (1.5n + O(n^{3/4}\log n))}$"
  - *Type*: Proof Polish & Repetition Reduction
  - *Annotated Change*: Removed repetitive "As such", clarified geometric expectation $\Ex{X} = 1/p \leq 1 + O(n^{-1/4})$, and added an explanatory remark on the worst-case per-round bound via Wald's identity.
  - *Rationale*: Strengthens pedagogical clarity and rigor.

---

## 7. Actionable Author Checklist

- [ ] **Accept Mathematical Typo Fixes**: Verify corrections in Example 1.3 ($\Var{Y_i}$ instead of $\Var{T_i}$; $(\Ex{Y})^2$ instead of $\Ex{Y^2}$).
- [ ] **Accept Index Typo Fix**: Confirm $Y = \sum_{i=1}^m \propertyX{r_i}$ in Section 2.
- [ ] **Decide on Transliteration**: Standardize throughout on either "Chebyshev" (modern standard) or "Chebychev" (traditional French transliteration).
- [ ] **Adopt Figure Inclusion**: Keep `\input{\File{figs/inverse_estimation_fig}}` in Section 3.1.1 to visually communicate the confidence interval mechanism.
- [ ] **Accept Algorithmic Boundary Check**: Retain the explicit cases for $k = \rank(r_-)$ and $k = \rank(r_+)$ in Section 3.2.1 before delegating to $S_m$.
- [ ] **Adopt Multi-line Aligned Displays**: Maintain the line breaks in Section 2 and Section 3.1 proof displays to preserve clean margins and eliminate overfull boxes.
