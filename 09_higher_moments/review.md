# Manuscript Review Report: Chapter 09 (Higher Moments and Some Inequalities)

## 1. Findings

### [Finding 1] Combinatorial Error in Fourth Moment Calculation (Exercise 2.3 & Lemma 2.4)
- **Severity & Type:** Confirmed Mathematical Bug (Major)
- **Location:** Original: [higher_moments.tex:L339, L363](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments.tex#L339) | Reviewed: [higher_moments_reviewed.tex:L342, L363](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L342)
- **Evidence & Impact:**
  1. In [Exercise 2.3](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments.tex#L339), item 3 claimed that $\Ex{X^4} = 6n^2 - 5n$ for $X = \sum_{i=1}^n X_i$ with independent symmetric signs $X_i \in \{-1, +1\}$.
  2. Expanding $X^4 = (\sum_{i=1}^n X_i)^4$, non-zero expectations require even powers on every index. There are only two non-zero cases:
     - All 4 indices equal ($i=j=k=\ell$): $n$ terms with $\Ex{X_i^4} = 1$, contributing $n \times 1 = n$.
     - Two distinct index pairs ($i=j \neq k=\ell$): $\binom{n}{2}$ ways to select the pair of distinct indices $\{a, b\}$, and $\binom{4}{2} = 6$ arrangements in the 4-tuple. Each term evaluates to $\Ex{X_a^2}\Ex{X_b^2} = 1$. The contribution is $6\binom{n}{2} = 3n(n-1) = 3n^2 - 3n$.
     - Summing both cases gives $\Ex{X^4} = n + (3n^2 - 3n) = 3n^2 - 2n$.
  3. The author's formula $6n^2 - 5n$ erroneously omitted the division by 2 in $\binom{n}{2}$, taking $6n(n-1) + n = 6n^2 - 5n$. For $n=2$, the true value is $\Ex{X^4} = \frac{1}{4}(2^4) + \frac{1}{2}(0^4) + \frac{1}{4}((-2)^4) = 8$, whereas $6(2^2) - 5(2) = 14 \neq 8$.
  4. In [Lemma 2.4](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments.tex#L363), this flawed fourth moment was used to claim $\Ex{Z^2} = 6n^2 - 5n \leq 6n^2$, leading to the bound $(1-1/4)^2/6 = 9/96 \geq 1/11$.
- **Action:** Corrected $\Ex{X^4} = 3n^2 - 2n$ in [Exercise 2.3](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L342). In [Lemma 2.4](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L363), evaluated $\Ex{Z^2} = 3n^2 - 2n \leq 3n^2$, which sharpens the Paley–Zygmund lower bound from $1/11$ to $(1-1/4)^2/3 = 9/48 = 3/16 \approx 0.1875$. Added explanatory remarks.

---

### [Finding 2] Missing Outer Square Roots in Cauchy–Schwarz Proof (Theorem 2.1)
- **Severity & Type:** Confirmed Mathematical Bug / Proof Flaw (Major)
- **Location:** Original: [higher_moments.tex:L247-L256](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments.tex#L247-L256) | Reviewed: [higher_moments_reviewed.tex:L221-L232](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L221-L232)
- **Evidence & Impact:**
  1. The proof of the Cauchy–Schwarz inequality for expectations applies the discrete vector inequality $|\langle u, v \rangle| \leq \|u\|_2 \|v\|_2$ to $u_{(x,y)} = x\sqrt{\Prob{X=x, Y=y}}$ and $v_{(x,y)} = y\sqrt{\Prob{X=x, Y=y}}$.
  2. The text omitted the outer square roots from the upper bound, writing:
     $$\LEQ \sum_{(x,y)} (u_{(x,y)})^2 \sum_{(x,y)} (v_{(x,y)})^2 = \Ex{X^2} \Ex{Y^2}.$$
  3. This falsely concluded $|\Ex{XY}| \leq \Ex{X^2} \Ex{Y^2}$, which directly contradicted the square roots in the theorem statement ($|\Ex{XY}| \leq \sqrt{\Ex{X^2}}\sqrt{\Ex{Y^2}}$). The displayed claim without square roots is mathematically false in general (e.g. for $X=Y=1/2$, $|\Ex{XY}|=1/4$, while $\Ex{X^2}\Ex{Y^2}=1/16 < 1/4$).
  4. In addition, an undefined variable $\mu$ was abruptly introduced in the first step ($\mu \EQ |\Ex{XY}|$) and never referenced again.
- **Action:** Restored outer square roots across all steps of the display in [higher_moments_reviewed.tex:L221-L232](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L221-L232), split the display cleanly across lines to maintain margin bounds, removed the unused symbol $\mu$, and added a clarifying `\remX`.

---

### [Finding 3] Arithmetic and Parameter Errors in Chebyshev Variance Derivation (Section 2.3.1)
- **Severity & Type:** Confirmed Mathematical Bug / Calculation Defect
- **Location:** Original: [higher_moments.tex:L398-L413](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments.tex#L398-L413) | Reviewed: [higher_moments_reviewed.tex:L401-L417](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L401-L417)
- **Evidence & Impact:**
  1. In computing the variance $\Var{Z} = \Ex{Z^2} - (\Ex{Z})^2$, the original text wrote $\Var{Z} = 6n^2 - 5n - n = 6(n^2 - n)$. Because $\Ex{Z} = n$, its square is $(\Ex{Z})^2 = n^2$. The text subtracted $n$ instead of $n^2$. With the corrected fourth moment, $\Var{Z} = (3n^2 - 2n) - n^2 = 2n^2 - 2n = 2n(n-1)$.
  2. Next, solving for the deviation $t\sqrt{\Var{Z}} = \Ex{Z}/2$, the text stated: $t = \frac{(\Ex{Z})^2}{4\Var{Z}} \approx \frac{1}{24}$. This formula computes $t^2$, not $t$. The actual parameter is $t = \frac{\Ex{Z}}{2\sqrt{\Var{Z}}} = \frac{n}{2\sqrt{2n(n-1)}} \approx \frac{1}{2\sqrt{2}} \approx 0.354$.
  3. Because $t < 1$, Chebyshev's upper bound $\Prob{|Z - \Ex{Z}| \geq \Ex{Z}/2} \leq 1/t^2 \approx 8 > 1$ is completely vacuous.
- **Action:** Corrected the variance to $\Var{Z} = 2n(n-1)$, fixed the expression and numerical value for $t$, and clarified that $t < 1$ produces a trivial bound $> 1$, whereas Paley–Zygmund succeeds. Added explanatory `\remX` annotations.

---

### [Finding 4] Verbatim Duplicate Corollary and Lemma Under Random Walk Heading
- **Severity & Type:** Major Drafting Defect / Structural Duplication
- **Location:** Original: [higher_moments.tex:L200-L220](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments.tex#L200-L220) | Reviewed: [higher_moments_reviewed.tex:L190-L197](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L190-L197)
- **Evidence & Impact:**
  1. Under `\paragraph*{Random walk on the integers.}`, the original draft duplicated Corollary 1.3 as Corollary 1.5 and duplicated Lemma 1.4 as Lemma 1.6 verbatim.
  2. The duplicated Lemma 1.6 also contained the contradictory wording "random independent variables, that are $k$-wise independent".
  3. This accidental repetition inflated the chapter and interrupted the conceptual flow of the random walk example.
- **Action:** Removed the duplicate corollary and lemma environments. Replaced them with an explicit, concise explanation linking the displacement of the 1D random walk $X = \sum_{i=1}^n X_i$ directly to [Corollary 1.3](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L161-L168), showing that the probability of drifting more than $k\sqrt{n}$ from the origin is bounded by $2^{-k}$. Added an explanatory `\remX`.

---

### [Finding 5] Explanation of Paley–Zygmund Utility, Anti-Concentration, and Concrete Examples
- **Severity & Type:** Pedagogical Clarification (Requested by User)
- **Location:** Original: [higher_moments.tex:L418-L420](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments.tex#L418-L420) | Reviewed: [higher_moments_reviewed.tex:L294-L319](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L294-L319)
- **Evidence & Impact:**
  1. The original manuscript contained only a single sentence at the end of Section 2.3.1: "It seems the Paley-Zygmund inequality is useful when the standard deviation is larger than the expectation, but not too much larger."
  2. It lacked an explanation of the fundamental dichotomy: standard tail bounds (Markov, Chebyshev, Chernoff) are *concentration* tools (upper bounds on deviations), whereas Paley–Zygmund is an *anti-concentration* tool (a guaranteed lower bound on the probability of exceeding a positive fraction of the mean).
  3. No examples beyond the random walk were provided to motivate where and why this inequality appears in algorithm analysis and discrete mathematics.
- **Action:** Authored a dedicated Subsection 2.2.1 ([higher_moments_reviewed.tex:L294-L319](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L294-L319)) covering:
  - The anti-concentration principle: guaranteeing $\Prob{Z > 0} \geq \Ex{Z}^2 / \Ex{Z^2} \geq 1/C$ whenever $\Ex{Z^2} \leq C (\Ex{Z})^2$.
  - Why Chebyshev fails in this regime ($\sigma = \Theta(\Ex{Z})$).
  - Three concrete examples:
    1. *Random walks and signed sums (Rademacher sums)*: bounding displacement away from zero.
    2. *The second moment method in random graphs*: proving that subgraph counts (e.g. triangles in $G(n, p)$) are strictly positive almost surely.
    3. *Non-vanishing of random polynomials and series*: Paley and Zygmund's foundational application to random trigonometric series.

---

### [Finding 6] Missing Bibliographical Notes and Foundational References
- **Severity & Type:** Missing Required Content (Requested by User)
- **Location:** Original: [higher_moments.tex:L436](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments.tex#L436) | Reviewed: [higher_moments_reviewed.tex:L439-L453](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L439-L453), [higher_moments_reviewed.bib:L1-L75](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.bib#L1-L75)
- **Evidence & Impact:**
  1. The original chapter contained only `\nocite{mr-ra-95}` at the bottom and lacked a `\section{Bibliographical notes}`.
  2. Key historical and algorithmic sources were completely uncredited:
     - Bienaym{\'e} (1853) and Chebyshev (1867) for the Chebyshev inequality.
     - Paley and Zygmund (1930, 1932) for the Paley–Zygmund inequality.
     - Schmidt, Siegel, and Srinivasan (1995) for higher-moment tail bounds under limited independence.
     - Alon and Spencer (2000) for the second moment method and anti-concentration.
     - Motwani & Raghavan (1995) and Mitzenmacher & Upfal (2017) for standard algorithmic treatments.
- **Action:** Authored a concise, to-the-point `\section{Bibliographical notes}` without rambling, and created the local self-contained bibliography database `higher_moments_reviewed.bib`.

---

### [Finding 7] Duplicate Section Titles and Grammatical Defects
- **Severity & Type:** Typographical & Grammatical Defects
- **Location:** Original: [higher_moments.tex:L29, L69, L77, L165, L179](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments.tex#L29) | Reviewed: [higher_moments_reviewed.tex:L66, L72, L163, L174](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L66)
- **Evidence & Impact:**
  1. Subsection 1.1 and Subsubsection 1.1.2 shared the identical title "Stronger concentration inequality".
  2. Multiple lemma hypotheses used the ungrammatical phrase "Consider $k$ be an even integer".
  3. Lemmas phrased hypotheses as "random independent variables" rather than "independent random variables".
- **Action:** Renamed Subsubsection 1.1.2 to "Concentration for sums of independent random signs", changed "Consider $k$ be an even integer" to "Let $k > 0$ be an even integer", and normalized "independent random variables".

---

## 2. Significant Revisions

- **Tracked Technical Changes:**
  - [higher_moments_reviewed.tex:L38-L41](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L38-L41): Added explicit hypotheses $k \geq 1$ and $t > 0$ to Lemma 1.1.
  - [higher_moments_reviewed.tex:L66-L68](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L66-L68): Updated Subsubsection 1.1.2 title to "Concentration for sums of independent random signs".
  - [higher_moments_reviewed.tex:L161-L168](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L161-L168): Clarified Corollary 1.3 by explicitly referencing substitution $t=2$ into Lemma 1.2.
  - [higher_moments_reviewed.tex:L190-L197](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L190-L197): Replaced duplicated Corollary 1.5 and Lemma 1.6 with an explicit random walk explanation referencing Corollary 1.3.
  - [higher_moments_reviewed.tex:L202-L233](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L202-L233): Fixed Cauchy–Schwarz proof by restoring outer square roots and eliminating undefined $\mu$.
  - [higher_moments_reviewed.tex:L240-L245](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L240-L245): Clarified finite second moment hypothesis in Paley–Zygmund theorem.
  - [higher_moments_reviewed.tex:L294-L319](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L294-L319): Authored new subsection on why Paley–Zygmund is useful with 3 concrete examples.
  - [higher_moments_reviewed.tex:L342-L345](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L342-L345): Corrected $\Ex{X^4} = 3n^2 - 2n$ in Exercise 2.3.
  - [higher_moments_reviewed.tex:L355-L390](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L355-L390): Updated Lemma 2.4 proof with the corrected fourth moment, establishing lower bound $3/16$.
  - [higher_moments_reviewed.tex:L401-L424](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L401-L424): Corrected variance $\Var{Z} = 2n(n-1)$ and parameter $t$ in Chebyshev derivation.
  - [higher_moments_reviewed.tex:L439-L453](file:///home/sariel/rand_alg/notes/09_higher_moments/higher_moments_reviewed.tex#L439-L453): Added concise bibliographical notes.

---

## 3. Verification

- **Compilation Command:** `l --no-env -s higher_moments_reviewed.tex`
- **Compiler Passes:** XeLaTeX (1) $\to$ Biber $\to$ XeLaTeX (2)
- **Compilation Outcome:**
  `✔ No errors/alerts/warnings.` (0 errors, 0 alerts, 0 warnings).
- **Environment Sanitization:** Verified under complete TeX environment sanitization (`TEXINPUTS`, `BIBINPUTS`, `BSTINPUTS`, `TEXMFHOME` cleared).
- **Test Suite Verification:** Ran `./tools/test_chapters_standalone 09` (`test_all_chaps.rb`), verifying that the standalone chapter builds cleanly in the project test suite.
- **Portability Contract:** All citations are resolved locally via `higher_moments_reviewed.bib` and relative symlink `styles -> ../styles`.

---

## 4. Author Actions

- **Review Fourth Moment Derivation:** Confirm that $\Ex{X^4} = 3n^2 - 2n$ matches the intended exercise solution and that the sharpened lower bound $\Prob{|X| \geq \sqrt{n}/2} \geq 3/16$ in Lemma 2.4 is preferred over the older $1/11$.
- **Subsubsection Title:** Confirm the new subsubsection title "Concentration for sums of independent random signs" or specify preferred wording.
