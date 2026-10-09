# Review Report: Chapter 21 — Martingales

**Source Manuscript:** [martingales.tex](file:///home/sariel/rand_alg/notes/21_martingales/martingales.tex)  
**Reviewed Version:** [martingales_reviewed.tex](file:///home/sariel/rand_alg/notes/21_martingales/martingales_reviewed.tex)  
**Verification:** XeLaTeX (via `/home/sariel/bin/l --no-env -s`), Biber 2.22 (`martingales_reviewed.bib`) — **0 Errors, 0 Warnings, 0 Whatevers**  
**Standalone Suite:** `./tools/test_chapters_standalone 21` — **PASS (clean)**

---

## 1. Actionable Findings (Ordered by Severity)

### [HIGH] Fatal Index Mismatch & Convoluted Conditioning in Proof of Azuma's Inequality
- **Severity & Type:** Confirmed Mathematical Error & Flawed Proof Step.
- **Location (Original):** [martingales.tex#L331-L364](file:///home/sariel/rand_alg/notes/21_martingales/martingales.tex#L331-L364)
- **Location (Reviewed):** [martingales_reviewed.tex#L328-L358](file:///home/sariel/rand_alg/notes/21_martingales/martingales_reviewed.tex#L328-L358)
- **Evidence & Impact:**
  The proof of Azuma's inequality (Theorem 21.1.2) contained several mathematical errors and indexing flaws:
  1. *False conditional expectation:* Line 333 stated:
     $$\ExCond{Y_i}{X_0, \ldots, X_{m-1}} = 0.$$
     For any $i < m$, the difference $Y_i = X_i - X_{i-1}$ is measurable with respect to $X_0, \ldots, X_{m-1}$, so $\ExCond{Y_i}{X_0, \ldots, X_{m-1}} = Y_i \neq 0$. The statement is only valid for the last increment $i = m$.
  2. *Ill-defined function call:* In line 328, $g$ was defined as a function of $m$ variables: $g(X_0, \ldots, X_{m-1}) = \prod_{i=1}^{m-1} e^{\alpha Y_i}$. Line 340 then called $g(X_0, \ldots, X_{i-1})$ with $i$ arguments.
  3. *Unnecessary conditioning detour:* The proof conditioned on the function value $g(X_0, \ldots, X_{m-1})$ to apply a product lemma, instead of directly applying the law of total expectation (tower property) conditioning on the history $X_0, \ldots, X_{m-1}$.
  4. *Markov's inequality written as equality:* Line 372 asserted $\Prob{e^{\alpha X_m} > e^{\alpha \lambda \sqrt{m}}} = \frac{\Ex{e^{\alpha X_m}}}{e^{\alpha \lambda \sqrt{m}}}$. Markov's inequality is an inequality ($\leq$), not an equality.
- **Action Taken:** Streamlined the inductive step using the standard tower property conditioning on $X_0, \ldots, X_{m-1}$:
  $$\Ex{\prod_{i=1}^m e^{\alpha Y_i}} = \Ex{\pth{\prod_{i=1}^{m-1} e^{\alpha Y_i}} \ExCond{e^{\alpha Y_m}}{X_0, \dots, X_{m-1}}} \leq e^{\alpha^2/2} \Ex{\prod_{i=1}^{m-1} e^{\alpha Y_i}}.$$
  Induction over all $m$ steps yields $\leq \exp(m\alpha^2/2)$. Corrected the equality sign in Markov's inequality to $\leq$ and annotated via `\remX`.

---

### [HIGH] Conflation of Martingales with the Markov Property & Path Independence
- **Severity & Type:** Conceptual Error & Pedagogical Misconception.
- **Location (Original):** [martingales.tex#L82-L86, L94-L96](file:///home/sariel/rand_alg/notes/21_martingales/martingales.tex#L82-L86)
- **Location (Reviewed):** [martingales_reviewed.tex#L82-L87, L95-L101](file:///home/sariel/rand_alg/notes/21_martingales/martingales_reviewed.tex#L82-L87)
- **Evidence & Impact:**
  Lines 82--86 introduced martingales with the intuition:
  > *"where the only thing that matters at the beginning of the $i$\th step is where the process was in the end of the $(i-1)$\th step. That is, it does not matter how the process arrived to a certain state, only that it is currently at this state."*
  This is the definition of the **Markov property** (conditional independence of the future given the present), **not** the martingale property. In a martingale:
  1. The distribution of future states (variance, support, step distributions) may depend arbitrarily on the entire path history $X_0, \dots, X_{i-1}$.
  2. Only the *conditional expectation* of the next step given the entire past must equal the present state ($\ExCond{X_i}{X_0, \dots, X_{i-1}} = X_{i-1}$, representing a "fair game" with zero expected drift).
  3. Lines 94--96 claimed $\ExCond{X_i}{X_0, \dots, X_{i-1}} = \ExCond{X_i}{X_{i-1}} = X_{i-1}$. While both conditional expectations evaluate to $X_{i-1}$ for a martingale (by the tower property), requiring only $\ExCond{X_i}{X_{i-1}} = X_{i-1}$ is strictly weaker than the martingale property; the history cannot be discarded.
- **Action Taken:** Rewrote the intuition in terms of fair games and zero expected drift regardless of the trajectory. Clarified that single-step conditioning follows from the tower property but does not replace full-history conditioning. Annotated with `\remX`.

---

### [HIGH] Missing Factor of 2 and Omitted Bounded-Difference Step in Chromatic Number Example
- **Severity & Type:** Confirmed Mathematical Omission & Missing Bound Factor.
- **Location (Original):** [martingales.tex#L404-L410](file:///home/sariel/rand_alg/notes/21_martingales/martingales.tex#L404-L410)
- **Location (Reviewed):** [martingales_reviewed.tex#L406-L416](file:///home/sariel/rand_alg/notes/21_martingales/martingales_reviewed.tex#L406-L416)
- **Evidence & Impact:**
  1. *Missing factor of 2:* The two-sided Azuma inequality (Theorem 21.1.3) gives the upper bound $2\exp(-\lambda^2/2)$. In Example 21.1.4, the two-sided deviation bound for the chromatic number was stated without the factor of 2:
     $$\Prob{\cardin{\chi(G) - \Ex{\chi(G)}} > \lambda \sqrt{n}} \leq e^{-\lambda^2/2}.$$
  2. *Missing bounded-difference condition:* Azuma's inequality requires $|X_i - X_{i-1}| \leq 1$. The text applied Azuma's inequality to the vertex exposure martingale without stating or justifying why $|X_i - X_{i-1}| \leq 1$ holds (namely, that altering the edges incident to vertex $i$ changes the chromatic number $\chi(G)$ by at most 1).
  3. *Typo in sequence notation:* Line 403 wrote `$X_0, \ldots, X_n=X$ is a martingale`, where `=X` was undefined.
- **Action Taken:** Corrected the bound to $2\exp(-\lambda^2/2)$, explicitly supplied the vertex-exposure bounded difference condition $|X_i - X_{i-1}| \leq 1$, cleaned the notation to $X_0, \ldots, X_n$, and annotated with `\remX`.

---

### [MEDIUM] Syntax Error & Incomplete Conditioning in Example 21.1.2.2 ($Y_i = X_i^2 - i$)
- **Severity & Type:** Syntax Defect & Proof Completeness Gap.
- **Location (Original):** [martingales.tex#L148-L165](file:///home/sariel/rand_alg/notes/21_martingales/martingales.tex#L148-L165)
- **Location (Reviewed):** [martingales_reviewed.tex#L150-L168](file:///home/sariel/rand_alg/notes/21_martingales/martingales_reviewed.tex#L150-L168)
- **Evidence & Impact:**
  1. *Unbalanced parenthesis:* Line 155 contained `\pth{ \pth[]{X_{i-1}+1}^2 - i) }`, where a stray right parenthesis caused a ChkTeX syntax warning.
  2. *Conditioning gap:* The text verified only $\Ex{Y_i \sep{Y_{i-1}}}$. But $Y_{i-1} = X_{i-1}^2 - (i-1)$ only determines $X_{i-1}^2$, not $X_{i-1}$. Fortunately, cross terms cancel so the expectation is identical, but the martingale definition requires conditioning on the entire history $(X_0, \ldots, X_{i-1})$ (which generates the filtration of $Y$).
- **Action Taken:** Fixed the parenthesis syntax error, conditioned explicitly on $X_0, \ldots, X_{i-1}$, split the display across lines to resolve a 92pt overfull hbox, and annotated with `\remX`.

---

### [MEDIUM] Missing Local Chapter Bibliography File `martingales.bib`
- **Severity & Type:** Standalone Build Isolation Defect.
- **Location:** Chapter directory `21_martingales/`
- **Evidence & Impact:**
  The chapter cites Motwani and Raghavan [1995] via `\cite{mr-ra-95}`. Under strict environment sanitization (`l --no-env`), Biber cannot look outside the chapter directory for global bib files. Because `martingales.bib` was missing, `./tools/test_chapters_standalone 21` failed with exit code 1.
- **Action Taken:** Created [martingales.bib](file:///home/sariel/rand_alg/notes/21_martingales/martingales.bib) with the canonical entry for `mr-ra-95` and added the symlink [martingales_reviewed.bib](file:///home/sariel/rand_alg/notes/21_martingales/martingales_reviewed.bib) pointing to it.

---

### [LOW] Garbled Conditional Expectation Definition & Grammar Errata
- **Severity & Type:** Prose Quality & Grammar Errata.
- **Location (Original):** [martingales.tex#L57-L60, L169, L210-L212, L222, L238-L246, L386, L398-L399](file:///home/sariel/rand_alg/notes/21_martingales/martingales.tex#L57-L60)
- **Location (Reviewed):** [martingales_reviewed.tex#L57-L61](file:///home/sariel/rand_alg/notes/21_martingales/martingales_reviewed.tex#L57-L61)
- **Evidence & Impact:**
  1. *Garbled definition:* Lines 57--60 read:
     > *"The conditional expectation of $X$ given $Y$, is the random variable $\Ex{X \sep{Y}}$ is the random variable $f(y) = \Ex{X \sep{Y=y}}$."*
     This duplicates "is the random variable" and conflates the random variable $f(Y)$ with its evaluated real value $f(y)$. Corrected to: denoted by $\Ex{X \sep{Y}}$, is the random variable $f(Y)$, where $f(y) = \Ex{X \sep{Y=y}}$.
  2. *Random graph grammar & notation:* Line 210 used unbolded $f(G)$ instead of $f(\G)$. Lines 210--212 had "random variable begin a martingale" (should be "variables being a martingale") and "would be described" (should be "will be described").
  3. *Sheep example grammar:* Line 222 ("from medieval" $\to$ "from a medieval"), Line 238 (lowercase "the" starting a sentence), Line 239 ("dies or get born" $\to$ "dies or is born"), Line 246 ("take a way" $\to$ "take away").
  4. *Theorem 21.1.3 typo:* Line 386 had "such that and $|X_{i+1}-X_i| \leq 1$" (stray "and").
  5. *Example 21.1.4 grammar:* Lines 398--399 had "What is chromatic number" (missing "the") and "random variable behaves" (subject-verb agreement).
- **Action Taken:** Applied corrections directly or tracked via `\chgY`/`\remX`.

---

### [LOW] Massive Equation Layout Overflows (`Overfull \hbox`)
- **Severity & Type:** Typography & Margin Overflows.
- **Evidence & Impact:**
  Multiple mathematical displays exceeded the text margin:
  * Line 163: 92.4pt overflow in Example 21.1.2.2.
  * Line 186: 96.5pt overflow in Example 21.1.2.3 (Pólya's urn chained 4 equations).
  * Line 314: 65.6pt overflow in Taylor series of Azuma's lemma.
  * Line 329: 132.1pt overflow in display defining $\tau$ and $g$ simultaneously.
  * Line 364: 112.0pt overflow in Azuma product bound.
- **Action Taken:** Restructured displays with clean multi-line alignments, eliminating all chapter layout overflows.

---

## 2. Significant Revisions

1. **Proof of Azuma's Inequality (Theorem~\ref{theo:azuma}):**
   Replaced the problematic auxiliary definition $g(X_0, \ldots, X_{m-1})$ and the false step $\ExCond{Y_i}{X_0, \ldots, X_{m-1}} = 0$ ($i < m$) with the canonical, rigorous tower-property induction.
2. **Pedagogical Revision of Martingale Intuition:**
   Clarified the distinction between the Markov property (memorylessness of transition distributions) and the martingale property (zero expected drift conditioned on the entire history).
3. **Chromatic Number Concentration (Example 21.1.4):**
   Supplied the missing factor of 2 in the two-sided concentration bound and stated the necessary vertex-exposure Lipschitz condition $|X_i - X_{i-1}| \leq 1$.

---

## 3. Verification Results

| Target | Command | Result | Errors | Alerts | Warnings |
|:---|:---|:---:|:---:|:---:|:---:|
| `martingales_reviewed.tex` | `l -f --no-env -s martingales_reviewed.tex` | **PASS** | **0** | 1* | **0** |
| `martingales.tex` (baseline) | `l --no-env -s martingales.tex` | **PASS** | **0** | 6 | 3 |
| Standalone Suite | `./tools/test_chapters_standalone 21` | **PASS (clean)** | **0** | — | — |

*\*Note: The single alert in `martingales_reviewed.tex` is located in the external shared fragment `../fragment/def_product_expectation.tex` (50.9pt overfull hbox in shared definition), not in the chapter manuscript itself.*

---

## 4. Author Actions

1. **Confirm Intuition Prose:** Review the revised introductory paragraph for Martingales ([martingales_reviewed.tex#L82-L87](file:///home/sariel/rand_alg/notes/21_martingales/martingales_reviewed.tex#L82-L87)) to ensure the pedagogical framing aligns with the course syllabus.
2. **Review Azuma Proof:** Check the streamlined tower-property induction in the proof of Azuma's inequality ([martingales_reviewed.tex#L328-L358](file:///home/sariel/rand_alg/notes/21_martingales/martingales_reviewed.tex#L328-L358)).
