# Manuscript Review Report: Chapter 06 (Verifying Identities, and Some Complexity)

## 1. Findings

### [Finding 1] Variable Shadowing and Index Collision in Schwartz--Zippel Proof
- **Severity & Type:** Confirmed Technical Defect (Major)
- **Location:** Original: [verify.tex:L299-L337](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L299-L337) | Reviewed: [verify_reviewed.tex:L299-L337](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L299-L337)
- **Evidence & Impact:** In the polynomial expansion $f(x_1, \ldots, x_n) = \sum_{i=0}^d x_1^i f_i(x_2, \ldots, x_n)$, the index $i$ was used as the summation dummy variable. Immediately afterward, the text defined $i$ as the *maximum* index such that $f_i \neq 0$, creating a notation collision.
- **Action:** Per author request, changed the maximum non-zero index to $\xi$: defined $\xi$ as the maximum index such that $f_\xi \neq 0$. Consistently updated all subsequent steps in the proof ($f_\xi$, $\Prob{\EventF} \leq (d-\xi)/|S|$, and $\ProbCond{\EventG}{\smash{\overline{\EventF}}} \leq \xi/|S|$) to use $\xi$, leaving $i$ purely as the dummy summation index in $f$ and $g$.

---

### [Finding 2] Schwartz--Zippel Single-Variable Step Justification
- **Severity & Type:** Mathematical Rigor / Exposition
- **Location:** Original: [verify.tex:L314-L315](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L314-L315) | Reviewed: [verify_reviewed.tex:L319-L325](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L319-L325)
- **Evidence & Impact:** In bounding $\ProbCond{\EventG}{\smash{\overline{\EventF}}}$, the text stated "by induction, we have that $\ProbCond{\EventG}{\smash{\overline{\EventF}}} \leq i/|S|$". However, conditional on $\smash{\overline{\EventF}}$, $g(x)$ is a non-zero single-variable polynomial of degree $i$, and $r_1$ is sampled from $S$. The root bound follows from the **base case** ($n=1$, roots of univariate polynomials), not from the inductive hypothesis for $n-1$ multivariate variables.
- **Action:** Corrected "by induction" to "by the base case" using `\chgY`.

---

### [Finding 3] Field Definition Over-Specification and Finite Set Constraint
- **Severity & Type:** Mathematical Precision
- **Location:** Original: [verify.tex:L239, L282](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L239) | Reviewed: [verify_reviewed.tex:L239, L282](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L239)
- **Evidence & Impact:**
  1. Section 1.2.1 introduced $\Field$ as "Let $\Field$ be a field (i.e., real numbers)". Schwartz--Zippel holds over any field, and the bipartite matching section later specifically employs finite fields $\ZZ_p$.
  2. Lemma 1.5 stated "Let $S \subseteq \Field$ be finite", omitting the requirement that $S$ be non-empty (to avoid division by $|S| = 0$).
- **Action:** Corrected "(i.e., real numbers)" to "(e.g., the real numbers or a finite field $\ZZ_p$)", and added "non-empty" to the specification of $S$.

---

### [Finding 4] Vector Difference Modulo Arithmetic Clarity
- **Severity & Type:** Pedagogical Clarity
- **Location:** Original: [verify.tex:L90-L113](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L90-L113) | Reviewed: [verify_reviewed.tex:L90-L113](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L90-L113)
- **Evidence & Impact:** The proof assumed $\vecA$ and $\vecB$ differ on the $n$-th bit ($u_n \neq v_n$), and immediately split into cases $\alpha' \not\equiv \beta'$ and $\alpha' \equiv \beta'$. A reader must infer why $r_n = 0$ works for Case 1 and $r_n = 1$ works for Case 2. Since $u_n, v_n \in \{0,1\}$, we have $v_n - u_n \equiv 1 \pmod 2$, which directly implies $\alpha - \beta \equiv (\alpha' - \beta') + r_n \pmod 2$.
- **Action:** Added the explicit relation $\alpha - \beta \equiv (\alpha' - \beta') + r_n \pmod 2$, making the two cases immediately transparent. Cleaned up inline track-change artifacts from the previous revision.

---

### [Finding 5] Incomplete Bibliographical Coverage
- **Severity & Type:** Completeness / Missing Content (Addressed per Prompt)
- **Location:** Original: [verify.tex:L597-L600](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L597-L600) | Reviewed: [verify_reviewed.tex:L600-L618](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L600-L618)
- **Evidence & Impact:** The bibliographical notes originally contained only a single sentence referencing Motwani & Raghavan \cite{mr-ra-95} for Section 2. Major foundational results presented in the chapter (Freivalds' matrix verification algorithm, Schwartz and Zippel's polynomial identity testing lemma, Lovász's bipartite matching algorithm, Babai's Las Vegas terminology, and Gill's probabilistic complexity classes) lacked citations.
- **Action:** Added concise, focused bibliographical notes covering all core topics. Added 9 missing BibTeX entries to `/home/sariel/papers/bib/geometry.bib` with standard citation keys (`f-pmcul-77`, `s-fpavp-80`, `z-pasp-79`, `dl-prapt-78`, `e-sdra-67`, `t-flg-47`, `l-odmra-79`, `b-mcmgi-79`, `g-ccptm-77`).

---

### [Finding 6] Unit Circle Remark Clarification
- **Severity & Type:** Minor Exposition / Geometry
- **Location:** Original: [verify.tex:L340](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L340) | Reviewed: [verify_reviewed.tex:L344](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L344)
- **Evidence & Impact:** The polynomial $(x-1)^2 + (y-1)^2 - 1 = 0$ is a unit circle centered at $(1,1)$, not the standard unit circle centered at the origin.
- **Action:** Clarified as "the unit circle \newX{centered at $(1,1)$}".

---

### [Finding 7] Degree Expansion in Polynomial Product Verification
- **Severity & Type:** Pedagogical Suggestion
- **Location:** Original: [verify.tex:L367-L373](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L367-L373) | Reviewed: [verify_reviewed.tex:L373-L378](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L373-L378)
- **Evidence & Impact:** When testing whether $fg = h$ for polynomials $f, g$ of degree $d$, the product $fg$ has degree up to $2d$. If the test samples from $S = \IRX{d^3}$, the error probability is bounded by $2d/|S|$ rather than $d/|S|$.
- **Action:** Added an explanatory `\remX` noting that $|S| \geq (2d)^3$ preserves the target error probability.

---

### [Finding 8] Finite Field Matching Bound
- **Severity & Type:** Pedagogical Clarification
- **Location:** Original: [verify.tex:L433-L437](file:///home/sariel/rand_alg/notes/06_verify/verify.tex#L433-L437) | Reviewed: [verify_reviewed.tex:L444-L448](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L444-L448)
- **Evidence & Impact:** The text noted that evaluation can be done over $\ZZ_p$ for a prime $p$ without connecting the field size back to Schwartz--Zippel.
- **Action:** Added a `\remX` explaining that choosing $p > 2n$ ensures error probability $\leq n/p < 1/2$.

---

## 2. Significant Revisions

- **Tracked Technical Changes:**
  - Schwartz--Zippel proof: dummy summation index $i$ in $f$ and $g$; maximum non-zero index changed to $\xi$ for readability ($f_\xi$, $\Prob{\EventF} \leq (d-\xi)/|S|$, and $\ProbCond{\EventG}{\smash{\overline{\EventF}}} \leq \xi/|S|$) ([verify_reviewed.tex:L299-L337](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L299-L337)). Justified univariate step using base case ($n=1$) instead of induction.
  - Remark 1.6: annotated circle center as $(1,1)$ ([verify_reviewed.tex:L344](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L344)).
  - Complexity notes: explicitly recorded $\CClass{ZPP} = \CClass{RP} \cap \coCClass{RP}$ ([verify_reviewed.tex:L545](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L545)) and clarified that the margin of advantage in $\CClassPP$ can be exponentially small ($1/2 + 2^{-n}$) ([verify_reviewed.tex:L574-L576](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L574-L576)).
  - Section 3: replaced single-sentence note with concise, comprehensive bibliographical notes ([verify_reviewed.tex:L600-L618](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex#L600-L618)).
- **Silent Minor Corrections:**
  - "non-negative integer number" $\to$ "non-negative integer".
  - "black-box" $\to$ "black box" (noun form).
  - "two computations of dot-product modulo 2" $\to$ "two dot-product computations modulo $2$".
  - "if the `$\boldsymbol \ne$' is returned then" $\to$ "if `$\boldsymbol \ne$' is returned, then".
  - "sum of monomial" $\to$ "sum of monomials".
  - "for any two different permutation" $\to$ "for any two different permutations".
  - "for all permutation $\pi$" $\to$ "for all permutations $\pi$".
  - "we need to computes its determinant" $\to$ "we need to compute its determinant".
  - "what are Turing machines" $\to$ "what Turing machines are".
  - "logarithmic model. \CClass{PSPACE}," $\to$ "logarithmic model, \CClass{PSPACE},".
  - "If you do now know what are those things" $\to$ "If you do not know what those things are".
  - "worst case polynomial running time" $\to$ "worst-case polynomial running time".
  - "an algorithm that make a mistake" $\to$ "an algorithm that makes a mistake".
  - "An algorithm is in \CClassPP needs" $\to$ "An algorithm in \CClassPP needs".

---

## 3. Verification

- **Build Engine & Command:** `/home/sariel/bin/l -s verify_reviewed.tex`
- **XeLaTeX & Biber Status:** **PASS** (0 Errors, 0 Warnings, 0 Alerts).
- **Bibliography Verification:** All 10 cited keys (`b-mcmgi-79`, `dl-prapt-78`, `e-sdra-67`, `f-pmcul-77`, `g-ccptm-77`, `l-odmra-79`, `mr-ra-95`, `s-fpavp-80`, `t-flg-47`, `z-pasp-79`) resolved completely with clean citations and entries in `junk/verify_reviewed.bbl`.
- **Output Artifacts:** `junk/verify_reviewed.pdf` (84.7 KB, cleanly compiled with dual-mode pagination at page 45).
- **Repository Hygiene:** Working tree clean; base `verify.tex` untouched.

---

## 4. Author Actions

1. **Circle Equation (Remark 1.6):** The text writes $f(x,y) = (x-1)^2 + (y-1)^2 - 1 = 0$. If the author prefers the standard origin-centered circle, it can simply be updated to $x^2 + y^2 - 1 = 0$.
2. **Review Macros:** Once the author confirms the tracked changes in [verify_reviewed.tex](file:///home/sariel/rand_alg/notes/06_verify/verify_reviewed.tex), they can be accepted in place into [verify.tex](file:///home/sariel/rand_alg/notes/06_verify/verify.tex).
