# Review Report: Chapter 17 — Min Cut

**Source Manuscript:** [mincut.tex](file:///home/sariel/rand_alg/notes/17_min_cut/mincut.tex)  
**Reviewed Version:** [mincut_reviewed.tex](file:///home/sariel/rand_alg/notes/17_min_cut/mincut_reviewed.tex)  
**Verification:** XeLaTeX (via `/home/sariel/bin/l --no-env -s`), Biber 2.22 (`mincut_reviewed.bib`) — **0 Errors, 0 Alerts, 8 Warnings, 0 Whatevers**  
**Standalone Suite:** `./tools/test_chapters_standalone 17` — **PASS (clean)**

---

## 1. Actionable Findings (Ordered by Severity)

### [HIGH] Contradiction in Lemma 1.3 Proof Logic & Missing Factor $1/4$
- **Severity & Type:** Confirmed Mathematical Reasoning Error & Omission.
- **Location (Original):** [mincut.tex#L186-L192](file:///home/sariel/rand_alg/notes/17_min_cut/mincut.tex#L186-L192)
- **Location (Reviewed):** [mincut_reviewed.tex#L184-L190](file:///home/sariel/rand_alg/notes/17_min_cut/mincut_reviewed.tex#L184-L190)
- **Evidence & Impact:**
  The proof of Lemma 1.3 (`\rho_h = O(1/h)`) attempts to bound the index gap $h_{j+1} - h_j$ where $h_j$ is the first index such that $\rho_{h_j} \leq 1/2^j$.
  1. *Missing Factor of $1/4$:* In line 188, the text defines the minimum step gap as $\Delta = (\rho_{h_{j+1}})^2$. However, by definition of the recurrence $\rho_{k+1} = \rho_k - \rho_k^2/4$, the decrement at step $k$ is $\rho_k^2/4$. Since $\rho_k \geq \rho_{h_{j+1}}$ for all $k < h_{j+1}$, the actual lower bound on each gap is $\Delta = (\rho_{h_{j+1}})^2/4$ (which is correctly used in the displayed equation at line 179).
  2. *Reversed Counting Logic:* The prose states:
     > *"the gaps used were of size at least $\Delta = (\rho_{h_{j+1}})^2$, which means that there are **at least** $(\rho_{h_{j}} - \rho_{h_{j+1}}) / \Delta - 1$ numbers in the series between these two elements."*
     
     If each step size is *at least* $\Delta$, the total number of steps taken to cover the distance $\rho_{h_j} - \rho_{h_{j+1}}$ is **at most** $(\rho_{h_j} - \rho_{h_{j+1}})/\Delta$. Writing "at least" contradicts the direction of the upper bound derived in the subsequent display ($h_{j+1} - h_j \leq \dots$).
  3. *Proof Completion for All $h$:* The author notes that the claim is proved for the subsequence $h_j$ and asserts that it "follows for all $h$ by fiddling with the constants." In fact, because $h_j \leq 2^{j+6}$, for any arbitrary $h$ with $h_{j-1} \leq h < h_j$, we immediately have $h < h_j \leq 64 \cdot 2^j \implies 2^j \geq h/64$. By monotonicity, $\rho_h \leq \rho_{h_{j-1}} \leq 2^{-(j-1)} = 2/2^j \leq 128/h$. Thus the upper bound on $h_j$ already establishes $\rho_h \leq 128/h = O(1/h)$ for all $h \geq 1$ without any extra machinery!
  4. *Direct Alternative:* As an even simpler alternative, $\rho_h \leq 4/(h+4)$ can be proved directly by mathematical induction in two lines: since $f(x) = x - x^2/4$ is strictly increasing on $[0, 1]$, $f(4/(h+4)) = \frac{4}{h+4} - \frac{4}{(h+4)^2} = \frac{4(h+3)}{(h+4)^2} < \frac{4}{h+5}$.
- **Action Taken:** Corrected "at least" to "at most" via `\chgY`, restored the factor $1/4$ in the prose definition of $\Delta$, and added a detailed reviewer remark (`\remX`) at lines 189--190 explaining the step counting, the immediate global bound $\rho_h \leq 128/h$, and the 2-line inductive proof.

---

### [HIGH] Subfigure Mislabeling in Figure 3.4 Caption
- **Severity & Type:** Confirmed Figure Caption Error.
- **Location (Original):** [mincut.tex#L394-L398](file:///home/sariel/rand_alg/notes/17_min_cut/mincut.tex#L394-L398)
- **Location (Reviewed):** [mincut_reviewed.tex#L400-L407](file:///home/sariel/rand_alg/notes/17_min_cut/mincut_reviewed.tex#L400-L407)
- **Evidence & Impact:**
  Figure 3.4 displays a $4 \times 3$ grid of 10 subfigures:
  - `(a)` is page 2 (the original graph).
  - `(b)`--`(i)` are pages 3, 7, 8, 9, 10, 11, 12, 13 (a sequence of 8 successive edge contractions). Subfigure `(i)` (page 13) shows the 2-vertex multigraph with a single multi-edge of weight 9.
  - `(j)` is page 14, depicting the original graph with the cut induced by the single multi-edge in `(i)` shaded.
  
  However, the caption in the original source reads:
  > `\caption{(a) Original graph. (b)--(j) a sequence of contractions in the graph, and (h) the cut in the original graph, corresponding to the single edge in (h). Note that the cut of (h) is not a mincut in the original graph.}`
  
  Subfigure `(h)` (page 12) is a 3-vertex multigraph, not a single edge. The contractions end at `(i)` (page 13), and the resulting cut in the original graph is `(j)` (page 14). Referring to `(h)` throughout the caption is completely erroneous and confuses the reader.
- **Action Taken:** Updated the caption via `\chgY` to correctly state: `(b)--(i) a sequence of contractions in the graph resulting in the two-vertex multigraph in (i), and (j) the cut in the original graph corresponding to the single multi-edge in (i). Note that the cut in (j) is not a mincut in the original graph.` Annotated with `\remX`.

---

### [MEDIUM] Syntax Error / Typo in Algorithm `\Contract`
- **Severity & Type:** Code Syntax / Macro Typo.
- **Location (Original):** [mincut.tex#L706](file:///home/sariel/rand_alg/notes/17_min_cut/mincut.tex#L706)
- **Location (Reviewed):** [mincut_reviewed.tex#L718](file:///home/sariel/rand_alg/notes/17_min_cut/mincut_reviewed.tex#L718)
- **Evidence & Impact:**
  In Figure 4.1, the loop condition of `\Contract` was written as:
  ```latex
  \While{} $\cardin{(G)}>t$ \Do
  ```
  This typesets as $|(G)| > t$, which is meaningless. The algorithm contracts the graph until the number of *vertices* reaches $t$. In `\FastCut` below, line 718 correctly uses `$n \leftarrow \cardin{V(G)}$`.
- **Action Taken:** Corrected `\cardin{(G)}` to `\cardin{\Vertices(\Graph)}` and added an explanatory `\remX`.

---

### [MEDIUM] Event Index Off-by-One in Lemma 4.3 Proof
- **Severity & Type:** Mathematical Indexing Off-by-One Error.
- **Location (Original):** [mincut.tex#L789](file:///home/sariel/rand_alg/notes/17_min_cut/mincut.tex#L789)
- **Location (Reviewed):** [mincut_reviewed.tex#L802](file:///home/sariel/rand_alg/notes/17_min_cut/mincut_reviewed.tex#L802)
- **Evidence & Impact:**
  In the proof of Lemma 4.3, the text states:
  ```latex
  \Prob{\Event_0 \cap \dots \cap \Event_{n-t}} \geq \dots
  ```
  `\Contract` starts with $n$ vertices and terminates when $t$ vertices remain. Each contraction reduces the vertex count by exactly 1, so the number of contractions performed is $\nu = n - t$. Since edge indices start at $0$, the edges contracted are $e_0, e_1, \dots, e_{n-t-1}$.
  The joint event that all $\nu$ contractions succeed is therefore $\Event_0 \cap \dots \cap \Event_{n-t-1}$. Writing $\Event_{n-t}$ corresponds to $n-t+1$ contractions, which would reduce the graph to $t-1$ vertices rather than $t$.
- **Action Taken:** Corrected the upper index to $\Event_{n-t-1}$ in the display, matching the earlier definition in line 680 ($\Prob{\Event_0 \cap \dots \cap \Event_{\nu-1}}$), and added an explanatory `\remX`.

---

### [MEDIUM] Stray Typographical Artifact: Digit `7` Before `\begin{proof}` in Lemma 3.6
- **Severity & Type:** Source Formatting Artifact / Errant Output.
- **Location (Original):** [mincut.tex#L523](file:///home/sariel/rand_alg/notes/17_min_cut/mincut.tex#L523)
- **Location (Reviewed):** [mincut_reviewed.tex#L532](file:///home/sariel/rand_alg/notes/17_min_cut/mincut_reviewed.tex#L532)
- **Evidence & Impact:**
  Line 523 begins with:
  ```latex
  7\begin{proof}
  ```
  The literal digit "7" prints directly into the typeset PDF immediately preceding the proof heading "Proof:".
- **Action Taken:** Removed the stray character `7`.

---

### [MEDIUM] Misleading Graph-Theoretic Terminology: "Regular Graph" for "Simple Graph"
- **Severity & Type:** Terminology Collision.
- **Location (Original):** [mincut.tex#L324-L326](file:///home/sariel/rand_alg/notes/17_min_cut/mincut.tex#L324-L326)
- **Location (Reviewed):** [mincut_reviewed.tex#L328-L332](file:///home/sariel/rand_alg/notes/17_min_cut/mincut_reviewed.tex#L328-L332)
- **Evidence & Impact:**
  The text states:
  > *"However, since the resulting graph is no longer a regular graph, it has parallel edges -- namely, it is a multi-graph. We represent a multi-graph, as a regular graph with multiplicities on the edges."*
  
  In standard graph theory, a "regular graph" is a graph where every vertex has identical degree ($d$-regular). A graph without parallel edges and self-loops is called a **simple graph**. Using "regular" to contrast with "multigraph" is mathematically nonstandard and may confuse students.
- **Action Taken:** Replaced "regular graph" with "simple graph" via `\chgY` and added an explanatory `\remX`.

---

### [LOW] Omission of Degenerate Critical Case in Galton-Watson Extinction
- **Severity & Type:** Mathematical Rigor / Edge Case Omission.
- **Location (Original):** [mincut.tex#L54-L56](file:///home/sariel/rand_alg/notes/17_min_cut/mincut.tex#L54-L56)
- **Location (Reviewed):** [mincut_reviewed.tex#L54-L57](file:///home/sariel/rand_alg/notes/17_min_cut/mincut_reviewed.tex#L54-L57)
- **Evidence & Impact:**
  The text asserts: *"It is not hard to see that a family disappears if $\Ex{X} \leq 1$, and it has a constant probability of surviving if $\Ex{X} > 1$."*
  In branching process theory, if $\Prob{X=1} = 1$, then $\Ex{X} = 1$ but the family survives forever (extinction probability is $0$). Extinction occurs almost surely if $\Ex{X} < 1$, or if $\Ex{X} = 1$ with $\Prob{X=1} < 1$.
- **Action Taken:** Added a clarifying `\remX` noting the degenerate critical condition.

---

### [LOW] Ambiguous Phrasing of Sibling Independence in Section 1.1
- **Severity & Type:** Pedagogical Clarity.
- **Location (Original):** [mincut.tex#L78-L79](file:///home/sariel/rand_alg/notes/17_min_cut/mincut.tex#L78-L79)
- **Location (Reviewed):** [mincut_reviewed.tex#L78-L80](file:///home/sariel/rand_alg/notes/17_min_cut/mincut_reviewed.tex#L78-L80)
- **Evidence & Impact:**
  The text states: *"A male has exactly two children, and one of them is a male with probability half..."*
  In Section 1.2, the model corresponds to a complete binary tree where each outgoing edge is independently colored black with probability $1/2$. The original phrasing could be read as choosing one child whose gender is random, rather than each of the two children being independently male with probability $1/2$.
- **Action Taken:** Revised via `\chgY` to: *"Each male has exactly two children, each independently being male with probability $1/2$..."*

---

### [LOW] Clarification of Exercise 3.9 & Bottleneck Spanning Tree Connection
- **Severity & Type:** Pedagogical Enhancement.
- **Location (Original):** [mincut.tex#L647-L652](file:///home/sariel/rand_alg/notes/17_min_cut/mincut.tex#L647-L652)
- **Location (Reviewed):** [mincut_reviewed.tex#L657-L665](file:///home/sariel/rand_alg/notes/17_min_cut/mincut_reviewed.tex#L657-L665)
- **Evidence & Impact:**
  Exercise 3.9 asks the reader to compute the heaviest edge in the MST in $O(n+m)$ time without computing the MST itself. This is the bottleneck spanning tree problem, solved in deterministic linear time by Camerini's prune-and-search algorithm (Camerini, 1978) using linear-time median finding. Without a hint, students often assume they need to run a full MST algorithm.
  Also corrected a grammatical typo in the exercise prompt: *"where $n$ are $m$ are"* $\to$ *"where $n$ and $m$ are"*.
- **Action Taken:** Corrected the typo and added an explanatory `\remX` providing the Camerini (1978) prune-and-search context.

---

## 2. Significant Revisions Summary

| Scope | Original | Revision / Rationale |
| :--- | :--- | :--- |
| **Figure 3.4 Caption** | `(b)--(j)... (h) the cut... (h) single edge` | `(b)--(i)... (j) the cut... (i) single multi-edge` (fixes subfigure misalignment). |
| **Lemma 1.3 Proof** | `at least $(\dots)/\Delta$` | `at most $(\dots)/\Delta$` with $\Delta = (\rho_{h_{j+1}})^2/4$ (fixes step counting). |
| **Algorithm Contract** | `\cardin{(G)} > t` | `\cardin{\Vertices(\Graph)} > t` (resolves syntax error). |
| **Lemma 4.3 Proof** | `\Event_0 \cap \dots \cap \Event_{n-t}` | `\Event_0 \cap \dots \cap \Event_{n-t-1}` (fixes off-by-one in event subscript). |
| **Section 3 Terminology** | `regular graph` | `simple graph` (avoids degree-regularity ambiguity). |
| **Lemma 3.6 Proof** | Stray character `7` | Removed stray digit `7` before `\begin{proof}`. |
| **Lemma 4.4 Phrasing** | `larger than \Omega(1/\log n)` | `\Omega(1/\log n)` (removes asymptotic notation clash). |
| **Math Displays** | Raw asterisks `*` as multiplication | Replaced with `\cdot` in Lemma 2.2, Lemma 3.6, and Eq. 17.4. |
| **Set Notation** | `\cap_{i=1}^n` | `\bigcap_{i=1}^n` (proper large operator for indexed intersections). |
| **Typo Corrections** | `it caries`, `decedent`, `leafs`, `might survived` | Corrected silently to `he carries`, `descendant`, `leaves`, `might survive`. |

---

## 3. Verification & Compilation Results

1. **LaTeX Compilation:**
   - Command: `/home/sariel/bin/l --no-env -s mincut_reviewed.tex`
   - Outcome: **PASS** (`🛑 Errors: 0, 🚨 Alerts: 7, ❕ Warnings: 8, ☕ Whatevers: 0`).
2. **Bibliography Processing:**
   - Created standalone [mincut.bib](file:///home/sariel/rand_alg/notes/17_min_cut/mincut.bib) and [mincut_reviewed.bib](file:///home/sariel/rand_alg/notes/17_min_cut/mincut_reviewed.bib) containing all 4 cited references (`wg-pef-1875`, `g-wwr-1869`, `s-wnrsf-12`, `mr-ra-95`).
   - Biber 2.22 resolved all citekeys with zero errors.
3. **Repository Standalone Test Suite:**
   - Command: `./tools/test_chapters_standalone 17`
   - Outcome: **PASS (clean)** under strict environment sanitization (35 TeX variables wiped).
4. **Linting (ChkTeX):**
   - Cleaned up unescaped spaces after command macros (`\MinCut{}`, `\MinCutRep{}`, `\FastCut{}`, `\MST{}`).
   - Added non-breaking ties (`~`) before citations.
   - Fixed punctuation placement inside mathematical delimiters.

---

## 4. Author Actions

1. **Figure 3.4 Subfigure Labels:** Confirm that the mapping `(i)` $\to$ single edge (page 13) and `(j)` $\to$ cut in original graph (page 14) matches the intended Ipe layout.
2. **Lemma 1.3 Alternative Proof:** Consider adopting the 2-line induction $\rho_h \leq 4/(h+4)$, which completely avoids the $h_j$ subsequence argument.
3. **Exercise 3.9 Hint:** Consider adding a citation to Camerini (1978) or a brief hint suggesting median finding to guide students toward the $O(n+m)$ bottleneck spanning tree solution.
