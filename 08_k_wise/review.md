# Manuscript Review Report: Chapter 08 (On $k$-wise Independence)

## 1. Findings

### [Finding 1] Vandermonde Determinant Leibniz Formula & Monomial Degree Flaw
- **Severity & Type:** Confirmed Mathematical Bug (Major)
- **Location:** Original: [k_wise.tex:L390-L398](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise.tex#L390-L398) | Reviewed: [k_wise_reviewed.tex:L395-L404](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L395-L404)
- **Evidence & Impact:**
  1. The Leibniz determinant expansion for $V$ was written as $\sum_{\pi \in \Pi} \mathrm{sign}(\pi) x_i^{\pi(i)}$. This omitted the row product $\prod_{i=1}^n$, left the variable index $i$ unbound, and used 1-based powers $\pi(i)$ rather than the 0-based exponents $\pi(i)-1$ matching the matrix definition ($V_{i,j} = x_i^{j-1}$).
  2. The total degree of each monomial was stated as $\sum_{i=1}^n \pi(i) = 1 + 2 + \cdots + n = n(n-1)/2$. But $1 + \cdots + n = n(n+1)/2$, not $n(n-1)/2$. The correct exponent sum over column powers is $\sum_{i=1}^n (\pi(i)-1) = 0 + 1 + \cdots + (n-1) = n(n-1)/2$.
- **Action:** Corrected the formula to $\sum_{\pi \in \Pi} \mathrm{sign}(\pi) \prod_{i=1}^n x_i^{\pi(i)-1}$ and updated the degree derivation to $\sum_{i=1}^n (\pi(i)-1) = 0 + 1 + \cdots + (n-1) = n(n-1)/2$. Added an explanatory `\remX`.

---

### [Finding 2] Matrix Dimension Mismatch in Lemma 2.7 (Vandermonde Interpolation)
- **Severity & Type:** Confirmed Mathematical Bug (Major)
- **Location:** Original: [k_wise.tex:L476-L483](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise.tex#L476-L483) | Reviewed: [k_wise_reviewed.tex:L482-L490](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L482-L490)
- **Evidence & Impact:** Lemma 2.7 considers a polynomial with $k$ coefficients $\mathsf{b} \in \ZZ_p^k$ evaluated at $k$ distinct points $\alpha_1, \ldots, \alpha_k \in \ZZ_p$. The linear system was written with matrix $\mathsf{M}$ having rows $\alpha_1, \ldots, \alpha_n$ and column powers up to $n-1$. The symbol $n$ is undefined in this lemma and misrepresents the system as $n \times n$ rather than $k \times k$.
- **Action:** Resized and relabeled matrix $\mathsf{M}$ to $k \times k$ with rows $\alpha_1, \ldots, \alpha_k$ and powers $0, \ldots, k-1$. Clarified that invertibility holds over the finite field $\ZZ_p$ because $\det(\mathsf{M}) = \prod_{1 \leq i < j \leq k} (\alpha_j - \alpha_i) \not\equiv 0 \pmod p$. Added an explanatory `\remX`.

---

### [Finding 3] Self-Canceling XOR in Pairwise Independent Bits Proof
- **Severity & Type:** Confirmed Mathematical Bug (Major)
- **Location:** Original: [k_wise.tex:L104-L115](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise.tex#L104-L115) | Reviewed: [k_wise_reviewed.tex:L105-L120](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L105-L120)
- **Evidence & Impact:** In the proof that $Y_i$ and $Y_{i'}$ are pairwise independent, index $\beta \in B \setminus B'$ was singled out. The text wrote $X_\beta \otimes \bigotimes_{j: \mathrm{bit}(i,j)=1} X_j = v$. Because the second term already contains $X_\beta$, this is equivalent to $X_\beta \otimes X_\beta \otimes (\dots) = 0 \otimes (\dots)$, canceling out the isolated variable $X_\beta$ entirely.
- **Action:** Removed $\beta$ from the index set of the remaining XOR product, writing $X_\beta \otimes (\bigotimes_{j \in B \setminus \{\beta\}} X_j) = v$. Since $\beta \notin B'$, the bit $X_\beta$ does not appear in $Y_{i'}$ or the remaining terms; by independence of the source bits, conditioning on $Y_{i'} = v'$ leaves $X_\beta$ uniformly distributed with probability $1/2$. Added an explanatory `\remX`.

---

### [Finding 4] Variable Collision in Definitions 1.1 and 1.2
- **Severity & Type:** Confirmed Typographical / Definition Defect
- **Location:** Original: [k_wise.tex:L28-L33, L44-L46](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise.tex#L28-L33) | Reviewed: [k_wise_reviewed.tex:L31-L36, L47-L52](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L31-L36)
- **Evidence & Impact:**
  1. In Definition 1.1 of pairwise independence for variables $X_1, \ldots, X_n$, the joint probability was written as $\Prob{X_i = \alpha \text{ and } Y_j = \beta} = \Prob{X_i = \alpha}\Prob{Y_j = \beta}$, referencing a nonexistent family $Y$. Furthermore, it omitted the requirement that $i \neq j$ be distinct.
  2. In Definition 1.2 of mutual independence, the final factor was written as $Y_{i_t} = \alpha_{i_t}$.
- **Action:** Replaced $Y_j$ and $Y_{i_t}$ with $X_j$ and $X_{i_t}$, added the explicit condition $i \neq j$ (and distinct $i_1, \ldots, i_t$ with $2 \leq t \leq n$), and added explanatory remarks.

---

### [Finding 5] Inverted Divisibility Statement in Lemma 2.3
- **Severity & Type:** Confirmed Mathematical Bug / Logic Reversal
- **Location:** Original: [k_wise.tex:L326-L327](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise.tex#L326-L327) | Reviewed: [k_wise_reviewed.tex:L330-L334](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L330-L334)
- **Evidence & Impact:** The proof argued: "However, $a$ and $x-y$ cannot divide $p$ since $p$ is prime and $a < p$ and $0 < x-y < p$." If $a(x-y) \equiv 0 \pmod p$, then $p$ divides $a(x-y)$. Since $p$ is prime, Euclid's lemma requires $p \divides a$ or $p \divides (x-y)$. Stating that "$a$ and $x-y$ cannot divide $p$" reverses divisor and multiple.
- **Action:** Track-corrected using `\chgY` to "However, $p$ cannot divide $a$ or $x-y$".

---

### [Finding 6] Inappropriate "Max-Cut" Claims for 1/2-Approximation
- **Severity & Type:** Terminology / Algorithmic Precision
- **Location:** Original: [k_wise.tex:L184](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise.tex#L184) | Reviewed: [k_wise_reviewed.tex:L189-L194](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L189-L194)
- **Evidence & Impact:** Lemma 1.4 stated: "one can compute a max-cut of $\Graph$ ... using $O(\log n)$ random bits ... expected size of the cut is $\geq m/2$." Computing an exact max-cut is NP-hard. The randomized algorithm computes a cut whose expected size is at least $m/2$, which is an expected $1/2$-approximation, not a max-cut.
- **Action:** Corrected "a max-cut" to "a cut" using `\chgY` and added an explanatory `\remX`.

---

### [Finding 7] Variable Mismatch and Redundancy in Definition 3.4 & Contradiction in Lemma 3.5
- **Severity & Type:** Confirmed Mathematical Bug / Exposition
- **Location:** Original: [k_wise.tex:L768-L771, L781](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise.tex#L768-L771) | Reviewed: [k_wise_reviewed.tex:L783-L792, L800-L808](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L783-L792)
- **Evidence & Impact:**
  1. Definition 3.4 stated "any $k$ values $x_1, \ldots, x_k$", but wrote $\Prob{\bigcap_{\ell=1}^k (X_{i_\ell} = v_\ell)}$ in the displayed formula.
  2. Lemma 3.5 stated: "let $X_1, \ldots, X_n$ be $n$ random independent variables, that are $k$-wise independent". Stating they are independent and limited-independent is contradictory.
- **Action:** Corrected $x_1, \ldots, x_k$ to $v_1, \ldots, v_k$, changed the lemma hypothesis to "$k$-wise independent random variables", and added explanatory remarks.

---

### [Finding 8] Missing Bibliographical Notes and Foundational References
- **Severity & Type:** Missing Required Content (Addressed per Prompt)
- **Location:** Original: [k_wise.tex:L795](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise.tex#L795) | Reviewed: [k_wise_reviewed.tex:L817-L840](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L817-L840)
- **Evidence & Impact:** The original file concluded with only `\nocite{mr-ra-95}` and lacked a bibliographical notes section. Foundational developments presented in the chapter lacked citations (Carter & Wegman 1979 for universal hashing and pairwise independence; Luby 1986 and Alon, Babai & Itai 1986 for derandomization, subset XOR bits, and Max-Cut; Joffe 1971 for polynomial $k$-wise independence; Chor & Goldreich 1989 for RP amplification; Schmidt, Siegel & Srinivasan 1995 for limited-independence tail bounds).
- **Action:** Authored a concise, self-contained `\section{Bibliographical notes}` citing Carter--Wegman \cite{cw-uchf-79}, Luby \cite{l-spar-86}, Alon--Babai--Itai \cite{abi-fsrpa-86}, Joffe \cite{j-sadki-71}, Chor--Goldreich \cite{cg-ubwsr-89}, Schmidt--Siegel--Srinivasan \cite{sss-chbal-95}, and Motwani--Raghavan \cite{mr-ra-95}. Added canonical BibTeX entries to both `/home/sariel/papers/bib/geometry.bib` and `k_wise_reviewed.bib`.

---

### [Finding 9] Unnecessary Constraint in Lemma 2.4 (Unique Inverse / Pairwise Hashing)
- **Severity & Type:** Mathematical Precision / Remark
- **Location:** Original: [k_wise.tex:L337](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise.tex#L337) | Reviewed: [k_wise_reviewed.tex:L345-L349](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L345-L349)
- **Evidence & Impact:** Lemma 2.4 required $r, s \in \ZZ_p$ to satisfy $r \neq s$ for the existence of unique $a, b \in \ZZ_p$ such that $ax + b \equiv r \pmod p$ and $ay + b \equiv s \pmod p$. If $r = s$, the system is solved uniquely by $a = 0$ and $b = r$. For pairwise independence, $Y_x = r$ and $Y_y = r$ is a valid event that occurs with probability $1/p^2$.
- **Action:** Removed the unnecessary restriction $r \neq s$ and added an explanatory `\remX`.

---

### [Finding 10] Finite Field vs Prime Randomness for RP Amplification
- **Severity & Type:** Pedagogical Clarification
- **Location:** Original: [k_wise.tex:L588-L590](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise.tex#L588-L590) | Reviewed: [k_wise_reviewed.tex:L605-L612](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L605-L612)
- **Evidence & Impact:** The amplification argument assumed $n$ is prime to define $r_i = ai + b \bmod n$. If an algorithm takes $m = \lg n$ random bits, its sample space is $\{0,1\}^m$ and $n = 2^m$ is not prime.
- **Action:** Added an explanatory `\remX` noting that one can instead perform linear operations over the Galois field $\mathbb{F}_{2^m}$ to obtain pairwise independent binary strings in $\{0,1\}^m$ using $2m$ random bits without assuming $n$ is prime.

---

## 2. Significant Revisions

- **Tracked Technical Changes:**
  - Section 1.1: `\chgY{Pairwise independence}{Basic definitions}` to eliminate redundant subsection title.
  - Definition 1.1 & 1.2: Added `\newX{distinct}` indices and `\newX{$2 \leq t \leq n$}` ([k_wise_reviewed.tex:L31-L50](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L31-L50)).
  - Lemma 1.3 proof: `\chgY{if pick all the true random variables $X_0, \ldots, X_{t-1}$ in such an order such that}{if we pick all the independent random variables $X_0, \ldots, X_{t-1}$ in an order such that}` ([k_wise_reviewed.tex:L84-L87](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L84-L87)).
  - Lemma 1.4: `\chgY{a max-cut}{a cut}` ([k_wise_reviewed.tex:L189](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L189)).
  - Definition 2.2: `\chgY{a number $p$}{an integer $n \geq 1$}` and `\chgY{the $x \bmod y = 0$, than}{$x \bmod y = 0$, then}` ([k_wise_reviewed.tex:L256-L260](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L256-L260)).
  - Lemma 2.3: `\chgY{However, $a$ and $x-y$ cannot divide $p$}{However, $p$ cannot divide $a$ or $x-y$}` ([k_wise_reviewed.tex:L330-L332](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L330-L332)).
  - Section 2.5: `\chgY{$k$-wide}{$k$-wise}` ([k_wise_reviewed.tex:L545](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L545)).
  - Lemma 3.2 & Corollary 3.3: `\chgY{Consider $k$ be an even integer and let $X_1, \ldots, X_n$ be $n$ random independent variables}{Let $k$ be an even integer, and let $X_1, \ldots, X_n$ be $n$ independent random variables}` ([k_wise_reviewed.tex:L667-L670, L758-L761](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L667-L670)).
  - Definition 3.4: `\chgY{$x_1, \ldots, x_k$}{$v_1, \ldots, v_k$}` ([k_wise_reviewed.tex:L783](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L783)).
  - Lemma 3.5: `\chgY{random independent variables, that are $k$-wise independent}{$k$-wise independent random variables}` ([k_wise_reviewed.tex:L801-L802](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L801-L802)).
  - Section 4: Added concise, comprehensive bibliographical notes ([k_wise_reviewed.tex:L817-L840](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex#L817-L840)).

- **Silent Minor Corrections:**
  - "non-negative integer number" $\to$ "non-negative integer".
  - "each one of them is 1 with probability 1/2" $\to$ "each equal to $1$ with probability $1/2$".
  - Comma in spacing `\\[0,2cm]` $\to$ `\\[0.2cm]`.
  - Equation punctuation: removed dangling punctuation in $(S, \overline{S})$ definition.
  - "which needs to be stored" $\to$ "which need to be stored".
  - "probability half" $\to$ "probability $1/2$".
  - "huge save" $\to$ "huge saving".
  - "Let assume" $\to$ "Let us assume".
  - "such that the runs results in" $\to$ "such that the runs result in".
  - "zero determinate" $\to$ "zero determinant".
  - "it generated in $g$" $\to$ "it is generated in $g$".
  - "It is to verify" $\to$ "It is easy to verify".
  - "These terms corresponds to" $\to$ "These terms correspond to".
  - Typos in polynomial coefficients `$b_0. b_1$` $\to$ `$b_0, b_1$`.
  - Removed trailing backslash before display in Definition 3.4.

---

## 3. Verification

- **Build Engine & Command:** `/home/sariel/bin/l --no-env -s k_wise_reviewed.tex`
- **XeLaTeX & Biber Status:** **PASS** (0 Errors, 0 Alerts, 0 Warnings).
- **Bibliography Verification:** All 7 cited keys (`abi-fsrpa-86`, `cg-ubwsr-89`, `cw-uchf-79`, `j-sadki-71`, `l-spar-86`, `mr-ra-95`, `sss-chbal-95`) resolved cleanly with complete metadata, full author names, journals, volume/issue numbers, and DOIs.
- **Output Artifacts:** `junk/k_wise_reviewed.pdf` (clean build, dual-mode pagination starting at page 62).
- **Repository Hygiene:** Working tree clean; source `k_wise.tex` preserved untouched.

---

## 4. Author Actions

1. **Lemma 2.4 Condition ($r \neq s$):** As noted in Finding 9, removing $r \neq s$ is mathematically sound and allows pairwise collision events $Y_x = r, Y_y = r$ (which occur with probability $1/p^2$ when $a=0, b=r$). If the author intended specifically $a \neq 0$ (2-universal hashing family without constant functions), that can be explicitly specified.
2. **Review Macros:** Once the author reviews the tracked modifications in [k_wise_reviewed.tex](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise_reviewed.tex), the changes can be accepted into [k_wise.tex](file:///home/sariel/rand_alg/notes/08_k_wise/k_wise.tex).
