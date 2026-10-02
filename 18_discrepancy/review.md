# Review Report: Chapter 18 — Discrepancy and Derandomization

**Source Manuscript:** [discrepancy.tex](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex)  
**Reviewed Version:** [discrepancy_reviewed.tex](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy_reviewed.tex)  
**Verification:** XeLaTeX (via `/home/sariel/bin/l --no-env -s`), Biber 2.22 (`discrepancy_reviewed.bib`) — **0 Errors, 0 Alerts, 0 Warnings, 0 Whatevers**  
**Standalone Suite:** `./tools/test_chapters_standalone 18` — **PASS (clean)**

---

## 1. Actionable Findings (Ordered by Severity)

### [HIGH] Erroneous Normalization Factor $2^n$ and Graph Macro `\Vertices` in Conditional Probability Formula
- **Severity & Type:** Confirmed Mathematical Error & Macro Collision.
- **Location (Original):** [discrepancy.tex#L234-L242](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L234-L242)
- **Location (Reviewed):** [discrepancy_reviewed.tex#L236-L244](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy_reviewed.tex#L236-L244)
- **Evidence & Impact:**
  In the derivation of $P_\ind^+ = \Prob{C_\ind^+ \sep{\vecA_1, \dots, \vecA_k}}$, the text conditions on the first $k$ coordinates of $\vecA$ and reduces the probability to the number of heads in $V$ flips of an unbiased coin, where $V = \sum_{i \geq k+1, \rowc_i = 1} 1$ is the number of unassigned non-zero entries in row $\ind$. However, the displayed equation stated:
  $$P_\ind^+ = \sum_{i = \lceil(L+V)/2\rceil}^{\Vertices} \binom{\Vertices}{i} \frac{1}{2^n} = \frac{1}{2^n} \sum_{i = \lceil(L+V)/2\rceil}^{\Vertices} \binom{\Vertices}{i}.$$
  This contains two fatal flaws:
  1. *Denominator $2^n$ instead of $2^V$:* There are only $V \leq n-k$ independent random variables remaining in the sum. Dividing by $2^n$ underestimates the conditional probability by an exponential factor $2^{-(n-V)}$. If all remaining entries are $0$ ($V=0$), the conditional probability is $0$ or $1$, yet this formula would yield numbers scaled by $2^{-n}$.
  2. *Macro `\Vertices` instead of scalar $V$:* In `styles/prefix_latex.tex`, `\Vertices` is defined as `\VV` ($\mathsf{V}$, the vertex set of a graph). It was typeset as the upper summation limit and the top index of the binomial coefficient: $\binom{\mathsf{V}}{i}$. The correct scalar count is $V$.
  3. *Strict Inequality vs Ceiling:* The condition is $\sum_{i \geq k+1, \rowc_i=1} \frac{\vecA_i+1}{2} > \frac{L+V}{2}$. For an integer number of heads $H$, $H > x \iff H \geq \lfloor x \rfloor + 1$. When $x = (L+V)/2$ is non-integer (the typical case here since $L$ involves $4\sqrt{n\ln n}$), $\lfloor x \rfloor + 1 = \lceil x \rceil$. If $(L+V)/2 < 0$, all outcomes satisfy the condition and the sum is $1$; if $(L+V)/2 \geq V$, the probability is $0$.
- **Action Taken:** Corrected the denominator to $2^V$, replaced `\Vertices` with $V$, and added an explanatory reviewer remark (`\remX`).

---

### [HIGH] Incorrect Variable Count $m$ in Row Sum in Theorem 18.1.4 Proof
- **Severity & Type:** Confirmed Mathematical Specification Error.
- **Location (Original):** [discrepancy.tex#L115](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L115)
- **Location (Reviewed):** [discrepancy_reviewed.tex#L115](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy_reviewed.tex#L115)
- **Evidence & Impact:**
  Line 115 asserts:
  > *"As such $Y$ is the sum of $m$ independent random variables that accept values in $\{-1,+1\}$."*
  
  In lines 105--114, $i_1, \dots, i_\tau$ are defined as the indices where row $v$ has non-zero entries ($v_{i_j} = 1$), and $Y = \sum_{j=1}^\tau b_{i_j}$. Thus $Y$ is the sum of **$\tau$** independent random variables ($\tau \leq n$), not $m$. Dimension $m$ was the row count of an $m \times n$ matrix from Definition 18.1.3; using $m$ here confuses the number of terms in a single row sum with the number of rows in the matrix.
- **Action Taken:** Corrected `$m$' to `$\tau$' via `\chgY` and annotated with `\remX`.

---

### [HIGH] Typographical Corruption `$4 \sqrt{ n\ln ,}$` and Omitted Union Bound in Theorem 18.1.4
- **Severity & Type:** Syntax Corruption & Missing Proof Step.
- **Location (Original):** [discrepancy.tex#L143-L148](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L143-L148)
- **Location (Reviewed):** [discrepancy_reviewed.tex#L146-L153](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy_reviewed.tex#L146-L153)
- **Evidence & Impact:**
  1. *Stray comma typo:* Line 144 reads:
     ```latex
     exceeds (in absolute values) $4 \sqrt{ n\ln ,}$ is smaller than $2/m^7$.
     ```
     The radical contains a stray comma instead of the argument $n$ (or $m$).
  2. *Missing Union Bound Step:* The preceding display bounds the two-sided tail for a *single* row by $2/n^8$ (or $2/m^8$). The prose immediately asserted that "the probability that *any* entry in $\Matrix b$ exceeds ... is smaller than $2/m^7$" without mentioning the union bound over all $n$ rows ($n \cdot (2/n^8) = 2/n^7$).
  3. *Scalar $b$ vs Vector $\vecb$:* The text wrote `$\Matrix b$` rather than `$\Matrix \vecb$`.
- **Action Taken:** Corrected the typo to $4\sqrt{n\ln n}$, explicitly supplied the union bound step over all $n$ rows, fixed the vector notation to $\vecb$, and annotated with `\remX`.

---

### [HIGH] Undefined Index Subscript $\alpha_i = 1$ in Section 18.2
- **Severity & Type:** Undefined Notation / Variable Typo.
- **Location (Original):** [discrepancy.tex#L224-L229](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L224-L229)
- **Location (Reviewed):** [discrepancy_reviewed.tex#L224-L231](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy_reviewed.tex#L224-L231)
- **Evidence & Impact:**
  In lines 202--220, the row is defined as $\row_\ind = (\rowc_1, \dots, \rowc_n)$, and the conditions are written as $\rowc_i \neq 0$ and $\rowc_i = 1$. In lines 224 and 228, the summation conditions abruptly switched to:
  $$\sum\nolimits_{i \geq k+1, \, \alpha_i = 1} (\vecA_i + 1) > L+V.$$
  The symbol $\alpha_i$ was never defined anywhere in the chapter; it is an uncorrected typo for $\rowc_i$.
- **Action Taken:** Replaced $\alpha_i = 1$ with $\rowc_i = 1$ and annotated with `\remX`.

---

### [MEDIUM] Matrix-Vector Notation Collision ($A$ vs $\Matrix$ vs $\vecA$)
- **Severity & Type:** Notation Collision / Semantic Ambiguity.
- **Location (Original):** [discrepancy.tex#L268, L274](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L268), [discrepancy.tex#L274](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L274)
- **Location (Reviewed):** [discrepancy_reviewed.tex#L277, L284](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy_reviewed.tex#L277), [discrepancy_reviewed.tex#L284](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy_reviewed.tex#L284)
- **Evidence & Impact:**
  The problem and theorem statements define the binary matrix as $\Matrix$ (`\Matrix`) and the sign vector as $\vecA$. In lines 268 and 274 (and Theorem 18.2.2), the text abruptly wrote:
  $$\dist{A \vecA'}_\infty \leq 4 \sqrt{n \log n} \quad \text{and} \quad \dist{A \vecA}_\infty \leq 4 \sqrt{n \log n}.$$
  Writing italic $A$ alongside $\vecA$ produces the jarring juxtaposition $A \vecA$, confusing the matrix with the vector coordinates.
- **Action Taken:** Changed $A$ to $\Matrix$ (`\Matrix \vecA'` and `\Matrix \vecA`) and annotated with `\remX`.

---

### [MEDIUM] Overloading $P(v)$ with Opposite Meanings & Direction of Inequality
- **Severity & Type:** Expositional Inconsistency & Pedagogical Gap.
- **Location (Original):** [discrepancy.tex#L181-L192, L256-L267](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L181-L192)
- **Location (Reviewed):** [discrepancy_reviewed.tex#L193, L265-L272](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy_reviewed.tex#L193)
- **Evidence & Impact:**
  1. In lines 181--192, $P(v)$ is introduced as the probability that a random computation from $v$ *succeeds*, where we seek $\max(P(v_l), P(v_r)) \geq P(v)$.
  2. In line 256, $P(v)$ is redefined as the sum of conditional *failure* probabilities: $P(v) = \sum_{\ind=1}^n \Prob{C_\ind \sep{\vecA_v}}$ (a *pessimistic estimator*). Here, we choose the child *minimizing* $P(v)$.
  3. In line 261, the text wrote: "for any $v \in T$, we have $P(v) \geq \min(P(v_l), P(v_r))$." While mathematically true for any average, the operationally meaningful inequality is $\min(P(v_l), P(v_r)) \leq P(v)$, which guarantees that the pessimistic estimator never increases.
  4. The root $r = \mathrm{root}(T)$ was referenced in line 258 ("$P(r) < 1$") before being defined in line 264.
  5. The crucial conclusion at the leaf was compressed: at a leaf $u$, each $\vecA_i$ is deterministically fixed, so every conditional failure probability $\Prob{C_\ind \sep{\vecA_u}}$ collapses to $0$ or $1$. Since their sum is at most $P(r) \leq 2/n^7 < 1$, every term must be $0$, ensuring zero bad events occur.
- **Action Taken:** Clarified the transition from idealized success probability to the tractable pessimistic failure estimator, corrected the inequality to $\min(P(v_l), P(v_r)) \leq P(v)$, defined root $r$, and explained the leaf integer collapse in `\remX`.

---

### [LOW] Missing Local Bibliography File `discrepancy.bib`
- **Severity & Type:** Build Environment Portability Defect.
- **Location:** Chapter directory `18_discrepancy/`
- **Evidence & Impact:**
  The chapter cites two books: `\cite{c-dmrc-01, m-gd-99}` (Bernard Chazelle, *The Discrepancy Method*, 2001; and Jiří Matoušek, *Geometric Discrepancy*, 1999). Under strict environment sanitization (`l --no-env`), Biber cannot access external user directories (`/home/sariel/papers/bib`) and looks for `\jobname.bib`. Because `discrepancy.bib` did not exist in the chapter folder, `./tools/test_chapters_standalone 18` failed with exit code 1.
- **Action Taken:** Created [discrepancy.bib](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.bib) and symlinked [discrepancy_reviewed.bib](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy_reviewed.bib) with accurate, canonical entries for both works.

---

### [LOW] Minor Typographical, Grammatical, and Notation Corrections
- **Severity & Type:** Minor LaTeX / English Mechanics (Silently Corrected).
- **Locations & Details:**
  - [discrepancy.tex#L43-L46](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L43-L46): Replaced en-dashes `--` with em-dashes `---`, removed stray comma after "do so", and fixed double space in "is  in".
  - [discrepancy.tex#L83](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L83): Corrected "For a $m \times n$ a binary matrix" to "For an $m \times n$ binary matrix".
  - [discrepancy.tex#L86](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L86): Standardized `\dist{\Matrix \vecb}_\infty` to `\norm{\Matrix \vecb}_\infty` to match Definition 18.1.2.
  - [discrepancy.tex#L100](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L100): Corrected "Chose a random" to "Choose a random".
  - [discrepancy.tex#L185](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L185): Corrected "if ends up with a vector" to "if it ends up with a vector".
  - [discrepancy.tex#L243](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L243): Removed stray comma in "This implies, that".
  - [discrepancy.tex#L264](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L264): Formatted `$root(T)$` as `$\mathrm{root}(T)$`.
  - [discrepancy.tex#L273](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L273): Standardized `\brc{-1,1}^n` to `\brc{-1,+1}^n`.
  - [discrepancy.tex#L277](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L277): Removed stray comma in "Note, that".
  - [discrepancy.tex#L292](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.tex#L292): Added non-breaking space before citation: `books~\cite{...}`.

---

## 2. Significant Revisions Summary

The table below summarizes substantive revisions tracked in [discrepancy_reviewed.tex](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy_reviewed.tex):

| Location | Original Text / Code | Reviewed Text / Code | Rationale |
| :--- | :--- | :--- | :--- |
| **Def 18.1.3** (`L86`) | `\dist{\Matrix \vecb}_\infty` | `\norm{\Matrix \vecb}_\infty` (with respect to $\Matrix$) | Matches Def 18.1.2 $\norm{\cdot}_\infty$ and clarifies matrix dependency. |
| **Thm 18.1.4** (`L94`) | $\dist{\Matrix \vecb}_\infty \leq 4\sqrt{n \log n}$ | $\norm{\Matrix \vecb}_\infty \leq 4\sqrt{n \ln n}$ | Clarifies base of natural logarithm matching Chernoff derivation. |
| **Proof 18.1.4** (`L115`) | sum of $m$ independent r.v. | sum of $\tau$ independent r.v. | Row $v$ contains $\tau \leq n$ non-zero entries; $m$ is matrix row count. |
| **Proof 18.1.4** (`L127-142`) | $\Delta = 4\sqrt{n \ln m}$, $\leq 2/m^8$ | $\Delta = 4\sqrt{n \ln n}$, $\leq 2/n^8$ | Harmonized with $n \times n$ matrix in theorem statement and Sec 18.2. |
| **Proof 18.1.4** (`L143-151`) | `$4\sqrt{n \ln ,}$`, $\Matrix b$, jumps to $2/m^7$ | $4\sqrt{n \ln n}$, $\Matrix \vecb$, union bound | Fixed broken radical typo, restored union bound over $n$ rows. |
| **Sec 18.2** (`L224, 228`) | $\sum_{i \geq k+1, \, \alpha_i = 1}$ | $\sum_{i \geq k+1, \, \rowc_i = 1}$ | Replaced undefined $\alpha_i$ with row coordinate $\rowc_i$. |
| **Sec 18.2** (`L237, 240`) | $\sum^{\Vertices} \binom{\Vertices}{i} \frac{1}{2^n}$ | $\sum^{V} \binom{V}{i} \frac{1}{2^V}$ | Fixed graph macro $\VV$ and normalized by $2^V$ flips (not $2^n$). |
| **Sec 18.2** (`L261`) | $P(v) \geq \min(P(v_l), P(v_r))$ | $\min(P(v_l), P(v_r)) \leq P(v)$ | Stated correct operational bound for pessimistic estimator minimization. |
| **Sec 18.2** (`L268, 274`) | $\dist{A \vecA'}_\infty$, $\dist{A \vecA}_\infty$ | $\norm{\Matrix \vecA'}_\infty$, $\norm{\Matrix \vecA}_\infty$ | Resolved symbol collision between matrix $\Matrix$ and sign vector $\vecA$. |

---

## 3. Verification & Compilation Results

- **Environment Sanitization:** Neutralized 35 TeX/LaTeX environment variables (`TEXINPUTS`, `BIBINPUTS`, `TEXMFHOME`, etc.) ensuring strict isolation from external system files.
- **Standalone Verification Suite:**
  ```bash
  ./tools/test_chapters_standalone 18
  ```
  **Result:** `[ 1/ 1] 18_discrepancy/discrepancy.tex ... PASS (clean) [5.3s]`
- **Reviewed Chapter Direct Build:**
  ```bash
  /home/sariel/bin/l --no-env -s discrepancy_reviewed.tex
  ```
  **Result:**
  - **Errors:** 0
  - **Alerts:** 0
  - **Warnings:** 0
  - **Whatevers:** 0
- **Bibliography:** Biber 2.22 resolved 2 citekeys (`c-dmrc-01`, `m-gd-99`) with zero missing citations via local `discrepancy.bib` / `discrepancy_reviewed.bib`.

---

## 4. Author Actions & Recommendations

1. **Keep Local Bibliography File:** Retain [discrepancy.bib](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy.bib) in `18_discrepancy/` to ensure standalone portability under sanitized builds (`l --no-env`).
2. **Accept Formula Corrections in [discrepancy_reviewed.tex](file:///home/sariel/rand_alg/notes/18_discrepancy/discrepancy_reviewed.tex):** In particular, the binomial normalization factor $1/2^V$ and the scalar limit $V$ (replacing `\Vertices`) in line 237 are critical mathematical fixes.
3. **Optional Generalization to $m \times n$ Matrices:** If desired, Theorem 18.1.4 can be stated directly for an $m \times n$ matrix with bound $4\sqrt{n \ln m}$ (assuming $m \geq 2$), and then specialized to $m=n$ for Section 18.2.
