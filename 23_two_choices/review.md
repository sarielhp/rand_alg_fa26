# Manuscript Review Report: Chapter 23 (The Power of Two Choices)

## 1. Findings

### [Finding 1] Off-by-One Group Offset in Always-Go-Left Rule
- **Severity & Type:** Confirmed Mathematical Bug / Range Defect
- **Location:** Original: [two_choices.tex:L611-L613](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L611-L613) | Reviewed: [two_choices_reviewed.tex:L651-L655](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L651-L655)
- **Evidence & Impact:** When defining the always-go-left rule in Section~23.2.3, the probed locations were specified as $Y_j = X_j + j(n/d)$ for $j = 1, \dots, d$, where $X_j \in \IRX{n/d}$. For $j = d$, this yields $Y_d = X_d + d(n/d) = X_d + n > n$, indexing strictly outside the range of the $n$ bins. Furthermore, for $j = 1$, $Y_1 = X_1 + n/d$ skips the first group of bins $\{1, \dots, n/d\}$ entirely.
- **Action:** Corrected the group offset from $j(n/d)$ to $(j-1)(n/d)$, so that $Y_j = X_j + (j-1)(n/d)$ for $j = 1, \dots, d$, properly selecting one bin from each of the $d$ contiguous blocks. Tracked with `\chgY` and annotated with `\remX`.

---

### [Finding 2] Inverted Negative Exponent in Denominator of Multi-Row Tail Bounds
- **Severity & Type:** Confirmed Mathematical Error / Notation Defect
- **Location:** Original: [two_choices.tex:L284-L286](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L284-L286), [two_choices.tex:L647](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L647) | Reviewed: [two_choices_reviewed.tex:L303-L308](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L303-L308), [two_choices_reviewed.tex:L690-L693](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L690-L693)
- **Evidence & Impact:** In Lemma~23.1.7(C), the bound on unplaced balls was written as $\Ex{Y(d, n, cn \log d)} = n/e^{-d/2}$, and the proof sketch of Theorem~23.2.8 repeated that "at most $dn/e^{-d/2}$ balls have height strictly larger than 2." Having a negative exponent in the denominator inverts the expression to $n e^{+d/2}$, which grows exponentially with $d$ instead of decaying exponentially. In the proof of Lemma~23.1.7(C) (line 335), the derivation correctly obtained $n/e^{d-D} \leq n/e^{d/2} = n e^{-d/2}$.
- **Action:** Replaced the erroneous expression and equality with $\Ex{Y(d, n, cn \log d)} \leq n/e^{d/2}$ in Lemma~23.1.7(C), and corrected $dn/e^{-d/2}$ to $dn/e^{d/2}$ in the proof sketch of Theorem~23.2.8 using `\chgY` and explanatory `\remX` annotations.

---

### [Finding 3] Invalid Chained Inequality in Lemma 23.1.1(A) Proof
- **Severity & Type:** Confirmed Mathematical Derivation Error
- **Location:** Original: [two_choices.tex:L110-L117](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L110-L117) | Reviewed: [two_choices_reviewed.tex:L115-L126](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L115-L126)
- **Evidence & Impact:** The chain of inequalities at the end of the proof of Lemma~23.1.1(A) ended with:
  \[
    \dots \geq (m-\alpha)(1-\alpha) = \alpha n - \alpha^2 n - \alpha + \alpha^2 \geq \frac{m-\alpha}{e}.
  \]
  However, $(m-\alpha)(1-\alpha) \geq \frac{m-\alpha}{e}$ is mathematically false for all $\alpha \in (1 - 1/e, 1]$. In particular, at $\alpha = 1$, $(m-\alpha)(1-\alpha) = 0$, while $\frac{m-\alpha}{e} = \frac{n-1}{e} > 0$, asserting $0 \geq \frac{n-1}{e}$. The bound $\frac{m-\alpha}{e}$ is an immediate consequence of the earlier term $(m-\alpha)\exp(-\alpha) \geq (m-\alpha)\exp(-1) = \frac{m-\alpha}{e}$ (since $\alpha \leq 1$), not of $(m-\alpha)(1-\alpha)$. Furthermore, the lemma statement claims the lower bound $\alpha n - \alpha^2 n - 1$.
- **Action:** Terminated the displayed derivation at $\geq \alpha n - \alpha^2 n - 1$ (which holds since $-\alpha + \alpha^2 \geq -1$ for $\alpha \in [0, 1]$), directly establishing the bound stated in Lemma~23.1.1(A). Annotated with an explanatory `\remX`.

---

### [Finding 4] Inverted Inequality and Recurrence Index Mismatch in Observation 23.1.4
- **Severity & Type:** Confirmed Mathematical / Logical Bug
- **Location:** Original: [two_choices.tex:L194-L208](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L194-L208) | Reviewed: [two_choices_reviewed.tex:L207-L229](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L207-L229)
- **Evidence & Impact:**
  1. The observation set $\alpha_2 = c$ and $\alpha_{i+1} = \alpha_i^2$, claiming $\alpha_{i+1} = c^{2^{i-2}}$. By induction, $\alpha_i = c^{2^{i-2}}$, so the $(i+1)$-th term is $\alpha_{i+1} = c^{2^{i-1}}$. The text misaligned the index by one.
  2. The displayed equation concluded that $\Delta = 3 + \lg \lg n - \lg \lg \frac{1}{1-1/e} \leq 3 + \lg \lg n$. However, for $c = 1 - 1/e \approx 0.6321$, $1/c \approx 1.582$ and $\lg(1/c) \approx 0.662 < 1$. Because $\lg(1/c) < 1$, its logarithm is negative: $\lg \lg(1/c) \approx -0.596 < 0$. Therefore, $- \lg \lg(1/c) \approx +0.596 > 0$, which strictly reverses the inequality to $\Delta > 3 + \lg \lg n$. (Note that if the fraction of balls rejected after the first round, $c = 1/e$, had been used instead of $1 - 1/e$, then $1/c = e$ and $\lg e \approx 1.443 > 1$, making $-\lg \lg e < 0$, which would validate $\leq 3 + \lg \lg n$.)
- **Action:** Corrected $\alpha_{i+1} = c^{2^{i-2}}$ to $\alpha_i = c^{2^{i-2}}$ using `\chgY`, removed the inverted $\leq 3 + \lg \lg n$ inequality from the display, and added an explanatory `\remX`.

---

### [Finding 5] Conflation of Sequential Load Levels with Independent Multi-Row Rounds in Lemma 23.2.4(C)
- **Severity & Type:** Proof Gap / Flawed Tail Argument
- **Location:** Original: [two_choices.tex:L422-L424](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L422-L424), [two_choices.tex:L535-L538](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L535-L538) | Reviewed: [two_choices_reviewed.tex:L446-L448](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L446-L448), [two_choices_reviewed.tex:L565-L573](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L565-L573)
- **Evidence & Impact:** The proof of Lemma~23.2.4(C) states: *"The probability that the first $j$ such rounds fail (i.e., that $\ballsY{I+1+j}{n} > 0$) is at most $q^j$, as claimed."* This argument confuses the multi-row model of Section~23.1 (which proceeds in separate rounds) with the sequential allocation of Section~23.2. In the two-choices model, balls are allocated into a single array of $n$ bins; the events $\ballsY{I+1+j}{n} > 0$ for increasing $j$ are nested ($\ballsY{I+1+j}{n} > 0 \implies \ballsY{I+j}{n} > 0$), so multiplying failure probabilities as $q^j$ is invalid.
- **Action:** Added a detailed `\remX` explaining the distinction between the models and noting that once $\Ex{\ballsY{I+2}{n}} \leq O(1/n^{d-1-\eps}) \ll 1$, Markov's inequality already ensures that with probability $1 - O(1/n^{d-1-\eps})$, no ball reaches height $I+2$ at all.

---

### [Finding 6] Conditioning and Indexing Defects in Lemma 23.2.4 Proof
- **Severity & Type:** Confirmed Technical / Notation Errors
- **Location:** Original: [two_choices.tex:L438-L440](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L438-L440), [two_choices.tex:L452-L453](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L452-L453), [two_choices.tex:L480](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L480), [two_choices.tex:L508](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L508) | Reviewed: [two_choices_reviewed.tex:L462-L466](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L462-L466), [two_choices_reviewed.tex:L479-L482](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L479-L482), [two_choices_reviewed.tex:L508-L512](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L508-L512), [two_choices_reviewed.tex:L539-L542](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L539-L542)
- **Evidence & Impact:**
  1. Line 439 conditioned on $\GoodEvent_{i-1}$ instead of $\GoodEvent_i = \cap_{k=1}^i \overline{\BadEvent_k}$; bounding the probes hitting bins of load $\geq i$ by $p_i = (\beta_i / n)^d$ requires $\BLX{i} \leq \beta_i$, which is guaranteed by $\GoodEvent_i$.
  2. Line 453 wrote $\sum_i Y_j' \geq \sum_i Y_i$, overloading the index $i$ and summing over an undefined variable. The sum is over the $n$ balls ($j \in \{1, \dots, n\}$).
  3. Line 480 conditioned on $\GoodEvent_1$, which only ensures $\BLX{1} \leq \beta_1 = n$ (vacuous). Conditioning must be on $\GoodEvent_I$ to ensure $\BLX{I} \leq \beta_I$.
  4. Line 508 wrote $\cap_{k=1}^\ell \overline{\BadEvent_1}$ with constant index $1$ instead of $\cap_{k=1}^\ell \overline{\BadEvent_k}$.
- **Action:** Fixed the conditioning events and summation indices using `\chgY` and added clarifying `\remX` annotations.

---

### [Finding 7] Nonsensical Terminology in Two-Choices Tie-Breaking
- **Severity & Type:** Exposition / Terminology Bug
- **Location:** Original: [two_choices.tex:L350](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L350) | Reviewed: [two_choices_reviewed.tex:L373-L375](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L373-L375)
- **Evidence & Impact:** Section~23.2 stated: *"If there are several bins with the same minimum number of bins, we resolve it arbitrarily."* Bins do not contain bins; they contain balls.
- **Action:** Changed to *"same minimum load"* (or minimum number of balls) using `\chgY` and annotated with `\remX`.

---

### [Finding 8] Missing Attribution and Citation for Shared-Choice / Memory Variant (Section 23.3)
- **Severity & Type:** Missing Citation & Historical Attribution
- **Location:** Original: [two_choices.tex:L745-L758](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.tex#L745-L758) | Reviewed: [two_choices_reviewed.tex:L791-L806](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L791-L806)
- **Evidence & Impact:** Section~23.3 ("Avoiding terrible choices") describes the elegant variant where each ball chooses between a fresh random bin $r_i$ and the previous ball's bin $r_{i-1}$, achieving $O(\log \log n)$ maximum load with only $n$ total choices. The Bibliographical Notes (Section~23.5) omitted any citation or credit for this paradigm.
- **Action:** Added attribution to Mitzenmacher, Prabhakar, and Shah \cite{mps-bbm-02} (FOCS 2002, "Balls and Bins with Memory") using `\newX`, added the canonical entry to [two_choices.bib](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.bib) and [two_choices_reviewed.bib](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.bib), and annotated with `\remX`.

---

### [Finding 9] Missing Local Standalone Bibliography File (`two_choices.bib`)
- **Severity & Type:** Build Portability & Toolchain Defect
- **Location:** Directory [23_two_choices](file:///home/sariel/rand_alg/notes/23_two_choices)
- **Evidence & Impact:** Under strict environment variable sanitization (`l --no-env -s`), `BIBINPUTS` is empty. Because `two_choices.bib` was absent, `prefix_latex.tex` attempted to load external `shortcuts.bib` and `geometry.bib`, causing standalone compilation to fail with `ERROR - Cannot find 'shortcuts.bib'!`.
- **Action:** Created [two_choices.bib](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.bib) containing all cited entries (`bk-mah-90`, `abku-ba-90`, `v-hshlb-03`, `mps-bbm-02`), and symlinked [two_choices_reviewed.bib](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.bib) to ensure standalone compilation passes cleanly with zero errors.

---

## 2. Significant Revisions

### Tracked Technical Changes
- **Group offset correction:** Changed $Y_j = X_j + j(n/d)$ to $Y_j = X_j + (j-1)(n/d)$ ([two_choices_reviewed.tex:L652](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L652)).
- **Negative exponent removal:** Replaced $= n/e^{-d/2}$ with $\leq n/e^{d/2}$ in Lemma~23.1.7(C) ([two_choices_reviewed.tex:L305](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L305)) and $dn/e^{-d/2}$ with $dn/e^{d/2}$ in Theorem~23.2.8 proof sketch ([two_choices_reviewed.tex:L691](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L691)).
- **Tie-breaking terminology:** Replaced "minimum number of bins" with "minimum load" ([two_choices_reviewed.tex:L373](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L373)).
- **Conditioning & indexing fixes:** Corrected conditioning events $\GoodEvent_{i-1} \to \GoodEvent_i$ ([two_choices_reviewed.tex:L463](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L463)) and $\GoodEvent_1 \to \GoodEvent_I$ ([two_choices_reviewed.tex:L510](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L510)), fixed sum index $\sum_i Y_j' \to \sum_{j=1}^n Y_j'$ ([two_choices_reviewed.tex:L480](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L480)), and corrected product intersection index $\overline{\BadEvent_1} \to \overline{\BadEvent_k}$ ([two_choices_reviewed.tex:L540](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L540)).
- **Stopping iteration bound:** Clarified $\beta_I \leq o(\log n) \to \beta_{I+1} \leq 16 c \ln n$ ([two_choices_reviewed.tex:L617](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L617)).
- **Bibliographical expansion:** Added attribution for V{\"o}cking and new citation for Mitzenmacher, Prabhakar, and Shah ([two_choices_reviewed.tex:L798-L803](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L798-L803)).

### Silent Minor Corrections
- Corrected "How sweat" $\to$ "How sweet" ([two_choices_reviewed.tex:L15](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L15)).
- Corrected "Gunter Grass" $\to$ "G{\"u}nter Grass" ([two_choices_reviewed.tex:L20](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L20)).
- Corrected "contains less balls" $\to$ "contains fewer balls" ([two_choices_reviewed.tex:L27](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L27)).
- Corrected "with only two-choices -- see" $\to$ "with only two choices---see" ([two_choices_reviewed.tex:L33-L34](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L33-L34)).
- Corrected "till all the balls had found" $\to$ "until all the balls have found" ([two_choices_reviewed.tex:L51](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L51)).
- Corrected "How many rows one needs" $\to$ "How many rows does one need" ([two_choices_reviewed.tex:L52](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L52)).
- Corrected "Let $\Yend$ the number" $\to$ "Let $\Yend$ be the number" ([two_choices_reviewed.tex:L61](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L61)).
- Standardized "in the end of the process" $\to$ "at the end of the process" ([two_choices_reviewed.tex:L62](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L62), [L378](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L378), [L402](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L402)).
- Corrected "significantly large than the second therm" $\to$ "significantly larger than the second term" ([two_choices_reviewed.tex:L181-L182](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L181-L182)).
- Corrected "calculations ... breaks down" $\to$ "break down" ([two_choices_reviewed.tex:L233](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L233)).
- Corrected "a ball ... are promoted" $\to$ "any ball ... is promoted" ([two_choices_reviewed.tex:L247-L249](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L247-L249)).
- Corrected "Using Chenroff inequality" $\to$ "Using Chernoff's inequality" ([two_choices_reviewed.tex:L318](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L318)).
- Corrected "rows in expectation contains" $\to$ "contain" ([two_choices_reviewed.tex:L328](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L328)).
- Corrected "arriving to a row" $\to$ "arriving at a row" ([two_choices_reviewed.tex:L338](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L338), [L341](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L341), [L353](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L353)).
- Corrected "we already seen" $\to$ "we have already seen" ([two_choices_reviewed.tex:L380](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L380)).
- Corrected "for $n$ sufficient large" $\to$ "for $n$ sufficiently large" ([two_choices_reviewed.tex:L560](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L560)).
- Added missing terminal period to Theorem~23.2.6 statement ([two_choices_reviewed.tex:L610](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L610)).
- Corrected missing closing parenthesis and grammar in Figure~23.1 caption: "(i.e., $\approx 3$ in this case, there does not seem to be any reasonable cases where the is a significant differences" $\to$ "(i.e., $\approx 3$ in this case), there do not seem to be any reasonable cases where there is a significant difference" ([two_choices_reviewed.tex:L724-L726](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L724-L726)).
- Corrected "Experiments shows" $\to$ "Experiments show" ([two_choices_reviewed.tex:L767](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L767)).
- Corrected "making less probes" $\to$ "making fewer probes" ([two_choices_reviewed.tex:L768](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L768)).
- Corrected "if one use" $\to$ "if one uses" ([two_choices_reviewed.tex:L770](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L770)).
- Corrected "a sequence of really bad choices are rare" $\to$ "is rare" ([two_choices_reviewed.tex:L772](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex#L772)).

---

## 3. Verification

- **Compiler Engine:** XeLaTeX via project driver `/home/sariel/bin/l --no-env -s`.
- **Environment Sanitization:** 35 TeX/LaTeX environment variables neutralized (`TEXINPUTS`, `BIBINPUTS`, `BSTINPUTS`, `TEXMFHOME`, etc.).
- **Bibliography Processing:** Biber 2.22 resolving against [two_choices.bib](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.bib) and [two_choices_reviewed.bib](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.bib).
- **Standalone Verification:**
  - `two_choices_reviewed.tex`: **0 Errors**, 3 Alerts, 4 Warnings (14 pages compiled). All 4 citations (`abku-ba-90`, `bk-mah-90`, `mps-bbm-02`, `v-hshlb-03`) resolved cleanly.
  - `two_choices.tex`: Tested via `tools/test_chapters_standalone 23` $\to$ **PASS (clean)** (12 pages compiled).
- **Repository Health:** Clean git status preserved; temporary build outputs confined to `junk/`.

---

## 4. Deliverables

- Reviewed Manuscript: [two_choices_reviewed.tex](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.tex)
- Standalone Bibliography: [two_choices.bib](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices.bib) and [two_choices_reviewed.bib](file:///home/sariel/rand_alg/notes/23_two_choices/two_choices_reviewed.bib)
- Review Report: [review.md](file:///home/sariel/rand_alg/notes/23_two_choices/review.md)
