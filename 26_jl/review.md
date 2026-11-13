# Review of Dimension Reduction

## What was done

- Original: [jl.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/26_jl/jl.tex). All locations below refer to its original line numbers. The original and shared sources were not edited.
- Review copy: [jl_review.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/26_jl/jl_review.tex): one tracked replacement, six notes with matching anchors, and the minor corrections logged below. Substantive mathematical repairs remain proposals, not applied changes.
- Checked every proof: Gaussian normalization and moments, product density and rotational projection, the exponential-moment calculation, concentration constants, the single-vector and all-pairs JL argument, affine Gaussians, and both sum-of-Gaussians lemmas. Separate simplification, notation, and writing passes covered the whole chapter. No sections were excluded.
- Checked Laurent–Massart's Lemma 1 and its chi-square corollary against the PDF supplied in `refs/`; checked all three citations' authors against the local bibliography. The cited tail bounds are transcribed correctly.
- Verification: independent-agent. A fresh-context adversarial reviewer checked the mathematical candidates and proposed repairs, including both simplifications and the local mathematical corrections. Review agents inherited the coordinator's model with high reasoning effort requested; the actual model identifier was not exposed. Coordinator checks were additional self-checks, not independent verification.
- Numerical checks used Ruby 3.3.8; analytical checks establish the full parameter ranges. No simulation was needed. A suspected notation split between `d` and `\hdim` was discarded because both render as the same symbol. Independence in the projection lemma and the equal-points case require, at most, routine clarification, not separate gap findings.
- Build: original and review successfully compiled with XeLaTeX, Biber, and two further XeLaTeX passes, with TeX/Bib environment overrides removed. The final review has zero errors, unresolved references/citations, or reported warnings/overfull boxes. The original has one 0.51 pt overfull box. The project command `/home/sariel/bin/l -no-env -s jl.tex` initially failed in its bibliography-cache step (`Cannot find './book.bib'`); the direct toolchain fallback succeeded. Temporary build copies were used, and generated files that reached the chapter directory were removed, retaining only the requested review PDF. Review-only paragraph stretch and one line break accommodate annotations. Rendered annotation pages were inspected.
- PDF: [jl_review.pdf](/home/sariel/papers/teach/26/fa26_rand_alg/notes/26_jl/jl_review.pdf).

## Summary of findings

**1 error, 2 gaps, 2 simplifications, 0 notation findings, 1 writing finding.** The JL proof works with the stated local corrections and explicit parameter restrictions. The final geometric Gaussian proof needs a signed-offset argument for negative thresholds; an earlier lemma makes the whole proof unnecessary.

### Errors

- **E1**, line 185 — the variance integral uses a point probability instead of a density; for a continuous Gaussian the written integrand is zero (confidence: high). Exact correction proposed in the copy, not applied.

### Gaps

- **G1**, lines 322–326, 552–564, 622–625 — the construction and final theorem omit the cardinality and distortion restrictions required by the displayed proof (confidence: high). Restrictions and singleton treatment proposed, not applied.
- **G2**, lines 702–719 — the weighted-Gaussian proof treats a signed offset as a distance and only explains halfspaces containing the origin, leaving negative CDF thresholds uncovered (confidence: high). Rotation repair proposed, not applied.

### Simplifications

- **S1**, lines 693–745 — derive the weighted Gaussian sum directly from the earlier projection and scaling lemmas; also resolves G2. Alternative proof proposed, not applied.
- **S2**, lines 438–486 — replace the geometric-series estimate by a short logarithm bound, improving the intermediate tail exponent from 1/16 to 1/8. Proposed, not applied.

### Notation

No substantive notation-only findings: 0 clashes, 0 splits, 0 convention findings, 0 definition findings. Mathematical issues originating in the audit are counted once under E1/G1/G2; unmistakable argument/point slips are logged as minor corrections. All active symbols were checked against their macro expansions; comments were excluded from occurrence judgments.

### Proposed notation rule sheet

- Established: retain the point/image macros and the distinction between sans-serif image points and italic Gaussian directions.
- Established: use the second parameter of the normal law for variance, not standard deviation.
- Proposed clarification: distinguish a density value from a point-event probability, and a signed offset from a geometric distance.
- Established: local reuse of Gaussian random-variable letters is acceptable when explicitly rebound. No global renaming is proposed.

### Writing

- **W1**, lines 491–493 — explicitly name Laurent and Massart when introducing their concentration inequality; one tracked replacement applied. Both other cited works already name their two authors correctly.

## Details

### E1. Density versus point probability

The old expression is `\int_{x=-\infty}^\infty x^2 \Prob{X =x} \diffX{x}`. A Gaussian has no atoms, so this integral is zero, not its second moment. Replace only `\Prob{X =x}` by `f(x)`. The next displayed integral already has the correct Gaussian density, and integration by parts correctly yields variance one. This is highlighted rather than silently corrected because the density/probability distinction matters in a chapter introducing continuous distributions.

### G1. State the scope supported by the construction

At line 322, replace `of $n$ points` by `of $n\geq2$ points`; at line 323, replace `$\eps >0$` by `$\eps\in(0,1/2)$`. Make the corresponding replacements in the final theorem: `of $n$ points` becomes `of $n\geq2$ points`, and `a parameter $\eps$` becomes `a parameter $\eps\in(0,1/2)$`.

Add before the construction: “A singleton can be mapped to the unique point of $\Re^0$, preserving its only distance, zero; below assume $n\geq2$.” This avoids evaluating the formula containing `1/\sqrt{k}` when `k=0`.

These edits explicitly **narrow the formal theorem's parameter range** to the one established by the stated corollary; they are not cosmetic corrections and have not been applied. The issue does not refute JL for the usual larger range. An alternative is to extend the concentration corollary to `0<\eps\leq1`, justified by its preceding calculation, and propagate that range explicitly. The minimal repair above keeps the current corollary unchanged.

For `n>=2`, the dimension calculation is valid with an inequality:

\[
8\epsilon^{-2}\ln(2n^2)\leq24\epsilon^{-2}\ln n.
\]

That local relation has been corrected in the review copy. Equality holds only at `n=2`. The original constant 24 is sufficient; no increase is needed.

### G2. Preserve the sign when rotating a halfspace

For `alpha=beta=1` and `z=-1`, the claimed distance `z/sigma=-1/sqrt(2)` is negative, and the origin is outside `H^-`. Thus the stated origin-containing argument does not cover this case.

Replace “the distance of $\ell$ from the origin is $d=z/\sigma$” by “the signed offset of $\ell$ in the unit-normal direction $(\alpha,\beta)/\sigma$ is $d=z/\sigma$.” Replace the origin-containing explanation at lines 715–719 by:

> Rotate the plane so that the unit normal $(\alpha,\beta)/\sigma$ becomes $(1,0)$. This sends $H^-$ to $T=\{(x,y):x\leq d\}$ for every real $z$. Rotational invariance of the Gaussian therefore gives $\Pr(H^-)=\Pr(T)$.

Both the defect and this repair were independently verified. Merely replacing `z` by `|z|` would break the intended CDF calculation. The separate tangent/normal-vector typo at line 698 is corrected directly and logged below.

### S1. A three-line weighted-Gaussian proof

Replace the proof, not its statement, by:

\[
w=(\alpha,\beta)/\sigma,\qquad \|w\|=1,\qquad
Z/\sigma=\langle w,(X,Y)\rangle\sim\mathcal N(0,1).
\]

The last relation follows from the product-normal and projection properties in `normal:distribution`. The preceding affine-normal lemma then gives `Z~N(0,sigma^2)`. This proves the same statement, has no circular dependency, preserves the subsequent sum lemma, and removes the geometric calculation and G2 entirely. Choose either this replacement or the G2 repair, not both.

### S2. Shorter exponential-moment estimate

For `0<=u<=1/2`, let `F(u)=u+u^2+ln(1-u)`. Then `F(0)=0` and

\[
F'(u)=\frac{u(1-2u)}{1-u}\geq0,
\]

so `-ln(1-u)<=u+u^2`. Using the already computed moment-generating function and `t=epsilon/4` gives

\[
\Pr[Z\geq1+\epsilon]
\leq\exp\!\left(k[-t(1+\epsilon)-\tfrac12\ln(1-2t)]\right)
\leq\exp\!\left(k[-t\epsilon+2t^2]\right)
=e^{-k\epsilon^2/8}.
\]

Under the lemma's unchanged hypothesis this is at most `(varphi/2)^2<=varphi/2`. The original longer calculation is correct; this is an optional shorter proof with a stronger intermediate bound.

### Recomputed constants

The Laurent–Massart substitution `k=8 epsilon^-2 x` yields the upper deviation `epsilon/sqrt(2)+epsilon^2/4`, at most `(1/sqrt(2)+1/4)epsilon<epsilon` for `0<epsilon<=1`. Ceiling `k` only improves the bound. The union bound is `binom(n,2)/n^2=(n-1)/(2n)<1/2`; independence between pairs is unnecessary.

Reproduce the numerical checks with:

```sh
ruby -e 'puts 1/Math.sqrt(2)+0.25; puts 3*Math.log(4)-Math.log(32); puts (24*4*Math.log(1)).ceil'
```

Output: `0.9571067811865475`, `0.693147180559945`, `0`. These respectively check the upper-tail coefficient, the logarithm discrepancy at `n=4`, and the invalid singleton construction. The analytical arguments above, not the spot checks, establish the general conclusions.

## Minor corrections applied

Applied only in the review copy, without inline markup; excluded from finding counts. Mathematical corrections were checked independently. In the table, `↵` denotes a source newline.

| Original line | Old | New |
|---|---|---|
| 23 | `through dot-product` | `through dot products` |
| 36 | `Of course, one can do such compression of information without losing ↵ some information.` | `Such compression generally loses some information.` |
| 37 | `let the distances ↵ to be a bit off.` | `let the distances be a bit off.` |
| 50 | `$\hdim \times k$` | `$k \times \hdim$` |
| 95 | `in the same distance` | `at the same distance` |
| 97 | `$f(\cdot)$ it is indeed` | `$f(\cdot)$ is indeed` |
| 118 | `f(x) f(y)\, dx \, dy` | `f(x) f(y)\, dy \, dx` |
| 122 | `g(x, y) \diffX{x} \diffX{y}` | `g(x, y) \diffX{y} \diffX{x}` |
| 173 | `see \Eqref{normal:2d} is symmetric` | `see \Eqref{std:normal:density}, is symmetric` |
| 333 | `h(v)%` | `h(\pnt)%` |
| 360 | `a good approximation to $v$` | `a good approximation to the length of $v$` |
| 507 | `which ↵ implies $x = \ln( 2/\BadProb)$` | `so ↵ we choose $x = \ln(2/\BadProb)$` |
| 522 | `that that` | `that` |
| 549 | `Observe that if for a number $x$, if` | `Observe that for a nonnegative number $x$, if` |
| 559 | `8 \eps^{-2} \ln (2n^2)% ↵         =%` | `8 \eps^{-2} \ln (2n^2)% ↵         \leq%` |
| 577 | `\distY{ \Matrix \pnt}{\Matrix \pntA }%` | `\distY{ \Matrix \pnt}{\Matrix \pnt' }%` |
| 579 | `(1+\eps) \distY{\pnt}{\pntA}.%` | `(1+\eps) \distY{\pnt}{\pnt'}.%` |
| 583 | `    The key observation is that $\Matrix$ is a linear operator. As ↵     such, let` | `    The claim is immediate when $\pnt=\pnt'$, so assume the points ↵     are distinct. The key observation is that $\Matrix$ is a linear ↵     operator. As such, let` |
| 611 | `the later condition` | `the latter condition` |
| 613 | `the probability of failure is ↵ ` | `the probability of failure is at most ↵ ` |
| 698 | `the vector $(-\beta,\alpha)$` | `the vector $(\alpha,\beta)$` |
| 800 | `which in turn follows Indyk` | `which in turn follow Indyk` |
| 801 | `and Motwani \cite{im-anntr-98},` | `and Motwani~\cite{im-anntr-98}.` |
