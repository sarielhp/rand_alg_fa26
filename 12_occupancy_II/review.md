# Review Report: Chapter 12 — Coupon Collector's Problem II

**Source Manuscript:** [occupancy_II.tex](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex)  
**Reviewed Version:** [occupancy_II_reviewed.tex](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II_reviewed.tex)  
**Bibliography Files:** [occupancy_II.bib](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.bib), [occupancy_II_reviewed.bib](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II_reviewed.bib)  
**Verification:** XeLaTeX (via `/home/sariel/bin/l --no-env`), Biber 2.22 — **0 Errors, 0 Alerts, 0 Warnings, 1 Whatever**

---

## 1. Findings (Ordered by Severity)

### [CRITICAL] Missing Chapter Bibliography File Breaks Standalone Compilation
- **Severity / Type:** Confirmed Build & Toolchain Failure.
- **Location:** [occupancy_II.tex#L330-L331](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L330-L331)
- **Evidence & Impact:** The chapter concludes with a citation to Motwani & Raghavan (`\cite{mr-ra-95}`). However, unlike other standalone chapters in the repository, the directory lacked `occupancy_II.bib`. Under sanitized environment builds (`l --no-env` and `./tools/test_chapters_standalone 12`), `BIBINPUTS` is cleared, and `biber` aborted with a fatal error:
  ```
  INFO - Looking for bibtex file 'shortcuts.bib' for section 0
  ERROR - Cannot find 'shortcuts.bib'!
  ```
  This caused standalone compilation to fail with exit code 1.
- **Action Taken:** Created [occupancy_II.bib](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.bib) and [occupancy_II_reviewed.bib](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II_reviewed.bib) containing the entry for `mr-ra-95`. Both the original and reviewed standalone documents now compile with 0 errors and 0 warnings.

---

### [HIGH] Missing Trial Count Exponent on Random Event in Union Bound
- **Severity / Type:** Confirmed Technical / Notation Error.
- **Location (Original):** [occupancy_II.tex#L153](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L153)
- **Location (Reviewed):** [occupancy_II_reviewed.tex#L155](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II_reviewed.tex#L155)
- **Evidence & Impact:** The event $Z_i^r$ was defined on line 129 as the event that the $i$-th coupon was not picked in the first $r$ trials. In the union bound display:
  $$\Prob{X > \beta n \log n} \leq \Prob{\bigcup_{i} Z_i^{\beta n \log n}} \leq n \cdot \Prob{Z_1} \leq n^{-\beta + 1},$$
  the term $\Prob{Z_1}$ omitted the superscript $r = \beta n \ln n$. Writing $Z_1$ without its parameter treats it as an undefined bare variable and obscures how the trial count determines the probability bound.
- **Action Taken:** Corrected $n \cdot \Prob{Z_1}$ to $n \cdot \Prob{Z_1^{\beta n \ln n}}$, added explicit summation/union bounds ($i=1$ to $n$), and annotated with `\remX`.

---

### [HIGH] Informal Limit Exchange in Theorem 12.1.6 ("Fluffy Math") vs Elementary Bonferroni Squeeze
- **Severity / Type:** Mathematical Rigor & Proof Gap.
- **Location (Original):** [occupancy_II.tex#L308-L323](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L308-L323)
- **Location (Reviewed):** [occupancy_II_reviewed.tex#L326-L345](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II_reviewed.tex#L326-L345)
- **Evidence & Impact:** Lines 309–323 evaluate the asymptotic tail probability by asserting:
  $$\lim_{n \rightarrow \infty} \Prob{X > m} = \lim_{n \rightarrow \infty} \lim_{k \rightarrow \infty} S_k^n = \lim_{k \rightarrow \infty} S_k = 1 - \exp(-e^{-c}),$$
  dismissing the interchange as "(using fluffy math)". For any fixed $n$, the inclusion-exclusion sum terminates at $n$, so $\lim_{k\to\infty} S_k^n = S_n^n = \Prob{\bigcup_{i=1}^n Z_i^m}$. Interchanging $\lim_n$ and $\lim_k$ without justification is a gap.
  Crucially, hand-waving is unnecessary: the text already introduced the Bonferroni inequalities on line 275:
  $$S_{2k}^n \leq \Prob{\bigcup_{i=1}^n Z_i^m} \leq S_{2k+1}^n.$$
  For any fixed $k \geq 1$, taking $n \to \infty$ gives $S_{2k} \leq \liminf_{n\to\infty} \Prob{\bigcup Z_i^m} \leq \limsup_{n\to\infty} \Prob{\bigcup Z_i^m} \leq S_{2k+1}$. Taking $k \to \infty$ squeezes both sides to $1 - \exp(-e^{-c})$ with total rigor.
- **Action Taken:** Replaced the informal limit exchange with the Bonferroni squeeze proof and documented the derivation with `\remX`.

---

### [HIGH] Incomplete Proof and Stated Domain in Lemma 12.1.1 (`\lemlab{exponent:m:x}`)
- **Severity / Type:** Mathematical Completeness / Rigor Omission.
- **Location (Original):** [occupancy_II.tex#L38-L53](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L38-L53)
- **Location (Reviewed):** [occupancy_II_reviewed.tex#L40-L58](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II_reviewed.tex#L40-L58)
- **Evidence & Impact:**
  1. The lemma statement reads: "For $x \geq 0$, we have $1-x \leq \exp(-x)$ and $1+x \leq e^x$. Namely, for all $x$, we have $1+x \leq e^x$." Both inequalities actually hold for all $x \in \Re$ ($1-x \leq e^{-x}$ follows immediately from $1+u \leq e^u$ with $u = -x$).
  2. The proof differentiates both sides and checks only $x \geq 0$. Differentiating does not establish the inequality for $x < 0$ without reversing integration bounds. Let $h(x) = e^x - (1+x)$; its derivative $h'(x) = e^x - 1$ is strictly negative for $x < 0$ and strictly positive for $x > 0$. Hence $x = 0$ is the unique global minimum on $\Re$, proving $1+x \leq e^x$ for all $x \in \Re$ cleanly.
- **Action Taken:** Clarified that the inequality holds for all $x \in \Re$, provided the complete critical-point argument, and tracked with `\chgY` and `\remX`.

---

### [MEDIUM] Sign Inversion and Division by $-2yx$ in Lemma 12.1.2 Proof
- **Severity / Type:** Mathematical Rigor / Edge Case.
- **Location (Original):** [occupancy_II.tex#L67-L76](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L67-L76)
- **Location (Reviewed):** [occupancy_II_reviewed.tex#L69-L86](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II_reviewed.tex#L69-L86)
- **Evidence & Impact:** The proof deduces:
  $$y(-2x)(1-x^2)^{y-1} \geq -2yx \iff (1-x^2)^{y-1} \leq 1.$$
  Dividing by $-2yx$ reverses the inequality only when $-2yx < 0$, which requires $x > 0$. If $x < 0$, $-2yx > 0$ and the inequality does not flip. Because both sides depend only on $x^2$, the statement is symmetric; restricting to $x \in (0, 1]$ and appealing to even symmetry resolves the step. Alternatively, this is simply Bernoulli's inequality $(1+t)^y \geq 1+yt$ with $t = -x^2 \in [-1, 0]$ and $y \geq 1$.
- **Action Taken:** Explicitly restricted the derivative step to $x \in (0, 1]$, noted symmetry for $|x| \leq 1$, and added a clarifying `\remX`.

---

### [MEDIUM] Unnecessary Restriction $c > 0$ in Lemma 12.1.5 Conflicting with Theorem 12.1.6
- **Severity / Type:** Mathematical Domain Inconsistency.
- **Location (Original):** [occupancy_II.tex#L185](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L185)
- **Location (Reviewed):** [occupancy_II_reviewed.tex#L196](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II_reviewed.tex#L196)
- **Evidence & Impact:** Lemma 12.1.5 requires $c > 0$, yet Theorem 12.1.6 applies it for "any constant $c \in \Re$". The limit $\lim_{n \to \infty} \binom{n}{k}(1 - k/n)^m = \frac{e^{-ck}}{k!}$ holds identically for all real $c$ because $k^2(n\ln n + cn)/n^2 \to 0$ as $n \to \infty$ regardless of the sign of $c$. Restricting $c > 0$ in the lemma creates a false contradiction.
- **Action Taken:** Relaxed the condition to $c \in \Re$, specified integer $k \geq 0$, made the squeeze theorem explicit in the sandwich derivation, and annotated with `\remX`.

---

### [MEDIUM] Undefined Parameter $m$ and Asymptotic vs Non-Asymptotic Exposition in Lemma 12.1.4
- **Severity / Type:** Pedagogical & Exposition Clarity.
- **Location (Original):** [occupancy_II.tex#L162-L178](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L162-L178)
- **Location (Reviewed):** [occupancy_II_reviewed.tex#L168-L188](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II_reviewed.tex#L168-L188)
- **Evidence & Impact:**
  1. The proof of Lemma 12.1.4 writes $\alpha = (1-1/n)^m$ without defining $m$. It should explicitly set $m = \lceil n \ln n + cn \rceil$.
  2. Following Lemma 12.1.4, lines 176–178 state: "we show a slightly stronger bound on the probability, which is $1 - \exp(-e^{-c})$". Theorem 12.1.6 establishes that $1 - \exp(-e^{-c})$ is the *asymptotic limit* as $n \to \infty$, rather than a non-asymptotic upper bound for finite $n$.
- **Action Taken:** Defined $m = \lceil n \ln n + cn \rceil$, clarified the phrasing regarding the asymptotic limit, and added `\remX`.

---

### [LOW / TYPO] Typographical, Grammatical, and LaTeX Mechanics
- **Severity / Type:** Typographical and Mechanical Errors.
- **Locations & Corrections:**
  - [occupancy_II.tex#L7](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L7): Title typo `Coupon's Collector Problems II` $\to$ `Coupon Collector's Problem II` (wrapped in `\texorpdfstring` to preserve clean PDF bookmarks).
  - [occupancy_II.tex#L23](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L23): Capitalization in attribution `Cry, the beloved country` $\to$ `Cry, the Beloved Country`.
  - [occupancy_II.tex#L33-L35](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L33-L35): Replaced straight typewriter quotes `"` with LaTeX smart quotes ```` ``...'' ````, corrected Douglas Adams' book title to *\emph{Life, the Universe and Everything}*, and replaced double hyphens `--` with em-dash `---`.
  - [occupancy_II.tex#L68](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L68): "compute the derivative of $x$ of both sides" $\to$ "Differentiating with respect to $x$ on both sides".
  - [occupancy_II.tex#L91-L92](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L91-L92): Sentence fragment "As for the left side. Observe that" $\to$ "As for the left side, observe that".
  - [occupancy_II.tex#L115-L116](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L115-L116): "picked in random" $\to$ "picked at random"; "How many trials one has to perform" $\to$ "How many trials must one perform".
  - [occupancy_II.tex#L119](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L119): "and we still did not pick all coupons" $\to$ "and not all coupons have been picked".
  - [occupancy_II.tex#L126](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L126): "for any $t$" $\to$ "for any $t > 0$".
  - [occupancy_II.tex#L128](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L128): Stray comma in "A stronger bound, follows" $\to$ "A stronger bound follows".
  - [occupancy_II.tex#L138-L145](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L138-L145): Mixed notation $\log n$ vs $\ln n$ $\to$ standardized to $\ln n$ (required for $\exp(-\beta \ln n) = n^{-\beta}$).
  - [occupancy_II.tex#L252](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L252): Incorrect idiom "dwelling into the proof" $\to$ "delving into the proof".
  - [occupancy_II.tex#L284](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L284): Displayed equation ended with trailing comma $\to$ period.
  - [occupancy_II.tex#L330](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex#L330): Glaring phonetic typo `Are presentation follows` $\to$ `Our presentation follows`.

---

## 2. Significant Revisions

- **Chapter Title & Navigation:** Corrected grammar to `Coupon Collector's Problem II` with `\texorpdfstring` to prevent hyperref token warnings in PDF metadata.
- **Lemma 12.1.1:** Unified and expanded domain to $x \in \Re$, providing the complete critical-point argument for $x < 0$.
- **Lemma 12.1.2:** Clarified the derivative condition on $x \in (0, 1]$ when dividing by $-2yx$, and noted symmetry for $|x| \leq 1$.
- **Lemma 12.1.3:** Clarified conditions for division by $(1+x)e^x > 0$ ($x \in (-1, 1]$) with the boundary case $x = -1$.
- **Coupon Collector Bounds:** Standardized notation to $\ln n$, restored missing event parameter $Z_1^{\beta n \ln n}$, and defined $m = \lceil n \ln n + cn \rceil$.
- **Lemma 12.1.5:** Extended parameter domain from $c > 0$ to $c \in \Re$ and made the sandwich squeeze explicit.
- **Theorem 12.1.6:** Replaced informal limit exchange ("fluffy math") with a rigorous squeeze proof using the Bonferroni inequalities.
- **Bibliographical Notes:** Fixed "Are" $\to$ "Our" and restored local `.bib` dependencies.

---

## 3. Toolchain & Verification Results

### Build Environment & Commands
- **Compiler:** XeLaTeX via `/home/sariel/bin/l --no-env`
- **Bibliography:** Biber 2.22 via `occupancy_II.bib` / `occupancy_II_reviewed.bib`
- **Standalone Test Suite:** `../tools/test_chapters_standalone 12`

### Verification Results
1. **Original Document (`occupancy_II.tex` with `occupancy_II.bib`):**
   - Output: `✔ No errors/alerts/warnings.`
   - Diagnostics: **0 Errors, 0 Alerts, 0 Warnings, 0 Whatevers**
2. **Reviewed Document (`occupancy_II_reviewed.tex` with `occupancy_II_reviewed.bib`):**
   - Output: `✔ No errors/alerts/warnings.`
   - Diagnostics: **0 Errors, 0 Alerts, 0 Warnings, 1 Whatever** (1.79pt whatever in Lemma 12.1.5 well below threshold)
3. **Standalone Suite Runner:**
   ```
   [ 1/ 1] 12_occupancy_II/occupancy_II.tex ... PASS (clean) [5.5s]
   All 1 chapters compiled successfully as standalones with sanitized environment!
   ```

---

## 4. Author Actions & Recommendations

1. **Commit `occupancy_II.bib`:** Ensure [occupancy_II.bib](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.bib) is committed to Git so future CI builds and `./tools/test_chapters_standalone` pass out-of-the-box.
2. **Accept Bonferroni Squeeze in Theorem 12.1.6:** The rigorous squeeze using Bonferroni inequalities eliminates the informal "fluffy math" while utilizing the exact bounds already stated in the text.
3. **Merge `occupancy_II_reviewed.tex`:** Once reviewed, the tracked improvements in [occupancy_II_reviewed.tex](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II_reviewed.tex) can be applied in-place to [occupancy_II.tex](file:///home/sariel/rand_alg/notes/12_occupancy_II/occupancy_II.tex).
