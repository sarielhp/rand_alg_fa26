# Manuscript Review Report: Chapter 06 (Verifying Identities)

## 1. Findings

### [Finding 1] Trivialized Dot-Product Equality Check
- **Severity & Type:** Confirmed Technical Error (Critical)
- **Location:** [verify.tex:L73-L78](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L73-L78) | Reviewed: [verify_reviewed.tex:L73-L78](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L73-L78)
- **Evidence & Impact:** In the vector equality test, both branches compared $\DotProd{\vecA}{\vecRand}$ to itself modulo 2:
  ```latex
  \item If $\DotProd{\vecA}{\vecRand} \equiv \DotProd{\vecA}{\vecRand} \bmod 2 \dots$
  \item If $\DotProd{\vecA}{\vecRand} \nequiv \DotProd{\vecA}{\vecRand} \bmod 2 \dots$
  ```
  Because $\DotProd{\vecA}{\vecRand} \equiv \DotProd{\vecA}{\vecRand} \bmod 2$ is an identity, the algorithm unconditionally returned `=` and never detected unequal vectors.
- **Action:** Corrected the second operand in both cases to $\DotProd{\vecB}{\vecRand}$ using `\chgY`.

---

### [Finding 2] Inverted Guarantee in Vector Equality Amplification Lemma
- **Severity & Type:** Confirmed Technical Error (Critical)
- **Location:** [verify.tex:L161-L163](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L161-L163) | Reviewed: [verify_reviewed.tex:L161-L163](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L161-L163)
- **Evidence & Impact:** The lemma stated:
  ```latex
  \item[\qquad $\boldsymbol =$:] Then, with probability $\geq 1-\delta$, we have $\vecA \neq \vecB$.
  ```
  This asserted that when the algorithm reports equality, the vectors are different with probability $\geq 1-\delta$, completely reversing the soundness guarantee.
- **Action:** Corrected $\vecA \neq \vecB$ to $\vecA = \vecB$ using `\chgY`.

---

### [Finding 3] Unbound Index & Double Sign in Bipartite Matching Determinant
- **Severity & Type:** Confirmed Technical Error (Critical)
- **Location:** [verify.tex:L380, L398-L400](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L380) | Reviewed: [verify_reviewed.tex:L380-L399](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L380-L399)
- **Evidence & Impact:**
  1. Monomial definition $f_\pi = \mathrm{sign}(\pi) \prod_{i=1}^n M[i,j]$ had an unbound column variable $j$ instead of $\pi(i)$.
  2. Defining $f_\pi$ with $\mathrm{sign}(\pi)$ and then expanding $\det(M) = \sum_{\pi \in \Pi} \mathrm{sign}(\pi) f_\pi$ squares the permutation sign: $(\mathrm{sign}(\pi))^2 = 1$. This turns the determinant into the permanent (which is \#P-complete, precluding polynomial-time evaluation via Gaussian elimination).
- **Action:** Redefined $f_\pi = \prod_{i=1}^n M[i,\pi(i)]$ as the unsigned monomial, leaving $\det(M) = \sum_{\pi} \mathrm{sign}(\pi) f_\pi$. Added an explanatory `\remX`.

---

### [Finding 4] Erroneous Exponent in Schwartz-Zippel Proof
- **Severity & Type:** Confirmed Technical Error (Major)
- **Location:** [verify.tex:L298](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L298) | Reviewed: [verify_reviewed.tex:L298](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L298)
- **Evidence & Impact:** In the reduction to a single-variable polynomial, $g(x)$ was written as:
  ```latex
  g(x) = \sum_{j=0}^d f_j(r_2, \ldots, r_n) x^i
  ```
  The variable $x$ was raised to $x^i$ for all terms instead of the summation index $x^j$.
- **Action:** Corrected $x^i$ to $x^j$ and annotated with `\remX`.

---

### [Finding 5] Unbound Index in Vector Difference Analysis
- **Severity & Type:** Confirmed Technical Error (Major)
- **Location:** [verify.tex:L100, L104](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L100) | Reviewed: [verify_reviewed.tex:L100, L104](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L100)
- **Evidence & Impact:** The proof assumed $\vecA$ and $\vecB$ differ at coordinate $n$ ($u_n \neq v_n$). The two cases then analyzed the random bit as $r_i = 0$ and $r_i = 1$ rather than $r_n = 0$ and $r_n = 1$.
- **Action:** Corrected $r_i$ to $r_n$ using `\chgY`.

---

### [Finding 6] Corrupted Macro Definition `\RetNEq`
- **Severity & Type:** Confirmed Defect (Major)
- **Location:** [verify.tex:L113](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L113) | Reviewed: [verify_reviewed.tex:L113](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L113)
- **Evidence & Impact:** `\RetNEq` was defined as `\ensuremath{\text{`$\boldsymbol =$'}}\xspace`, printing equality `'='` instead of `'≠'`.
- **Action:** Updated the inner math symbol from `\boldsymbol =` to `\boldsymbol \ne` using `\chgY`.

---

### [Finding 7] Conflation of Sample Evaluation and Zero Polynomial in Event $\EventG$
- **Severity & Type:** Mathematical Exposition / Ambiguity
- **Location:** [verify.tex:L301, L306](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L301) | Reviewed: [verify_reviewed.tex:L301, L306](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L301)
- **Evidence & Impact:** Defining $\EventG$ as "$g(x) = 0$" suggests the polynomial $g$ is identically zero, whereas the conditional probability bounds $\ProbCond{g(r_1) = 0}{\smash{\overline{\EventF}}}$ for a uniform sample $r_1 \in S$.
- **Action:** Clarified the event definition and conditional probability to $g(r_1) = 0$.

---

### [Finding 8] Stray Character `4` in Body Text
- **Severity & Type:** Typographic Glitch
- **Location:** [verify.tex:L495](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L495) | Reviewed: [verify_reviewed.tex:L495](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L495)
- **Evidence & Impact:** The source had `\end{equation*}4`, which rendered an isolated digit `4` in the PDF between the definition and "where $\overline{L} = \Sigma^* \setminus L$".
- **Action:** Removed the stray character `4`.

---

### [Finding 9] Free Variable $x$ in Complexity Definitions
- **Severity & Type:** Notation Defect
- **Location:** [verify.tex:L468, L478](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L468) | Reviewed: [verify_reviewed.tex:L468, L478](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L468)
- **Evidence & Impact:** Definitions of $\CClass{P}$ and $\CClass{NP}$ began "such that for any input $\Sigma^*$, we have", omitting the variable name $x$ before using $x \in L$ in the items below.
- **Action:** Corrected to "for any input $x \in \Sigma^*$".

---

## 2. Significant Revisions

- **Tracked Technical Changes:**
  - Vector dot-product equality condition: $\DotProd{\vecA}{\vecRand} \equiv \DotProd{\vecB}{\vecRand} \bmod 2$.
  - Vector lemma guarantee: $\vecA = \vecB$ on output `=`.
  - Proof variables: $r_i \to r_n$.
  - Polynomials ring notation: $\Field[x_1, \dots, x_n]$ ($X_n \to x_n$).
  - Schwartz-Zippel polynomial: $g(x) = \sum_{j=0}^d f_j(r_2,\dots,r_n) x^j$.
  - Matching matrix entry: $M[i,\pi(i)]$.
  - Complexity input specification: $x \in \Sigma^*$.
- **Silent Minor Corrections:**
  - "could the use the black-box" $\to$ "could use the black-box".
  - "less calls" $\to$ "fewer calls".
  - "sum of monomial" $\to$ "sum of monomials".
  - "one of the $f$s must be non-zero, and let $i$ the maximum value" $\to$ "one of the $f_i$s must be non-zero, and let $i$ be the maximum value".
  - "we need to computes its determinant" $\to$ "we need to compute its determinant".
  - "randomized algorithms that {\em always} return" $\to$ "randomized algorithm that {\em always} returns".
  - "The only variant is that it's running time" $\to$ "The only variation is that its running time".
  - "example for a Las Vegas" $\to$ "example of a Las Vegas".
  - "logarithmic model. \CClass{PSPACE}," $\to$ "logarithmic model, \CClass{PSPACE},".
  - "If you do now know what are those things" $\to$ "If you do not know what those things are".
  - "algorithm that make a mistake" $\to$ "algorithm that makes a mistake".
  - "mind-boggling stupid" $\to$ "mind-bogglingly stupid".
  - "as it return the correct" $\to$ "as it returns the correct".

---

## 3. Verification

- **Build Engine & Driver:** `/home/sariel/bin/l -s verify_reviewed.tex` (XeLaTeX multi-pass driver with Biber integration).
- **Compilation Status:** **PASS** (0 Errors, 0 Warnings, 4 Alerts, 1 Suppressed).
- **Generated Output:** `junk/verify_reviewed.pdf` (83.4 KB, cleanly rendered with continuous dual-mode pagination at page 45).
- **Git Status:** Working directory clean; only `verify_reviewed.tex` and `review.md` added.

---

## 4. Author Actions

1. **Circle Remark (Section 1.2.1):** The text states that $f(x,y) = (x-1)^2 + (y-1)^2 - 1 = 0$ is the "unit circle". This is centered at $(1,1)$. If the author intended the standard unit circle centered at $(0,0)$, replace with $x^2 + y^2 - 1 = 0$.
2. **Field Size in Matching Application (Section 1.3):** For testing $\det(M) \neq 0$ over a finite field $\ZZ_p$, it would be pedagogically helpful to mention that choosing $p > 2n$ ensures error probability $\leq n/p < 1/2$ by Schwartz-Zippel, connecting the algorithm directly to the lemma.
