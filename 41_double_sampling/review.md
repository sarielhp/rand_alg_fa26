# Review of Double sampling

All line numbers below refer to the original [double_sampling.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/41_double_sampling/double_sampling.tex). The original and shared files are unchanged.

## What was done

- Created an [annotated review copy](/home/sariel/papers/teach/26/fa26_rand_alg/notes/41_double_sampling/double_sampling_review.tex), with 19 tracked prose spans (`\chgY`) and 16 remarks (`\remX`). Mathematical displays retain the original text, with remarks pointing to the corrections below.
- Added the requested approximately one-page subsection, **“Double sampling beyond range spaces,”** under a new Bibliographical notes section. It covers ghost samples, independent holdout validation, Efron–Stein resampling, matrix symmetrization, and a single-sample prophet inequality. A [local bibliography](/home/sariel/papers/teach/26/fa26_rand_alg/notes/41_double_sampling/double_sampling_review.bib) supplies all eight cited works, including the original chapter citations.
- Read every definition, lemma, proof, and the three included concentration statements. Checked the main theorem end to end, then made separate simplification, notation, and writing passes. No mathematical proof was merely skimmed. Other chapters were consulted only for definitions; the full book was not reviewed.
- Three fresh-context reviewers used the inherited session model with requested **high** reasoning effort. The collaboration interface did not expose a more specific model identifier. Two proof reviewers cross-checked each other's findings and repairs; a third audited rendered notation, writing, and the added bibliographical material. No lower-effort override was used.
- Verification: all six E findings, four G findings, and three S proposals received independent-agent checking. All five N findings received a second check against the definitions and macro expansions. The final added prose was independently checked after tightening the matrix-independence and prophet tie-breaking assumptions. One preliminary objection to the Chernoff range in the moment calculation was withdrawn: the exact Chernoff exponent justifies those terms. It is not reported as an error.
- Computations: exact integer/Rational Ruby calculations checked the discrepancy counterexample and the false binning step; elementary numerical checks confirmed the growth and logarithm errors. Analytic checks establish the full scopes of the repairs, rather than relying on numerical tests.
- Build verification is recorded at the end of this report.

## Summary of findings

**6 errors, 4 gaps, 3 simplifications, 5 notation findings, and 4 writing/addition items.** The discrepancy lemma is false with its stated constant. The main epsilon-net theorem survives the proposed repairs with its stated sample-size constants; a factorial-moment argument substantially shortens its proof and makes the preceding moment lemma unnecessary for that argument.

### Errors

- **E1**, lines 147–158, `double:sample:2:sets`: the claimed discrepancy bound is false (confidence: high).
- **E2**, lines 194–253: the signed-discrepancy proof uses the wrong mean, loses factors, and does not condition correctly (confidence: high).
- **E3**, lines 340–346, `two:samples:gen`: the displayed tail-binning chain is false, although the lemma can be repaired (confidence: high).
- **E4**, lines 393–399: the growth bound by (n^d) fails already for (d=1) (confidence: high).
- **E5**, lines 522 and 546–571, `V:C:e1`: the ghost-sample reduction contains mismatched variables, thresholds, and inequalities (confidence: high).
- **E6**, lines 660–698: the final substitution, logarithm split, and one inequality direction are incorrect (confidence: high).

### Gaps

- **G1**, lines 165–253: neither discrepancy proof treats the arbitrary fixed subset in the statement (confidence: high).
- **G2**, lines 426–458, `two:samples`: three hypotheses required by the invoked bounds are unavailable (confidence: high).
- **G3**, lines 50, 63, 147, 426–436, and 479–486: parameter and independence conventions need completion, especially positive failure probability and dimension zero (confidence: high).
- **G4**, lines 609–645, `e2`: justify conditioning on the entire union, and correct the scope of the trace-count and small-trace assertions (confidence: high).

### Simplifications

- **S1**, lines 80–137: two objectwise conditional probabilities prove the first lemma and supply G4's stronger conditioning.
- **S2**, lines 320–387: an exponential-moment argument gives a stronger moment bound with substantially weaker assumptions.
- **S3**, lines 409–458: factorial moments give a stronger expected-growth bound directly, bypassing the moment machinery.

### Notation

Five meaning-preserving findings: **1 clash, 4 definition issues, 0 splits, 0 convention violations**; ten affected tokens/words. Technical notation problems are included in E2, E5, and G2 rather than counted again.

- **N1**, lines 612–618: `\SetB` renders as (T), colliding with the second sample. Replace its five occurrences here by (B); leave the sample (T) unchanged.
- **N2**, lines 110 and 114: both undefined product limits (b) should be (m).
- **N3**, line 289: replace `\Sample_2` by `\Sample`; the single-set lemma defines only one sample.
- **N4**, line 499: replace “probability” by “event” when defining `\Event_1` (tracked in the review copy).
- **N5**, [def_Chernoff_simplified.tex:10](/home/sariel/papers/teach/26/fa26_rand_alg/notes/fragment/def_Chernoff_simplified.tex:10): replace `1-p` by `1-p_i`. The shared original fragment is not edited.

The audit checked macro expansions, local scopes, definitions and uses, and the included fragments. Legitimate reuse of (m,X,T) in separate proofs is retained. The script growth function and the explicit upper-bound function are distinct, not inconsistent names for one object.

Proposed notation rules:

- Established: event symbols denote events; probability operators turn them into numbers.
- Established: distinguish the script growth function from its explicit expected-growth bound.
- Proposed locally: reserve (T) for the ghost sample and (B) for a trace in the net proof.
- Proposed locally: use (K) for the signed proof's support count, and a fresh symbol for any duplicated-universe sample.
- Check rendered symbols, not just macro spellings; do not change the shared `\SetB` macro globally.

### Writing and requested addition

- **W1**, lines 142–143: “three proofs” becomes “two proofs”; both original proof bodies are retained for review.
- **W2**, lines 404–406 and 470–473: add explicit prose attribution to Har-Peled and to Haussler and Welzl, preserving the citation keys and avoiding annotations in theorem headings.
- **W3**, before line 709: add the requested bibliographical subsection with verified author names, dates, and primary references; distinguish related resampling and validation methods from the exact ghost-sample argument.
- **W4**, lines 282–283, 312, and 470–471: clarify that the sample misses every object in the range, repair the introductory grammar, and state directly that each element has weight one. These preserve the mathematical content.

## Details and repairs

### E1, E2, G1. Discrepancy: counterexample and complete repair

Take 1,000 equally weighted objects, (ho=100), (arepsilon=2/5), and the fixed subset equal to the whole ground set. The two sample sizes are independent (operatorname{Bin}(1000,1/10)) variables. Then

\[
\Pr(|X-Y|>40)=0.00254927095158116\ldots
>3e^{-8}=0.00100638788370754\ldots.
\]

The contradiction was independently checked using exact arithmetic. The following Ruby snippet reproduces it; every assertion succeeds:

```ruby
n = 1000
weights = [9**n]
n.times { |k| weights << weights[-1] * (n - k) / ((k + 1) * 9) }
total = 0
prefix = weights.map { |weight| total += weight }
numerator = 2 * (41..n).sum { |k| weights[k] * prefix[k - 41] }
denominator = 10**(2 * n)
raise unless weights.sum == 10**n
raise unless 500 * numerator > denominator
term = Rational(1)
series = term
1.upto(12) { |k| term = term * 8 / k; series += term }
raise unless series > 2000
puts Rational(numerator, denominator).to_f
```

Thus the true probability exceeds (1/500), whereas (3e^{-8}<3/2000).

For a repair, explicitly assume independent samples, (ho>0), and (0<arepsilonle1). Write (q_i=hoomega_i/W). Restrict the signed variables to the fixed subset (B): outside (B), set them to zero. Let (K) count nonzero variables and (Y) be their sum. Then

\[
\mathbb EK=2\sum_{i\in B}q_i(1-q_i)\le2\rho.
\]

For the entire universe the exact mean is (2ho-2sum_iq_i^2), not (2ho). A Chernoff argument using the upper bound on the mean gives

\[
\Pr(K>2(1+\varepsilon)\rho)\le e^{-\rho\varepsilon^2/2}.
\]

Conditional on the exact nonzero support, the signs are independent and fair. For (K>0), the cited sign bound gives (2e^{-(arepsilonho)^2/(2K)}), with no additional factor two in the exponent. For (K=0), the discrepancy event is impossible. Therefore

\[
\Pr(|Y|>\varepsilon\rho)
\le e^{-\rho\varepsilon^2/2}
   +2e^{-\rho\varepsilon^2/[4(1+\varepsilon)]}
\le3e^{-\rho\varepsilon^2/8}.
\]

This establishes a corrected statement. It also resolves the unsupported conditioning, the second `\Sample_1` at line 232, the undefined `\xi` at line 253, and the collision between the fixed set (rendered (T)) and scalar support count (T). These should be repaired together, not as isolated typographical substitutions.

The first proof supplies only a weaker estimate, even for the whole universe. For a general (B), its correct center is (mu_B=sum_{i\in B}q_i\le\rho), not (ho). Retaining two proofs requires redoing that concentration step; retaining only the corrected sign proof is simpler. This lemma is not used in the final epsilon-net proof.

### E3, S2. Repair or replace the moment calculation

For (X\sim\operatorname{Bin}(32,1/2)), (m=16), and (eta=1), the first two terms of the middle tail sum are

\[
16+32\Pr(X\ge16)=\frac{4595507491}{134217728}
=34.2391989455\ldots>32.
\]

The remaining terms are identical on both sides of the claimed inequality. A minimal repair is to remove that middle sum and partition directly into (X<2m) and (jm\le X<(j+1)m), (j\ge2). This works for real (m>0), too. The subsequent Chernoff estimates are valid; the lemma's conclusion is not disproved by this error.

A shorter replacement proves

\[
\mathbb Ef(X)\le\alpha(2m)^\beta
\quad\text{for }\alpha\ge0,\quad\beta>0,\quad m\ge\beta/2.
\]

Set (u=\beta/(2m)\le1). Maximizing (x^\beta e^{-ux}) gives (x^\beta\le(\beta/(eu))^\beta e^{ux}). Independence and (e^u-1\le2u) on ([0,1]) give

\[
\mathbb Ee^{uX}\le\exp(m(e^u-1))\le e^{2mu}=e^\beta.
\]

Multiply to obtain the claimed bound. This removes the tail calculation and the discussion of the constant 16. It does not, by itself, repair the small-sample problem in G2.

### E4, G2, S3. Growth and factorial moments

Define the extremal growth function for VC dimension **at most** (d); otherwise it is undefined when (n<d), sizes used by the later random experiment. Use (\binom ni=0) for (i>n). Then (G_d(n)=\sum_{i=0}^d\binom ni), but (G_1(n)=n+1>n). Delete the last bound in line 399.

The expected-growth proof has three independent problems:

1. Its polynomial majorant is justified only for realized size at least (2d); in particular (G_d(0)=1>f(0)=0).
2. Applying the stated moment lemma to a sample of mean (2m) requires (m\ge8d), not merely (m\ge d).
3. Its chosen (\alpha=2(e/d)^d) is below one already at (d=4), contrary to that lemma's assumptions.

The duplicated-universe passage also shadows the first sample and introduces an undefined literal (T), although `\SampleA` renders as (\mathsf R'). If retained, use a fresh sample (Q) and the identity (|Q|=|\mathsf R|+|\mathsf R'|).

The recommended replacement avoids all these issues. Let (K) be the sum of the two sample sizes. It is a sum of independent Bernoulli indicators of total mean (lambda=2m). Then

\[
\mathbb E\binom Ki
=\sum_{|A|=i}\prod_{j\in A}p_j
\le\frac{\lambda^i}{i!},
\qquad
\mathbb EG_d(K)\le\sum_{i=0}^d\frac{(2m)^i}{i!}.
\]

For (d\ge1) and (m\ge d), put (u=d/(2m)\le1). Thus

\[
\sum_{i=0}^d\frac{(2m)^i}{i!}
\le u^{-d}\sum_{i=0}^d\frac{(2mu)^i}{i!}
\le u^{-d}e^{2mu}
=\left(\frac{2em}{d}\right)^d.
\]

This is stronger than the existing (4(4em/d)^d) bound, includes small and zero realized sizes, and works for unequal object weights. It leaves the existing theorem constants available unchanged. For (d=0), the growth function and its expectation are one.

The deterministic growth estimate also has a short proof: for (n\ge d\ge1),

\[
(d/n)^d\sum_{i=0}^d\binom ni\le(1+d/n)^n\le e^d,
\qquad
\binom nd=\prod_{j=0}^{d-1}\frac{n-j}{d-j}\ge(n/d)^d.
\]

Consequently the factor two in its upper bound is unnecessary.

### G3. Parameter conventions

Require a positive target size and explicitly independent samples. The introduction already suggests independence, so this is primarily statement hygiene. The substantive omissions are (0<\varphi<1), required by the logarithm, and the use of formulas dividing by (d) without treating dimension zero.

For (d=0), two distinct ranges would shatter a singleton where they differ; hence there is at most one distinct range. If that range is heavy, its miss probability is at most (e^{-\varepsilon m}\le\varphi) by the first sample-size threshold. Then the remaining proof may assume (d\ge1). State that the expected-growth lemma uses (d\ge1) as well.

The sampling model imposes (m<n) in the unweighted setting. If the requested bound reaches (n), take the full ground set instead. This is an explicit extension/convention, not a counterexample to a theorem about existing (m)-samples. Treat an empty ground set separately rather than dividing by its size.

### E5. Ghost-sample reduction

At line 522 the expectation should involve the random set (T), not the fixed ground set. In the proof, condition on a realized failed (N), choose a heavy witness range for that realization, and draw (T) independently. Writing (X=|r\cap T|) and (\mu=\mathbb E[X\mid N]\ge\varepsilon m),

\[
\Pr(X<\varepsilon m/2\mid N)
\le\Pr(X<\mu/2\mid N)
\le e^{-\mu/8}
\le e^{-\varepsilon m/8}<1/2.
\]

Averaging over failed (N) gives (\Pr(E_2)\ge\Pr(E_1)/2), also when (\Pr(E_1)=0). This avoids the original undefined conditional ratio in that case.

Exact local corrections: line 547 uses (\ge\varepsilon n), not (>\varepsilon n); line 550 uses (\varepsilon m/2), not (\varepsilon n/2); line 556 uses the strict failure event (X<\varepsilon m/2); line 562 replaces equality by inequality. The original event comparison can fail at an atom: with (n=128,m=64,\varepsilon=1) and the full ground set as witness, (\Pr(X\le32)>\Pr(X<32)).

### S1, G4, N1. Conditioning on the full union

For per-object inclusion probability (q_i),

\[
\Pr(i\in R_1\mid i\in R_1\cup R_2)=\frac1{2-q_i}\ge\tfrac12,
\quad
\Pr(i\in R_1\setminus R_2\mid i\in R_1\cup R_2)
=\frac{1-q_i}{2-q_i}\le\tfrac12.
\]

Conditioning on any fixed realization of the entire union factors objectwise, so it preserves independence across the objects' membership pairs. Multiply the relevant probabilities to prove both bounds in the first lemma and the conditional bound needed in the last claim.

In that claim, rename the trace to (B). The five affected `\SetB` occurrences are its definition at line 612, its cardinality at 613, two occurrences at 617, and one at 618. The symbol (B) is free in this scope. For a fixed union (S=s) and trace (B\subseteq s),

\[
\Pr(B\subseteq T,\ B\cap N=\varnothing\mid N\cup T=s)
\le2^{-|B|}.
\]

At line 611 there are **at most** (G_d(|s|)) traces. At lines 613–614, a trace smaller than (\varepsilon m/2) cannot witness (E_2'); it does not prevent another trace from witnessing the event. These are substantive scope corrections, not just grammar. Finally use (|N\cup T|\le|N|+|T|) and monotonicity of the growth function before invoking the expected-growth lemma.

### E6. Final constants survive the algebra repairs

Substituting the definition of the expected-growth bound gives prefactor (2\cdot4=8), not 16. One may retain 16 as a sufficient upper bound, but the first equivalence must then be replaced by a sufficient-condition statement.

With 16, the correct logarithmic split is

\[
\left(\frac{\varepsilon m}{8}-4-d\lg(4e)\right)
+\left(\frac{\varepsilon m}{8}-\lg\frac1\varphi\right)
+\left(\frac{\varepsilon m}{4}-d\lg\frac md\right).
\]

The original split is larger by (d\lg d). For (d\ge1), the correct comparison is

\[
-4-d\lg(4e)\ge-4-4d\ge-8d\ge-\varepsilon m/8.
\]

The second bracket is nonnegative by the first sample-size threshold. For the last bracket set (t=16/\varepsilon\ge16) and (x=m/d\ge t\lg t). At (x_0=t\lg t),

\[
\varepsilon x_0/4=4\lg t\ge\lg(t\lg t)=\lg x_0.
\]

The function (\varepsilon x/4-\lg x) is increasing for (x\ge x_0\ge64/\varepsilon). Hence the last bracket is nonnegative throughout the required range. This completes the repaired theorem with the original constants.

## Bibliographical checks

The addition uses primary sources and explicitly distinguishes several related mechanisms. It does not claim that every use of two samples is the same theorem.

- Vapnik and Chervonenkis (1971), Sections 3–4: doubled-sample comparison and conditioning on the combined sample; [original paper](https://courses.grainger.illinois.edu/ece544na/fa2014/vapnik71.pdf). Haussler and Welzl (1987): [epsilon-nets and range searching](https://doi.org/10.1007/BF02187876).
- Holdout validation: the independence argument is conditional on training information; bounded loss and independent identically distributed validation observations are explicit. The adaptive-reuse reference is Dwork and five coauthors' [2015 Science paper](https://doi.org/10.1126/science.aaa9375), cited as Dwork `\etal`.
- Efron and Stein: the [1981 paper](https://doi.org/10.1214/aos/1176345462) is described as a related coordinate-resampling variance method, not the origin of whole-sample symmetrization.
- Rudelson and Vershynin: [2008 journal paper](https://doi.org/10.1002/cpa.20227), independent-copy symmetrization in the author-hosted paper's tail argument. Candès and Recht: [matrix-completion paper](https://arxiv.org/pdf/0805.4471), Section 6, proof of Lemma 4.4, introduces an independent copy and random signs. No recovery guarantee without the respective structural assumptions is asserted.
- Rubinstein `\etal`: [ITCS 2020 paper](https://doi.org/10.4230/LIPIcs.ITCS.2020.60), Definition 1 and Theorem 2 establish the maximum-sample threshold and one-half guarantee. Section 2 specifies random tie labels; Section 3 exchanges the roles of two independent draws per distribution. The guarantee averages over both offline samples and arriving values.

## Build verification

The [review PDF](/home/sariel/papers/teach/26/fa26_rand_alg/notes/41_double_sampling/double_sampling_review.pdf) was built with XeLaTeX through the project wrapper, leeni 1.0.53:

```text
rtk proxy /home/sariel/bin/l -no-env -f --all --no-color --no-link double_sampling_review.tex
```

All builds ran in an isolated directory under `/tmp`, with the existing shared styles/fragments and the chapter's relative `styles` link preserved. No build auxiliaries or local `junk/` directory were created in the repository; the repository-wide cleanup tool was therefore unnecessary. No generated files were committed.

The unmodified original initially failed because `-no-env` could not find its external `shortcuts.bib`. For a diagnostic comparison, the scratch copy of the original was then supplied with the local bibliography under its own job name; the original source remained byte-for-byte identical. That supplemented baseline built with **0 errors, 11 overfull-box alerts, 2 warnings, and 1 minor hyperref diagnostic**.

The review built with **0 errors, 10 overfull-box alerts, 2 warnings, and 2 minor diagnostics**. The ten large overfull boxes and both ordinary warnings match the baseline; one baseline overfull box disappeared after the prose edit. The review adds a **1.97 pt** overfull box in tracked prose at review line 301. The other minor diagnostic is the pre-existing mathematical chapter-section title in a PDF bookmark. No undefined references or citations were reported; PDF text extraction found no unresolved `??` markers. The new bibliographical prose fits on one page, excluding its headings and review remark.

Only standalone mode was compiled; a full-book build was not run. Original source SHA-256 after review: `d23ef8ac991a6e951437b337f907e8d8165baee39ac6c574e912eda633e6d095` (unchanged).
