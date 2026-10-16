# Review of “Approximating the Number of Distinct Elements in a Stream”

Locations below refer to the original [freq_est_2.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/29_freq_est_2/freq_est_2.tex), not the annotated copy.

## What was done

- Created [freq_est_2_review.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/29_freq_est_2/freq_est_2_review.tex): 4 tracked prose edits (`\chgY`), 19 notes (`\remX`), and minor silent copyedits. Mathematical replacements are proposals in notes and this report; the original equations remain visible.
- Read the whole chapter, its four imported prerequisite statements, and relevant shared macros. Checked every local proof, including the final algorithm end to end; performed separate simplification, notation, and writing passes. Proofs of results in other chapters were outside scope.
- Verification: **independent-agent** for all six reported errors/gaps and their repairs, the three simplifications, and substantive notation/writing corrections. The explicitly declared density abuse was classified as writing, and the suspected median-aggregation defect was rejected. The coordinating reviewer also checked the calculations.
- Models: inherited GPT-6-based model; exact resolved model identifier unavailable. Correctness, notation, refutation, and mathematical writing reviewers were explicitly requested at **high** effort. Coordinator effort was not exposed. No lower-effort override was requested.
- Exact Ruby arithmetic checked 40 minimum-moment/variance cases, 9,900 reciprocal-conversion endpoints, all 49 affine-hash seeds over a seven-element field, and the binomial counterexample below. These finite checks supplement the algebraic arguments, rather than prove their generality.
- Build: original and review compiled with **0 errors, 8 existing overfull-box alerts, and 2 existing overfull-box warnings**; no new diagnostics or unresolved references/citations. The nine-page [review PDF](/home/sariel/papers/teach/26/fa26_rand_alg/notes/29_freq_est_2/freq_est_2_review.pdf) is included.

## Summary of findings

**4 errors, 2 gaps, 3 simplifications, 4 notation findings, and 5 writing findings.** One error is in an imported prerequisite statement. The main repair is to cap the sampling probability and handle exact sampling separately; the final scale-selection proof also needs a witness satisfying the estimator's promise. The claimed asymptotic result survives the repairs below.

### Errors

- **E1**, lines 43–44 — Uniform marginals alone do not imply the minimum's distribution or moments; add independence (confidence: high).
- **E2**, lines 328–329 — The prescribed sampling probability exceeds one at small scales, including the final algorithm's first level (confidence: high).
- **E3**, line 348 — Chebyshev's bound has an erroneous factor of `\eps^2` instead of its reciprocal (confidence: high).
- **E4**, [imported Chebyshev fragment](/home/sariel/papers/teach/26/fa26_rand_alg/notes/fragment/def_Chebyshev.tex:4), lines 4–8 — The standardized statement is false for zero variance (confidence: high).

### Gaps

- **G1**, lines 402–417 — The final proof does not identify a guaranteed numerical level within the earlier lemma's promise; use the first scale at least the distinct count (confidence: high).
- **G2**, lines 241–244 and 395–399 — Efficient evaluation of the random bits does not establish the claimed small seed storage; specify a finite pairwise-independent hash implementation (confidence: high).

### Simplifications

- **S1**, lines 61–139 — Obtain the minimum's density and both moments from its survival function, eliminating the delicate point-probability proof and guessed antiderivatives.
- **S2**, lines 276–309 — Sum variances of pairwise-independent indicators instead of expanding the second moment.
- **S3**, lines 183–204 — Bound reciprocal relative error in one calculation instead of the long inequality chain.

### Notation

Counts: **1 clash, 1 split, 0 convention violations, 2 definition issues**; these count findings, not occurrences. All four repairs were independently verified. The highest-payoff changes are defining the distinct-value set, separating the basic and amplified estimates, and using one sample typeface.

- **N1**, definition, lines 233–238 — Define `S=\distinctX{\STRM}` explicitly; later sums must range over distinct values.
- **N2**, split, lines 250–251 — Replace the two `\Sample` occurrences by `R`, matching the nine ordinary-`R` occurrences that follow.
- **N3**, clash, lines 130 and 149–169 — Use `Y` consistently for the basic minimum and `X` for the amplified estimate; also correct the two stray `X` symbols in the variance identity.
- **N4**, definition, lines 143–147 — Introduce the stream items and length before first use.

### Proposed notation rule sheet

- Established: `\STRM` is the stream, and `\strm_i` is its ith item.
- Proposed clarification: `S=\distinctX{\STRM}` is its set of distinct values; each sum over `S` counts a value once.
- Proposed consistency: `Y` is one minimum estimator; `X` is the amplified estimate in Section 1.
- Proposed consistency: ordinary `R` is the sampled set; in Section 2, `X=|R|` is its size.
- Established: retain `\Prob`, `\Ex`, `\Var`, `\eps`, and `\BadProb`. Local reuse of `N`, `M`, and `\nu` in separate scopes needs no global renaming.

### Writing

- **W1**, lines 50–80, 95, 111 — Replace the acknowledged density/point-mass abuse by density notation; fill in the missing argument of the CDF.
- **W2**, lines 213–219 — State the relative-error and failure guarantees in the idealized lemma, whose current statement only says “estimate.”
- **W3**, lines 338–365 and 386–391 — Use explicit unconditional success events for overflow and for the median of the numerical outputs.
- **W4**, lines 39, 148–149, 249 — Add a short roadmap and clarify the update sentence; tracked prose edits are in the copy. A note proposes the mathematical punctuation fix `[0.1]` → `[0,1]`.
- **W5**, original build — Ten overfull lines need display breaks or other local layout repairs; see build details.

## Details

### E1. Independence is necessary

For `u=2`, take `X_1=X_2=U` with `U` uniform on `[0,1]`. Every stated marginal hypothesis holds, but `Y=U` and `E[Y]=1/2`, not `1/3`. Replace “u random variables uniformly distributed” by “u independent random variables uniformly distributed” and specify `u>=1`. The perfectly random hash model later in the chapter supplies this independence for distinct keys.

### E2. Cap the sampling probability

At `N=2`, `eps=1/8`, and the chosen `c=32`, the formula gives `p=1024`. These parameters satisfy the stated parameter ranges, and `N=2` is the first dyadic level.

Set `p=min{1,32/(N eps^2)}`. When `p=1`, retain distinct elements until the count exceeds `8N`; then the overflow declaration is certainly true. Otherwise return the exact count. This branch stores at most `floor(8N)+1=O(eps^-2)` values because `N<=32/eps^2`. Treat it directly, without division by a zero standard deviation. When `p<1`, the corrected Chebyshev proof applies. G2 gives a finite implementation with rounded probabilities.

### E3. Correct Chebyshev's factor

The expression at line 348 must be

\[
\frac{\operatorname{Var}(X)}{\epsilon^2(\mathbb E X)^2},
\]

not `eps^2 Var(X)/(E[X])^2`. With `N=4096`, `eps=1/8`, `p=1/2`, and `nu=1025>N/4`, independent sampling gives `X~Binomial(1025,1/2)`. The exact tail is approximately `0.00006255844823`, exceeding the printed bound `1/65600 ≈ 0.00001524390244`. The corrected bound is `64/1025<1/8`; thus `c=32` remains sufficient.

Reproduce with this exact-arithmetic Ruby command (the decimals are only output formatting):

```sh
rtk proxy ruby -e 'u=1025; e=Rational(1,8); b=1; tail=0; (0..u).each { |k| tail+=b if (2*k-u).abs>e*u; b=b*(u-k)/(k+1) if k<u }; p=Rational(tail,2**u); puts "counterexample=#{p>e**2/u}"; puts [p.to_f,(e**2/u).to_f,(1/(e**2*u)).to_f]'
```

Output: `counterexample=true`, followed by `6.255844823287766e-05`, `1.524390243902439e-05`, and `0.0624390243902439`.

### E4. Zero variance in the imported statement

The fragment permits `X=0` almost surely and `t=2`. Its event `|X-mu_X|>=t sigma_X` then has probability one, while its purported upper bound is `1/4`. Require `0<Var(X)<infinity`, or state the more robust version

\[
\Pr(|X-\mathbb E X|\ge a)\le \operatorname{Var}(X)/a^2,
\qquad a>0,
\]

for finite variance. The latter includes deterministic variables. The shared fragment was not edited; a review note appears at its inclusion site, original line 438.

### G1. Choose a valid stopping witness

The printed `N_i/4 <= F_0 <= 2F_0` does not ensure a numerical answer. Nor can the guarantee at level `M` be invoked merely because `N_M>=n`: a small distinct count may violate its premise `F_0>N_M/4`.

For a nonempty stream and `n>=2`, put `nu=F_0` and choose

\[
i_* = \min\{i:N_i\ge\nu\}.
\]

This index exists, and `nu<=N_{i_*}<=2nu`, including `nu=1`. Every `j<=i_*` therefore satisfies `nu>N_j/4`. Give each level failure budget `delta/M`; a union bound shows that all outputs through `i_*` are correct with probability at least `1-delta`. On this event, the answer at `i_*` cannot be an overflow declaration, and any earlier numerical answer is accurate. Hence the first numerical answer is accurate. No guarantee for larger, out-of-promise levels is needed.

Take `delta=n^{-a}` for any fixed desired `a>0`. Then `log(M/delta)=O(log n)` and total space is `O(eps^-2 log^2 n)` words. Return zero for an empty stream, and count exactly when `n=1`; otherwise `M=0` at `n=1` leaves the specified algorithm with no output. These repairs also avoid taking a minimum over an empty stream in Section 1.

### G2. Specify the seed and the actual sampling probability

The sentence “we can compute B_i efficiently” does not bound the space needed to retain the random function. For the final algorithm, choose a prime `n<=q<2n`, for `n>=2`, and choose independent uniform `a,b` in the field of size `q`. Map a universe value `j` to `j-1`, and define

\[
p_0=\min\{1,32/(N\epsilon^2)\},\quad
k=\lceil qp_0\rceil,\quad
B_j=\mathbf1[(a(j-1)+b\bmod q)<k].
\]

The included polynomial-hashing theorem gives pairwise independence. The actual success probability is `p'=k/q`: use it in `T=p'N` and in the estimate `|R|/p'`. The seed and threshold occupy constantly many `O(log n)`-bit words.

If `p_0<1`, then `p'>=p_0`, preserving the concentration bound. At every dyadic scale used by the final algorithm, `N<2n`, so `p'N<=32/eps^2+N/q<32/eps^2+2`; the sample cap still costs `O(eps^-2)` words. Under the single-level promise, the analogous bound uses `N<4n`. If `p_0=1`, use the exact branch from E2. State that space is measured in words, with ordinary arithmetic on these stored integers, and that repetitions use independently chosen seeds. This supplies the missing implementation rather than assuming an oracle for the bits.

### S1. Survival probabilities give the density and moments

Under E1's repaired hypotheses, for `0<=t<=1`,

\[
\Pr(Y>t)=(1-t)^u,\qquad F_Y(t)=1-(1-t)^u.
\]

Differentiation gives `f_Y(t)=u(1-t)^{u-1}` on `(0,1)` and density zero outside `[0,1]`. Tail integration gives

\[
\mathbb EY=\int_0^1(1-t)^u\,dt=\frac1{u+1},\qquad
\mathbb EY^2=2\int_0^1t(1-t)^u\,dt
=\frac2{(u+1)(u+2)}.
\]

Subtracting the square of the mean gives the stated variance. The tail identities follow by integrating `Y=integral_0^1 1{Y>t} dt` and its squared analogue with integrand `2t`; no special order-statistics theorem is needed. This replaces the two guessed antiderivatives and avoids conditioning the proof on a probability-zero point event.

### S2. Sum indicator variances

With `X=sum_{i in S} B_i`, linearity gives `E[X]=nu p`. Pairwise independence makes all cross covariances zero, so

\[
\operatorname{Var}(X)=\sum_{i\in S}\operatorname{Var}(B_i)
=\nu p(1-p).
\]

This proves exactly the same lemma with no second-moment expansion. Full independence is unnecessary.

### S3. Reciprocal error in one calculation

Write `X=(1+eta)/(u+1)` with `|eta|<=eps/4`. For `u>=1` and `0<eps<1`,

\[
\frac{|(1/X-1)-u|}{u}
=\frac{u+1}{u}\frac{|\eta|}{|1+\eta|}
\le\frac{2|\eta|}{1-|\eta|}
\le\frac{2\epsilon}{4-\epsilon}<\epsilon.
\]

This proves the same conversion without the long chain of upper and lower bounds. The original chain is otherwise correct under these hypotheses.

### N1–N4. Exact notation edits

**N1:** Replace lines 233–236, beginning `In the following, let $\distinctX{S}$ denote the set of values that appear in $S$. That is`, by:

```latex
Let $\distinctX{\STRM}$ denote the set of values that appear in
$\STRM$, and set $S=\distinctX{\STRM}$. Thus,
\begin{equation*}
    \Frq_0=\Frq_0(\STRM)=\cardin{S}
```

Retain the existing end of the display. The 16 subsequent occurrences of `S` at 257 (twice), 265, 270, 272, 280, 282, 284, 288, 330 (twice), 331, 333, 336, 360, and 363 need no substitution. This is a definition of the intended set, not an identification of a stream with its occurrences.

**N2:** At 250 and 251 replace exactly `$\Sample$` by `$R$`. The macro renders as sans-serif R, unlike the ordinary R at 257, 263 (twice), 268, 297, 330, 331, 335, and 336. Those nine occurrences stay unchanged. Counts exclude comments and other meanings.

**N3:** At 149, `$X = \min_i h(\strm_i)$` → `$Y = \min_i h(\strm_i)$`; at 152, `$X$` → `$Y$`; at 153, `\Ex{X}` → `\Ex{Y}`. At 130, `\Ex{X^2} -\pth{\Ex{X}}^2` → `\Ex{Y^2} -\pth{\Ex{Y}}^2`. The latter corrects an unambiguous transcription error in the variance of Y. These are the five affected symbol occurrences. Keep all amplified-estimator and Section 2 uses of X. The name Y is already used for exactly this minimum at 44 and 169, so the proposed unification creates no new binding.

**N4:** After the heading at 143, insert `Write the stream as $\STRM=\strm_1,\ldots,\strm_m$.` The later declaration at 232 can remain as a fresh section introduction.

### W1–W3. Mathematical exposition

**W1:** At 54 use `F(x)=\Prob{X\leq x}`. For a variable with a density, explain that probabilities of intervals are integrals of `f_X`, and the density is the derivative of the CDF where appropriate. Write `f_{X_i}(x)=1` on `(0,1)`, not `\Prob{X_i=x}=1`. At 95 and 111 replace the density placeholders `\Prob{Y=y}` by `f_Y(y)` if retaining those integrals. The author explicitly acknowledges the abuse, so this is a pedagogical repair, not an additional false intended result. S1 provides the clean replacement proof.

**W2:** Proposed complete content for the idealized lemma: for `eps,phi in (0,1)` and a nonempty stream with `u` distinct values, under the stated idealization of constant-word fully random real-valued hash functions and stored hash values, return `rho` with

\[
\Pr((1-\epsilon)u\le\rho\le(1+\epsilon)u)\ge1-\varphi
\]

using `O(eps^-2 log(2/phi))` words. The harmless `2` makes the repetition bound meaningful even when `phi` approaches one. This explicitly states the guarantee already proved; it does not claim a finite implementation of the idealized hash functions.

**W3, overflow:** Define X to be the size of the final conceptual sample, even when stored sampling stops early. On `|X-pnu|<=eps pnu`, overflow implies `X>8pN` and thus `nu>=X/((1+eps)p)>8N/(1+eps)>2N`. This yields an unconditional probability of correct output. Avoid suggesting the probability remains `7/8` after conditioning on overflow.

**W3, amplification:** Run `r=O(log(2/phi))` independent copies. Call a copy bad when its output is incorrect. Chernoff bounds the probability of at least `r/4` bad copies by `phi`. With fewer than `r/4` bad copies, an overflow majority includes a correct certificate. Otherwise more than `r/2` outputs are numerical, fewer than `r/4` are bad, and their median is within the permitted interval. Thus the algorithm as written is valid; the extra argument explains why discarding nonnumerical outputs is safe.

## Build and reproducibility

Builds used `/home/sariel/bin/l -no-env -s` (the `leeni` wrapper, XeLaTeX default) on temporary copies under `/tmp/freq-est-review-20261016-3-drr4us/29_freq_est_2`. The first baseline attempt could not find `shortcuts.bib`. After the user supplied its location, both [shortcuts.bib](/home/sariel/papers/bib/shortcuts.bib) and the preamble's other required file, [geometry.bib](/home/sariel/papers/bib/geometry.bib), were copied into staging. The sole cited key, `mr-ra-95`, resolves to Motwani and Raghavan in the latter. There are no textual citations requiring author-name edits.

The completed baseline has **0 errors, 8 overfull-box alerts, and 2 overfull-box warnings**, with no unresolved citations or references. Original source locations: 78, 105, 124, 138, the lemma starting at 160, 291, 309, 350; warnings at 229 and the proof starting at 402. Excess widths range from 8.63pt to 136.74pt. W5 recommends breaking the long equation chains and wide inline formulas; the mathematical review does not silently reformat them.

The computation script is [check_freq_est_review.rb](/tmp/check_freq_est_review.rb), run with `rtk proxy ruby /tmp/check_freq_est_review.rb`. Syntax and strict Ruby AST audit passed. Its temporary location is session-local; the main counterexample command is preserved above.

The final review build has the same **0 errors, 8 alerts, and 2 warnings** as the completed baseline. Two small annotation-induced overfull lines were corrected before this final build. Extracted PDF text contains all 19 review notes and no unresolved-reference markers; the first page was also visually inspected.

The original source matches its untouched staging copy byte for byte, and Git reports no tracked manuscript changes. Only the review source, report, and review PDF were created in this chapter directory. All auxiliary build files remain in temporary staging; no repository-wide cleanup was performed. The pre-existing review files in the neighboring chapter were left untouched. Nothing was committed.
