# Review Report: Chapter 15 — Concentration of Random Variables (Chernoff's Inequality)

**Source Manuscript:** [chernoff.tex](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex)  
**Reviewed Version:** [chernoff_reviewed.tex](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex)  
**Verification:** XeLaTeX (via `/home/sariel/bin/l --no-env`), BibLaTeX (`chernoff_reviewed.bib`) — **0 Errors, 0 Warnings, 1 Whatevers**

---

## 1. Findings (Ordered by Severity)

### [CRITICAL] Recurring Upper Summation Index $b$ Instead of $n$
- **Severity / Type:** Confirmed Technical Error.
- **Locations (Original):**
  - Theorem 15.9 (`\thmlab{Chernoff:simplified}`): [chernoff.tex#L897](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L897)
  - Lemma 15.13 (`\lemlab{chernoff:small:delta:1}`): [chernoff.tex#L1147](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1147)
  - Lemma 15.14 (`\lemlab{chernoff:small:delta}`): [chernoff.tex#L1204](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1204)
  - Lemma 15.15 (`\lemlab{chernoff:delta:gap}`): [chernoff.tex#L1248](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1248)
  - Lemma 15.16 (`\lemlab{chernoff:delta:big}`): [chernoff.tex#L1294](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1294)
  - Lemma 15.17 (`\lemlab{chernoff:delta:r:big}`): [chernoff.tex#L1324](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1324)
  - Lemma 15.18 (`\lemlab{chandra:wanted:it}`): [chernoff.tex#L1382](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1382)
  - Example 15.19: [chernoff.tex#L1448](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1448)
- **Locations (Reviewed):**
  - [chernoff_reviewed.tex#L898-L903](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L898-L903), [chernoff_reviewed.tex#L1155](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1155), [chernoff_reviewed.tex#L1214](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1214), [chernoff_reviewed.tex#L1260](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1260), [chernoff_reviewed.tex#L1309](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1309), [chernoff_reviewed.tex#L1340](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1340), [chernoff_reviewed.tex#L1402](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1402), [chernoff_reviewed.tex#L1473](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1473)
- **Evidence & Impact:** The sum of $n$ independent variables is consistently defined as $X = \sum_{i=1}^b X_i$ (or $Y = \sum_{i=1}^b X_i$). The symbol $b$ is undefined and conflicts with upper bounds $b_i$ later used in Hoeffding's inequality.
- **Action Taken:** Replaced $\sum_{i=1}^b X_i$ with $\sum_{i=1}^n X_i$ in all 8 locations and documented with `\remX`.

---

### [CRITICAL] Undefined Cross-Reference in Solution (`\Eqref{sol}`)
- **Severity / Type:** Confirmed Technical Error (Broken Reference).
- **Location:** [chernoff.tex#L2137](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L2137) vs [chernoff_reviewed.tex#L2168-L2169](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L2168-L2169)
- **Evidence & Impact:** In the solution to Exercise 15.25 (`Chernoff:tight`), the text states: `In particular, the first term in \Eqref{sol} is`. The target equation at [chernoff.tex#L2106](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L2106) is labeled `\eqlab{sum}`. There is no label `sol` anywhere in the repository. In solution-enabled builds, this renders as an unresolved reference `(??)`.
- **Action Taken:** Corrected `\Eqref{sol}` to `\Eqref{sum}`.

---

### [HIGH] Inverted Inequalities and Sign Errors in Lemma 15.18 (`\lemlab{chandra:wanted:it}`) Proof
- **Severity / Type:** Confirmed Mathematical Rigor Error.
- **Location:** [chernoff.tex#L1410-L1412](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1410-L1412), [chernoff.tex#L1426-L1436](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1426-L1436) vs [chernoff_reviewed.tex#L1430-L1433](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1430-L1433), [chernoff_reviewed.tex#L1448-L1460](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1448-L1460)
- **Evidence & Impact:**
  1. *Case 1 ($\xi \geq 2e - 1$):* The text asserts:
     $$-\mu(1+\xi) > -\mu\xi > \mu\frac{3\ln\BadProb^{-1}}{\mu\delta^2} > \log_2\BadProb^{-1}.$$
     Since $\mu > 0$ and $1+\xi > \xi$, $-\mu(1+\xi) < -\mu\xi$ (the reverse of what is written). Furthermore, $\mu$ appears in both numerator and denominator unsimplified. To prove $2^{-\mu(1+\xi)} < \BadProb$, one must show $\mu(1+\xi) > \log_2\BadProb^{-1}$.
  2. *Case 2 ($\xi \leq 6$):* The display reads:
     $$-\frac{\mu}{5}\xi^2 = -\frac{\mu}{5}\pth{\delta + \frac{3\ln\BadProb^{-1}}{\mu\delta^2}}^2 > -\frac{\mu}{5}\pth{2\delta\frac{3\ln\BadProb^{-1}}{\mu\delta^2}} = -\frac{6}{5}\frac{\ln\BadProb}{\delta} > -\ln\BadProb.$$
     Because of the negative sign in front, $-(\delta+A)^2 \leq -2\delta A$, so the inequality direction is $\leq$, not $>$. Furthermore, $\BadProb \in (0, 1] \implies \ln\BadProb \leq 0$, so writing $-\frac{6}{5}\frac{\ln\BadProb}{\delta} > -\ln\BadProb$ conflates $\ln\BadProb$ with $\ln\BadProb^{-1}$.
- **Action Taken:** Corrected the derivations cleanly:
  - Case 1: $\mu(1+\xi) > \mu\xi = \mu\delta + \frac{3\ln\BadProb^{-1}}{\delta^2} \geq 3\ln\BadProb^{-1} > \log_2\BadProb^{-1}$, justifying $2^{-\mu(1+\xi)} < \BadProb$.
  - Case 2: $-\frac{\mu}{5}\xi^2 \leq -\frac{6}{5\delta}\ln\BadProb^{-1} \leq -\ln\BadProb^{-1} = \ln\BadProb$, justifying $\exp(-\frac{\mu}{5}\xi^2) \leq \BadProb$.

---

### [HIGH] Cheat Sheet Summary Table Discrepancies
- **Severity / Type:** Confirmed Pedagogical / Mathematical Inconsistency.
- **Location:** [chernoff.tex#L144-L170](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L144-L170), [chernoff.tex#L269](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L269), [chernoff.tex#L358-L391](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L358-L391) vs [chernoff_reviewed.tex#L144-L170](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L144-L170), [chernoff_reviewed.tex#L269](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L269), [chernoff_reviewed.tex#L435](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L435)
- **Evidence & Impact:**
  1. *Symmetric Variable Subtable:* The header explicitly defines $X_i \in \{-1, +1\}$ with equal probability ($Y = \sum X_i$, $\Ex{Y}=0$). Row 3 lists $\Prob{|Y - n/2| \geq \Delta} \leq 2\exp(-2\Delta^2/n)$, citing Corollary 15.7 (`\corref{Chernoff:0:1}`). But Corollary 15.7 is for $\{0, 1\}$ coin flips. For $\{-1, +1\}$, the two-sided bound is $\Prob{|Y| \geq \Delta} \leq 2\exp(-\Delta^2/2n)$ from Corollary 15.6 (`\corref{Chernoff:special}`). Subtracting $n/2$ under the $\{-1, +1\}$ header is misleading.
  2. *Relative Entropy Lower Tail Condition:* Table 2 lists $\delta \geq 0$ for the relative entropy bound $\Prob{Y < (1-\delta)\mu} < [\frac{e^{-\delta}}{(1-\delta)^{1-\delta}}]^\mu$. For $\delta > 1$, $(1-\delta)^{1-\delta}$ is undefined for real numbers. The bound requires $\delta \in (0, 1)$.
  3. *Omitted Citations:* Subtable 3 leaves the reference cells for the lower-tail bounds blank.
- **Action Taken:** Corrected the domain condition to $\delta \in (0, 1)$ in Table 2, and added a detailed reviewer remark (`\remX`) directly following the table environment explaining the subtable 1 mismatch and omitted references.

---

### [MEDIUM] Missing Hypothesis Constraints in Theorems
- **Severity / Type:** Mathematical Completeness / Rigor Omission.
- **Locations:**
  - Theorem 15.11 (`\thmlab{Chernoff:2}`): [chernoff.tex#L1044](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1044) vs [chernoff_reviewed.tex#L1044](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1044)
  - Theorem 15.25 (`\thmlab{special:h:i:e}`): [chernoff.tex#L1730](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1730) vs [chernoff_reviewed.tex#L1762](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1762)
  - Exercise 15.27 (`\exeref{geometric:tail:inequality}`): [chernoff.tex#L2276](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L2276) vs [chernoff_reviewed.tex#L2310](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L2310)
- **Evidence & Impact:**
  - In Theorem 15.11, the relative lower tail bound omits the hypothesis $\delta \in (0, 1)$ (unlike Theorem 15.9 which states $\delta > 0$).
  - In Theorem 15.25, the bound $\Prob{X - \mu \geq \eps\mu} \leq \exp(-\eps^2\mu/4)$ relies on integration over $x \in [0, 1]$ where $\eps \in [0, 1]$, but this domain is omitted from the theorem statement.
  - In Exercise 15.27, the claimed bound and its reduction $\sum Z_i \leq (1-\delta/2)\rho$ require $\delta \in (0, 1]$ (for $\delta > 1$, $1 - \delta/2 < 1/2$ and the reduction fails).
- **Action Taken:** Explicitly supplied $\delta \in (0, 1)$, $\eps \in [0, 1]$, and $\delta \in (0, 1]$ in the respective statements.

---

### [MEDIUM] Variable Collisions and Calculus Slips in Proofs
- **Severity / Type:** Confirmed Minor Technical Errors.
- **Locations & Issues:**
  1. *Remark 15.8 ([chernoff.tex#L857-L862](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L857-L862)):* The prose states `Set $\delta = t\sqrt{n}$`, but the equation uses $\Delta$ (`\cardin{Y - n/2} \geq \Delta`). Furthermore, the sentence ends abruptly at `We have by` without referencing `\corref{Chernoff:0:1}`. Corrected to $\Delta = t\sqrt{n}$ and supplied `\corref{Chernoff:0:1}:`.
  2. *Theorem 15.7 Proof ([chernoff.tex#L741](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L741)):* `for an arbitrary $t$, to specified shortly`. Missing $t > 0$, which is required for $\exp(tY) \geq \exp(t\Delta) \iff Y \geq \Delta$. Corrected to $t > 0$.
  3. *Theorem 15.23 ([chernoff.tex#L1606](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1606)):* `let $p = \Ex{X}$` where $\overline{X} = (\sum X_i)/n$. Expectation $\Ex{X} = \mu = np$, so $p = \Ex{\overline{X}}$. Corrected to $p = \Ex{\overline{X}}$.
  4. *Theorem 15.23 Proof ([chernoff.tex#L1650](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1650)):* Text states `the denominator is minimized for $t = (q-p)/2$`. The quadratic denominator $(q-t)(p+t)$ is maximized at $1/4$, which minimizes the negative quantity $-1/((q-t)(p+t)) \leq -4$. Clarified to `the denominator $(q-t)(p+t)$ is maximized`.
  5. *Corollary 15.24 ([chernoff.tex#L1692](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1692)):* `let $Y = \sum_{i=1}^n X_i$, and let $\mu = \Ex{X}$`. Corrected to $\mu = \Ex{Y}$.
  6. *Lemma 15.15 Proof ([chernoff.tex#L1259](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1259)):* Text states `we need to prove the claim only for $\delta \in (4,5]$`, but the lemma covers $(0, 6)$ and the boundary evaluated is $\delta = 6$. Corrected to $\delta \in (4, 6]$.
  7. *Lemma 15.26 / Reference in text ([chernoff.tex#L1506](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1506)):* Text cites `$\Ex{s^{X_1}} \leq 1 + (s-1)\Ex{X_i}$` with mixed indices. Corrected to $\Ex{s^{X_i}} \leq 1 + (s-1)\Ex{X_i}$.

---

### [LOW / SYNTAX] Formula and Punctuation Typos
- **Severity / Type:** Syntax & Typographical Errors.
- **Locations & Corrections:**
  - [chernoff.tex#L661](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L661): `f(\delta)=\exp()n \delta^2 / 16)` $\to$ `f(\delta)=\exp(n\delta^2/16)`.
  - [chernoff.tex#L121](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L121): Unclosed parenthesis in Figure 15.2 caption: `(under appropriate rescaling and translation.` $\to$ `(under appropriate rescaling and translation).`
  - [chernoff.tex#L2098](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L2098): Unbalanced parens `\exp(-\Delta^2/2n))` $\to$ `\exp(-\Delta^2/(2n))`.
  - [chernoff.tex#L1148](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1148): Stray comma `$\delta, \in (0,1)$` $\to$ `$\delta \in (0,1)$`.
  - [chernoff.tex#L1210](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1210), [chernoff.tex#L1253](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1253): Trailing commas on displayed equations replaced by periods.
  - [chernoff.tex#L2144](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L2144): `eqnarray`-style double ampersand `&\geq&` in `align*` changed to standard `&\geq`.
  - [chernoff.tex#L2284](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L2284): Incomplete sentence in Exercise 15.27 solution: `Since a geometric variable... one has to read till encountering one.` $\to$ `A geometric variable with probability $p$ can be interpreted as the number of coin flips needed until the first head.`

---

### [PEDAGOGY] Simplification of Lemma 15.26 (`\lemlab{technical}`)
- **Location:** [chernoff.tex#L1841-L1900](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L1841-L1900) vs [chernoff_reviewed.tex#L1873-L1904](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L1873-L1904)
- **Pedagogical Finding:** The current proof of $\Ex{s^X} \leq 1 + (s-1)\Ex{X}$ for $X \in [0, 1]$ and $s \geq 1$ uses a 20-line probability perturbation argument restricted to discrete variables and $\alpha \in (0, 1/2)$.
- **Direct Proof:** For any $x \in [0, 1]$, since $s \geq 1$, the function $x \mapsto s^x$ is convex on $[0, 1]$, and therefore bounded above by its secant line connecting $(0, 1)$ to $(1, s)$:
  $$ s^x \leq (1-x)s^0 + x s^1 = 1 + (s-1)x. $$
  Taking expectations on both sides yields $\Ex{s^X} \leq 1 + (s-1)\Ex{X}$ in a single line, holding unconditionally for all random variables on $[0, 1]$.
- **Action Taken:** Appended an explanatory reviewer remark (`\remX`) after the proof.

---

### [PEDAGOGY / SCHOLARSHIP] Missing Foundational References in Bibliographical Notes
- **Severity / Type:** Missing Scholarly Attribution & Primary Sources.
- **Location:** [chernoff.tex#L2072](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.tex#L2072) vs [chernoff_reviewed.tex#L2104-L2118](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex#L2104-L2118); [chernoff.bib](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.bib)
- **Evidence & Impact:** The chapter derives and extensively uses Chernoff's inequality, Hoeffding's inequality, and the multiplicative Poisson-trial bounds without citing any of the seminal primary literature:
  1. Sergei Bernstein (1924), who originated the MGF bounding technique via $\Prob{X \geq t} \leq \Ex{e^{\lambda X}} e^{-\lambda t}$.
  2. Herman Chernoff (1952), whose paper established the asymptotic relative-entropy bound (with credit to Herman Rubin).
  3. Wassily Hoeffding (1963), who proved both the general bounded-range inequality ($\sum (b_i-a_i)^2$) and the $[0, 1]$ relative-entropy bound.
  4. Dana Angluin & Leslie Valiant (1979), who introduced and popularized the modern multiplicative forms in theoretical computer science.
- **Action Taken:** Added all four foundational BibTeX entries to [chernoff.bib](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff.bib) (`b-mcief-24`, `c-maetbso-52`, `h-pissbrv-63`, `av-fpahm-79`) and added an annotated historical paragraph inside `\newX{...}` in Section 15.8 of [chernoff_reviewed.tex](file:///home/sariel/rand_alg/notes/15_chernoff/chernoff_reviewed.tex).

---

## 2. Summary of Significant Revisions

1. **Summation Upper Bounds:** Normalized all 8 instances of $\sum_{i=1}^b X_i$ to $\sum_{i=1}^n X_i$.
2. **Broken Equation Reference:** Replaced `\Eqref{sol}` with `\Eqref{sum}` in Exercise 15.25 solution.
3. **Lemma 15.18 Proof:** Inverted inequality signs corrected and rigorous exponent comparisons established.
4. **Cheat Sheet Table Annotations:** Added comprehensive commentary on table inconsistencies and missing references.
5. **Hypothesis Domains:** Explicitly added $\delta \in (0, 1)$ to Theorem 15.11, $\eps \in [0, 1]$ to Theorem 15.25, and $\delta \in (0, 1]$ to Exercise 15.27.
6. **Foundational Citations:** Added Bernstein (1924), Chernoff (1952), Hoeffding (1963), and Angluin–Valiant (1979) to bibliography and Section 15.8.
7. **Silent Minor Edits:** Corrected typos ("looses" $\to$ "loses", "phenomena" $\to$ "phenomenon", "in the end of" $\to$ "at the end of", "random variants" $\to$ "random variables"), missing articles ("a fair coin"), and unclosed/unbalanced parentheses.

---

## 3. Verification Results

- **Compiler Engine:** XeLaTeX via `/home/sariel/bin/l --no-env -f -s chernoff_reviewed.tex`
- **Bibliography Management:** BibLaTeX with extracted chapter bibliography `chernoff_reviewed.bib` (symlinked from `chernoff.bib`).
- **Compilation Outcome:**
  ```text
  🛑 Errors: 0, 🚨 Alerts: 1, ❕ Warnings: 0, ☕ Whatevers: 1
  ```
  *(Note: The 1 alert is from pre-existing file `disaster/chernoff.tex` scanned by the driver; `chernoff_reviewed.tex` compiles with 0 errors and 0 warnings).*
- **PDF Generation:** Produced clean 25-page standalone chapter PDF `chernoff_reviewed.pdf`.

---

## 4. Recommended Author Actions

1. **Cheat Sheet Table 1 Layout:** Decide whether to split Table 1 into two separate subheadings (one for $\{-1, +1\}$ and one for symmetric $\{0, 1\}$ variables), or replace row 3 with $\Prob{|Y| \geq \Delta} \leq 2\exp(-\Delta^2/(2n))$ from Corollary 15.6.
2. **Exercise 15.26 (H):** Remove the unused quantifier `for any integer $t > 0$` from the problem statement of part (H).
3. **Lemma 15.26 Proof:** Consider replacing the discrete shifting proof with the one-line convexity/secant argument.
