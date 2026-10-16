# Review of Frequency Estimation over a Stream

All locations below refer to the original [frequency_est.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/28_frequence_est/frequency_est.tex), not the review copy.

## What was done

- Created [frequency_est_review.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/28_frequence_est/frequency_est_review.tex): 4 tracked prose edits, 24 review notes, two documented reference-key corrections, and silent minor copyedits. Mathematical corrections remain proposals in notes and this report.
- Read the full chapter, relevant shared macros, and all four included prerequisite fragments. Checked every proof, both streaming constructions, amplification constants, and the final guarantees. Conducted separate simplification, notation, and writing passes. The bibliography attribution to Alon, Matias, and Szegedy is correct.
- Correctness, simplification, notation, writing, and adversarial verification used fresh-context agents with high reasoning effort requested and the inherited model. Agents identify as Codex/GPT-6; the exact serving variant and effective effort are not exposed. The coordinator also checked the arguments and edits.
- Verification: independent-agent for all 10 E/G findings, both simplifications, the four notation proposals, and W3's algorithm/boundary clarifications. Prose-only edits were additionally self-checked. Dropped a suspected missing fraction after checking the exact source. Did not treat equivalent macro spellings as notation defects or the Chernoff constant 4 as incorrect.
- Ruby 3.3.8 exact arithmetic verified 252 small frequency-vector/moment cases, the sample-budget counterexample, the polynomial-count obstruction, and the repaired ternary variance formula. Scripts stayed in `/tmp`; reproducible checks appear below.
- Original SHA-256: `2d0a21d255a100a43682c55145e5f937fb950d739f1a6c0d1ce315192e2365c4`.
- Build results are recorded below. No original manuscript, shared style, or prerequisite fragment was edited.

## Summary of findings

**6 errors, 4 gaps, 2 simplifications, 4 notation findings, and 4 grouped writing findings.** The main mathematical issue is the claim that conditioning the polynomial hash on having no zero outputs preserves independence. Keeping the ternary outputs and rescaling gives a short repair with the same variance bound. The other major repairs concern median amplification and several incorrect displayed expressions; the intended frequency-moment guarantees remain supported after these repairs and the stated computational assumptions.

### Errors

- **E1 — Zero-variance cases:** lines 78–83, 88, 129–134, 197–203, 785–786 permit zero samples or divide by zero (confidence: high).
- **E2 — Median failure event:** lines 171 and 221–225 use an equality instead of containment and mishandle even-sized medians (confidence: high).
- **E3 — Bound becomes equality:** lines 379–384, `f:e:exp:X`, incorrectly replace a conditional upper bound by an exact second moment (confidence: high).
- **E4 — Wrong moment index:** line 461, `f:e:v:X`, needs `\Frq_{2k-1}`, not `\Frq_{2k-2}` (confidence: high).
- **E5 — Conditional independence fails:** lines 566–589, 599–602, 646–649 do not produce the exact independent signs used in the proof (confidence: high).
- **E6 — Frequency/index ranges:** lines 334, 519, 605, 639, 642, 745 confuse moment order, universe size, and stream length (confidence: high; line 519 alone narrows the statement rather than making it false).

### Gaps

- **G1 — Sample accounting and rounding:** lines 185–208, 493–502, 521–522, 758–760, 776–777 conflate total samples and groups, omit integer rounding, and drop necessary constant terms (confidence: high).
- **G2 — Independence in formal statements:** lines 133, 161, 187, 199–201, 482, 763–767 need explicit independent draws and copies (confidence: high; earlier prose makes the intended convention apparent).
- **G3 — Executable parameter choice:** lines 475–483 choose repetitions from the unknown true mean and variance; use the proved ratio bound instead (confidence: high).
- **G4 — Final Chernoff application:** lines 796–812 need an argument using an upper bound on the mean and a non-strict threshold (confidence: high; the constant 4 is sufficient).

### Simplifications

- **S1 — Direct telescoping:** lines 303–329 and 367–386 can sum over the uniformly sampled position, avoiding conditional expectations and divisions by zero frequencies.
- **S2 — Center the quadratic estimator:** lines 624–751 can use orthogonality of centered diagonal and pair terms, removing the quadruple partition.

### Notation

Notation-only counts: **1 clash, 0 splits, 0 convention violations, 3 definition issues**. Technical notation problems retain E/G IDs: G1 also has a count-symbol clash, E4 has a wrong subscript, and E6 has inconsistent index domains; they are not counted again as N findings. Highest-payoff changes are separating total samples from groups, enforcing the universe/stream distinction, and reserving `G_i` for indicators.

- **N1 — clash:** lines 212, 214 reuse sampled `X_i` as good-group indicators; replace both indicator occurrences by `G_i`.
- **N2 — definition:** line 550 writes `g(i)` but defines an expression in free variable `x`; replace the left side by `g(x)`.
- **N3 — definition:** lines 183–184 introduce an unused absolute constant `c`; delete that declaration.
- **N4 — definition:** line 423 introduces an unused local `m`; delete `and $m = \sum_i f_i$`.

### Proposed notation rule sheet

- Established: `m` is stream length; `n` is universe size. Frequency sums run to `n`; position sums run to `m`.
- Established: `\frq_i` is a frequency and `\Frq_k` a moment. Their expansions are `f_i` and `F_k`; literal spellings are not separate notation.
- Proposed consistent use: `\alpha` samples per average, `\beta` averages per median, `M` total samples.
- Proposed consistent use: `X` denotes sampled estimators; `G_i` denotes a good-group indicator.
- Established: `\nu` is variance, `\eps` relative error, and `\BadProb` (rendered as `\varphi`) failure probability. Locally defined `\rho` and `\mu` are both acceptable mean notation.

### Writing

- **W1 — Orientation and prose:** lines 39–47, 50–53, 148–157: add a one-sentence roadmap; remove the repeated “probability … high probability” wording. Four concrete prose changes are tracked in the copy.
- **W2 — Broken references and unfinished sentence:** lines 75–76, 219, 798, 812: two reference keys are corrected in the copy; replace the third undefined reference together with G4 and finish the dangling sentence.
- **W3 — Algorithm/proof clarity:** lines 270–273, 343, 407–408, 685–686: explicitly reset the reservoir counter; include `k=1`; justify convexity at zero by continuity; say an index “appears exactly once.”
- **W4 — Equation layout:** the baseline has substantial overfull equations, particularly lines 359, 437, 736. Break long chains into aligned lines when applying the mathematical repairs; annotations do not repair the original layout.

## Details and proposed repairs

### E1. Positive sample counts and direct Chebyshev

For the constant distribution `X=1`, the mean is positive and variance is zero. The minimum prescribed block size is zero, so the displayed average is undefined. Also, the event `|Z−EZ| ≥ 2√Var(Z)` has probability **one**, not at most one quarter, when `Z` is constant. This boundary occurs naturally for `k=1` and for all-distinct streams.

Use finite variance, positive mean, and

\[
\alpha=\max\{1,\lceil4\nu/(\epsilon^2\mu^2)\rceil\},\qquad
\Pr(|Z-\mu|\ge\epsilon\mu)
\le \operatorname{Var}(Z)/(\epsilon^2\mu^2)\le1/4.
\]

At line 88, replace the premature choice `\alpha=\ceil{\nu/\rho}` by “take a positive integer number of samples, to be chosen below.” At lines 785–786 omit the division and multiplication by `√Var(Y_i)` and apply Chebyshev directly. Handle an empty stream by immediately returning zero. The included Chebyshev fragment also needs positive variance for its standardized, non-strict-threshold statement; that shared dependency was left untouched.

### E2 and G1. Correct amplification and its sample budget

Let `α` be the positive block size above, choose

\[
\beta=2\lceil12\ln(1/\varphi)\rceil+1,
\qquad M\ge\alpha\beta,
\]

and use the first `αβ` independent samples. The statement's `M` remains the **total** sample count; the proof's current block-size `m` becomes `α`, and its group-count `M` becomes `β`. This is a joint statement/proof correction, not merely a rename.

The current rounding is insufficient for its own proof: a Bernoulli(1/2) source with `ε=φ=1/2` has block size 16. The statement permits 267 samples; the proof uses `16⌈24 ln 2⌉=272`. This exposes a proof gap, not a counterexample to every possible estimator using 267 samples.

For the median, only the implication “bad median implies fewer than half good” is needed, and it is valid for odd `β`. Equality is false: values `(0,1,2)` with acceptable interval `[1/2,3/2]` have a good median but only one good value. For even size, `(1,100)` has half its values good but the conventional median is bad. Write

\[
\Pr(\text{bad median})\le\Pr(Y<\beta/2)
\le e^{-\beta/24}\le\varphi.
\]

For the final F2 construction, use `α=⌈16/ε²⌉` and `β=⌈4 ln(1/φ)⌉`; the G4 proof below works for either parity. The last `=1/8` at line 794 becomes `≤1/8` after rounding. Uniformly over `φ∈(0,1)`, use

\[
O\bigl((1+\nu/(\epsilon^2\mu^2))(1+\ln(1/\varphi))\bigr)
\]

for the general construction, and respectively
`O(k n^(1−1/k) ε⁻² (1+ln(1/φ)))` and
`O(ε⁻² (1+ln(1/φ)))` for the two stream algorithms. Alternatively restrict `φ≤1/2`, after which the additive logarithmic constant is absorbed. This avoids claiming that a positive integer number of sketches tends to zero as `φ→1`.

### G2 and G3. Independence and a computable algorithm

State that all observations within and across blocks are independent, and that each reservoir/hash sketch uses independent randomness. Marginal notation alone does not supply this hypothesis: if every `X_i` equals the same Bernoulli(1/2) variable, every average lies outside `[1/4,3/4]`, regardless of the number of copies. Earlier prose already suggests independence, so this is a formal-statement clarification.

The streaming algorithm need not know `μ=F_k` or its actual variance. Choose

\[
\alpha=\left\lceil4kn^{1-1/k}/\epsilon^2\right\rceil
\]

using the established bound `Var(X)/F_k²≤kn^(1−1/k)`, and use the corrected `β` above. This is determined before the stream arrives and proves the intended space bound. State the arithmetic model: constant-word reservoir state is clear, but exact values such as `r^k` need `Θ(k log m)` bits when `k` varies. The existing arithmetic argument is directly justified for fixed `k`; a uniform variable-`k` implementation needs an explicit representation/precision analysis.

### E3 and E4. Two false displayed steps

At line 382, replace the equality before the sum of conditional upper bounds by `\leq`. For stream `(1)` and `k=2`, `X=1`, whereas the written right-hand side is 2. The lemma's inequality is correct.

At line 461, replace `\Frq_{2k-2}` by `\Frq_{2k-1}`. For stream `(1,1)` and `k=2`, the estimator takes values 2 and 6 equally often, so `EX²=20`; the written bound is `kmF₂=16`. The corrected expression `kmF₃=32` agrees with the preceding lemma and the next line.

### E5. An explicit obstruction and a repair preserving the constants

Unconditionally the constructed `b(i)` are six-wise independent **ternary** variables with
`Eb(i)=0` and `Eb(i)²=q=(p−1)/p`. Thus the unconditioned `T²` has expectation `qF₂`, not `F₂`.

Conditioning on no zero outputs does not fix this while preserving independence. Take `n=7`, `φ=1/2`, and the prime `p=1,000,000,007`, which lies in the prescribed interval `[2·7¹⁰,2·7¹¹]`. Inclusion–exclusion counts the degree-at-most-five coefficient vectors avoiding `p−1` at all seven inputs:

\[
A=\sum_{j=0}^{6}(-1)^j\binom7j p^{6-j}-1
=\frac{(p-1)^7-(p-1)}p.
\]

Here `A mod 4=2`. Conditional coefficient vectors are equiprobable. Even two independent unbiased signs would require each of their four patterns to occur exactly `A/4` times, which is impossible.

**Repair:** retain zeros and never condition. Use a common odd prime `p>n` with `p=O(max(n,2))`, independent uniformly sampled coefficient vectors for the sketches, and return `X=T²/q`, where `q=(p−1)/p`. Four-wise independence suffices. Then

\[
\mathbb ET^2=qF_2,\qquad
\mathbb ET^4=qF_4+6q^2\sum_{i<j}f_i^2f_j^2,
\]
\[
\mathbb EX=F_2,\qquad
\operatorname{Var}X
=2F_2^2+(1/q-3)F_4\le2F_2^2,
\]

because `q≥2/3`. Consequently the original averaging constant 16 survives.

This also eliminates two unaccounted costs in the current construction: a separate failure event for each of the `αβ` hashes, and a seed needing `Θ(log n+log(1/φ))` bits rather than a constant number of the stated words. The repaired seed uses `O(log(n+1))` bits. Constant-time evaluation assumes unit-cost modular arithmetic on a constant number of words; finding the prime by random sampling is expected randomized preprocessing. The new lemma should describe ternary outputs, rather than retain its false promise of exact signs.

### E6. Complete index corrections

| Original line | Old text | Proposed replacement |
|---|---|---|
| 334 | `\frq_1, \ldots, \frq_k` | `\frq_1, \ldots, \frq_n` |
| 519 | `\STRM=(\strm_1, \ldots, \strm_n)` | `\STRM=(\strm_1, \ldots, \strm_m)` |
| 605, 639, 642, 745 | Each `\sum_{i=1}^m` | `\sum_{i=1}^n` |

Keep line 607's `\sum_{j=1}^m`: that sum is over stream positions. For `n=2`, `m=1`, and stream `(2)`, the current first sum in the definition of `T` is zero, while the position sum is `b(2)`. This directly disproves the written identity.

### G4. A short tail argument that handles both issues

After the corrected construction, let `B_i` indicate that average `i` is bad. These are independent and `Pr(B_i=1)≤1/8`. For `U=ΣB_i`, Markov's inequality applied to `7^U` gives

\[
\Pr(U\ge\beta/2)
\le7^{-\beta/2}\mathbb E7^U
\le7^{-\beta/2}(1+6/8)^\beta
=\left(\frac{\sqrt7}{4}\right)^\beta.
\]

Since `ln(4/√7)=0.413339…>1/4`, choosing `β≥4 ln(1/φ)` makes this at most `φ`. This works for nonidentical failure probabilities and a non-strict threshold. Alternatively justify stochastic domination by `Bin(β,1/8)` and the non-strict form of the cited Chernoff bound. Its deviation parameter 3 is allowed; the issue is the missing justification, not that parameter.

### S1. Direct uniform-position calculation

Each position is selected with probability `1/m`. The suffix ranks for the occurrences of item `i` are exactly `1,…,f_i`. Therefore

\[
\mathbb EX
=\frac1m\sum_{i=1}^n\sum_{r=1}^{f_i}
m\bigl(r^k-(r-1)^k\bigr)
=F_k.
\]

Likewise

\[
\mathbb EX^2
=m\sum_{i=1}^n\sum_{r=1}^{f_i}
\bigl(r^k-(r-1)^k\bigr)^2
\le kmF_{2k-1}.
\]

Absent items contribute empty sums. The difference-squares lemma also holds at `k=1` by equality, or handle that case directly with `X=m`. If replacing both proofs, delete the now-unused definition of `V` at lines 284–286. This also repairs E3 without introducing a new intermediate lemma.

### S2. Centering avoids the fourth-moment partition

For genuine independent unbiased signs, write

\[
X-F_2=2\sum_{i<j}f_if_jb(i)b(j).
\]

Distinct unordered pairs have zero cross expectation: their product contains an index occurring once, and at most four distinct signs are involved. Hence `Var(X)=4Σ_{i<j}f_i²f_j²≤2F₂²`.

For the **recommended ternary repair**, use instead

\[
X-F_2=\sum_i f_i^2\left(\frac{b(i)^2}{q}-1\right)
+\frac2q\sum_{i<j}f_if_jb(i)b(j).
\]

The centered diagonal terms and distinct pair terms are mutually orthogonal. Their variance contributions are `(1/q−1)F₄` and `4Σ_{i<j}f_i²f_j²`, respectively. Adding gives E5's repaired variance formula. This proves the same bound without the three quadruple classes. Do not apply the exact-sign version to the conditioned polynomial construction.

### N1–N4. Exact notation proposals

- **N1:** line 212, `$X_i$` → `$G_i$`; line 214, `\sum_{i=1}^{M}X_i` → `\sum_{i=1}^{M}G_i`. Coordinate both upper bounds `M` with G1's group-count rename. These are the two indicator occurrences; the input-sample `X_i` stays. `G_i` already denotes the corresponding good-group indicator at lines 168–171.
- **N2:** line 550, `$g(i) = \sum_{i=0}^5 c_i x^i \bmod p$` → `$g(x) = \sum_{i=0}^5 c_i x^i \bmod p$`. One definition changes; subsequent evaluations `g(i)` stay.
- **N3:** lines 183–184, `let $\eps, \BadProb \in (0,1)$ be parameters. For some absolute constant $c >0$, let` → `let $\eps, \BadProb \in (0,1)$ be parameters. Let`. The declaration is the only occurrence of this constant.
- **N4:** line 423, `Let $M =\max_i \frq_i$ and $m = \sum_i f_i$. We have` → `Let $M =\max_i \frq_i$. We have`. Its local `m` has no uses. The later stream-length `m` is retained.

Counts exclude comments and unrelated local variables. Each replacement was checked against the whole chapter and macro expansions.

### W2–W4. Specific writing and presentation repairs

The copy corrects `Chebychev:inequality` to `Chebyshev:inequality`, and replaces `\lemref{Chernoff's inequality}` by `\lemrefY{Chernoff's inequality}{chernoff:2:s}`. Both targets exist in the included fragments. The still-undefined `f:e:using:ch` at line 798 should be replaced by the explicit G4 argument; finish line 812 with a period instead of “, and.”

At lines 270–273, use: “Each time a representative is selected, reset its counter to one and count subsequent occurrences until it is replaced.” At line 343, allow `k≥1`, including the equality case. At lines 407–408, state the derivative calculation for `x>0`, extending convexity to zero by continuity; this handles real `1<k<2`. At lines 685–686, replace “with `i` being the unique value” by “with `i` appearing exactly once.”

The baseline overflows range up to about 129 points. The replacements in S1/S2 remove several long displays; other chains should be broken into `align*` rows without changing the mathematics.

## Reproducible computations

Executed `rtk proxy ruby /tmp/frequency_review_checks.rb` and `rtk proxy ruby /tmp/frequency_f2_check.rb`, with syntax checks; the coordinator's check script passed strict Ruby audit. Selected output:

```text
sample budget: stated=267, proof=272
frequency=1: E[X^2]=1/1, printed bound=2
frequency=2: E[X^2]=20/1, printed bound=16
prime=true, eligible delta=1/2=true, count mod4=2
exact moment identity and second-moment bound: 252 cases passed
rescaled ternary q=2/3: mean=14/1, variance=245/1, formula=245/1, bound=392/1
```

The 252 cases comprise every nonzero vector in `{0,1,2,3}³` and each integer moment `1,…,4`. They check the exact mean and corrected second-moment inequality, not a substitute for the general proof. The ternary check enumerates all 27 independent equally likely assignments in `{-1,0,1}³` for frequencies `(1,2,3)`, so it checks the moment algebra at `q=2/3`; it does not model the polynomial construction at those three universe inputs.

To reproduce the key counterexamples independently of temporary files:

```ruby
require 'prime'
p = 1_000_000_007
puts [p.prime?, p.between?(2 * 7**10, 2 * 7**11),
      (((p - 1)**7 - (p - 1)) / p) % 4].inspect
puts [(24 * 16 * Math.log(2)).ceil, 16 * (24 * Math.log(2)).ceil].inspect
puts Rational(2**2 + 6**2, 2) # 20, exceeding the printed bound 16
```

## Build

Builds used an isolated copy under `/tmp/frequency-review-20261016-2-1gghes/chapter`, retaining the chapter's relative `styles -> ../styles` link. The repository source directory received no build auxiliaries. Commands used the project driver, `rtk proxy /home/sariel/bin/l --no-env --emacs <file>.tex`, with XeLaTeX.

The original's unmodified isolated build fails because `shortcuts.bib` is unavailable under `--no-env`. Supplying the existing `shortcuts.bib` and `geometry.bib` only in the temporary build directory allows the baseline to compile: **0 errors, 12 alerts, 6 warnings**, including three undefined references and the overfull equations above. This supplemental build does not establish standalone bibliography portability.

The final review copy compiles to a [14-page PDF](/home/sariel/papers/teach/26/fa26_rand_alg/notes/28_frequence_est/frequency_est_review.pdf): **0 errors, 12 alerts, 4 warnings**. The remaining undefined reference is `lemma:f:e:using:ch`, deliberately flagged for replacement with G4. All remaining overfull boxes correspond to pre-existing passages; two annotation-induced overflows were corrected and the build rerun. The first PDF page was visually inspected, and extracted text was checked for readable annotations. The original manuscript hash remains unchanged. No whole-book build was run.
