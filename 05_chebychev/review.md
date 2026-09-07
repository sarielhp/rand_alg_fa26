# Manuscript Review Report: Chebyshev, Sampling and Selection

**Document Under Review:** [05_chebychev/chebychev.tex](file:///tmp/bws/agent_494528287/05_chebychev/chebychev.tex)  
**Annotated Manuscript:** [05_chebychev/chebychev_reviewed.tex](file:///tmp/bws/agent_494528287/05_chebychev/chebychev_reviewed.tex)  
**Compilation Status:** **PASS — 0 Errors** (via `/home/sariel/bin/l -no-env -s`)  
**Original File Integrity:** **Unmodified** (verified via `git status`)

---

## 1. Executive Summary

- **Overall Quality Assessment**:  
  This chapter presents a vibrant, pedagogically lucid introduction to Chebyshev's inequality, second-moment concentration, property estimation via random sampling, and randomized selection. The progression—moving from an elementary symmetric random walk on $\{-1,+1\}^n$, to Chebyshev's inequality for general random variables, to sampling-based estimation of proportions, and culminating in the sublinear-pivot selection algorithm—is well calibrated for students. The exposition maintains an accessible, conversational style that demystifies concentration of measure.

- **Core Pedagogical Strengths**:
  - **Pedagogical Informality over Heavy Machinery**: Probabilistic concepts are developed through elementary calculations, intuitive recurrences, and concrete examples rather than measure-theoretic abstractions.
  - **Transparent Second-Moment Analysis**: Demonstrates with clarity how pairwise independence suffices for variance additivity, clearly delineating Chebyshev's scope from higher-moment techniques like Chernoff bounds.
  - **Intuitive Memoryless Recurrence**: Uses a natural restart recurrence ($F \leq C_{\text{round}} + (1-p)F$) to analyze expected comparisons, giving students a concrete, constructive understanding of algorithmic restarts without requiring the machinery of stopping times or filtrations.
  - **Strong Visual Intuition**: Figure 1 effectively illustrates the geometry of inverse estimation, showing how sample pivots bracket the target rank-$k$ element.

- **Primary Revision Priorities**:
  1. **Theorem 3.6 Proof Corrections**: Fixed the expected number of rounds $\Ex{Y} = 1/p \leq 1 + O(1/n^{1/4})$ (previously written as $1/(1-p) = 1 + O(1/n^{3/4})$) and corrected the recurrence expansion factor to $1/p \leq 1 + 4/n^{1/4}$ (which mistakenly had $n^{3/4}$ in the denominator).
  2. **Removal of Dangling Wald Sentence**: Excised the dangling sentence referencing Wald's identity at the end of Theorem 3.6 proof. Clarified that the memoryless recurrence directly accounts for partition comparisons ($1.5n + O(n^{3/4})$), and adding sorting costs ($O(n^{3/4}\log n)$) across $O(1)$ expected rounds cleanly completes the claimed $1.5n + O(n^{3/4}\log n)$ comparison bound.
  3. **Cross-Reference Corrections (Lemma 3.1 & Subsection 3.1.1)**: Corrected cross-references pointing to Lemma 2.3 (`lemref{estimate:chebyshev}`) so they point to Lemma 2.1 (`lemref{Chebyshev-1}`), which establishes the concentration of the sample count $Y$.
  4. **Asymptotic Bound Precision (Subsection 3.2.1)**: Corrected the failure condition threshold from $\Theta(n^{3/4})$ to $O(n^{3/4})$, properly reflecting an asymptotic upper-bound check.
  5. **Pairwise Independence Highlighting**: Emphasized pairwise independence in Remark 1.1 and Lemma 1.1 to reinforce this key pedagogical takeaway.
  6. **Zero Variance Edge Case**: Added a remark on Exercise 1.3 explaining the degeneracy of standardized Chebyshev's inequality when $\sigma_X = 0$.
  7. **Low-Level Prose Polish**: Eliminated duplicate words ("each taking each value", "that, we have that") and fixed missing punctuation ("that is,").

---

## 2. Mathematical Rigor & Technical Critique

### A. Randomized Selection Analysis (Theorem 3.6)
1. **Geometric Distribution Expectation**:
   - In Subsection 3.2.2, each round succeeds with probability $p \geq 1 - 3/n^{1/4}$ (\Eqref{s-p-r-selection}).
   - The number of rounds $Y$ until the first success is a geometric random variable with parameter $p$. Its expected value is:
     $$\Ex{Y} = \frac{1}{p} \leq \frac{1}{1 - 3/n^{1/4}} \leq 1 + \frac{4}{n^{1/4}} = 1 + O(1/n^{1/4}),$$
     for sufficiently large $n$ (as established in \Eqref{q-s-few-rounds}).
   - *Original draft slip:* The text wrote $\Ex{Y} = \frac{1}{1-p} = 1 + O(1/n^{3/4})$. This conflated the success probability $p$ with the failure probability $1-p$, and misstated the asymptotic exponent as $n^{3/4}$ instead of $n^{1/4}$.
   - *Fix applied:* Corrected to $\Ex{Y} = 1/p \leq 1 + O(1/n^{1/4})$.

2. **Recurrence Solving & Denominator Exponent**:
   - Let $F$ denote the expected number of comparisons used in the partitioning steps. A round performs an expected $1.5n + O(n^{3/4})$ comparisons if successful, and at most $2n$ comparisons before restarting if it fails:
     $$F \leq 1.5n + O(n^{3/4}) + (1-p)(2n + F) \leq 1.5n + O(n^{3/4}) + (1-p)F.$$
   - Solving for $F$:
     $$F \leq \frac{1.5n + O(n^{3/4})}{p} \leq \left(1 + \frac{4}{n^{1/4}}\right)\left(1.5n + O(n^{3/4})\right) \leq 1.5n + O(n^{3/4}).$$
   - *Original draft slip:* The recurrence line wrote $\pth{1 + \frac{6}{n^{3/4}}}$, placing $n^{3/4}$ in the denominator instead of $n^{1/4}$.
   - *Fix applied:* Corrected the expansion factor to $\pth{1 + \frac{4}{n^{1/4}}}$.

3. **Total Comparison Accounting & Excising Dangling Wald Reference**:
   - *Original draft slip:* Following the display for $F$, a dangling unedited sentence appeared:
     `using \Eqref{s-p-r-selection} Wald's identity yields $\Ex{C} \leq \Ex{Y}(1.5n + O(n^{3/4} \log n)) = \dots$`
     This sentence introduced an undefined variable $C$ and invoked Wald's identity after the proof had already completed the recurrence for $F$.
   - *Fix applied:* The dangling sentence was removed. The proof now cleanly explains the total comparison tally:
     - Partitioning comparisons across all rounds sum to $F \leq 1.5n + O(n^{3/4})$.
     - Sample sorting takes $O(m \log m) = O(n^{3/4} \log n)$ comparisons per round.
     - Final candidate set $S_m$ sorting takes $O(|S_m| \log |S_m|) = O(n^{3/4} \log n)$ comparisons in the successful round.
     - Across $\Ex{Y} = O(1)$ expected rounds, sorting adds an expected $O(n^{3/4} \log n)$ comparisons.
     - Summing partitioning and sorting yields the claimed total of $1.5n + O(n^{3/4} \log n)$ comparisons.

### B. Cross-Reference Alignment (Lemma 3.1 & Subsection 3.1.1)
- In Lemma 2.1 (`\lemlab{Chebyshev-1}`), the sample count $Y = \sum_{i=1}^m Y_i$ is proven to satisfy:
  $$\Prob{\Ex{Y} - t\sqrt{m}/2 \leq Y \leq \Ex{Y} + t\sqrt{m}/2} \geq 1 - 1/t^2.$$
- In Lemma 2.3 (`\lemlab{estimate:chebyshev}`), the scaled estimator $Z = (n/m)Y$ is proven to estimate $\numC$.
- In Lemma 3.1 (line 407) and Subsection 3.1.1 (line 481), $Y$ represents the raw count of sample elements $\leq \EBRY{U}{k}$. The text erroneously cited `\lemref{estimate:chebyshev}` instead of `\lemref{Chebyshev-1}`.
- *Fix applied:* Corrected both references to point to `\lemref{Chebyshev-1}`.

### C. Asymptotic Failure Bound (Subsection 3.2.1)
- In the algorithm description, the second failure branch checks whether the candidate set $S_m$ is too large:
  $$\cardin{S_m} > 8t\frac{n}{\sqrt{m}}.$$
- For $t = \ceil{n^{1/8}}$ and $m = \ceil{n^{3/4}}$, the cutoff evaluates to:
  $$8t\frac{n}{\sqrt{m}} = 8\ceil{n^{1/8}}\frac{n}{\sqrt{\ceil{n^{3/4}}}} = O(n^{3/4}).$$
- *Original draft slip:* The text wrote $\Theta(n^{3/4})$. Because this is a threshold cutoff against an unusually large sample rather than an exact equality for $|S_m|$, an asymptotic upper bound $O(n^{3/4})$ is the correct mathematical specification.
- *Fix applied:* Corrected $\Theta(n^{3/4})$ to $O(n^{3/4})$.

### D. Zero Variance Case in Exercise 1.3
- In standard standardized Chebyshev:
  $$\Prob{|X - \mu_X| \geq t \sigma_X} \leq \frac{1}{t^2}.$$
- If $\Var{X} = 0$, then $X = \mu_X$ almost surely, and the deviation $|X - \mu_X| \geq 0$ occurs with probability $1$. For any $t > 1$, $1 > 1/t^2$, which violates the inequality unless $\sigma_X > 0$ is explicitly required.
- In contrast, the unstandardized formulation:
  $$\Prob{|X - \mu_X| \geq \lambda} \leq \frac{\Var{X}}{\lambda^2},$$
  holds unconditionally for all $\lambda > 0$, correctly giving $\Prob{0 \geq \lambda} = 0 \leq 0$.
- *Fix applied:* Added a remark (`\remX`) in Exercise 1.3 clearly elucidating this edge case.

---

## 3. Pedagogical & Presentation Evaluation

### A. Valuing Pedagogical Informality Over Unnecessary Formalism
In an instructional setting, the primary objective is to build intuition, fluency, and algorithmic insight:
1. **Memoryless Recurrences vs. Measure-Theoretic Stopping Times**:
   - The memoryless recurrence for expected comparisons ($F \leq C_1 + (1-p)F$) maps directly to the algorithm's control flow: "try once; if it fails, restart."
   - Introducing formal stopping times, filtrations ($\mathcal{F}_n = \sigma(X_1, \dots, X_n)$), and uniform integrability for Wald's equation adds significant overhead without improving algorithmic comprehension.
   - Retaining the recurrence as the primary analysis and appending Wald's Equation as an optional, high-level theorem provides the ideal balance: intuitive self-containment for the main narrative, and an interesting pointer for advanced readers.

2. **Pairwise Independence as a Conceptual Anchor**:
   - Students frequently conflate independence requirements across concentration tools.
   - Emphasizing in Remark 1.1 and Lemma 1.1 that Chebyshev requires only pairwise independence gives students a memorable, practical heuristic for when to choose second-moment bounds over Chernoff bounds (e.g., when designing 2-universal hash functions).

3. **Concrete Numerical Grounding**:
   - Example 2.2 (sampling $m = 4 \cdot 10^6$ coin flips) provides an intuitive, visceral sense of concentration: out of 4 million flips, the outcome stays within $\pm 10,000$ with $99\%$ probability. This bridges abstract probability and real-world intuition effectively.

---

## 4. Compilation & Linting Diagnostics

- **Compilation Tool**: `/home/sariel/bin/l -no-env -s chebychev_reviewed.tex`
- **XeLaTeX Engine Execution**: Successfully generated `chebychev_reviewed.pdf` (13 pages).
- **Compilation Result**: **PASS — 0 Errors, 16 Warnings** (standard minor overfull hbox warnings on long comment strings and package notices).
- **Macro Safety**:
  - The review strictly adhered to ulem compilation safety rules.
  - Complex commands with arguments (`\cite`, `\ref`, `\lemref`) and display math were never wrapped inside `\sout`, `\delX`, or `\chgY`.
  - All mathematical corrections and cross-reference fixes were formatted using `\newX` and safe descriptive `\remX` annotations, guaranteeing robust compilation.
- **Repository Hygiene**:
  - `05_chebychev/chebychev.tex` was left 100% untouched.
  - No auxiliary or build junk was left in the tracked workspace.

---

## 5. Section-by-Section Review Table

| Section / Element | Status | Key Observations & Editorial Actions |
| :--- | :--- | :--- |
| **Preamble & Frontmatter** | Pass | Good epigraph. Preserved author's lighthearted tone in footnote 1. |
| **1.1 Example: Moments** | Pass | Removed duplicate word: `each \chgY{taking each value}{taking value}`. |
| **Remark 1.1** | Pass | Retitled to highlight pairwise vs. mutual independence. Added pedagogical remark on utility in hashing/streaming. |
| **Lemma 1.1 & Proof** | Pass | Clarified pairwise independence in lemma statement and proof remark. |
| **1.2 Chebyshev's inequality** | Pass | Preserved clean proof via Markov on $Y = (X - \mu_X)^2$. |
| **Exercise 1.3** | Pass | Added inline remark explaining $\sigma_X = 0$ degeneracy in standardized form vs. unstandardized form. |
| **Example 1.4 (Binomial)** | Pass | Verified additivity of variance under pairwise independence. |
| **2. Estimation via sampling** | Pass | Clear problem formulation and unbiased estimator $Z = (n/m)Y$. |
| **Lemma 2.1 (Chebyshev-1)** | Pass | Concentration bound correctly derived via complement of Chebyshev tail. |
| **Example 2.2 (Numerical)** | Pass | Removed duplicate "that": `\chgY{ that, we have that}{, we have that}`. |
| **Example 2.3** | Pass | Added missing comma: `\chgY{that is}{that is,}`. |
| **Lemma 2.3 (Universe Count)** | Pass | Verified scaling factor $n/m$ and complement derivation. |
| **3.1 Inverse estimation** | Pass | Corrected cross-reference from `\lemref{estimate:chebyshev}` to `\lemref{Chebyshev-1}` in proof of Lemma 3.1. |
| **3.1.1 Intuition** | Pass | Corrected cross-reference from `\lemref{estimate:chebyshev}` to `\lemref{Chebyshev-1}`. |
| **3.2.1 The algorithm** | Pass | Corrected failure threshold from $\Theta(n^{3/4})$ to $O(n^{3/4})$. |
| **3.2.2 Analysis** | Pass | Verified geometric distribution parameter and success probability. |
| **3.2.3 Doing better & Thm 3.6** | Critical Fix | Fixed $\Ex{Y} = 1/p \leq 1 + O(1/n^{1/4})$, corrected recurrence factor $1 + 4/n^{1/4}$, removed dangling Wald sentence, and added sorting comparison accounting. |
| **Wald's Equation Theorem** | Pass | Added pedagogical remark noting that memoryless recurrence is simpler and preferred for class notes. |

---

## 6. Detailed Editing Log

### 1. Subsection 1.1: Duplicate Word Removal
- **Original Excerpt:**  
  `... each taking each value in $\brc{-1,+1}$ with equal probability $1/2$.`
- **Classification:** Low-Level Prose Fix
- **Annotated Change:**  
  `each \chgY{taking each value}{taking value} in $\brc{-1,+1}$ with equal probability $1/2$.`
- **Rationale:** Eliminated accidental repetition of the word "each".

### 2. Remark 1.1 & Lemma 1.1: Pairwise Independence
- **Original Excerpt (Remark 1.1):**  
  `\begin{remark}[Maybe skip for now]`
- **Classification:** Pedagogical Polish
- **Annotated Change:**  
  `\begin{remark}[\chgY{Maybe skip for now}{Pairwise vs.~mutual independence}] ... \remX{Pedagogical emphasis: Highlighting pairwise independence here is central. Chebyshev's inequality only requires pairwise cancellation of cross-terms $\Ex{X_i X_j} = \Ex{X_i}\Ex{X_j}$ for $i \neq j$. This provides significant algorithmic utility in scenarios where full mutual independence is impossible or computationally costly to construct, such as universal hashing and streaming algorithms.}`
- **Rationale:** Upgraded remark title and added context emphasizing why pairwise independence makes Chebyshev indispensable compared to Chernoff bounds.

- **Original Excerpt (Lemma 1.1):**  
  `Let $X_1, \ldots, X_n \in \brc{-1,+1}$ be independent random variables, each taking each value in $\brc{-1, +1}$ ...`
- **Classification:** Mathematical Precision & Prose Fix
- **Annotated Change:**  
  `Let $X_1, \ldots, X_n \in \brc{-1,+1}$ be \chgY{independent}{pairwise independent} random variables, each \chgY{taking each value}{taking value} in $\brc{-1, +1}$ ...`
- **Rationale:** Explicitly stated pairwise independence to match the section's derivation; removed duplicate "each".

### 3. Exercise 1.3: Zero Variance Edge Case
- **Original Excerpt:**  
  `\begin{exercise}[Not too interesting] Consider the case that $\sigma_X = \Var{X} = 0$, what happens then with Chebyshev's inequality? \end{exercise}`
- **Classification:** Mathematical Clarification
- **Annotated Change:**  
  `\begin{exercise}[\chgY{Not too interesting}{Zero variance case}] ... \remX{Zero variance case ($\sigma_X = 0$): When $\Var{X} = 0$, $X = \mu_X$ almost surely. In the standardized tail form $\Prob{|X - \mu_X| \geq t \sigma_X} \leq 1/t^2$, the event becomes $\Prob{0 \geq 0} = 1$, which strictly exceeds $1/t^2$ for any $t > 1$. Hence, the standardized form implicitly assumes $\sigma_X > 0$. In contrast, the unstandardized Chebyshev bound $\Prob{|X - \mu_X| \geq \lambda} \leq \Var{X}/\lambda^2$ remains unconditionally valid for every $\lambda > 0$, correctly yielding $0 \leq 0$ when $\Var{X} = 0$.} \end{exercise}`
- **Rationale:** Answered the exercise inline, noting the implicit $\sigma_X > 0$ requirement in standardized form and contrasting it with the unstandardized bound.

### 4. Example 2.2: Duplicate Word Removal
- **Original Excerpt:**  
  `... and by the \lemrefY{above lemma}{Chebyshev-1} that, we have that`
- **Classification:** Low-Level Prose Fix
- **Annotated Change:**  
  `and by the \lemrefY{above lemma}{Chebyshev-1}\chgY{ that, we have that}{, we have that}`
- **Rationale:** Removed repetitive conjunction clause ("that, we have that").

### 5. Example 2.3: Punctuation Fix
- **Original Excerpt:**  
  `... property---that is $\widehat{p} n = \tfrac{n}{m} Y$.`
- **Classification:** Typographic / Punctuation Fix
- **Annotated Change:**  
  `property---\chgY{that is}{that is,} $\widehat{p} n = \tfrac{n}{m} Y$.`
- **Rationale:** Added missing comma after the introductory transition phrase "that is,".

### 6. Lemma 3.1 & Subsection 3.1.1: Cross-Reference Corrections
- **Original Excerpt (Lemma 3.1):**  
  `Let $Y$ be the number of elements in the sample $\Sample$ that are $\leq \EBRY{U}{k}$. By \lemref{estimate:chebyshev}, we have ...`
- **Classification:** Cross-Reference Correction
- **Annotated Change:**  
  `... By \newX{\lemref{Chebyshev-1}}\remX{Cross-reference correction: Replaced reference to Lemma~2.3 with \lemref{Chebyshev-1}, which establishes the concentration bound for the sample count $Y$.}, we have ...`
- **Rationale:** Lemma 2.1 (`Chebyshev-1`) bounds the deviation of the raw sample count $Y$, whereas Lemma 2.3 (`estimate:chebyshev`) bounds the scaled estimator $Z = (n/m)Y$.

- **Original Excerpt (Subsection 3.1.1):**  
  `Furthermore, for any $t\geq 1$, \lemref{estimate:chebyshev} implies that ...`
- **Classification:** Cross-Reference Correction
- **Annotated Change:**  
  `Furthermore, for any $t\geq 1$, \newX{\lemref{Chebyshev-1}}\remX{Cross-reference correction: Replaced reference to \lemref{estimate:chebyshev} with \lemref{Chebyshev-1} for the concentration of $Y$.} implies that ...`
- **Rationale:** Aligned cross-reference with Lemma 2.1 (`Chebyshev-1`).

### 7. Subsection 3.2.1: Asymptotic Bound Correction
- **Original Excerpt:**  
  `\item If $\cardin{S_m} > 8 t {n}/ \sqrt{m} = \Theta( n^{3 / 4})$, then the set $S_m$ is too large, and the algorithm fails.`
- **Classification:** Mathematical Precision
- **Annotated Change:**  
  `\item If $\cardin{S_m} > 8 t {n}/ \sqrt{m} = \newX{O(n^{3/4})}$,\remX{Asymptotic bound correction: Corrected $\Theta(n^{3/4})$ to $O(n^{3/4})$. The cutoff threshold $8tn/\sqrt{m} = 8\ceil{n^{1/8}}n/\sqrt{\ceil{n^{3/4}}} = O(n^{3/4})$ is an asymptotic upper-bound test; using big-$O$ notation is mathematically accurate.} then the set $S_m$ is too large, and the algorithm fails.`
- **Rationale:** Corrected $\Theta(n^{3/4})$ to $O(n^{3/4})$ since testing if $|S_m|$ exceeds the threshold is an asymptotic upper-bound check.

### 8. Theorem 3.6 Proof: Geometric Expectation & Recurrence Factor
- **Original Excerpt (Geometric Expectation):**  
  `As the expectation of $Y$ is $\Ex{Y} = \frac{1}{1-p} = 1 + O(1/n^{3/4})$, it follows ...`
- **Classification:** Mathematical Correction
- **Annotated Change:**  
  `As the expectation of $Y$ is \newX{$\Ex{Y} = 1/p \leq 1 + O(1/n^{1/4})$}\remX{Mathematical correction: For a geometric random variable with success probability $p \geq 1 - 3/n^{1/4}$, the expected number of trials is $\Ex{Y} = 1/p \leq 1/(1 - 3/n^{1/4}) \leq 1 + O(1/n^{1/4})$. The original text erroneously wrote $\frac{1}{1-p} = 1 + O(1/n^{3/4})$.}, it follows ...`
- **Rationale:** For a geometric variable with parameter $p$, $\Ex{Y} = 1/p$. With $p \geq 1 - 3/n^{1/4}$, this is bounded by $1 + O(1/n^{1/4})$.

- **Original Excerpt (Recurrence Solving):**  
  `F \LEQ \frac{1.5 n + O(n^{3/4}) }{p} \LEQ \pth{ 1 + \frac{6}{n^{3/4}}} \cdot \pth{1.5 n + O(n^{3/4}) } \LEQ 1.5n + O(n^{3/4}),`
- **Classification:** Mathematical Correction
- **Annotated Change:**  
  `F \LEQ \frac{1.5 n + O(n^{3/4}) }{p} \LEQ \newX{\pth{ 1 + \frac{4}{n^{1/4}}}} \cdot \pth{1.5 n + O(n^{3/4}) } \LEQ 1.5n + O(n^{3/4}),`
- **Rationale:** Corrected denominator exponent from $n^{3/4}$ to $n^{1/4}$, matching \Eqref{q-s-few-rounds}.

### 9. Theorem 3.6 Proof: Excising Dangling Wald Sentence & Completing Accounting
- **Original Excerpt:**  
  `using \Eqref{s-p-r-selection} Wald's identity yields $\Ex{C} \leq \Ex{Y}(1.5n + O(n^{3/4} \log n)) = 1.5n + 6n^{3/4} + O(n^{3/4} \log n) = 1.5n + O(n^{3/4} \log n) = 1.5n + o(n)$.`
- **Classification:** Mathematical & Pedagogical Cleanup
- **Annotated Change:**  
  `\remX{Corrected denominator: By \Eqref{q-s-few-rounds}, $1/p \leq 1 + 4/n^{1/4}$ for sufficiently large $n$, correcting the typo that wrote $n^{3/4}$ in the denominator.} \newX{The recurrence above cleanly accounts for the expected $1.5n + O(n^{3/4})$ comparisons performed in partitioning across all rounds. In addition, sorting the sample $\Sample$ takes $O(m \log m) = O(n^{3/4} \log n)$ comparisons per round, and sorting $S_m$ in the final successful round takes $O(|S_m| \log |S_m|) = O(n^{3/4} \log n)$ comparisons. Since the expected number of rounds is $\Ex{Y} = 1 + O(1/n^{1/4}) = O(1)$, summing the partitioning and sorting costs yields the claimed total of $1.5n + O(n^{3/4} \log n)$ expected comparisons.} \remX{Pedagogical note on recurrence vs.~Wald's identity: The dangling sentence invoking Wald's identity has been removed. The memoryless recurrence already accounts for all partitioning comparisons directly and intuitively without requiring stopping times or formal martingales.}`
- **Rationale:** Removed the disconnected Wald sentence. The proof now cleanly and rigorously accounts for all comparison components (partitioning via the recurrence, sample sorting, and final subset sorting).

### 10. Wald's Equation Theorem: Pedagogical Note
- **Original Excerpt:**  
  `\begin{theorem}[Wald's Equation] ... \Ex{\sum_{i=1}^Y X_i} = \Ex{Y} \Ex{X_1}. \end{math} \end{theorem}`
- **Classification:** Pedagogical Commentary
- **Annotated Change:**  
  `... \remX{Pedagogical note: While Wald's Equation is mathematically elegant and provides an alternative way to sum i.i.d.~rounds, introducing formal stopping times, filtrations, and measure-theoretic machinery adds unnecessary formalism for class notes. The memoryless recurrence for expected comparisons used in the proof of Theorem~3.6 is intuitive, elementary, self-contained, and pedagogically preferred for students.}`
- **Rationale:** Explicitly articulated why the elementary recurrence is pedagogically superior for class notes, while acknowledging Wald's equation as an elegant general tool.

---

## 7. Actionable Author Checklist

- [x] **Correct Geometric Expectation in Theorem 3.6**: Adopt $\Ex{Y} = 1/p \leq 1 + O(1/n^{1/4})$ in place of the erroneous $1/(1-p) = 1 + O(1/n^{3/4})$.
- [x] **Correct Denominator in Recurrence Expansion**: Update $\pth{1 + \frac{6}{n^{3/4}}}$ to $\pth{1 + \frac{4}{n^{1/4}}}$ in the calculation for $F$.
- [x] **Remove Dangling Wald Sentence**: Delete the unedited leftover sentence citing Wald's identity at the end of Theorem 3.6 proof, and replace it with the explicit sorting cost addition.
- [x] **Update Lemma 3.1 and Subsection 3.1.1 Cross-References**: Change `\lemref{estimate:chebyshev}` to `\lemref{Chebyshev-1}` where bounding the deviation of sample count $Y$.
- [x] **Refine Failure Threshold Notation in Subsection 3.2.1**: Replace $\Theta(n^{3/4})$ with $O(n^{3/4})$.
- [x] **Highlight Pairwise Independence**: Keep the explicit emphasis on pairwise independence in Remark 1.1 and Lemma 1.1.
- [x] **Address Zero Variance Edge Case**: Keep the inline note in Exercise 1.3 clarifying that standardized Chebyshev requires $\sigma_X > 0$.
- [x] **Adopt Low-Level Prose Fixes**: Apply the fixes for duplicate words ("each taking value", "we have that") and missing punctuation ("that is,").
