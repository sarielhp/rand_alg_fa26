# Review Report: Chapter 13 (Conditional Expectation and Concentration)

Manuscript: [cond_exp.tex](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp.tex)  
Reviewed version: [cond_exp_reviewed.tex](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp_reviewed.tex)

---

## 1. Actionable Findings

### Finding 1: Incorrect equality relation in concentration proof
- **Severity & Type:** Confirmed Technical Error.
- **Location:** [cond_exp.tex#L169-L174](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp.tex#L169-L174) (proof of Lemma 13.3).
- **Evidence & Impact:** The chain of inequalities opens with:
  $$\Prob{\sum_{i=1}^n X_i > \frac{3}{4}n} = \Prob{Y_n \geq (1/2)^{n/4}}.$$
  Since $Y_n = (1/2)^{n - \sum_i X_i}$, the condition $Y_n \geq (1/2)^{n/4}$ is equivalent to $n - \sum_i X_i \leq n/4$, which is $\sum_i X_i \geq \frac{3}{4}n$. Whenever $\frac{3}{4}n$ is an integer (e.g. $n = 4, 8, \ldots$), the event $\left\{\sum_i X_i > \frac{3}{4}n\right\}$ is a *strict subset* of $\left\{\sum_i X_i \geq \frac{3}{4}n\right\}$. For instance, for $n = 4$:
  $$\Prob{\sum_{i=1}^4 X_i > 3} = \Prob{X = 4} = \frac{1}{16}, \quad\text{whereas}\quad \Prob{Y_4 \geq \frac{1}{2}} = \Prob{X \geq 3} = \frac{5}{16}.$$
  Writing an equality ($=$) here is mathematically incorrect. Furthermore, two steps later on line 174, the substitution of the exact expectation $\Ex{Y_n} = (3/4)^n$ is written with an inequality ($\le$) rather than an equality ($=$).
- **Action Taken:** In [cond_exp_reviewed.tex#L174-L181](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp_reviewed.tex#L174-L181), corrected the first step to an inequality ($\le$) reflecting event inclusion, and replaced the subsequent $\le$ with $=$ upon substituting $\Ex{Y_n} = (3/4)^n$. Annotated with `\remX`.

---

### Finding 2: Conceptual imprecision in definition of conditional expectation
- **Severity & Type:** Consequential Clarity / Mathematical Rigor.
- **Location:** [cond_exp.tex#L45-L61](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp.tex#L45-L61) (Definition 13.1 and subsequent paragraph).
- **Evidence & Impact:** 
  1. The text states that $\ExCond{X}{Y}$ is "a shorthand for $\ExCond{X}{Y=y}$." In probability theory, $\ExCond{X}{Y=y}$ is a deterministic real number (a function $g(y)$ of the realized value $y$), whereas $\ExCond{X}{Y}$ is a *random variable* $g(Y)$. This distinction is critical because Lemma 13.1 immediately states $\Ex{\ExCond{X}{Y}} = \Ex{X}$, which only makes mathematical sense when the inner conditional expectation is a random variable.
  2. The sum is written over $x \in \Omega$, which conflates the sample space $\Omega$ with the support of the random variable $X$.
  3. The condition $\Prob{Y=y} > 0$ is omitted, leaving conditional probability formally undefined when $\Prob{Y=y} = 0$.
  4. The paragraph following the definition repeats "As such,... As such,..." in consecutive sentences.
- **Action Taken:** In [cond_exp_reviewed.tex#L45-L64](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp_reviewed.tex#L45-L64), clarified the distinction between the function $g(y) = \ExCond{X}{Y=y}$ and the random variable $\ExCond{X}{Y} = g(Y)$, required $\Prob{Y=y} > 0$, replaced $x \in \Omega$ with $\sum_x$ over the support of $X$, and revised the prose using `\chgY` and `\remX`.

---

### Finding 3: Notation clash in proof of Law of Total Expectation
- **Severity & Type:** Mathematical Exposition / Notation Consistency.
- **Location:** [cond_exp.tex#L78](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp.tex#L78) (proof of Lemma 13.1).
- **Evidence & Impact:** The proof writes $\ExExt{Y}{\ExCond{X}{Y=y}} = \sum_y \Prob{Y=y}\ExCond{X}{Y=y}$. Placing the dummy realization index $y$ inside an expectation subscripted by the random variable $Y$ introduces a notation clash (taking expectation with respect to $Y$ of an expression with free index $y$).
- **Action Taken:** In [cond_exp_reviewed.tex#L76-L95](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp_reviewed.tex#L76-L95), expanded directly as $\Ex{\ExCond{X}{Y}} = \sum_y \Prob{Y=y} \ExCond{X}{Y=y}$, eliminating the index clash.

---

### Finding 4: Notation shift in Lemma 13.2 proof
- **Severity & Type:** Notation Consistency.
- **Location:** [cond_exp.tex#L113-L115](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp.tex#L113-L115) (proof of Lemma 13.2).
- **Evidence & Impact:** The lemma statement uses the semantic macro $\ExCond{X}{Y}$, but the proof switches abruptly to $\Ex{X \sep{Y}}$ and $\Ex{X \sep{Y=y}}$.
- **Action Taken:** In [cond_exp_reviewed.tex#L110-L124](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp_reviewed.tex#L110-L124), used $\ExCond{X}{Y}$ and $\ExCond{X}{Y=y}$ consistently.

---

### Finding 5: Severe overfull `\hbox`es (3 alerts, 1 warning)
- **Severity & Type:** LaTeX Mechanics / Typography.
- **Location:**
  1. [cond_exp.tex#L103-L107](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp.tex#L103-L107) (Lemma 13.2 statement): 50.97pt overfull `\hbox` caused by inline `\begin{math}` following paragraph text.
  2. [cond_exp.tex#L125](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp.tex#L125) (Lemma 13.2 proof): 54.47pt overfull `\hbox` from chaining 3 multi-term expressions in a single-line `equation*`.
  3. [cond_exp.tex#L180](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp.tex#L180) (Lemma 13.3 proof): 59.71pt overfull `\hbox` from chaining 7 expressions in a single-line `equation*`.
  4. [cond_exp.tex#L180-L184](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp.tex#L180-L184) (Lemma 13.3 symmetry): 2.70pt inline overfull `\hbox`.
- **Evidence & Impact:** Equations spill significantly into the right margin (up to 21mm past text boundary), degrading PDF presentation.
- **Action Taken:** In [cond_exp_reviewed.tex](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp_reviewed.tex):
  - Changed Lemma 13.2 statement to a displayed `equation*` (matching Lemma 13.1).
  - Formatted Lemma 13.2 and Lemma 13.3 proofs with multi-line `align*` environments.
  - Placed the symmetric lower tail bound in a displayed equation.
  All three alerts and the typography warning were eliminated.

---

### Finding 6: Missing label and unstated conditional independence in Lemma 13.3
- **Severity & Type:** Minor Technical Exposition / Referencing.
- **Location:** [cond_exp.tex#L134-L149](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp.tex#L134-L149).
- **Evidence & Impact:** Lemma 13.3 lacks a `\lemlab{...}`. In the proof, $Y_i = Y_{i-1}(1/2)^{1-X_i}$, and taking the expectation $\ExCond{Y_i}{Y_{i-1}} = \frac{3}{4}Y_{i-1}$ relies on $X_i$ being independent of $X_1, \ldots, X_{i-1}$ (and thus independent of $Y_{i-1}$), which is worth stating for pedagogical clarity.
- **Action Taken:** Added `\lemlab{concentration:cond:exp}` and explicitly noted that $X_i$ is independent of $Y_{i-1}$.

---

## 2. Significant Revisions

1. **Definition 13.1 & Surrounding Prose ([cond_exp_reviewed.tex#L45-L64](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp_reviewed.tex#L45-L64)):**
   Tracked revision clarifying that $\ExCond{X}{Y=y}$ defines a deterministic function $g(y)$, while $\ExCond{X}{Y}$ is the random variable $g(Y)$. Removed repetitive "As such" phrasing.
2. **Lemma 13.2 Statement & Display ([cond_exp_reviewed.tex#L98-L107](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp_reviewed.tex#L98-L107)):**
   Converted inline `\begin{math}` to `\begin{equation*}` and added a pedagogical remark linking the lemma to the general tower property $\Ex{g(Y)\ExCond{X}{Y}} = \Ex{g(Y)X}$.
3. **Lemma 13.3 Proof Relations ([cond_exp_reviewed.tex#L167-L185](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp_reviewed.tex#L167-L185)):**
   Fixed the first relation from $=$ to $\le$ and the expectation substitution from $\le$ to $=$. Split equation into a two-line `align*`.

---

## 3. Verification

- **Build Engine & Command:** `/home/sariel/bin/l --no-env -s cond_exp_reviewed.tex` (XeLaTeX via project driver under sanitized environment).
- **Diagnostics Comparison:**
  - Original (`cond_exp.tex`): `Errors: 0, Alerts: 3, Warnings: 2` (Alerts: 50.97pt, 54.47pt, 59.71pt overfull boxes; Warnings: 2.70pt overfull box, empty bibliography).
  - Reviewed (`cond_exp_reviewed.tex`): `Errors: 0, Alerts: 0, Warnings: 1` (Only warning is the harmless empty bibliography emitted by `\ChapterEnd{}`).
- **Cross-References:** All lemma labels and internal references (`\lemref{conditional:expectation}`, `\lemref{concentration:cond:exp}`) resolved with 0 undefined references.
- **Repository Integrity:** Original file [cond_exp.tex](file:///home/sariel/rand_alg/notes/13_cond_exp/cond_exp.tex) was preserved unchanged.
