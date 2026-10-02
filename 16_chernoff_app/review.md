# Review Report: Chapter 16 — Applications of Chernoff's Inequality

**Source Manuscript:** [chernoff_app.tex](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex)  
**Reviewed Version:** [chernoff_app_reviewed.tex](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex)  
**Verification:** XeLaTeX (via `/home/sariel/bin/l --no-env`), BibLaTeX (`chernoff_app_reviewed.bbl`) — **0 Errors, 0 Alerts, 6 Warnings, 0 Whatevers**

---

## 1. Actionable Findings (Ordered by Severity)

### [CRITICAL] Inequality Reversal and Conflation of Bounds in Routing Delay Chernoff Step
- **Severity & Type:** Confirmed Technical Error (Mathematical Invalidity).
- **Location (Original):** [chernoff_app.tex#L420-L426](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L420-L426)
- **Location (Reviewed):** [chernoff_app_reviewed.tex#L428-L434](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L428-L434)
- **Evidence & Impact:**
  The derivation establishes an upper bound $\mu \leq n/2$, and then bounds the tail probability as:
  $$\Prob{\sum_j H_{ij} > 7n} \leq \Prob{\sum_j H_{ij} > (1+13)\mu} < 2^{-13\mu} \leq 2^{-6n}.$$
  This contains a critical mathematical flaw:
  1. *Inequality Reversal:* Because $\mu \leq n/2$, multiplying by $-13$ gives $-13\mu \geq -13(n/2) = -6.5n$. Since the exponential base-2 function is strictly decreasing in the negative exponent, $\mu \leq n/2 \implies 2^{-13\mu} \geq 2^{-6.5n}$, **not** $\leq 2^{-6n}$. Bounding $\mu$ from above and substituting it into a decreasing function reverses the inequality direction.
  2. *Conditional vs. Unconditional Distribution:* The indicator variables $H_{ij}$ are mutually independent only *conditionally* given the path $\rho_i$. Given $\rho_i$, the conditional expectation is bounded by $\cardin{\rho_i}$, which can be as large as $n$.
  3. *Rigorous Fix:* To obtain the bound $2^{-6n}$ correctly, one must condition on $\rho_i$ and apply Chernoff with an upper-bounding parameter $\mu_0 = n$:
     $$\ProbCond{\sum_{j \neq i} H_{ij} > 7n}{\rho_i} = \ProbCond{\sum_{j \neq i} H_{ij} > (1+6)\mu_0}{\rho_i} < 2^{-6\mu_0} = 2^{-6n}.$$
     This bound holds uniformly for *every* choice of $\rho_i$, hence taking expectation over $\rho_i$ yields $\Prob{\sum_{j \neq i} H_{ij} > 7n} < 2^{-6n}$ unconditionally.
- **Action Taken:** Added a comprehensive reviewer remark (`\remX`) at lines 433--434 explaining both the invalid inequality reversal and the proper conditional Chernoff argument with $\mu_0 = n$.

---

### [CRITICAL] Directional Inversion in Theorem 16.3 Proof (Bounding Sub-Expectation Events)
- **Severity & Type:** Confirmed Mathematical Rigor Error.
- **Location (Original):** [chernoff_app.tex#L170-L190](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L170-L190)
- **Location (Reviewed):** [chernoff_app_reviewed.tex#L174-L195](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L174-L195)
- **Evidence & Impact:**
  The theorem claims upper bounds on $\Prob{Z > t\ln n}$. The proof computes:
  $$\mu = \Ex{Z} = \sum_{i=1}^n \frac{1}{i} = H_n \geq \int_1^{n+1} \frac{1}{x}\,\mathrm{d}x = \ln(n+1) \geq \ln n.$$
  The proof then sets $\delta = t-1$ and invokes Chernoff's inequality.
  However, setting $\delta = t-1$ yields $(1+\delta)\mu = t\mu = t H_n$.
  Chernoff's upper tail bound applies to $\Prob{Z > (1+\delta)\mu} = \Prob{Z > t H_n}$.
  Because $H_n > \ln n$, we have $t H_n > t\ln n$.
  The event $\{Z > t H_n\}$ is a *strict subset* of $\{Z > t\ln n\}$, which implies:
  $$\Prob{Z > t\ln n} \geq \Prob{Z > t H_n}.$$
  Bounding $\Prob{Z > t H_n}$ from above does **not** provide an upper bound on $\Prob{Z > t\ln n}$. For example, when $t = 1$, $t\ln n = \ln n < H_n = \Ex{Z}$, so $\{Z > \ln n\}$ contains the entire upper half of the distribution including the mean, where upper-tail Chernoff bounds do not apply.
- **Action Taken:** Annotated the proof with a detailed reviewer remark (`\remX`) at lines 194--195. Recommended either formulating the theorem in terms of the exact expectation $H_n$ (i.e. $\Prob{Z > t H_n}$) or taking into account the additive constant $H_n - \ln n \leq 1$.

---

### [HIGH] Flawed Independence Claim and Probability Definition for QuickSort Step
- **Severity & Type:** Confirmed Mathematical Error.
- **Location (Original):** [chernoff_app.tex#L20-L33](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L20-L33)
- **Location (Reviewed):** [chernoff_app_reviewed.tex#L20-L34](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L20-L34)
- **Evidence & Impact:**
  The text defines $u$ to be successful in the $i$\th level if $\cardin{S_{i+1}} \leq \cardin{S_i}/2$, and claims $\Prob{X_i = 1} = 1/2$.
  This is mathematically incorrect: if $u$ is near the median of $S_i$, choosing a pivot to the left of $u$ leaves $u$ in a subproblem of size $\geq \cardin{S_i}/2$; choosing a pivot to the right of $u$ also leaves $u$ in a subproblem of size $\geq \cardin{S_i}/2$. Thus, $u$ is in a subproblem of size $\leq \cardin{S_i}/2$ *only* when the pivot is chosen adjacent to $u$. For such an element, $\Prob{X_i = 1} \leq 2/\cardin{S_i} \to 0$ as $\cardin{S_i} \to \infty$.
  In standard analyses (e.g. Motwani & Raghavan 1995, Section 4.1), a step is defined to be successful if the pivot falls in the central half $[ \cardin{S_i}/4, 3\cardin{S_i}/4 ]$, which occurs with probability at least $1/2$ and guarantees $\cardin{S_{i+1}} \leq \frac{3}{4}\cardin{S_i}$, requiring at most $\lceil \log_{4/3} n \rceil$ successful steps.
  Furthermore, the indicator variable $X_i$ was defined redundantly twice in consecutive paragraphs (lines 24--25 and lines 30--31).
- **Action Taken:** Added a detailed reviewer remark (`\remX`) at lines 33--34 specifying the standard Motwani--Raghavan middle-half definition and parameters.

---

### [HIGH] Unconditional vs. Conditional Independence in Hypercube Routing
- **Severity & Type:** Confirmed Conceptual Probability Error.
- **Location (Original):** [chernoff_app.tex#L355-L368](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L355-L368)
- **Location (Reviewed):** [chernoff_app_reviewed.tex#L361-L366](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L361-L366)
- **Evidence & Impact:**
  The text claims: "Crucially, for a fixed $i$, the variables $H_{i1}, \ldots, H_{iN}$ are independent."
  This is false unconditionally: if $\rho_i$ is long, it contains more edges and is more likely to intersect any other path $\rho_j$, making $H_{ij}$ and $H_{ik}$ positively correlated. Mutual independence holds **only conditionally given the specific path $\rho_i$**, because once $\rho_i$ is fixed, the destination choices $\sigma(j)$ and $\sigma(k)$ for distinct packets $j, k \neq i$ are mutually independent.
- **Action Taken:** Tracked correction to `conditionally independent given the path $\rho_i$` using `\delX` and `\newX`, and added explanatory `\remX`.

---

### [MEDIUM] Total Stage Count Omission in Theorem 16.7 (Traversal Time vs. Delay)
- **Severity & Type:** Confirmed Exposition / Rigor Omission.
- **Location (Original):** [chernoff_app.tex#L428-L434](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L428-L434)
- **Location (Reviewed):** [chernoff_app_reviewed.tex#L437-L445](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L437-L445)
- **Evidence & Impact:**
  Theorem 16.7 states that each packet arrives in $\leq 14n$ stages. However, $7n$ was established as an upper bound on the queue *delay* in phase 1, and $7n$ in phase 2. The total time spent by a packet is its route length plus its queue delay. Since route length is at most $n$, phase 1 takes up to $n + 7n = 8n$ stages, and phase 2 takes up to $8n$ stages, totaling at most $16n$ stages (or $14n$ if delay is bounded by $6n$).
- **Action Taken:** Annotated Theorem 16.7 with a reviewer remark (`\remX`) at line 444 clarifying the distinction between delay and total stages.

---

### [MEDIUM] Directed vs. Undirected Hypercube Edges and Congestion Calculation
- **Severity & Type:** Modeling Inconsistency and Notation Overloading.
- **Location (Original):** [chernoff_app.tex#L377-L417](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L377-L417)
- **Location (Reviewed):** [chernoff_app_reviewed.tex#L385-L426](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L385-L426)
- **Evidence & Impact:**
  1. *Directed vs. Undirected Edges:* In parallel routing, each directed edge has an independent FIFO queue and can transmit one packet per clock tick. The hypercube has $Nn$ directed edges. Since the total expected path length is $N(n/2)$, the average load per directed edge is $1/2$. The text counted undirected edges ($Nn/2$), giving an average load of $1$.
  2. *Self-Inclusion:* The upper bound $\sum_{j=1}^N H_{ij} \leq \sum_{m=1}^k T(e_m)$ includes packet $i$ itself on each edge $e_m \in \rho_i$, so $T(e_m) \geq 1$. Conditioning on $\rho_i$, the other packets contribute $\leq \cardin{\rho_i}/2 \leq n/2$.
  3. *Index Collision:* The original display at line 377 used dummy variable $j$ simultaneously for packet index ($j=1\dots N$) and edge index ($j=1\dots k$).
- **Action Taken:**
  - Renamed the edge summation index from $j$ to $m$ (`\sum_{m=1}^k T(e_m)`).
  - Clarified footnote 1 regarding directed ($Nn$) vs. undirected ($Nn/2$) edges.
  - Replaced the single-line 157.6pt overfull `equation*` with a clean two-line `align*` environment.
  - Documented in `\remX`.

---

### [MEDIUM] Inconsistent QuickSort Depth Formula & Missing Proof for Lemma 16.2
- **Severity & Type:** Algebraic Inconsistency and Incomplete Exposition.
- **Location (Original):** [chernoff_app.tex#L82-L95](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L82-L95)
- **Location (Reviewed):** [chernoff_app_reviewed.tex#L83-L97](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L83-L97)
- **Evidence & Impact:**
  1. The text states $L = (4+c)\ceil{\lg n} = 2\ceil{\lg n} + 4c\sqrt{\lg n}\sqrt{\lg n}$. But $2\ceil{\lg n} + 4c\lg n = (2+4c)\lg n$, which equals $(4+c)\lg n$ only if $c = 2/3$.
  2. Bounding $2\exp(-c\lg n) \leq 1/n^c$ requires $2n^{-c/\ln 2} \leq n^{-c}$, which requires $n^{c(1/\ln 2 - 1)} \geq 2$.
  3. In line 88, taking a union bound over $n$ elements to get total failure probability $\leq 1/n^c$ requires bounding each individual failure probability by $1/n^{c+1}$, which shifts $c \to c+1$.
  4. Lemma 16.2 is stated without units ("performs more than $(6+c)n\lg n$") and without proof.
- **Action Taken:** Supplied the missing unit "comparisons" via `\newX`, and added `\remX` explaining the formula discrepancy, union bound parameters, and the missing proof (summing recursion depths over all $n$ elements).

---

### [MEDIUM] Off-by-One Node Indexing in Algorithm RandomRoute
- **Severity & Type:** Minor Indexing Inconsistency.
- **Location (Original):** [chernoff_app.tex#L268](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L268)
- **Location (Reviewed):** [chernoff_app_reviewed.tex#L273](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L273)
- **Evidence & Impact:**
  The vertices of the hypercube are defined on line 198 as $[0, \ldots, N-1]$. In step 1 of Algorithm `RandomRoute`, the intermediate destination $\sigma(i)$ was sampled from $[1, \ldots, N]$.
- **Action Taken:** Corrected the destination range to $[0, \ldots, N-1]$.

---

### [MEDIUM] Translation Missing in Unit Hypersphere Embedding (Lemma 16.9 Proof)
- **Severity & Type:** Mathematical Gap in Proof.
- **Location (Original):** [chernoff_app.tex#L495-L498](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L495-L498)
- **Location (Reviewed):** [chernoff_app_reviewed.tex#L508-L512](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L508-L512)
- **Evidence & Impact:**
  The vertices of $\{0, 1\}^n$ lie on the sphere of radius $\sqrt{n}/2$ centered at $(1/2, \dots, 1/2)$. Simply scaling down by $\sqrt{n}/2$ shifts the center to $(1/\sqrt{n}, \dots, 1/\sqrt{n}) \neq \mathbf{0}$, which is not the standard unit hypersphere centered at the origin.
- **Action Taken:** Corrected the proof using `\chgY` to translate $P$ by $-(1/2, \dots, 1/2)$ to the origin before scaling down by $\sqrt{n}/2$.

---

### [LOW] Severe Overfull `\hbox`es & Duplicate Fragment Inclusion
- **Severity & Type:** LaTeX Typography & Mechanics.
- **Locations (Original):**
  - [chernoff_app.tex#L64-L71](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L64-L71): 79.51pt overfull `\hbox` in Lemma 16.1 proof `align*`.
  - [chernoff_app.tex#L400-L417](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L400-L417): 157.59pt overfull `\hbox` in single-line equation.
  - [chernoff_app.tex#L481-L483](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L481-L483): 38.74pt overfull `\hbox` in Euclidean section.
  - [chernoff_app.tex#L537](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app.tex#L537): Duplicate `\IncFragment{c_h_r_0_1}` in `\StandAloneMode`.
- **Action Taken:**
  - Split long displayed expressions across lines in `align*` environments.
  - Cleaned up duplicate fragment `c_h_r_0_1`.
  - Reduced compiler alerts from 5 to **0**.

---

## 2. Significant Revisions

1. **Lemma 16.1 Hypothesis ([chernoff_app_reviewed.tex#L45](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L45)):** Added explicit assumption $\Prob{X_i = 1} = 1/2$ to the lemma statement.
2. **Lag Argument Correction ([chernoff_app_reviewed.tex#L343-L345](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L343-L345)):** Corrected "at step $\mu+1$" to "at time $\tau+1$", which directly contradicts the maximality of $\tau$ in the lag charging proof.
3. **Probability Phrasing ([chernoff_app_reviewed.tex#L435-L441](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L435-L441)):** Corrected "with probability $\leq 2^{-5n}$ all packets arrive... in a delay of most $7n$" to "with probability at least $1 - 2^{-5n}$, all packets arrive... with a delay of at most $7n$".
4. **Unit Hypersphere Proof ([chernoff_app_reviewed.tex#L508-L512](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L508-L512)):** Added translation by $-(1/2, \dots, 1/2)$ before scaling.
5. **Bibliography Citations ([chernoff_app_reviewed.tex#L518-L521](file:///home/sariel/rand_alg/notes/16_chernoff_app/chernoff_app_reviewed.tex#L518-L521)):** Added non-breaking spaces before citations (`~\cite{...}`).

---

## 3. Verification & Compilation Status

- **Build Driver:** `/home/sariel/bin/l --no-env chernoff_app_reviewed.tex`
- **Compiler:** XeLaTeX (XeTeX 3.141592653-2.6-0.999998, TeX Live 2026/Debian)
- **Bibliography:** BibLaTeX with Biber backend, alpha style (`chernoff_app_reviewed.bbl`)
- **Compilation Outcome:**
  - **Errors:** 0
  - **Alerts:** 0 (down from 5 in original and intermediate versions)
  - **Warnings:** 6 (minor underfull/overfull <16pt; 0 undefined references, 0 missing citations)
  - **Whatevers:** 0

---

## 4. Author Action Items

1. **Section 16.1 (QuickSort Success Probability):** Replace the $\cardin{S_{i+1}} \leq \cardin{S_i}/2$ definition by the standard Motwani--Raghavan middle-half definition $[ \cardin{S_i}/4, 3\cardin{S_i}/4 ]$ to restore the valid success probability $\geq 1/2$.
2. **Section 16.2 (Minimum Changes Concentration):** Restate Theorem 16.3 to bound deviations from the true expectation $\mu = H_n$ rather than $\ln n$, avoiding the invalid sub-expectation bounding step.
3. **Section 16.3 (Routing Delay Chernoff Bound):** State the Chernoff bound conditioned on the path $\rho_i$ with parameter $\mu_0 = n$, eliminating the inequality reversal $2^{-13\mu} \leq 2^{-6n}$.
4. **Section 16.3 (Total Stages in Theorem 16.7):** Update the stage bound from $\leq 14n$ to $\leq 16n$ (or adjust delay bound to $6n$) to properly include the $2n$ path traversal stages.
