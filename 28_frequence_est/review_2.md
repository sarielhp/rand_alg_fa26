# Review of Frequency Estimation over a Stream

Locations below refer to the original [frequency_est.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/28_frequence_est/frequency_est.tex), unless another source is named. All passes were requested; no optional focus was supplied.

## What was done

- Created [annotated source](/home/sariel/papers/teach/26/fa26_rand_alg/notes/28_frequence_est/frequency_est_review_2.tex) and [16-page PDF](/home/sariel/papers/teach/26/fa26_rand_alg/notes/28_frequence_est/frequency_est_review_2.pdf): **29 tracked edits** (`\chgY`) and **22 notes** (`\remX`), plus minor copyedits and display reflow. Formula corrections and replacement proofs remain proposals in notes and this report. The existing review/report deletions were preserved by using unused `_2` names.
- Read the whole chapter, relevant shared macros, and all four imported probability/hash-function fragments. Checked every proof, including both streaming conclusions end to end; separate simplification, notation, and writing readings followed. No proofs were merely skimmed. Citation authorship was checked against the supplied Alon–Matias–Szegedy paper and the bibliography source.
- Models: reviewers inherited the session model; its exact model identifier was not exposed. Correctness, simplification, notation, adversarial verification, and writing reviewers were explicitly launched with **high** reasoning effort and fresh contexts. Coordinator effort was not exposed; no lower-effort reviewer configuration was requested.
- Verification: **independent-agent** for the ten retained Error/Gap bundles, all four simplifications, all five notation proposals, and mathematical writing changes. Independent reviewers attempted to refute candidates and checked the proposed repairs. One inherited error allegation was rejected; the stream-endpoint issue was classified as a scope clarification rather than a false theorem.
- Computations: Ruby 3.3.8, exact rational/integer arithmetic; 315 small frequency/order cases, sign and ternary moment enumerations, the conditional-seed counterexample, and repetition constants. Syntax and `ruby-audit` checks passed for the scratch computation script. Small-case agreement supplements the analytic proofs below.
- Build: original XeLaTeX build failed with two misplaced alignment tabs at lines 387/391. The review uses the project wrapper with `-no-env -e x`, Biber, and convergence passes in a staged `/tmp` tree. Final diagnostics are recorded below. The [review bibliography](/home/sariel/papers/teach/26/fa26_rand_alg/notes/28_frequence_est/frequency_est_review_2.bib) copies the two cited entries unchanged from the existing bibliography, so the review does not depend on the original fallback bibliography search path.
- Original source SHA-256 remained `d5724fe9222cdde455762c7936624ce7f17cbc3f87180a315d7129f90f983321`. No original or shared source was edited; nothing was committed, pushed, or published.

## Summary of findings

**5 errors, 5 gaps, 4 simplifications, 5 notation findings, and 5 writing findings.** The main defect is the signed-bit construction: conditioning away zero outputs does not preserve the independence used in the second-moment proof. Retaining and normalizing the ternary outputs repairs this while keeping the stated variance bound. The general estimator also needs explicit sample/group accounting and treatment of deterministic distributions.

### Errors

- **E1**, lines 623–648, 659–710 — Conditioning the polynomial outputs invalidates the fair-independent-sign model; retain ternary outputs and normalize (confidence: high).
- **E2**, `f:e:v:X`, line 510 — `F_{2k-2}` should be `F_{2k-1}`; the printed intermediate bound is false (confidence: high).
- **E3**, lines 193, 248–250 — Too few good groups is not equivalent to median failure; use implication, an odd group count, and a probability inequality (confidence: high).
- **E4**, lines 368, 664, 700, 703, 806 — Frequency lists/sums use the moment order or stream length instead of the universe size (confidence: high).
- **E5**, lines 850–851 and imported Chebyshev statement — Zero variance makes the standardized threshold undefined, and the imported non-strict standardized inequality is false in that case (confidence: high).

### Gaps

- **G1**, lines 207–225, 529–554, 575, 821–842 — Total samples and group counts are conflated; rounding and the uniform bound as the failure parameter approaches one need repair (confidence: high).
- **G2**, lines 203–225 — The general median theorem needs finite moments, a positive mean, and a nonzero group size when variance is zero (confidence: high).
- **G3**, lines 529–534 — The streaming algorithm chooses repetitions from unknown moments; use the available variance-ratio bound (confidence: high).
- **G4**, lines 183–194, 209–225, 826–830 — State mutual independence across samples and independently initialized streaming sketches (confidence: high; likely intended implicitly).
- **G5**, lines 863–877 — The cited Chernoff statement uses the actual mean and a strict threshold; justify the substitutions or use the direct generating-function argument below (confidence: high).

### Simplifications

- **S1**, lines 375–520 — Bound the basic estimator pointwise to replace the chain of four intermediate moment lemmas.
- **S2**, lines 335–361 — Sum directly over stream positions to prove unbiasedness without conditional expectations.
- **S3**, lines 685–812 — Center the second-moment estimator to avoid the quadruple partition; include the diagonal fluctuation term for ternary outputs.
- **S4**, lines 816–878 — Apply the repaired general amplification theorem instead of repeating Chebyshev and Chernoff calculations.

### Notation

Counts for the meaning-preserving findings: **clash 1; split 1; convention 0; definition 3**. Technical count/subscript issues are cross-linked to E2, E4, and G1, not counted twice. Highest payoff: distinguish samples from indicators, fix the polynomial argument, and remove the unused constant.

- **N1**, clash, lines 209/236/238 — Keep `X_i` for samples and use the earlier `G_i` for good-group indicators.
- **N2**, definition, line 605 — Write the polynomial definition as `g(x)`, matching its right-hand side.
- **N3**, definition, lines 205–206 — Delete the unused absolute constant `c`.
- **N4**, definition, line 470 — Delete the unused local declaration of `m` in the norm-product proof.
- **N5**, split, line 722 — Use `\ell` for the fourth tuple coordinate, as elsewhere in that proof.

### Proposed notation rule sheet

- Established: `m` denotes stream length, `n` universe size, and `k` moment order.
- Established: `\frq_i`/`f_i` and `\Frq_k`/`F_k` render identically; no cosmetic source-wide replacement is needed.
- Proposed clarification: reserve `X_i` for sampled estimators and `G_i` for good-group indicators within the median argument.
- Proposed: define polynomials with the same free argument on both sides; use `\ell` consistently for the fourth tuple coordinate; remove unused declarations.

### Writing

- **W1**, lines 43–56, 565, 746–747, 889–890 — Tighten repeated introductory prose, identify singleton tuple values precisely, and streamline attribution; tracked edits are in the review copy.
- **W2**, lines 863/877 and bibliography setup — Replace the nonexistent lemma reference with the earlier median theorem, finish the sentence, and supply the review's local bibliography; the tail justification is separately G5.
- **W3**, lines 298–308, 338–346, 379, 448–450, 572 — Clarify reservoir resets, positive-frequency conditioning, the `k=1` boundary, convexity at zero, and the intended stream length; precise proposals below.
- **W4**, lines 385–396, 472–484, 504–517, 694–811, 847–876 — Repair the invalid display environment and split long aligned derivations without changing their formulas.
- **W5**, inherited annotations at lines 219–880 — Distinguish the new verified findings from old annotations, withdraw the stale equality complaint, and point current annotations to this report; old notes remain visibly struck through.

## Details

### E1. Conditioning is not an independence-preserving operation

Take `n=7`, failure parameter `1/2`, and prime `p=564950531`, which lies between `2*7^10` and `2*7^11`, as allowed by the proof. Among the `p^6` equally likely degree-at-most-five polynomials, inclusion–exclusion counts the seeds with no output equal to `p-1`:

\[
D=p^6-7p^5+21p^4-35p^3+35p^2-21p+6.
\]

Prescribing any `r<=6` evaluations leaves `p^(6-r)` polynomials; prescribing all seven to equal `p-1` leaves only the constant polynomial. This explains the final constant. Exact reproduction, from `/tmp`:

```sh
rtk proxy ruby -r prime -e 'p0=564950531; d=p0**6-7*p0**5+21*p0**4-35*p0**3+35*p0**2-21*p0+6; puts [p0.prime?,d,d%4]'
```

Output: `true`, `32513410079555784550749377581599704994417569852963370`, `2`. Conditional fair, pairwise-independent signs would require exactly `D/4` seeds for each sign pair, impossible.

**Repair, independently verified:** choose an odd prime `p>n` of size `O(n)` (use `p=3` for the small exceptional case), independent of the failure parameter. Keep the unconditioned ternary outputs. Put `q=1-1/p` and return `X=T^2/q`. Their odd moments vanish and their second/fourth moments equal `q`. Four-wise independence gives

\[
\mathbb EX=F_2,\qquad
\operatorname{Var}X=(q^{-1}-1)F_4+4\sum_{i<j}f_i^2f_j^2
=2F_2^2+(q^{-1}-3)F_4\le2F_2^2.
\]

The final inequality uses `q>=2/3`. Change the construction lemma to describe ternary outputs, remove the conditioning at both use sites, and normalize the output. The existing degree-five polynomial is sufficient; degree three would also suffice.

This also removes the unallocated per-sketch construction-failure budget and the claim that `O(log(n/varphi))` bits always occupy constant standard words. For example, `m=n`, `varphi=2^(-n)` needs order `n` seed bits in the printed construction. With the repaired prime choice the seed takes `O(log(n+1))` bits and evaluation takes constant word operations under the chapter's word-arithmetic convention.

### E2–E4. Concrete failing steps

**E2:** for stream `(1,1)`, `n=1,m=2,k=2`, the basic estimator is equally likely to be `2` or `6`. Thus `E[X^2]=20`, whereas the printed `kmF_{2k-2}` equals `16`. The corrected `kmF_{2k-1}` equals `32` and matches both the preceding lemma and the next expression. The variance lemma's final conclusion remains valid.

**E3:** with acceptable interval `[.75,1.25]`, estimates `0,1,2` have a good median despite only one good estimate. Conversely, for two estimates `0,1`, the arithmetic median is bad although the good count equals half the group count. For odd `b`, use

\[
\Pr(\text{bad median})\le\Pr(Y<b/2).
\]

The earlier sentence at line 193 is tracked as “can fail only if.” The corresponding displayed formula remains annotated for correction.

**E4:** replace the endpoint `k` by `n` in the list at line 368. Replace `m` by `n` in the four frequency sums at lines **664, 700, 703, 806**. Keep the stream-position sum at line 666 bounded by `m`. A stream consisting only of item `3` in universe `{1,2,3}` makes the printed first sum for `T` zero, while the stream-position sum is `b(3)`. The theorem at line 572 is a different issue: its endpoint `n` merely restricts its scope, addressed by W3.

### E5 and G2. Deterministic distributions must be covered

The imported [Chebyshev fragment](/home/sariel/papers/teach/26/fa26_rand_alg/notes/shared/fragment/def_Chebyshev.tex:1) states a non-strict deviation event at `t*sigma` without excluding `sigma=0`. For deterministic `X`, that event has probability one, contradicting `1/t^2` when `t>1`. Line 851 also explicitly divides by the standard deviation. The initial footnotes recognize the issue, but do not repair the later application or imported statement.

Use the positive-threshold formulation

\[
\Pr(|X-\mathbb EX|\ge t)\le\operatorname{Var}(X)/t^2,\qquad t>0.
\]

Require `0<mu<infinity`, `0<=nu<infinity` in the generic theorem and take at least one sample per group. This is necessary in the actual application: when `k=1`, the reservoir estimator is identically `m`, so the printed ceiling of the variance ratio is zero. The earlier averaging lemma explicitly excluded zero variance; extend it with this direct argument. For a nonnegative law with `mu=0`, or an empty stream, return zero separately.

### G1, G3, G4. A complete amplification specification

For the generic distribution choose

\[
a=\max\{1,\lceil4\nu/(\epsilon^2\mu^2)\rceil\},\qquad
b=\text{least positive odd integer at least }24\ln(1/\varphi),\qquad M=ab.
\]

Draw all samples independently, average in `b` disjoint groups of size `a`, and return the median. Extra supplied samples can be ignored. The lower-tail calculation gives `exp(-b/24)<=varphi`, and the uniform sample bound is
`O((1+nu/(epsilon^2 mu^2))*log(2/varphi))`.

The existing statement/proof do not have matching sample accounting: for group size seven and `varphi=1/2`, the statement permits 117 samples while its proof uses 119. This is a defect in that implementation proof, not a counterexample to the theorem's existential conclusion. Recompute with:

```sh
rtk proxy ruby -e 't=24*Math.log(2); puts [(7*t).ceil,7*t.ceil].inspect'
```

For the streaming implementation, use the **known** bound `B=k*n^(1-1/k)` and `a=ceil(4B/epsilon^2)`, instead of unknown `mu` and `nu`. The resulting space bound is `O(B*epsilon^(-2)*log(2/varphi))`. Restricting `varphi<=1/2` is an alternative if the author wishes to keep the existing logarithmic asymptotic expression.

Initialize each reservoir or polynomial sketch independently. The within-sketch limited independence is a different requirement. With exact signs and frequencies `(1,1)`, one sketch returns `0` or `4` although `F2=2`; reusing that sketch's randomness for every repetition fails with probability one for every `epsilon<1`.

### G5. The final constants are sufficient

Round `alpha` up from `16/epsilon^2` and choose odd integer `beta>=4*ln(1/varphi)`. Each group fails with probability at most `1/8`. For independent bad-group indicators `I_i` and `U=sum I_i`,

\[
\Pr(U\ge\beta/2)\le4^{-\beta/2}\mathbb E4^U
\le4^{-\beta/2}(11/8)^\beta=(11/16)^\beta
\le e^{-\beta/4}\le\varphi.
\]

Here `E[4^{I_i}]=1+3*Pr(I_i=1)<=11/8`; `log(11/16)<=-5/16<-1/4`. This deals directly with the non-strict threshold and the upper bound on each failure probability. **Neither 16 nor 4 is an erroneous constant.** Use `log(2/varphi)` for the uniform complexity, as in G1.

### S1–S4. Verified shorter arguments

**S1: pointwise bound.** For a nonempty stream, let `f_max=max_i f_i`. For all real `k>=1`,

\[
0\le X=m[r^k-(r-1)^k]\le kmf_{\max}^{k-1}
\le k n^{1-1/k}F_k.
\]

The last step follows from `m<=n^(1-1/k)F_k^(1/k)` (Jensen) and `f_max<=F_k^(1/k)`. Therefore `E[X^2]<=k n^(1-1/k)F_k E[X]=k n^(1-1/k)F_k^2`. This proves the needed variance bound, including `k=1`, without the four intermediate lemmas. Retain those lemmas if their separate pedagogical value is desired; their external use sites were also checked before suggesting removal.

**S2: positions telescope.** Every stream position has probability `1/m` of being chosen. For value `i`, the suffix counts are exactly `1,...,f_i`, so

\[
\mathbb EX=\frac1m\sum_i\sum_{r=1}^{f_i}m[r^k-(r-1)^k]=\sum_i f_i^k=F_k.
\]

Empty inner sums handle absent values. The same proof works for any function `g` with `g(0)=0`; its nonnegativity is unnecessary for unbiasedness alone.

**S3: center first.** For genuine fair four-wise independent signs,

\[
X-F_2=2\sum_{i<j}f_if_jb_ib_j,\qquad
\operatorname{Var}X=4\sum_{i<j}f_i^2f_j^2=2(F_2^2-F_4).
\]

Cross terms from distinct pairs vanish: overlapping pairs reduce to two distinct mean-zero signs, and disjoint pairs use four-wise independence. For the recommended ternary repair use instead

\[
X-F_2=\sum_i f_i^2(b_i^2/q-1)+\frac2q\sum_{i<j}f_if_jb_ib_j.
\]

Distinct summands are uncorrelated, giving exactly E1's variance formula. Omitting the diagonal fluctuation term would be incorrect for ternary outputs.

**S4: reuse amplification.** Once E1 and G1/G2/G4 are repaired, use `a=ceil(8/epsilon^2)` independent basic second-moment sketches per group and odd `b>=24*ln(1/varphi)`. The general theorem directly gives the final accuracy guarantee with space and update time `O(epsilon^(-2)*log(2/varphi))`. This removes the repeated final proof altogether. Handle the empty stream separately.

### N1–N5. Complete proposed notation edits

These batches were independently checked for capture, use-site consistency, and unchanged meaning. They are annotated proposals rather than unsafe strikethroughs inside mathematics.

| ID | Original location and exact old text | Proposed replacement |
|---|---|---|
| N1 | 236: `let $X_i$, for` | `let $G_i$, for` |
| N1 | 238: `$Y = \sum_{i=1}^{M}X_i$` | `$Y = \sum_{i=1}^{M}G_i$` |
| N2 | 605: `$g(i) = \sum_{i=0}^5 c_i x^i \bmod p$` | `$g(x) = \sum_{i=0}^5 c_i x^i \bmod p$` |
| N3 | 205–206: `For some absolute constant $c >0$, let` | `Let` |
| N4 | 470: `and $m = \sum_i f_i$. We have` | `. We have` (attach the period to the preceding definition of `M`) |
| N5 | 722: `$(i,j,k,l)$` | `$(i,j,k,\ell)$` |

N1 changes two occurrences only; the sampled variables at 209 stay unchanged. Apply it alongside G1's separate group-count repair. N2 changes only the free argument, leaving the bound summation index and later evaluations unchanged. N3's scalar `c` has no use; the later coefficients `c_i` are unrelated. N4's local `m` has no use before that proof ends; the stream-length `m` elsewhere is preserved. N5 reconciles one `l` with eleven active `\ell` coordinate occurrences; comments and inherited annotations were excluded from counts. The explicit change from `rho` to `mu` in the generic theorem is legitimate local rebinding, so no global rename is proposed.

### W3 and W5. Clarifications and rejected inherited claims

- The reservoir reset insertion is a clarity improvement, not a newly discovered algorithmic failure: the original initialization language already reasonably suggests resetting on selection.
- Before conditional expectations given `V=i`, specify `f_i>0`; alternatively use S2.
- The power-difference lemma at 379 also holds at `k=1`, with equality; include this immediate boundary to match its later use.
- In the convexity argument at 448–450, establish `g''(x)>=0` for `x>0` and extend convexity to zero by continuity. For `1<k<2`, the printed second derivative at zero is undefined. The convexity conclusion is nevertheless correct.
- At 572 replace `\STRM=(\strm_1, \ldots, \strm_n)` with `\STRM=(\strm_1, \ldots, \strm_m)` to state the intended generality. The preceding proof supports this change. An arbitrary real moment order also needs a convention for evaluating powers; this is not evidence against the constant-word reservoir state or the stated integer-order space bound.
- **Withdraw the inherited E3 note at 427.** The current second-moment proof already uses inequalities before its upper-bounding sum; the final equality to `mk F_{2k-1}` is correct. The lower-tail Chernoff reference at 246 also already resolves; no new key correction is needed there.

### Build and numerical verification record

Build command (executed in a temporary chapter directory with the original relative `styles -> ../shared` layout and shared, unedited dependencies):

```sh
rtk proxy /home/sariel/bin/l -no-env -e x -a --junk-dir /tmp/frequency-review-20261016-3-gynv07/build-review frequency_est_review_2.tex
```

**Final result: exit 0; 0 errors, 0 alerts, 6 warnings, 2 minor diagnostics.** There are no unresolved references/citations or overfull boxes. The six underfull-box warnings are at review-source lines 32, 368, 404, 445, 561, and 653; they arise from the annotated/reflowed layout and were not in the baseline diagnostics. Two pre-existing Hyperref warnings remain about math tokens in section bookmarks (review lines 278 and 596). The review uses a local paragraph-stretch allowance without redefining shared macros. Representative rendered pages were inspected for annotation readability and clipping. Builds and scratch computations were kept outside the manuscript tree; only review deliverables were added.

The exact-arithmetic script enumerated frequency vectors in `{0,1,2,3}^3`, excluding the zero vector, for integer orders `1,...,5`. It checked unbiasedness, `E[X^2]<=kmF_{2k-1}`, and the norm-product inequality after raising to the integer `k`th power. Output:

```text
General moment cases checked exactly: 315
Wrong subscript example: mean=4, second moment=20; claimed upper=16
Exact signs f=(1,2,3): mean=14, variance=196
Normalized ternary f=(1,2,3), p=3: mean=14, variance=245, bound=392
Conditional-seed count modulo 4: 2
Rounding: [117, 119]
Chernoff exponents: 1/24, 9/8
```

For example, the ternary enumeration is reproducible independently with:

```ruby
q = Rational(2, 3)
values = [-1, 0, 1].repeated_permutation(3).map do |signs|
  [1, 2, 3].zip(signs).sum { |f, b| f * b }**2 / q
end
mean = values.sum / values.length
variance = values.sum { |x| (x - mean)**2 } / values.length
puts [mean, variance, 2 * mean**2].inspect
```
