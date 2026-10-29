# Review of “On Complexity, Sampling, and ε-Nets and ε-Samples”

Locations below refer to the original [vc_dim.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/40_vc/vc_dim.tex), not the annotated copy.

## What was done

- Deliverables: [annotated source](/home/sariel/papers/teach/26/fa26_rand_alg/notes/40_vc/vc_dim_review.tex), [PDF](/home/sariel/papers/teach/26/fa26_rand_alg/notes/40_vc/vc_dim_review.pdf), and [review-only bibliography](/home/sariel/papers/teach/26/fa26_rand_alg/notes/40_vc/vc_dim_review.bib). The source contains **9 tracked edits** (`\chgY`) and **25 notes** (`\remX`), plus silent copyedits. Mathematical corrections remain proposals in notes and this report.
- All passes completed. Read the entire chapter, captions, shared preamble and mathematical macros. Checked the geometric examples, complement argument, affine-dependence claim, Radon theorem, halfspace lemma and VC bound, Sauer induction, growth bounds, inversion lemma, combination theorem end to end, corollaries, sampling applications, binomial calculations, and convex-hull definition. The sample theorem is cited without proof; its stated domains and use sites were checked, but its full external proof was not reconstructed. The net theorem's constants were checked through double sampling. No unrelated chapters were reviewed in full.
- Separate simplification, whole-chapter notation, and writing passes were performed. The notation audit reconciled macro expansions and local scopes; it did not treat identically rendered macro/literal spellings as errors.
- Models: reviewers inherited the coordinating model, with **high reasoning effort explicitly requested** for correctness, notation, writing, and refutation. The collaboration interface did not expose the resolved model identifier; no model override was requested. Coordinator model identifier/effort were not exposed. No known below-default reviewer configuration.
- Verification: **11 technical candidate groups** were independently rechecked: 7 Errors, 3 Gaps, and 1 Unclear item retained. The sample-to-net claim was downgraded from Error to Gap; the unspecified shattering convention remains Unclear. Both simplifications, all notation changes, and mathematical writing proposals were independently verified. `verification: independent-agent`. Suspicions about zero coefficients in Radon and the alternating-disks step were rejected. The learning section's explicitly acknowledged failure probability and distributional extension were not reported as new gaps.
- Computations used `/usr/bin/ruby` 3.3.8: exact small-family VC enumeration, rational growth and disk examples, and numerical logarithmic checks. Reproducible excerpts appear below; finite checks supplement the written arguments.
- Build: the unmodified original was first built in an isolated temporary copy using `rtk proxy /home/sariel/bin/l -no-env -cc vc_dim.tex`. It initially failed because `shortcuts.bib` was unavailable. Supplying unchanged copies of the author's `shortcuts.bib` and `geometry.bib` in that temporary copy produced a successful 16-page XeLaTeX baseline, with no unresolved references or citations. With `-a`, its only diagnostic was a 2.08 pt overfull box at original line 836. The review uses a new jobname bibliography containing only the two cited entries, copied without metadata changes from the author's bibliography. Final review build results are recorded at the end.
- Originals, figures, the relative `shared` symlink, and the existing `review.md` were preserved. Builds ran outside the repository; no repository-wide cleanup was run because it could remove existing review artifacts. No commit, push, or publication.

## Summary of findings

**7 errors, 3 gaps, 1 unclear issue, 2 simplifications, 4 notation issues, and 4 grouped writing issues.** The most consequential application defect is that a smallest disk consistent with positive and negative samples need not exist; any consistent disk suffices. Several proof statements and parameter domains also need correction, while the intended main conclusions remain supported by the repairs below.

### Errors

- **E1** Learning a concept, lines 955, 975–977 — a minimum-radius consistent disk need not exist; choose any consistent disk (confidence: high).
- **E2** `def:convex:hull`, lines 1123–1125 — the coefficient normalization has mismatched and unbound indices (confidence: high).
- **E3** `equation:g:d:n:estimate`, lines 447–454 — the intermediate exponential-series bound is false, and the final bound needs a small-$n$ qualification (confidence: high).
- **E4** `lemma:Sauer`, lines 502–506 — the twin family has dimension at most, not necessarily exactly, $\delta-1$ (confidence: high).
- **E5** `lemma:nemesis:function` (E), line 605 — the inverse lower bound fails on the decreasing branch $1<x<e$ (confidence: high).
- **E6** `theo:VC:combination`, lines 681, 711–727 — an invoked hypothesis is missing and a displayed inequality fails under the stated assumptions (confidence: high).
- **E7** Sampling theorem statements, lines 839–844, 881–888 — allowed parameters make sample sizes negative or logarithms undefined (confidence: high).

### Gaps

- **G1** Disks, lines 210–237 — the hull case split omits collinear boundary configurations; use the nonextreme-point condition (confidence: high).
- **G2** `lemma:a:basic:binomial`, lines 1037–1084, 1097–1109 — endpoint conventions and first-term cases need explicit treatment (confidence: high).
- **G3** Remark, lines 919–921 — the elementary sample-to-net implication does not justify the claimed sample size “up to constants” (confidence: high in the missing justification).

### Unclear

- **U1** `rem:epsilon:net:s`, lines 906–914 — shattering dimension is not defined, so the dependence on the polynomial-growth constant cannot be verified.

### Simplifications

- **S1** `lemma:growth:improved`, lines 534–557, 1091–1111 — the binomial theorem gives a shorter proof, removes the factor 2, and allows $1\le\delta\le n$.
- **S2** `lemma:trivial:observation`, lines 389–417 — convexity of the complementary open halfspace replaces the dot-product calculation.

### Notation

- Meaning-preserving N findings: **clash 0, split 2, convention 2, definition 0**; 9 affected occurrences.
- **N1** Convention, lines 144, 433, 435, 502, 647 — restore the established typefaces for the range space, ground set, and family.
- **N2** Split, line 677 — retain superscripts for the indexed range families.
- **N3** Split, line 992 — retain $D_{\mathrm{unknown}}$, rather than introducing $D'$ for the same disk.
- **N4** Convention, lines 982–983 — express a draw from a probability law with $\sim$, rather than $\in$.
- Technical notation-origin issues E2 and U1 add **2 definition issues** to the audit coverage; they are counted only once in overall totals. Highest-payoff notation changes: family indices, S/X/R typefaces, and the disk alias.

### Proposed notation rule sheet

- Established: use `\RangeSpace`, `\GroundSet`, and `\RangeSet` for the three distinct entity types.
- Established: use `\RangeSet^i` for input families in the combination theorem.
- Established: use `\disk_{\text{unknown}}` for the target and `\disk` for the hypothesis.
- Proposed: write `\pnt\sim\Distribution` for a draw from a probability law.
- Proposed: explicitly bind summation indices and match the coefficient normalization to the convex combination.

### Writing

- **W1** Lines 440, 899–900, 1026 — align the titles and roadmap with this chapter's contents; transition edited in the review copy, heading alternatives in notes.
- **W2** Lines 45–46, 186, 189, 207–208, 236–242, 265 — replace a literal icon name, correct float navigation, and supply informative captions; safe prose edits are tracked.
- **W3** Lines 828, 874 — name Vapnik and Chervonenkis, and Haussler and Welzl, in the theorem attributions; proposed outside moving arguments.
- **W4** Lines 94, 107–110, 931–933, 964, 982 — clarify the estimated quantity, the small-sample obstruction, additive count error, and the meaning of labels and the error bound.

## Details

### E1. A smallest consistent disk may not exist

Take positive points $(\pm1,0)$ and negative point $(0,1/2)$. A consistent **closed** disk with center $(a,b)$ and radius $r$ must satisfy

$$
(1+|a|)^2+b^2\le r^2<a^2+(b-1/2)^2.
$$

Thus $b<-3/4-2|a|$ and $r>5/4$. Yet centers $(0,-c)$ and radii $\sqrt{1+c^2}$ are consistent for every $c>3/4$, and approach radius $5/4$. The limiting disk contains the negative point on its boundary. Feasible disks exist, but no smallest one exists.

Replace “compute the smallest disk” by “find a disk” and add: “Such a disk exists because the unknown target disk is consistent with all sample labels.” Replace caption (b) by “A disk consistent with all sample labels.” The remaining proof uses only consistency. These repairs were independently verified.

### E2. Normalize the actual coefficients

The original vector sum runs from $i=0$ to $m$, while its normalization is `\sum_{j=1}^m \alpha_i =1`. Replace the display by:

```latex
\CHX{\PntSetC}
= \Set{\sum_{i=1}^m \alpha_i \pntB_i}{
   m\geq1\text{ is an integer},\quad
   \pntB_i\in\PntSetC,\ \alpha_i\geq0\ (i=1,\ldots,m),\quad
   \sum_{i=1}^m\alpha_i=1}.
```

This is the intended set of finite convex combinations and also gives the empty hull for an empty point set. It supports all preceding geometric uses.

### E3. Remove the false intermediate comparison

At $n=\delta=2$, the displayed chain reads $4\le5\le4$. At $n=1$, even $G_\delta(n)\le n^\delta$ fails for $\delta\ge2$.

Keep the direct statement $G_\delta(n)\le n^\delta$ for integers $n,\delta\ge2$, omitting the intermediate sum. A short justification is
$G_2(n)=(n^2+n+2)/2\le n^2$; for $\delta\ge3$, induction gives
$G_\delta(n)\le n^{\delta-1}+n^\delta/\delta!\le n^\delta$.
In the union proof at lines 650–654, dispose of $n\le1$ separately before using this bound.

### E4. Sauer needs an upper bound

Let $X=\{a,b,c\}$ and
$\mathcal R=\{\varnothing,\{a\},\{b\},\{a,b\},\{c\}\}$. Its dimension is 2. For $x=c$, the twin family is $\mathcal R_c=\{\varnothing\}$, of dimension 0 rather than 1.

At lines 503 and 504, change both exact assertions to “at most $\Dim-1$.” More precisely, the twin family cannot shatter a set larger than $\delta-1$, since adjoining $x$ would give a shattered set in the original family. This is exactly what the induction uses, including when the twin family is empty.

### E5. Restrict the inverse lower bound to the increasing branch

At $x=1.1$, $u=10$, $x/\ln x\approx11.54126\ge10$, but $x<10\ln10\approx23.02585$.
State $x>1$ as the lemma's overall domain, and replace part (E) by:

> For $u\ge e$ and $x\ge e$, if $f(x)\ge u$, then $x\ge u\ln u$.

Indeed $u\ln u\ge e$ and $f(u\ln u)\le u$; monotonicity on $[e,\infty)$ proves the assertion. The uses of part (C) in the combination arguments are unaffected.

### E6. Repair the combination proof's parameter split

The growth lemma used at line 717 requires $t\ge2\delta$. The later assumptions do not establish it. Furthermore, $t=3$, $\delta=2$ satisfies the expressly stated assumptions but gives

$$
1+\delta\lg(te/\delta)\approx5.055315
>3\delta\lg(t/\delta)\approx3.509775.
$$

Before the displayed trace count, assume positive integer $k$, handle $\delta=0$ separately, and dispose of $t<3\delta$ as an immediate bound. On the remaining branch, $t/\delta\ge3$, so the growth lemma applies and

$$
1/\delta+\lg e\le1+\lg e<2\lg3\le2\lg(t/\delta).
$$

This validates the disputed inequality and preserves the final explicit bound $12\delta k\ln(6k)$. For $\delta=0$, each nonempty input family has a single range, so its fixed Boolean combination has dimension 0. Write the theorem's asymptotic bound as $O(k\delta\lg(2k))$ to include $k=1$. These repairs preserve both two-family corollaries.

### E7. State meaningful sampling parameters

The sample theorem permits $\delta=2$, $\varepsilon=100$, $\varphi=1/2$, for which its size bracket is negative. The net theorem permits $\varphi=0$ or a negative value, making its logarithm undefined.

For the sample theorem, require a nonempty finite population, integer dimension upper bound $\delta\ge1$, and $0<\varepsilon,\varphi<1$. Use the ceiling of the displayed size, or the entire population when smaller. A dimension-zero space can simply use the upper bound $\delta=1$. Specify a uniformly random subset of the resulting cardinality. For the net theorem, retain $0<\varepsilon\le1$, add $0<\varphi<1$, and specify uniform independent draws from a nonempty finite population. Count repetitions as sampling positions; the support is the resulting net. These conventions also make the preceding normalized measures well-defined.

### G1. Complete the disk case split

The points $(0,0),(2,0),(0,2),(1,0)$ all lie on the hull boundary, but only three are vertices. They satisfy neither original case.
Replace “If the convex hull ... has only three points on its boundary” by “If one point lies in the convex hull of the other three.” Convexity prevents selecting exactly those other three. Otherwise all four are vertices. The alternating-circle argument in the remaining case is valid; no additional finding is warranted there.

### G2. Treat binomial endpoints explicitly

In the basic-binomial lemma, restrict (ii) to $n\ge2$ and (iv) to integer $1\le k\le n$. The existing derivation of (ii) divides by $n-1$; the first comparison in (iv) divides by $k-1$. An alternative convention for $0^0$ is possible, so this is a missing endpoint treatment rather than a claim that every convention makes the statement false.

For (iv), use $(n-j)/(k-j)\ge n/k$ for $0\le j<k$ and multiply; this covers $k=1$. In the later growth proof, apply the ratio calculation only for $2\le i\le\delta$, and separately handle $a_0=1$, $a_1=ne\ge2$. This covers $\delta=1$. S1 offers a simpler replacement for that entire growth argument.

### G3. The direct reduction gives a weaker net bound

An $\varepsilon/2$-sample hits every range of true measure at least $\varepsilon$, because its empirical measure is at least $\varepsilon/2>0$. However, the displayed sample theorem still gives an $\varepsilon^{-2}$ size dependence, whereas the net theorem has $\varepsilon^{-1}$. The elementary implication therefore does not justify “up to constants.” A different reduction has not been ruled out, so this is reported as a Gap.

Replace the remark by:

> An $\varepsilon/2$-sample is an $\varepsilon$-net, but this observation gives a weaker size bound than the $\varepsilon$-net theorem.

The reference to “bibliographical notes” should also be removed or replaced by an actual destination; this chapter contains no such notes.

### U1. Specify the shattering-dimension convention

The chapter defines $\pi_{\mathsf S}(m)$ but not “shattering dimension.” If the intended assumption is $\pi(m)\le C m^\delta$, specify the domain of $m$ and whether constants in the sampling bound may depend on $C$. Arbitrary $C$ cannot disappear from a uniform bound: the full powerset on $N$ points satisfies a polynomial bound with exponent 1 and, for example, $C=2^N$, despite VC dimension $N$. A convention that fixes or absorbs $C$ may explain the statement. No formula change is proposed until that convention is stated.

### S1. A shorter and stronger growth estimate

For $1\le\delta\le n$, put $a=\delta/n\in(0,1]$. Since $a^\delta\le a^i$ for $i\le\delta$,

$$
a^\delta G_\delta(n)
\le\sum_{i=0}^\delta\binom ni a^i
\le(1+a)^n\le e^{na}=e^\delta.
$$

Thus $G_\delta(n)\le(en/\delta)^\delta$. The lower bound is
$G_\delta(n)\ge\binom n\delta\ge(n/\delta)^\delta$.
This proves a stronger version of the stated lemma with fewer steps. If adopted, update **both** copies of `\LemmaGrowthImproved` at lines 534–557, even though the second `\providecommand` is currently inactive. All downstream uses remain valid. The combination proof can then use the branch $t\ge2\delta$ and omit its additive 1, but the independent repair in E6 does not require this simplification.

### S2. Use the complementary halfspace

Replace the proof of `lemma:trivial:observation` by:

> If $h^+$ contains no point of $\mathsf P$, then $\mathsf P$ lies in its complementary open halfspace, which is convex. Consequently $\mathcal{CH}(\mathsf P)$ lies in that complementary halfspace as well, contradicting $\mathsf v\in\mathcal{CH}(\mathsf P)\cap h^+$.

This proves the same statement and supports the Radon application. Keeping the longer proof is also reasonable if illustrating weighted averages is a teaching objective.

### N1–N4. Exact notation edits

All nine occurrences were checked against the whole source and macro definitions, excluding comments and unrelated local meanings. These are proposals; the source uses nearby remarks because strikethrough inside mathematics is unsafe.

| ID | Original line | Exact old text | Replacement |
|---|---:|---|---|
| N1 | 144, 433, 435 | `\VCDim(S)` | `\VCDim(\RangeSpace)` |
| N1 | 502 | `$( X \setminus \brc{x}, \RangeSet_x)$` | `$(\GroundSet \setminus \brc{x}, \RangeSet_x)$` |
| N1 | 647 | `$\range \in R$` | `$\range \in \RangeSet$` |
| N2 | 677 | `\in \RangeSet_1, \ldots, \range_k \in \RangeSet_k \bigr.}` | `\in \RangeSet^1, \ldots, \range_k \in \RangeSet^k \bigr.}` |
| N3 | 992 | `disk $\diskA$ that induces $f$` | `disk $\disk_{\text{unknown}}$ that induces $f$` |
| N4 | 982–983 | `\ProbExt{\pnt` followed by `\in \Distribution}` | `\ProbExt{\pnt` followed by `\sim \Distribution}` |

N2 retains the eight matching superscript occurrences already in the statement and proof. N3 retains the three existing unknown-disk occurrences at lines 961, 987, 993. N1 changes visibly different typefaces, not merely source spellings. N4 preserves the sampling interpretation already given in prose. No replacement captures an unrelated local variable.

### W1–W4. Proposals not fully shown as tracked prose

- **W1:** Replace `Shattering dimension and its dual` by `Growth and combinations of range spaces`; replace `A make growth function small again` by `Bounding the growth function`. The transition at lines 899–900 is tracked as “We now turn to two applications of these theorems.”
- **W2:** At line 242, add `\caption{The two alternating pairs $\{a,c\}$ and $\{b,d\}$ cannot both be realized by disks.}` At line 265, add `\caption{For points $U$ on a circle and any subset $V\subseteq U$, $\CHX{V}\cap U=V$.}` The explicit intersection avoids incorrectly saying the hull contains no other points of the plane. Figure navigation fixes and the literal `blacksmiley` replacement are tracked.
- **W3:** In the optional heading at line 828, replace the bare attribution `\cite{vc-ucrfe-71}` by `Vapnik and Chervonenkis~\cite{vc-ucrfe-71}`. At line 874, use `Haussler and Welzl~\cite{hw-ensrq-87}`. Authors were verified against the actual entries in [geometry.bib](/home/sariel/papers/bib/geometry.bib:16042), also copied into the review bibliography; the existing prose attribution at lines 112–113 is already correct. No `\etal` change is needed.
- **W4:** Replace lines 107–110 by: “In the worst case, a small sample cannot approximate the measure of every range. Indeed, if every subset of $\FGroundSet$ is a range, then $\FGroundSet\setminus\operatorname{supp}(\SetC)$ is missed by $\SetC$ and has measure at least $1-\cardin{\SetC}/\cardin{\FGroundSet}$.” Here support handles the allowed multiset convention. Replace the count-error sentence at lines 931–933 by: “We would like to quickly estimate how many points lie inside a query rectangle. Let us allow an additive error of $0.01\cardin{\PntSet}$ in this count.” The definition wording, label wording, and “at most” clarification are tracked in the source. These mathematical writing proposals were independently checked.

### Reproducible calculations

The following Ruby excerpt reproduces the numerical evidence without manuscript dependencies:

```ruby
series = (0..2).sum { |i| Rational(2**i, (1..i).reduce(1, :*)) }
puts [series, 2**2].inspect
puts [1.1 / Math.log(1.1), 10 * Math.log(10)].inspect
puts [1 + 2 * Math.log2(3 * Math::E / 2), 6 * Math.log2(1.5)].inspect
puts 2 * Math.log(2.0 / 100) + Math.log(2)
c = Rational(3, 4)
puts [1 + c*c, (c + Rational(1, 2))**2].inspect
```

Run from a scratch directory with `rtk proxy ruby check.rb`. Output:

```text
[(5/1), 4]
[11.54126455598277, 23.02585092994046]
[5.055315083220239, 3.5097750043269373]
-7.1308988302963465
[(25/16), (25/16)]
```

For E4, enumerating all subsets and their distinct traces for the explicitly listed five-range family gives dimensions 2 and 0. For E3, an independent exact check of all integers $2\le n,\delta\le100$ found no failure of the repaired direct bound; the induction above establishes it generally.

## Final build and preservation check

`rtk proxy /home/sariel/bin/l -no-env -a -cc vc_dim_review.tex` succeeded with XeLaTeX, producing **18 pages**, with **zero errors and no unresolved references or citations**. The existing 2.08 pt overfull box remains at review line 861 (original line 836). The only new final diagnostic is the harmless note that an `h` float placement was changed to `ht`; the review-induced overfull annotation was shortened and its warning eliminated. PDF text and representative rendered pages were checked for visible annotations and bibliography resolution. Full-book compilation was not run.

The constants 4 and 8 in the net theorem were independently checked using the fixed-size, indexed-multiset double-sampling bound
$P_{\rm bad}\le2G_\delta(2m)2^{-\varepsilon m/2}\le4(2em/\delta)^\delta2^{-\varepsilon m/2}$.
For $L=\lg(16/\varepsilon)\ge4$ and $x=\varepsilon m/(4\delta)\ge2L$, the inequality $eL\le2^L$ and monotonicity of $x-\lg x$ give $\delta\lg(2em/\delta)\le\varepsilon m/4$. The first sample-size lower bound then gives $P_{\rm bad}\le4\,2^{-\varepsilon m/4}\le\varphi$. Dimension zero is handled directly using its single fixed range.

SHA-256 comparisons confirmed all **34 pre-existing source, report, wrapper, and figure files** unchanged, including the original manuscript and existing report. The `styles -> ../shared` symlink is unchanged. All **21 finding IDs** used in the 25 annotations resolve to this report. Only four new deliverables were written in the chapter directory: `vc_dim_review.tex`, `vc_dim_review.pdf`, `vc_dim_review.bib`, and `review_vc_dim.md`. No generated auxiliary files were added there.
