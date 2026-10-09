# Comprehensive Review Report: Chapter 22 (Martingales II)

This document presents the mathematical review, pedagogical analysis, and technical verification for Chapter 22 of *Randomized Algorithms* ([`martin_II.tex`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex)).

The annotated, fully compilable review manuscript is saved beside the source as [`martin_II_reviewed.tex`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex).

---

## 1. Findings

### Technical Errors & Mathematical Inaccuracies

#### 1. Irrelevant and Confused Difference Condition in Doob Martingales
- **Severity**: Confirmed Technical Error
- **Location**: [`martin_II.tex:305-309`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L305-L309) / [`martin_II_reviewed.tex:309-314`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L309-L314)
- **Evidence & Impact**: The manuscript states:
  > *"Furthermore, if $\cardin{X_i - X_{i-1}} \leq 1$, for $i=1,\ldots, n$, then $\cardin{Y_i - Y_{i-1}} \leq 1$. and we can use Azuma's inequality on such a sequence."*
  
  In a Doob martingale sequence $Y_i = \Ex{f(X_1,\dots,X_n) \mid X_1,\dots,X_i}$, the underlying random variables $X_1, \dots, X_n$ are independent variables taking values in arbitrary domains $\Domain_i$ (e.g., bin assignments in $\{1,\dots,n\}$, colors, graph edges). The difference $\cardin{X_i - X_{i-1}}$ is completely undefined in general domains, and even when numeric, it has no bearing on the martingale increments.
  Crucially, the bounded difference condition $\cardin{Y_i - Y_{i-1}} \leq 1$ holds **unconditionally** because $f$ is $1$-Lipschitz (by McDiarmid's bounded differences lemma):
  $$Y_i - Y_{i-1} = \Ex{f(X) \mid X_1,\dots,X_i} - \Ex{f(X) \mid X_1,\dots,X_{i-1}} = \int [f(X_1,\dots,X_i,x_{i+1}^n) - f(X_1,\dots,X_{i-1},x_i',x_{i+1}^n)] \, dP,$$
  which is bounded in $[-1, 1]$ solely by the Lipschitz property of $f$. Conditioning this property on $|X_i - X_{i-1}| \leq 1$ confuses Doob martingales with general difference-bounded martingales.
- **Action**: Corrected the justification to state that $\cardin{Y_i - Y_{i-1}} \leq 1$ holds because $f$ satisfies the Lipschitz condition (with constant $1$). Added an explanatory remark.

#### 2. Inverted Inequality in Strong Azuma Occupancy Application
- **Severity**: Confirmed Mathematical Inaccuracy / Asymptotic Slip
- **Location**: [`martin_II.tex:481-490`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L481-L490) / [`martin_II_reviewed.tex:480-488`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L480-L488)
- **Evidence & Impact**: Subsection 3.1 states:
  $$\Prob{ \cardin{ Z_{\textrm{end}} - \mu} \geq \lambda \sqrt{n} } \leq 2 \exp \pth{ - \frac{\lambda^2 n (n-1/2)}{n^2 - \mu^2}} \leq 2 \exp \pth{ - \lambda^2 }.$$
  However, for $m = n \ln n$, we have $\mu = n(1 - 1/n)^m \leq 1$. This implies $\mu^2 \leq 1$. Consequently, $n^2 - n/2 < n^2 - \mu^2$ for all $n \geq 2$, so the coefficient satisfies:
  $$\frac{n(n - 1/2)}{n^2 - \mu^2} = 1 - \frac{1}{2n} + O\pth{\frac{1}{n^2}} < 1.$$
  Because this coefficient is strictly strictly less than $1$ for all finite $n$ (e.g., $\approx 0.9036$ for $n=4$, $\approx 0.9575$ for $n=10$), the exponent satisfies $-\frac{\lambda^2 n(n - 1/2)}{n^2 - \mu^2} > -\lambda^2$, which makes:
  $$2 \exp \pth{ - \frac{\lambda^2 n (n-1/2)}{n^2 - \mu^2}} > 2 \exp(-\lambda^2).$$
  The second inequality $\leq 2\exp(-\lambda^2)$ is therefore technically inverted for any finite $n$.
- **Action**: Preserved the display and added [`\remX{...}`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L486-L487) explaining that $\approx 2\exp(-\lambda^2)$ is an asymptotic approximation, and noting that for all $n \geq 2$, the factor $(n^2 - n/2)/(n^2 - \mu^2) \geq 3/4$, providing the rigorous finite-$n$ bound $\leq 2\exp(-3\lambda^2/4)$.

#### 3. Indexing Inconsistencies and Out-of-Bounds Ranges in Martingale Definitions
- **Severity**: Confirmed Indexing / Boundary Errors
- **Locations**:
  - Martingale difference: [`martin_II.tex:163-170`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L163-L170) / [`martin_II_reviewed.tex:163-172`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L163-L172)
  - Martingale relation: [`martin_II.tex:172-175`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L172-L175) / [`martin_II_reviewed.tex:174-176`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L174-L176)
  - Super/sub-martingales: [`martin_II.tex:177-186`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L177-L186) / [`martin_II_reviewed.tex:178-189`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L178-L189)
  - Filter martingale: [`martin_II.tex:191-200`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L191-L200) / [`martin_II_reviewed.tex:194-203`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L194-L203)
  - Doob martingale terminal index: [`martin_II.tex:296`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L296) / [`martin_II_reviewed.tex:300`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L300)
- **Evidence & Impact**:
  - In Definition 22.8, the sequence begins at $Y_1$, but the condition states "for all $i \geq 0$". For $i=0$, $Y_0$ is undefined. For $i=1$, the conditioning tuple $Y_1, \dots, Y_0$ is vacuous, representing $\Ex{Y_1} = 0$. The index should specify $i \geq 1$.
  - Directly following, $Y_i = X_i - X_{i-1}$ requires $X_0$ for $i=1$, but the sequence is introduced as "$X_1, \dots$". It must begin at $X_0$.
  - In Definition 22.9, the sequence $Y_1, Y_2, \dots$ uses $Y_{i-1}$ on the right-hand side. For $i=1$, $Y_{i-1} = Y_0$ is undefined unless the sequence starts at $Y_0$.
  - In Definition 22.10, the sequence is finite ($X_0, \dots, X_n$). Stating the condition "for all $i \geq 0$" attempts to evaluate $X_{n+1}$, which is undefined. The condition holds for $0 \leq i < n$.
  - In Definition 22.14, the sequence is introduced as $Y_0, \dots, Y_m$, but the function $f$ has $n$ independent variables $X_1, \dots, X_n$. The sequence ends at $Y_n$.
- **Action**: Tracked corrections in [`martin_II_reviewed.tex`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex) adjusting each boundary condition with remarks.

#### 4. Double Subtraction in Empty Bins Martingale Transition
- **Severity**: Confirmed Algebraic Typo
- **Location**: [`martin_II.tex:412-415`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L412-L415) / [`martin_II_reviewed.tex:416-419`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L416-L419)
- **Evidence & Impact**: In case (B) of the proof of Theorem 22.17, when ball $t$ lands in an empty bin, the remaining empty bins count updates to $Y_t = Y_{t-1} - 1$. The text states $Z_t = z(Y_t - 1, t)$, which would evaluate to $z(Y_{t-1} - 2, t)$. The actual value is $Z_t = z(Y_t, t) = z(Y_{t-1} - 1, t)$. The subsequent calculation in the proof already uses $z(Y_{t-1} - 1, t)$, showing this was an isolated intermediate typo.
- **Action**: Tracked replacement to $Z_t = z(Y_t, t) = z(Y_{t-1} - 1, t)$.

---

### Pedagogical & Conceptual Issues

#### 5. Undefined Sample Space Symbol $\Sigma$ and Set Hierarchy in Filter Explanation
- **Severity**: Conceptual / Notation Error
- **Location**: [`martin_II.tex:143-145`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L143-L145) / [`martin_II_reviewed.tex:144-147`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L144-L147)
- **Evidence & Impact**: The text reads:
  > *"Putting it explicitly, an atomic event $\Event$ of $\Family_i$, is a subset of $2^{\Sigma}$."*
  
  First, $\Sigma$ is undefined (the sample space was defined throughout as $\Omega$). Second, an event $\Event$ is a subset of $\Omega$ (meaning $\Event \in 2^\Omega$), rather than a subset of $2^\Omega$ (which would be a collection of subsets).
- **Action**: Corrected to "an atomic event $\Event$ of $\Family_i$ is a subset of $\Omega$ (and an atom of $\Family_i$)" with an explanatory remark.

#### 6. Missing Lipschitz Justification for Bins-and-Balls Function $F$
- **Severity**: Pedagogical Gap
- **Location**: [`martin_II.tex:317-320`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L317-L320) / [`martin_II_reviewed.tex:322-326`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L322-L326)
- **Evidence & Impact**: The section defines $Z = F(X_1, \dots, X_m)$ as the number of empty bins and immediately applies Azuma's inequality without explicitly verifying that $F$ satisfies the $1$-Lipschitz condition defined in Definition 22.14.
- **Action**: Added an explicit sentence: *"Since moving any single ball to another bin can change the number of empty bins by at most $1$, the function $F$ satisfies the $1$-Lipschitz condition."*

#### 7. Unexplained Conditioning Random Variables in Proof of Lemma 22.12
- **Severity**: Pedagogical Ambiguity
- **Location**: [`martin_II.tex:215-226`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L215-L226) / [`martin_II_reviewed.tex:217-227`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L217-L227)
- **Evidence & Impact**: The proof abruptly equates $\Ex{\Ex{X \mid \FamilyB} \mid \Family}$ to $\Ex{\Ex{X \mid G=g} \mid F=f}$ without explaining that $f$ and $g$ represent atoms of the sub-$\sigma$-fields $\Family$ and $\FamilyB$, and also uses bracket notation $\ProbLTR[X=x \cap G=g]$.
- **Action**: Added a remark clarifying the atomic evaluation setup and standardized probability notation to $\Prob{X=x \cap G=g}$.

---

### Prose, Typography & Layout Diagnostics

#### 8. Layout Alert: 107.16pt Overfull `\hbox` in Subsection 3.1
- **Severity**: Compiler Alert (107.16pt overflow)
- **Location**: [`martin_II.tex:468-478`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L468-L478) / [`martin_II_reviewed.tex:467-477`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L467-L477)
- **Evidence & Impact**: The entire derivation of the weak Azuma bound was placed on a single unbroken line within `align*`, extending 107.16pt beyond the right margin.
- **Action**: Split the equation across lines with an alignment break before $\leq 2\exp(-\dots)$, completely eliminating the Alert (0 alerts).

#### 9. Typographical, Grammatical, and LaTeX Operator Glitches
- **Spelling**: "Bibliograhpical notes" -> "Bibliographical notes" ([`martin_II.tex:492`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L492)).
- **Spelling / Contraction**: "Lets verify" -> "Let's verify" ([`martin_II.tex:461`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L461)); "its a sequence" -> "it is a sequence" ([`martin_II.tex:140`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L140)).
- **Grammar**: "where thrown" -> "were thrown" ([`martin_II.tex:389`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L389)); "had thrown" -> "were thrown" ([`martin_II.tex:318`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L318)); "with a arguments" -> "with arguments" ([`martin_II.tex:277`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L277)); "yield the result" -> "yields the result" ([`martin_II.tex:457`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L457)).
- **Punctuation**: Rogue comma after period `$X_m$.  , By` -> `$X_m$. By` ([`martin_II.tex:318`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L318)); period before connective `1$. and we can` -> `$1$, and we can` ([`martin_II.tex:307`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L307)).
- **Operators**: Missing union sign `$C_1 \cup C_2 \ldots \in \Family$` -> `$C_1 \cup C_2 \cup \dots \in \Family$` ([`martin_II.tex:38`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L38)); small binary operator used for indexed union `\cup_i C_i` -> large operator `\bigcup_i C_i` ([`martin_II.tex:52`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex#L52)).

---

## 2. Significant Revisions

The following tracked substantive changes were introduced into [`martin_II_reviewed.tex`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex):

1. **Doob Martingale Bounded Increments** ([lines 309-314](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L309-L314)):
   Replaced the false condition $\cardin{X_i - X_{i-1}} \leq 1$ with the true premise that $f$ is $1$-Lipschitz, ensuring the property holds unconditionally in accordance with McDiarmid's lemma.
2. **Analysis of the Strong Azuma Bound** ([lines 480-488](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L480-L488)):
   Added a detailed remark explaining that the second inequality $\leq 2\exp(-\lambda^2)$ is an asymptotic approximation, and provided the exact rigorous non-asymptotic lower bound on the exponent ($3/4 \lambda^2$ for $n \ge 2$).
3. **Sequence Index Normalization** ([lines 163-203, 300](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L163-L203)):
   Unified all martingale and martingale difference indices to eliminate undefined prior terms ($Y_0$, $X_{n+1}$, $Y_m$) and boundary inconsistencies.
4. **Lipschitz Condition for Occupancy** ([lines 322-326](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L322-L326)):
   Explicitly stated why the balls-in-bins empty bin counter $F$ satisfies the $1$-Lipschitz property, bridging the definition to the application.

---

## 3. Verification

The manuscript was verified using the repository's dedicated compiler wrapper (`l --no-env`).

### Build Command & Diagnostics

- **Build Driver**: `/home/sariel/bin/l`
- **Options**: `--no-env` (environment sanitization resetting `TEXINPUTS`, `BIBINPUTS`, `BSTINPUTS`), `-f` (force re-compilation)
- **Engine**: XeLaTeX with Biber (`biblatex`)
- **Compilation Passes**: `xelatex (1)`, `biber`, `xelatex (2)`, `xelatex (3)`

### Diagnostic Score Comparison

| Metric | Original Manuscript ([`martin_II.tex`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II.tex)) | Reviewed Manuscript ([`martin_II_reviewed.tex`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex)) |
| :--- | :---: | :---: |
| **Errors** | **0** | **0** |
| **Alerts** | **1** (107.16pt too wide on L478) | **0** (completely resolved) |
| **Warnings** | **1** (3.36pt too wide on L305) | **2** (minor hbox wrapping: 6.81pt, 3.36pt) |
| **Whatevers** | 1 | 1 |
| **Bibliography / Citations** | Resolved (`mr-ra-95`) | Resolved (`mr-ra-95`) |
| **Status** | Clean build with layout alert | **Clean build (0 errors, 0 alerts)** |

---

## 4. Author Actions

1. **Reviewer Remark on Strong Azuma Bound ([`martin_II_reviewed.tex:486-487`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L486-L487))**:
   Decide whether to keep the asymptotic notation $\approx 2\exp(-\lambda^2)$ in the main display, or replace the final inequality with the rigorous non-asymptotic bound $\leq 2\exp(-3\lambda^2/4)$ for $n \geq 2$.
2. **Reviewer Remark on Lemma 22.12 Tower Property ([`martin_II_reviewed.tex:217`](file:///home/sariel/rand_alg/notes/22_martingales_II/martin_II_reviewed.tex#L217))**:
   Confirm whether introducing explicit indicator notation $F=f$ and $G=g$ for the partition atoms in the proof statement is preferred over an informal explanation.
