# Manuscript Review Report: Chapter 01 (Introduction to Randomized Algorithms)

## 1. Findings

### [Finding 1] Subscript Index Defect in 1D Random Walk Step
- **Severity & Type:** Confirmed Mathematical Bug / Notation Defect
- **Location:** Original: [intro.tex:L256-L257](file:///home/sariel/rand_alg/notes/01_intro/intro.tex#L256-L257) | Reviewed: [intro_reviewed.tex:L256-L258](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L256-L258)
- **Evidence & Impact:** In defining the random walk on the line, the rightward step from position $X_{i-1}$ was written as $X_i = X_{-1}+1$. The subscript index $i$ was omitted, producing an undefined constant index $-1$ rather than the preceding position $X_{i-1}$.
- **Action:** Corrected to $X_i = X_{i-1}+1$ using `\chgY` and added an explanatory `\remX`.

---

### [Finding 2] Self-Referential Coordinate Subscripts in 2D Grid Transition
- **Severity & Type:** Confirmed Mathematical Bug / Notation Defect
- **Location:** Original: [intro.tex:L298-L306](file:///home/sariel/rand_alg/notes/01_intro/intro.tex#L298-L306) | Reviewed: [intro_reviewed.tex:L298-L307](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L298-L307)
- **Evidence & Impact:** When specifying the four candidate locations for step $X_i$ given $X_{i-1} = (x_{i-1}, y_{i-1})$, the displayed coordinates were written as $(x_i-1, y_i)$, $(x_i+1, y_i)$, $(x_i, y_i-1)$, and $(x_i, y_i+1)$. Defining the candidate values of $X_i$ using its own coordinates $(x_i, y_i)$ is circular and an off-by-one index error.
- **Action:** Corrected coordinates to $(x_{i-1}-1, y_{i-1})$, $(x_{i-1}+1, y_{i-1})$, $(x_{i-1}, y_{i-1}-1)$, and $(x_{i-1}, y_{i-1}+1)$ originating from the previous location $X_{i-1} = (x_{i-1}, y_{i-1})$, accompanied by an explanatory `\remX`.

---

### [Finding 3] Duplicate Subsection Heading for Three-Dimensional Grid
- **Severity & Type:** Structural / Header Error
- **Location:** Original: [intro.tex:L322](file:///home/sariel/rand_alg/notes/01_intro/intro.tex#L322) | Reviewed: [intro_reviewed.tex:L324-L325](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L324-L325)
- **Evidence & Impact:** Section 2.2.3 was titled `\SubSubSection{Walk on the two dimensional grid}`, duplicating verbatim the heading of Section 2.2.2. However, the accompanying text explicitly analyzes the 3D lattice $\ZZ \times \ZZ \times \ZZ$ and its return probability $\Theta(1/n^{3/2})$.
- **Action:** Corrected heading to `\SubSubSection{Walk on the \chgY{two}{three} dimensional grid}` with an explanatory `\remX`.

---

### [Finding 4] One-Sided Error Probability Specification in Primality Theorem
- **Severity & Type:** Mathematical Precision / Technical Exposition
- **Location:** Original: [intro.tex:L364-L367](file:///home/sariel/rand_alg/notes/01_intro/intro.tex#L364-L367) | Reviewed: [intro_reviewed.tex:L366-L370](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L366-L370)
- **Evidence & Impact:** Theorem 2.4 stated: *"if $n$ is not prime, the algorithm would return `not prime' with probability half, if it is prime, it would return `prime'."* For randomized Monte Carlo primality testing (Miller--Rabin, Solovay--Strassen), prime inputs are recognized with probability $1$ (zero error), while composite numbers fail to be detected with probability *at most* $1/2$ (i.e. detected with probability *at least* $1/2$). Phrasing the composite case as "probability half" conflates an exact probability with an upper/lower bound.
- **Action:** Clarified using `\chgY`: *"if $n$ is prime, the algorithm always returns `prime'; if $n$ is not prime (composite), the algorithm returns `not prime' with probability at least $1/2$."* Added an explanatory `\remX`.

---

### [Finding 5] Garbled Sentence in Primality Decision Procedure
- **Severity & Type:** Grammar / Prose Defect
- **Location:** Original: [intro.tex:L372-L373](file:///home/sariel/rand_alg/notes/01_intro/intro.tex#L372-L373) | Reviewed: [intro_reviewed.tex:L375-L376](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L375-L376)
- **Evidence & Impact:** The amplification procedure read: *"Otherwise, we return the number of is a prime."*
- **Action:** Corrected using `\chgY` to *"Otherwise, we return that the number is prime."*

---

### [Finding 6] Missing Bibliographical Notes and Foundational References
- **Severity & Type:** Missing Content / Core User Requirement
- **Location:** Original: [intro.tex:L419-L421](file:///home/sariel/rand_alg/notes/01_intro/intro.tex#L419-L421) | Reviewed: [intro_reviewed.tex:L423-L469](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L423-L469)
- **Evidence & Impact:** The original manuscript contained no bibliographical notes section, concluding directly with `\ChapterEnd{}`. This caused an empty-bibliography build warning (`LaTeX Warning: Empty bibliography on input line 420`) and omitted historical credits for all core algorithms and paradigms presented in the introductory chapter.
- **Action:** Authored a comprehensive `\section{Bibliographical notes}` covering all topics in the chapter:
  1. The rotating coin puzzle and adversary games: Martin Gardner \cite{g-mg-79} and minimax principles \cite{mr-ra-95}.
  2. 2SAT randomized random walk vs. deterministic SCC: Papadimitriou \cite{p-ssta-91} and Aspvall, Plass, and Tarjan \cite{apt-ltat-79}.
  3. Lattice random walks, recurrence, and transience: P{\'o}lya \cite{p-uawbi-21} and Norris \cite{n-mc-98}.
  4. RSA and randomized/deterministic primality testing: Rivest, Shamir, and Adleman \cite{rsa-modsp-78}, Miller \cite{m-rhtp-76}, Rabin \cite{r-patp-80}, Solovay and Strassen \cite{ss-fmctp-77}, and Agrawal, Kayal, and Saxena \cite{aks-pp-04}.
  5. Minimum cut contraction: Karger \cite{k-gmcro-93} and Karger--Stein \cite{ks-namcp-96}.
  6. General randomized algorithm texts: Motwani and Raghavan \cite{mr-ra-95} and Mitzenmacher and Upfal \cite{mu-pcrpt-17}.
  Added canonical entries to both [intro_reviewed.bib](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.bib) and the master bibliography [`~/papers/bib/geometry.bib`](file:///home/sariel/papers/bib/geometry.bib).

---

## 2. Significant Revisions

- **Tracked Technical Changes:**
  - 1D random walk step: `\chgY{$X_i = X_{-1}+1$}{$X_i = X_{i-1}+1$}` ([intro_reviewed.tex:L256-L258](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L256-L258)).
  - 2D random walk transitions: coordinate indices changed from $(x_i \pm 1, y_i)$ to $(x_{i-1} \pm 1, y_{i-1})$ ([intro_reviewed.tex:L298-L307](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L298-L307)).
  - 3D random walk header: `\chgY{\SubSubSection{Walk on the two dimensional grid}}{\SubSubSection{Walk on the three dimensional grid}}` ([intro_reviewed.tex:L324-L325](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L324-L325)).
  - Primality theorem: clarified one-sided error lower bound ($\geq 1/2$) on composite numbers ([intro_reviewed.tex:L366-L370](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L366-L370)).
  - Primality decision text: `\chgY{the number of is a prime}{that the number is prime}` ([intro_reviewed.tex:L375-L376](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L375-L376)).
  - Section 3: added comprehensive `\section{Bibliographical notes}` ([intro_reviewed.tex:L423-L469](file:///home/sariel/rand_alg/notes/01_intro/intro_reviewed.tex#L423-L469)).

- **Silent Minor Corrections:**
  - "algorithms that makes random decision" $\to$ "algorithms that make random decisions".
  - "variables, such that their value is taken from some random distribution" $\to$ "variables whose values are drawn from some probability distribution".
  - "let start with an example" $\to$ "let us start with an example".
  - "The adversary has a equilateral triangle" $\to$ "The adversary has an equilateral triangle".
  - "which are, numbered by, I don't known, 1,2,3" $\to$ "which are numbered, say, by $1, 2, 3$".
  - "adversary set each" $\to$ "adversary sets each".
  - "at vertex $1$ and $3$" $\to$ "at vertices $1$ and $3$".
  - "the game stop" $\to$ "the game stops".
  - "as she seems fit" $\to$ "as she sees fit".
  - "player randomly chooses a number among $1,2,3$" $\to$ "player randomly chooses a vertex among $1, 2, 3$ at every round and flips the coin at that vertex".
  - "other coin is the other side up" $\to$ "remaining coin has the opposite side up".
  - "geometric variable with geometric distribution with probability $1/3$" $\to$ "distributed geometrically with parameter $1/3$".
  - "one of these brain teasers" $\to$ "one of those brain teasers".
  - "analyzing algorithm" $\to$ "analyzing algorithms".
  - "worst case analysis" $\to$ "worst-case analysis".
  - "3 coins example" $\to$ "three-coins example".
  - "algorithms arises from derandomizing the randomized algorithms, and this are the only algorithm" $\to$ "algorithms arise from derandomizing randomized algorithms, and these are the only algorithms".
  - "power aga\-inst" $\to$ "power against".
  - "assumes that is given some distribution" $\to$ "assumes that one is given some distribution".
  - "problem that it is hard" $\to$ "problem is that it is hard".
  - "real world inputs" $\to$ "real-world inputs".
  - "which are \si{ored} together" $\to$ "which are \si{or}ed together".
  - "what values has to be assigned" $\to$ "what values have to be assigned".
  - "strong connected components" $\to$ "strongly connected components".
  - "and flip the value assigned to variable" $\to$ "and flips the value assigned to the variable".
  - "if the algorithm chosen" $\to$ "if the algorithm chose".
  - "the algorithm guess the right variable" $\to$ "the algorithm guesses the right variable".
  - "player randomly choose" $\to$ "player randomly chooses".
  - "visits the origin infinite number of times" $\to$ "visits the origin an infinite number of times".
  - "expected number of times this walk visits the origin $\sum...$" $\to$ "expected number of times this walk visits the origin is $\sum...$".
  - "the number of bits its uses" $\to$ "the number of bits it uses".
  - "and returns the smallest cut" $\to$ "and return the smallest cut".

---

## 3. Verification

- **Build Engine & Command:** `/home/sariel/bin/l -s --no-env intro_reviewed.tex`
- **Compiler Outcome:** **PASS** (`✔ No errors/alerts/warnings.` — 0 Errors, 0 Alerts, 0 Warnings, 0 Whatevers).
- **Bibliography Verification:** All 14 citations resolved cleanly with complete entries typeset in `junk/intro_reviewed.bbl` and `junk/intro_reviewed.pdf`:
  - `aks-pp-04` (Agrawal, Kayal, and Saxena 2004)
  - `apt-ltat-79` (Aspvall, Plass, and Tarjan 1979)
  - `g-mg-79` (Gardner 1979)
  - `k-gmcro-93` (Karger 1993)
  - `ks-namcp-96` (Karger and Stein 1996)
  - `m-rhtp-76` (Miller 1976)
  - `mr-ra-95` (Motwani and Raghavan 1995)
  - `mu-pcrpt-17` (Mitzenmacher and Upfal 2017)
  - `n-mc-98` (Norris 1998)
  - `p-ssta-91` (Papadimitriou 1991)
  - `p-uawbi-21` (P{\'o}lya 1921)
  - `r-patp-80` (Rabin 1980)
  - `rsa-modsp-78` (Rivest, Shamir, and Adleman 1978)
  - `ss-fmctp-77` (Solovay and Strassen 1977)
- **Book Mode Verification:** Master book (`book.tex`) compiled via `/home/sariel/bin/l -u -s book.tex` with 0 Errors.
