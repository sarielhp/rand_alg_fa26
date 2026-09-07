# Manuscript Review Report

## 1. Executive Summary

- **Overall Quality Assessment**:  
  This chapter provides an engaging, intuition-driven introduction to Chebyshev's inequality, concentration via the second moment, sampling-based estimation, and randomized selection. The pedagogical progression—starting from a toy symmetric random walk on $\{-1, +1\}^n$, generalizing to arbitrary random variables with finite variance, applying the technique to property estimation, and culminating in the elegant Floyd--Rivest selection algorithm—is pedagogically compelling and well structured.
- **Core Strengths**:  
  - Excellent conceptual intuition bridging probability and algorithm design.
  - Transparent exposition of how Chebyshev's inequality guarantees concentration with only **pairwise independence**.
  - A clean, non-recursive presentation of randomized selection achieving $1.5 n + o(n)$ expected comparisons.
- **Primary Revision Priorities**:  
  1. **Critical Mathematical Flaw in Lemma 2.1 Proof**: In the original proof, the deviation tail was asserted to satisfy $\Prob{|Y - \Ex{Y}| \geq t \sqrt{m}/2} \leq \Prob{|Y - \Ex{Y}| \geq t \sigma_Y} \leq 1 - 1/t^2$. Chebyshev's inequality bounds the tail by $1/t^2$, not $1 - 1/t^2$. The two-sided concentration bound $\geq 1 - 1/t^2$ is obtained by taking the complement ($1 - 1/t^2$).
  2. **Critical Typo in Lemma 2.3 Statement**: The original text defined the property fraction as $p = m/n$. Since $m$ is the sample size and $\numC$ is the count of elements in $U$ possessing the property, this must be $p = \numC / n$.
  3. **Degeneracy at $\sigma_X = 0$ in Theorem 1.2**: In standard standardized form $\Prob{|X - \mu_X| \geq t \sigma_X} \leq 1/t^2$, if $\Var{X} = 0$, the left-hand side is $\Prob{0 \geq 0} = 1$, which exceeds $1/t^2$ for $t > 1$. The theorem requires $\sigma_X > 0$, or should be phrased with absolute deviation $\lambda > 0$.
  4. **Intuition Section Ambiguity (Section 3.1.1)**: The text asserted that the sample rank intervals $\IntervalA(\cdot, t)$ are disjoint "with probability $\geq 1 - 3/t^2$". These index intervals are deterministic by choice of $g$ and $h$; it is the corresponding confidence intervals $\Interval(\cdot)$ in $U$ that intersect with probability $\leq 3/t^2$. Additionally, the bound $h - g \leq 4(t n / (2\sqrt{m}))$ dropped the $+4n/m$ term.
  5. **Missing Bibliography Entry**: The citation `\cite{b-pct-99}` in Section 1 was missing from `chebychev.bib`, triggering a Biber warning.

---

## 2. Mathematical Rigor & Technical Critique

### Theorems, Proofs & Claims
- **Theorem 1.2 (Chebyshev's Inequality)**:  
  The standard statement $\Prob{|X - \mu_X| \geq t \sigma_X} \leq 1/t^2$ requires $\sigma_X > 0$. When $\sigma_X = 0$, $X = \mu_X$ almost surely, yielding $\Prob{|X - \mu_X| \geq 0} = 1$, contradicting $1/t^2$ for $t > 1$. In the proof, Markov's inequality is applied with threshold $a = t^2 \sigma_X^2$, which requires $a > 0$. An explicit remark was added clarifying this condition and noting that the absolute deviation form $\Prob{|X - \mu_X| \geq \lambda} \leq \Var{X}/\lambda^2$ holds unconditionally for all $\lambda > 0$.
- **Lemma 2.1 (Sampling Estimation)**:  
  In the original proof, the chain of inequalities ended with $\LEQ 1 - 1/t^2$ on the deviation event. This conflated the tail bound with its complement. In `chebychev_reviewed.tex`, this is corrected to:
  $$\Prob{|Y - \Ex{Y}| \geq t \sqrt{m}/2} \leq \Prob{|Y - \Ex{Y}| \geq t \sigma_Y} \leq \frac{1}{t^2},$$
  followed by taking the complement:
  $$\Prob{|Y - \Ex{Y}| \leq t \sqrt{m}/2} = 1 - \Prob{|Y - \Ex{Y}| > t \sqrt{m}/2} \geq 1 - \frac{1}{t^2}.$$
- **Lemma 2.3 (Universe Count Estimation)**:  
  Corrected $p = m/n \to p = \numC / n$. The proof concludes by bounding the failure tail by $1/t^2$; an explicit note taking the complement was added to match the lemma statement.
- **Theorem 3.6 (Comparison Bound Rigor)**:  
  In the proof of Theorem 3.6, writing $C = 1.5 Y n + O(n^{3/4} \log n^{3/4})$ conflates the random variable $C$ with conditional expectation. Rigorously, by Wald's equation for stopping times:
  $$\Ex{C} = \Ex{\sum_{i=1}^Y C_i} = \Ex{Y} \Ex{C_1} \leq \left(1 + \frac{4}{n^{1/4}}\right) \left(1.5 n + O(n^{3/4} \log n)\right) = 1.5 n + O(n^{3/4} \log n).$$
  A detailed reviewer remark (`\remX`) was inserted to make this step transparent for graduate students.

### Edge Cases & Notation
- **Boundary Ranks in Lemma 3.1**:  
  When $g = k - t \frac{n}{\sqrt{m}} - 3 \frac{n}{m} \leq 0$, no elements in $U$ have rank $\leq g$, so zero elements are excluded from below. Symmetrically, if $h > n$, all elements have rank $\leq h$. In either extreme, the interval $[r_-, r_+]$ still contains at most $h - g \leq 8t n/\sqrt{m}$ elements. An inline remark clarifies this boundary behavior.
- **Pairwise vs. Mutual Independence**:  
  Remark 1.1 correctly points out that Chebyshev requires only pairwise independence. Stating this explicitly in Lemma 1.1 and Example 1.4 reinforces this fundamental advantage of second-moment methods over Chernoff bounds.

---

## 3. Pedagogical & Presentation Evaluation

- **Historical Context & Priority**:  
  - **Bienaymé's Priority**: Chebyshev's inequality was first proved by Irénée-Jules Bienaymé in 1853, fourteen years before Chebyshev's 1867 paper. Andrei Markov later gave explicit credit to Bienaymé. An inline remark (`\remX`) acknowledges this rich history.
  - **Floyd--Rivest Algorithm**: The randomized selection algorithm analyzed in Section 3.2 is the landmark Floyd--Rivest algorithm (Algorithm 489, CACM 1975). Adding historical attribution connects the notes to Hoare's QuickSelect (1961) and Blum et al.'s median-of-medians algorithm (1973).
- **Intuition vs. Rigor in Section 3.1.1**:  
  Section 3.1.1 provides helpful geometric intuition, but originally claimed that the rank intervals $\IntervalA(\cdot, t)$ are disjoint with probability $\geq 1 - 3/t^2$. In reality, $\IntervalA(\cdot, t)$ are deterministic intervals of indices; the random objects are the confidence intervals $\Interval(\cdot) \subset U$. This distinction has been clarified.

---

## 4. Compilation & Linting Diagnostics

- **LaTeX Engine**: XeLaTeX (via `/home/sariel/bin/l -no-env -s`)
- **Bibliography Tool**: Biber 2.22 / BibLaTeX
- **chktex Findings**:  
  - Fixed interword spacing warning on `\smallskip`.
  - Resolved missing `b-pct-99` citation entry by providing complete `chebychev_reviewed.bib`.
- **Compilation Status**: **PASS — 0 Errors** (`chebychev_reviewed.pdf` generated, 128.1 KB).
- **Original File Integrity**: The original file [chebychev.tex](file:///home/sariel/rand_alg/notes/05_chebychev/chebychev.tex) remains **completely untouched**.

---

## 5. Section-by-Section Review

| Section | Status | Key Observations & Recommendations |
| :--- | :--- | :--- |
| **Title & Frontmatter** | Pass | Good epigraph. Footnote 1 punctuation refined; historical priority of Bienaymé noted. |
| **1.1 Better inequality via moments** | Pass | Clarified variable ranges and summation indexing ($\sum_{i=1}^n$). Clarified pairwise independence. |
| **1.2 Chebyshev's inequality** | Needs Attention | Added critical remark on degeneracy when $\Var{X} = 0$. Clarified Markov condition $a > 0$. |
| **2. Estimation via sampling** | Critical Fix | Fixed mathematical proof error in Lemma 2.1 (tail bound $1/t^2$ vs $1 - 1/t^2$). Fixed $p = m/n \to p = \numC/n$ in Lemma 2.3. |
| **3.1 Inverse estimation** | Pass | Refined "number of rank $k$" to "element of rank $k$". Added edge case remark for boundary ranks $g \leq 0$ and $h > n$. |
| **3.1.1 Intuition** | Needs Attention | Clarified deterministic sample rank intervals vs random confidence intervals. Refined algebraic bound on $h - g$. |
| **3.2 Randomized selection** | Pass | Structured second failure branch symmetrically. Added Floyd--Rivest attribution and comparison with QuickSelect / BFPRT. |
| **3.2.2 Analysis** | Pass | Fixed grammar ("probability's way", "exposition, we ignore", tense). |
| **3.2.3 Doing better** | Pass | Clarified that Lemma 3.5 requires $r_-, r_+$ from Lemma 3.1. Clarified Wald's identity application for Theorem 3.6. |

---

## 6. Detailed Editing Log

### Section 1: Chebyshev's inequality
- **Original Excerpt**:  
  `... (Russian: \SpellIgnore{Пафну́тий Льво́вич Чебышёв}), (May 16, 1821--December 8, 1894) ...`  
  - **Type**: Typography / Punctuation  
  - **Annotated Change**: `\chgY{(Russian: ...), (May 16, 1821--December 8, 1894)}{(Russian: ...; May 16, 1821--December 8, 1894)}`  
  - **Rationale**: Replaced awkward consecutive parenthesized clauses with a unified parenthetical statement separated by a semicolon.

- **Original Excerpt**:  
  `... ``\SpellIgnore{Cheby-SHOV}''{},{} rhyming with ``shove''.}`  
  - **Type**: Typography Fix  
  - **Annotated Change**: `\chgY{''{},{}}{'',}`  
  - **Rationale**: Removed redundant empty grouping braces around the comma after the closing quotation mark.

### Subsection 1.1: Example: A better inequality via moments
- **Original Excerpt**:  
  `... each taking value $\pm 1$ with equal probability $1/2$. Let $Y= \sum_i X_i$.`  
  - **Type**: Mathematical Exposition & Precision  
  - **Annotated Change**: `each \chgY{taking value $\pm 1$}{taking each value in $\brc{-1,+1}$} with equal probability $1/2$. Let \chgY{$Y= \sum_i X_i$}{$Y= \sum_{i=1}^n X_i$}.`  
  - **Rationale**: Clearer mathematical phrasing specifying the sample space $\{-1, +1\}$ and explicit index bounds on the sum.

- **Original Excerpt**:  
  `\begin{remark}[Maybe skip for now]`  
  - **Type**: Pedagogical Framing  
  - **Annotated Change**: `\begin{remark}[\chgY{Maybe skip for now}{Pairwise vs.~mutual independence}]`  
  - **Rationale**: Replaced informal, colloquial title with a descriptive, professional label highlighting the central conceptual point.

- **Original Excerpt**:  
  `... Chebyshev is NOT strictly dominated by tools we would see later on.`  
  - **Type**: Grammar & Academic Tone  
  - **Annotated Change**: `\chgY{Chebyshev is NOT strictly dominated by tools we would see}{Chebyshev's inequality is not strictly dominated by tools we will see} later on.`  
  - **Rationale**: Fixed colloquial capitalization and future tense.

### Lemma 1.1 & Proof
- **Original Excerpt**:  
  `Let $X_1, \ldots, X_n \in \brc{-1,+1}$ be mutually independent random variables ...`  
  - **Type**: Mathematical Rigor  
  - **Annotated Change**: `Let $X_1, \ldots, X_n \in \brc{-1,+1}$ be \chgY{mutually independent}{pairwise independent} random variables ...`  
  - **Rationale**: As noted in Remark 1.1, pairwise independence is both necessary and sufficient for $\Var{\sum_i X_i} = n$, strengthening the lemma.

### Subsection 1.2: Chebyshev's inequality
- **Original Excerpt**:  
  `\begin{theorem}[Chebyshev's inequality] ... \Prob{\bigl. \cardin{X - \mu_X} \geq t \sigma_X} \leq \frac{1}{t^2}. \end{theorem}`  
  - **Type**: Mathematical Boundary Case Flag  
  - **Annotated Change**: Appended `\remX{Degeneracy when $\sigma_X = 0$: ...}`.  
  - **Rationale**: Flags that $\sigma_X > 0$ is required for the normalized tail bound, since $\sigma_X = 0 \implies \Prob{|X-\mu_X| \geq 0} = 1 > 1/t^2$ for $t > 1$.

- **Original Excerpt**:  
  `\begin{exercise}[Not too interesting]`  
  - **Type**: Academic Tone  
  - **Annotated Change**: `\begin{exercise}[\chgY{Not too interesting}{Degenerate variance}]`  
  - **Rationale**: Replaced dismissive header with informative mathematical topic.

### Section 2: Estimation via sampling
- **Original Excerpt**:  
  `\Prob{ \cardin{Y - \Ex{Y}} \geq t \sqrt{m}/2 } \LEQ \Prob{\Bigl. \cardin{Y - \Ex{Y}} \geq t \sigma_Y} \LEQ 1- \frac{1}{t^2}.`  
  - **Type**: Critical Mathematical Correction  
  - **Annotated Change**:  
    `\LEQ \chgY{1- \frac{1}{t^2}}{\frac{1}{t^2}}. \end{equation*} \newX{Taking the complement yields} \begin{equation*} \newX{\Prob{ \cardin{Y - \Ex{Y}} \leq t \sqrt{m}/2 } \geq 1 - \frac{1}{t^2},} \end{equation*} \newX{which is equivalent to the stated bound.}`  
  - **Rationale**: Chebyshev's inequality bounds deviation tails by $1/t^2$, not $1 - 1/t^2$. Taking the complement yields the two-sided concentration bound $\geq 1 - 1/t^2$.

- **Original Excerpt**:  
  `... assume that $\numC$ of them have the property (i.e., $p=\tfrac{m}{n}$).`  
  - **Type**: Critical Mathematical Typo Fix  
  - **Annotated Change**: `(i.e., \chgY{$p=\tfrac{m}{n}$}{$p=\tfrac{\numC}{n}$})`  
  - **Rationale**: $p$ represents the fraction of elements in $U$ having property $\propertyC$, which is $\numC / n$. The sample size $m$ was mistakenly typed in place of $\numC$.

- **Original Excerpt**:  
  `... and by the \lemrefY{above lemma}{Chebyshev-1} that \begin{equation*} ...`  
  - **Type**: Grammar Fix  
  - **Annotated Change**: `\chgY{and by the \lemrefY{above lemma}{Chebyshev-1} that}{and by \lemref{Chebyshev-1}, we have that}`  
  - **Rationale**: Repaired dangling subordinate clause missing an active main verb.

### Section 3: Randomized selection via sampling
- **Original Excerpt**:  
  `$\EBRY{U}{i}$ is the number of \emphi{rank} $i$ in $U$.`  
  - **Type**: Terminology Precision  
  - **Annotated Change**: `$\EBRY{U}{i}$ is \chgY{the number of \emphi{rank} $i$}{the element of \emphi{rank} $i$} in $U$.`  
  - **Rationale**: Precision in distinction between values and set elements.

- **Original Excerpt**:  
  `\item $\cardin{S_m} > 8 t {n}/ \sqrt{m} = O( n^{3 / 4})$. This is bad as the set $S_m$ is too large.`  
  - **Type**: Grammar & Structural Parallelism  
  - **Annotated Change**: `\item \chgY{$\cardin{S_m} > 8 t {n}/ \sqrt{m} = O( n^{3 / 4})$. This is bad}{If $\cardin{S_m} > 8 t {n}/ \sqrt{m} = O( n^{3 / 4})$, then the algorithm fails (as} the set $S_m$ is too large.`  
  - **Rationale**: Harmonized phrasing with the preceding failure case.

- **Original Excerpt**:  
  `We have that $\IntervalA(g, t)$, $\IntervalA(k, t)$ and $\IntervalA(h, t)$ are all disjoint, with probability $\geq 1 - 3/t^2$.`  
  - **Type**: Mathematical Conception & Clarity  
  - **Annotated Change**: `\chgY{We have that $\IntervalA(g, t)$, $\IntervalA(k, t)$ and $\IntervalA(h, t)$ are all disjoint, with probability $\geq 1 - 3/t^2$.}{By construction, the sample rank intervals $\IntervalA(g, t)$, $\IntervalA(k, t)$, and $\IntervalA(h, t)$ are deterministically pairwise disjoint.}`  
  - **Rationale**: Clarified that sample index intervals $\IntervalA$ are disjoint deterministically, while confidence intervals $\Interval$ in $U$ are disjoint with high probability.

- **Original Excerpt**:  
  `... fundamentally different than \AlgorithmI{QuickSelect}.`  
  - **Type**: Grammar & Historical Attribution  
  - **Annotated Change**: `fundamentally \chgY{different than}{different from} \AlgorithmI{QuickSelect}. \remX{Historical attribution: This randomized selection algorithm is the landmark Floyd--Rivest algorithm~\cite{fr-a4s-75,fr-etbs-75} ...}`  
  - **Rationale**: Standard preposition usage and essential attribution to Floyd and Rivest (1975).

- **Original Excerpt**:  
  `It is probability way politely stating there is no escape ...`  
  - **Type**: Grammar Fix  
  - **Annotated Change**: `It is \chgY{probability way politely stating}{probability's way of politely stating} there is no escape ...`  
  - **Rationale**: Restored missing genitive apostrophe and preposition.

- **Original Excerpt**:  
  `... it succeeded in the first try.`  
  - **Type**: Tense Agreement  
  - **Annotated Change**: `\chgY{it succeeded in the first try}{the algorithm succeeds on the first try}.`  
  - **Rationale**: Maintained consistent present tense for algorithmic analysis.

- **Original Excerpt**:  
  `... require only one comparison to put them into the right set.`  
  - **Type**: Pronoun Agreement  
  - **Annotated Change**: `... require only one comparison to \chgY{put them into the right}{put it into the right} set.`  
  - **Rationale**: Corrected plural pronoun "them" referring to singular antecedent "an element $s \in S$".

- **Original Excerpt**:  
  `C = 1.5Yn + O(n^{3/4} \log n^{3/4}).`  
  - **Type**: Mathematical Rigor  
  - **Annotated Change**: Appended `\remX{Probabilistic rigor: Each round $i$ uses an expected $\Ex{C_i} \leq 1.5n + O(n^{3/4})$ comparisons ...}`.  
  - **Rationale**: Explains how Wald's identity justifies $\Ex{C} \leq \Ex{Y} \Ex{C_1}$ without conflating random variable $C$ with its expectation.

---

## 7. Actionable Author Checklist

- [ ] **Fix Lemma 2.1 Proof in Source**: Replace the erroneous $\leq 1 - 1/t^2$ bound on the deviation tail with $\leq 1/t^2$, and add the complement step establishing the concentration interval.
- [ ] **Correct Typo in Lemma 2.3**: Update $p = \tfrac{m}{n}$ to $p = \tfrac{\numC}{n}$.
- [ ] **Qualify Theorem 1.2 for $\sigma_X > 0$**: Add the condition $\sigma_X > 0$ (or $\Var{X} > 0$) to the theorem statement to prevent the $1 \leq 1/t^2$ contradiction when variance is zero.
- [ ] **Add Missing Reference to `chebychev.bib`**: Merge the entry for `b-pct-99` (Butzer & Jongmans, 1999) from `chebychev_reviewed.bib` into `chebychev.bib`.
- [ ] **Clarify Sample vs. Confidence Intervals in Section 3.1.1**: Disentangle the deterministic sample rank intervals $\IntervalA(\cdot, t)$ from the random confidence intervals $\Interval(\cdot)$.
- [ ] **Attribute Floyd--Rivest (1975)**: Formally cite Floyd and Rivest (`\cite{fr-a4s-75,fr-etbs-75}`) in Section 3.2 to place this beautiful algorithm in its proper historical context alongside Hoare's QuickSelect and BFPRT.
- [ ] **Apply Editorial Polish**: Incorporate the low-level grammar, preposition, and punctuation corrections highlighted in `chebychev_reviewed.tex`.
