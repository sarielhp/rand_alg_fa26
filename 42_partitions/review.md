# Review of “Finite Metric Spaces and Partitions”

Reviewed on 2026-10-30. Locations below refer to the [preserved source snapshot](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex), captured at 09:11 CDT after incorporating the concurrent Călinescu-attribution and radius-display edits. Its SHA-256 is `2e7a2dcfa57c01b4e8c39f739ca5877498d9d718967a6592024953baa13b4c90`. The live chapter was edited again during preparation of the deliverables, including a rewrite of the partition construction. Those later edits are outside this review. This review did not change the live manuscript or shared files.

## What was done

- Deliverables: [annotated source](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review.tex), [review PDF](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review.pdf), and this report. The source uses a [review-only preamble wrapper](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_prefix.tex) that defines annotations before the unchanged shared preamble starts the document.
- The copy contains **35 tracked edits, 17 notes, and 9 span anchors**, plus **61 minor corrections** logged below. No legacy reviewer notes were retained.
- Checked the entire chapter: definitions, examples, every displayed proof, the main tree theorem end to end, both Euclidean constructions, all exercises, and bibliographical claims. Correctness, simplification, notation, and writing received separate passes. Historical sources were checked where needed, rather than exhaustively reviewing every cited paper.
- Verification: three correctness reviewers and three fresh independent adversarial verifiers checked the technical findings and proposed repairs. A separate reviewer audited notation and writing, and another checked the resulting edits. All delegated passes requested **high** reasoning effort and inherited the session model; its exact model identifier and actual runtime effort are not exposed. Minor prose corrections also received a coordinator self-check.
- Exact Ruby checks covered the four-point HST example, all 24 center permutations, star and cycle examples, quotient distances, and the geometric-tail calculation. The mathematical arguments below establish the claims beyond these checks.
- Build: **both the original snapshot and review compile successfully with XeLaTeX/Biber: 0 errors, 0 alerts, 0 warnings, and no unresolved references or citations**. The same pre-existing 1.32-point overfull line remains in both. The review PDF has 22 pages; representative annotation pages were visually checked. Builds used the project's `l -no-env -f -a` command in an isolated copy, preserving the existing chapter PDF and auxiliary files. `./tools/clean --skip-compile` completed in that copy only.

## Summary

**8 errors, 2 gaps, 1 simplification, 3 notation findings, and 3 writing findings.** Several central statements remain valid, but the supplied tree-embedding proof and the unbounded-spread construction require substantive repairs. The review copy deliberately retains those passages with explanations and verified replacement proposals, so it is an annotated draft rather than a corrected final chapter.

### Errors

All eight findings have high confidence and `verification: independent-agent`.

- **E1 — [line 46](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex:46):** the graph-to-metric claim lacks connectivity and positive weights. Sufficient hypotheses are tracked.
- **E2 — [line 156](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex:156):** the three-leaf star admits distortion \(2/\sqrt3<\sqrt2\); its geometric minimization argument also fails. The opening bound is tracked; the replacement proof below remains proposed.
- **E3 — [line 519](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex:519), Theorem H:S:T:** the first-failure event and its distance charge are false, and the padding/conditioning steps do not follow. A verified replacement construction below preserves \(24\ln n\); it is not substituted into the review copy.
- **E4 — [line 687](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex:687), bounded-spread theorem:** \(\Phi=1\) makes the stated dimension and distortion bounds vanish. The \(1+\ln\Phi\) repair and nonzero scale count are tracked.
- **E5 — [line 709](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex:709):** a coordinate can minimize over the empty set. The distance-to-set lemma's finite/nonempty hypotheses are tracked; the zero-coordinate convention remains proposed.
- **E6 — [line 831](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex:831):** minimum intercomponent distances need not satisfy the triangle inequality. The shortest-path repair and its necessary estimates are proposed below.
- **E7 — [line 840](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex:840):** the claimed \(O(n^2)\) spread bound is false independently of E6. Its deletion and replacement by a single-scale construction remain proposed.
- **E8 — [line 267](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex:267):** exactly \(k\) distinct centers are infeasible for \(k>n\). The range \(1\le k\le n\) is tracked in the definition, lemma, application, theorem, and exercise.

### Gaps

- **G1 — [line 412](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex:412), Lemma FRT:** the ordered centers and intervals depend on the radius being sampled. Interval length alone does not justify the probability estimate. The lemma is true; the fixed-center proof below is verified and proposed. Confidence: high; independent-agent.
- **G2 — [line 970](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex:970):** the shifted-quadtree sketch omits the construction details needed to eliminate spread dependence. Specify and prove the extra preprocessing or labeling rule. No complete replacement for that sketch is asserted. Confidence: high about the missing justification; independent-agent.

### Simplification

- **S1 — [line 849](/home/sariel/papers/teach/26/fa26_rand_alg/notes/42_partitions/partitions_review_base.tex:849):** replace the clipping case analysis and footnote by composition of two 1-Lipschitz functions. Proposed, conditional on E5/E6; independently verified.

### Notation

Counts are **0 clashes, 1 split, 0 convention findings, and 2 definition/scope findings**; each grouped item counts once. The complete chapter and relevant macro expansions were checked.

- **N1, split:** unify metric, graph, event, radius, and input-set symbols. The radius and final embedding names are tracked; the remaining exact renames below are proposals.
- **N2, definition:** use one coherent coordinate index range, input set, and target dimension in the bounded-spread proof. The full correction is proposed below.
- **N3, definition:** explicitly bind \(K\ge1\), the HST factor \(k\ge1\), nonroot vertices, finite injective embeddings, and \(0<\epsilon<1\). These clarifications are tracked.

The largest gains are a coherent bounded-embedding coordinate block, consistent metric symbols, and the point/component distinction included in E6. Mathematical portions of these changes were independently checked.

### Proposed notation rule sheet

- Established: use \(\mathcal X\) for the input point set, \(\mathsf d\) for its metric, and \(P\) for a partition.
- Established: use the same graph symbol in a graph and its distance subscript; use the defined event macro.
- Proposed: use \(i\) for scale, \(j\) for repetition, \(\alpha\) for the scale count, and \(\beta\) for the repetition count throughout the bounded proof.
- Proposed: write \(q_i(x)\) when using a component metric; distinguish points from their quotient components.
- Established and clarified: reserve \(G\) for the scaled Euclidean embedding in that proof; state parameter domains at their definitions.

### Writing

- **W1 — lines 114 and 203:** the introduction presents stronger results as context; the promised but absent lower-bound sketch is deleted. Tracked.
- **W2 — lines 950 and 962:** give explicit author attribution and correct “Emek et al.” to “Elkin et al.” The bibliography supplies the author order. Tracked. The concurrently added Călinescu attribution is preserved.
- **W3 — lines 383 and 901:** describe the probability actually bounded by the lemma, and explain finite-coordinate retention by preserving witness scales, rather than claiming discarded coordinates contribute nothing. Tracked and mathematically verified.

## Details

### E1 and E8. Necessary domains

A disconnected graph gives infinite shortest-path distance, and a zero-weight edge gives distance zero between distinct vertices. “A finite connected undirected graph with strictly positive edge weights” is sufficient.

The chapter defines centers as a subset of exactly \(k\) points. This requires \(1\le k\le n\). No algorithmic change is needed. The HST dynamic program works at both endpoints.

### E2. Correct star bound and proof

The claimed impossibility at distortion \(\le\sqrt2\) is contradicted by an equilateral triangle of side two, with the center mapped to its centroid. Center-to-leaf distances are \(2/\sqrt3\), and leaf-pair distances remain two.

The equal-radii step is false even for admissible expansive images: leaves at \((-2,0),(2,0),(0,1)\) have smallest enclosing circle centered at \((0,0)\), with radii \(2,2,1\). Their circumcircle has radius \(5/2\).

**Proposed replacement for both repeated minimization paragraphs**, retaining the figures: let \(v_a=f(a)-f(s)\), \(v_b=f(b)-f(s)\), \(v_c=f(c)-f(s)\), and \(R=\max\{\|v_a\|,\|v_b\|,\|v_c\|\}\). Noncontraction gives
\[
12\le \sum_{p<q}\|v_p-v_q\|^2
 =3\sum_p\|v_p\|^2-\|v_a+v_b+v_c\|^2
 \le9R^2.
\]
Thus distortion is at least \(2/\sqrt3\). The equilateral construction attains it in dimension at least two. The lower bound is valid in every target dimension.

### E3. The tree proof needs a different construction and charge

The open ball \(B(x,d(x,y))\) excludes \(y\). In the two-point space \(\{0,1\}\), the ball \(B(0,1)=\{0\}\) is never broken, even though the tree distance is one.

A separate counterexample defeats the child-scale charge:
\[
\mathcal X=\{0,1/101,100/101,1\},\qquad x=0,\quad y=1.
\]
Every root partition produces the two close pairs. Each child has diameter \(1/101\) and level \(-6\). The displayed charge is therefore \(1/64\), whereas \(d_T(x,y)=1\). Its truncated sum starting at \(j=0\) is zero. Moreover, the stated padding hypothesis fails at the lowest three scales, and a recursively partitioned subset supplies local ball counts, not the displayed ambient ratio.

The logarithmic tree-embedding theorem itself is valid. See the [Fakcharoenphol–Rao–Talwar paper](https://cedric.cnam.fr/~bentzc/INITREC/Files/FM4.pdf). The following independently checked replacement also proves the chapter's explicit constant.

**Proposed replacement of the construction and proof.** Normalize \(\operatorname{diam}(\mathcal X)=1\), with \(n\ge2\). For each integer \(i\le-2\), construct a random partition \(P_i\) of the entire metric, using a uniform radius in \([2^{i-1},2^i]\) and a uniform permutation. Refine successively by intersections with these partitions. Label the root one, a nonsingleton level-\(i\) cluster \(2^{i+1}\), and singleton leaves zero. Stop when \(2^{i+1}\) is smaller than the minimum nonzero input distance. The cluster-diameter bound makes this an expansive 2-HST.

Fix \(x,y\) and \(t=d(x,y)\). Order all centers \(w_k\) by
\[
s_k=\min\{d(w_k,x),d(w_k,y)\},\qquad
h_k=\max\{d(w_k,x),d(w_k,y)\}.
\]
A raw partition can separate the pair through \(w_k\) only if the radius lies between \(s_k\) and \(h_k\), and \(w_k\) is first among \(w_1,\ldots,w_k\) in the permutation. Consequently
\[
\Pr[P_i\text{ separates }x,y]
 \le\sum_{k=1}^n
 \frac{|[s_k,h_k]\cap[2^{i-1},2^i]|}{2^{i-1}k}.
\]
The first separation at level \(i\) has **parent** label \(2^{i+2}\). The radial intervals have disjoint interiors, so
\[
\mathbb E[d_T(x,y)]
 \le\sum_{i\le-2}2^{i+2}\Pr[P_i\text{ separates }x,y]
 \le8\sum_{k=1}^n\frac{h_k-s_k}{k}
 \le8tH_n\le24t\ln n.
\]
Here \(h_k-s_k\le t\) and \(H_n\le1+\ln n\le3\ln n\). Fixed distance ties and radius endpoints do not affect the argument. This replaces local recursive sampling with global partitions; it is not a cosmetic repair.

### E4 and E5. Bounded-spread construction

For an equilateral metric, \(\Phi=1\). Replace the theorem's bounds by
\[
k=O((1+\ln\Phi)\ln n),\qquad
\operatorname{dist}(F)=O(\sqrt{1+\ln\Phi}\,\ln n),
\]
for \(n\ge2\), and choose \(\alpha=\max\{1,\lceil\lg\Phi\rceil\}\). These changes are tracked.

If a partition has \(m\) nonempty clusters, all are selected with probability \(2^{-m}>0\). Then the complement is empty. **Proposed insertion at the coordinate definition:** “If the complement is empty, set this entire coordinate identically to zero.” Apply the same convention to the unbounded construction. A zero coordinate is nonexpansive, and no successful event is lost because such an event requires \(y\) outside the selected set. The preliminary distance-to-set lemma is now explicitly restricted to a nonempty subset of a finite metric.

### E6 and E7. A valid quotient metric, without a false spread assertion

For \(n=4\), \(r_i=1\), and
\[
\mathcal X=\{0,1/5,1/4,9/20\}\subset\mathbb R,
\]
the threshold is \(1/16\). The components are \(A=\{0\}\), \(B=\{1/5,1/4\}\), \(C=\{9/20\}\). The proposed distances are \(1/5,1/5,9/20\), and \(9/20>1/5+1/5\).

**Proposed replacement of the component-distance definition:** let \(d_i\) be the shortest-path metric on the complete component graph, giving edge \(CC'\) weight \(\min_{c\in C,c'\in C'}d(c,c')\). Introduce \(q_i:\mathcal X\to\mathcal X_i\), mapping each point to its component. Then
\[
d(x,y)-r_i/n\le d_i(q_i(x),q_i(y))\le d(x,y).
\]
To prove the lower bound, lift a simple shortest component path to original points. Its total internal travel is at most
\(\sum_C(|C|-1)r_i/n^2<r_i/n\).
Positive intercomponent edge weights ensure this is a metric.

At each scale, sample partitions of \(\mathcal X_i\) with cluster diameter at most \(r_i\), and independently select clusters with probability \(1/2\). If \(V_{i,j}\) denotes the selected **components**, define
\[
f_{i,j}(x)=
 \min\{d_i(q_i(x),\,\mathcal X_i\setminus V_{i,j}),\,2r_i\},
\]
with the zero-coordinate convention when the complement is empty. This replaces the mixed point/component formula at original lines 845–846.

For a pair at distance \(\phi\), choose \(\phi/4\le r_i\le\phi/2\). The quotient distance is at least \(3\phi/4>r_i\), so the two components lie in different partition clusters. With \(\rho=\phi/(64\ln n)\), one has \(\rho\le r_i/8\). The padding lemma applied to a **quotient ball**, followed by independent cluster colors, gives the same success probability and lower-coordinate bound. Clipping preserves it because \(2r_i\ge\rho\). Thus the advertised lower-bound constant survives.

The spread assertion is separately false: for \(\mathcal X=\{0,\epsilon,1/2\}\), \(r_i=\epsilon=2^{-k}\), all components are singletons and spread is \(1/(2\epsilon)\), unbounded for fixed \(n=3\). **Delete the assertion \(O(n^2)\)** and replace the accompanying explanation by: “At each resolution \(r_i\), apply the random partition construction to the quotient metric at that scale.” No global spread bound is needed.

### G1. A fixed-center proof of the padding lemma

Order every center \(w_1,\ldots,w_b\) in the fixed ball \(B(x,\Delta)\) by its distance \(d_k\) to \(x\). Let \(A_k\) mean that \(w_k\) is the first center in the permutation among \(B(x,R+t)\), and \(d_k\ge R-t\).

If the first such center instead lies in \(B(x,R-t)\), it covers the target ball before any earlier center can touch it. Therefore ball-cutting implies some \(A_k\). For \(k\le a\), this event is impossible. Otherwise it implies both \(R\in[d_k-t,d_k+t]\) and that \(w_k\) is first among the fixed centers \(w_1,\ldots,w_k\). Radius/permutation independence gives
\[
\Pr[A_k]\le\frac{8t}{\Delta k}.
\]
Summing \(k=a+1,\ldots,b\), and using the harmonic integral bound, proves the stated lemma. The review copy uses \(0<t\le\Delta/8\); the case \(t=0\) is trivial.

The original argument can alternatively be repaired by proving monotonicity of the radius-dependent rank distances and summing to a fixed upper limit. This is why the finding is a gap, not a counterexample to the lemma.

### G2. What the quadtree sketch needs

Under ordinary cell-size labels, consider \(\{0,\epsilon,1\}\), \(\epsilon=2^{-m}\), and a randomly translated dyadic grid under a root of side length two. The close pair is split at scale \(2^{-j}\) with probability \(\epsilon2^j\). First-separation probabilities give
\[
\mathbb E[d_T(0,\epsilon)]=(m+2)\epsilon.
\]
Thus the expected stretch depends on spread even when \(n=3\).

This does **not** refute a suitably modified construction: occupied-cluster-diameter labels, for example, change this counterexample. The passage must specify its preprocessing and labels and justify the claimed \(n\)-only bound. The annotation asks for that missing argument rather than inserting an unverified fix.

### S1. Remove the clipping case split

After E5/E6, for a nonempty complement \(A=\mathcal X_i\setminus V_{i,j}\), use
\[
|\min\{d_i(q_i(x),A),2r_i\}
 -\min\{d_i(q_i(y),A),2r_i\}|
 \le |d_i(q_i(x),A)-d_i(q_i(y),A)|
 \le d_i(q_i(x),q_i(y))\le d(x,y).
\]
The first inequality is simply that \(s\mapsto\min\{s,2r_i\}\) is 1-Lipschitz. An empty complement gives the constant zero coordinate. This replaces the display and footnote, including their mistaken distances to \(V_{i,j}\) instead of its complement.

### N1. Exact symbol replacements

Counts below exclude comments and unrelated local meanings. Remaining proposals are not silently applied.

| Original locations | Exact old source | Proposed new source | Status |
|---|---|---|---|
| 55, 284, 391, 481, 494, 687, 811, 839 | `(\FMS,d)` | `(\FMS,\DistChar)` | Proposed, 8 occurrences |
| 416, twice | `d(x, w_k)` and `d(x,w_k)` | `\DistChar(x,w_k)` | Proposed |
| 84, 93 | `\DistChar_Y` | `\DistChar_\FMSB` | Proposed |
| 50, 52, 158, 178 | `\DistChar_G` | `\DistChar_\Graph` | Proposed |
| 230 | `G = C_n` | `\Graph = C_n` | Proposed |
| 456–457 | `\mathcal` followed by newline and `E_k` | `\Event_k` | Proposed |
| 376 | `of radius $r$` | `of radius $R$` | Tracked |
| 501, 503, 506, 511 | `\diam(P)` | `\diam(\FMS)` | Superseded by the proposed E3 replacement |
| 799, 801 | `$\Graph$` | `$G$` | Tracked |
| 908 | `$F(P)$` | `$F(\FMS)$` | Tracked |
| 911 | `for $P$` | `for $\FMS$` | Tracked |

The macro pairs `\Diam`/`\diam` and `\Spread`/`\Phi` render identically and were not reported as splits. Italic \(d\) remains valid as Euclidean dimension.

### N2. One index scheme for the bounded proof

Apply these together, after E4:

| Original locations | Old | New |
|---|---|---|
| 697 | `random partition of $P$` | `random partition of $\FMS$` |
| 698 | `\thmref{H:S:T}` | `\secref{partitions}` |
| 704–705 | `For a point $u \in` newline `x$` | `For a point $x\in\FMS$` |
| 713 | `i=0,\ldots, m` | `i=1,\ldots,\alpha` |
| 714–715 | `\Re^{(m+1) \cdot` newline `\beta}` | `\Re^{\alpha\beta}` |
| 732–733 | `Let $k$ be an integer such that $r_u \leq \phi/2 \leq r_{u+1}$` (across lines) | `Choose $1\leq u\leq\alpha$ such that $r_u\leq\phi/2\leq2r_u$` |

Replace the entire coordinate list at lines 720–727 by:
```latex
\underbrace{f_{1,1}(x),f_{1,2}(x),\ldots,
 f_{1,\beta}(x)}_{\text{first resolution block}},
 \ldots,
 f_{\alpha,1}(x),f_{\alpha,2}(x),\ldots,
 f_{\alpha,\beta}(x)
```

Retain the surrounding parentheses. State that partitions and fair cluster-color coins are sampled independently across repetitions. The repaired scale inequality avoids referring to the undefined \(r_{\alpha+1}\).

### Exercise checks and rejected suspicions

The uniform-star exercise is valid with constants independent of dimension: packing gives \(D\ge n^{1/d}/4\); a maximal 2-separated set in a ball of radius \(2n^{1/d}\), containing the origin, gives the matching upper bound.

The occupied-dyadic-scale assertion is also **valid**, not an error. Let \(T\) be a minimum spanning tree. For every occupied integer \(i\), its witnessing pair has an MST path whose edges have weight at most \(2^{i+1}\), so
\[
2^i\le\sum_{e:w_e\le2^{i+1}}w_e.
\]
After division by \(2^i\) and summation over occupied \(i\), each edge contributes at most four. Hence \(|U|\le4(n-1)\). Only the missing integer/existential binding and the concluding “\(n\)” instead of “\(O(n)\)” needed local corrections.

The HST clustering dynamic program and diameter exercises also check out under their stated/repaired parameter ranges. The latter's linear-time grid extraction uses the usual grid-indexing model; sparse hashing gives expected linear time.

### Reproducible calculation checks

The scratch [calculation script](/tmp/latex-review-42.eiyUBe/calculations.rb) and [tree check](/tmp/partitions_trees_check.rb) were run with Ruby:

```text
ruby /tmp/latex-review-42.eiyUBe/calculations.rb
ruby /tmp/partitions_trees_check.rb
```

The first prints the quotient triangle failure `9/20 > 2/5`, star comparison `4/3 < 2`, and geometric-tail value `1/192`, which exceeds the original bound `841/202500` and satisfies the repaired bound `841/151875`. The second checks all 24 permutations in the four-point tree example. These computations accompany the exact proofs above, not a claim that testing establishes the general theorems.

## Minor corrections applied

These edits are applied without markup and excluded from finding counts. Locations are in the reviewed original. In the table, **↵ denotes a source newline**, and repeated identical edits are grouped. The two longer calculation replacements are local repairs of upper bounds; their hypotheses and the intended final bounds are unchanged.


| Original lines | Old | New |
|---|---|---|
| 25 | `\index{metric space} \index{metric space}` | `\index{metric space}` |
| 46 | `spaces rise naturally` | `spaces arise naturally` |
| 60 | `Underling` | `Underlying` |
| 124 | `euclidean` | `Euclidean` |
| 144 | `at least one pair of points $x, y \in \FMS$` | `at least one pair of distinct points $x, y \in \FMS$` |
| 145 | `\dist{x-y}` | `\dist{f(x)-f(y)}` |
| 146 | `\max_{x,y} \frac{\dist{x - y}}{\DistChar(x,y)}` | `\max_{x\ne y} \frac{\dist{f(x)-f(y)}}{\DistChar(x,y)}` |
| 153 | `Consider the a graph` | `Consider a graph` |
| 155 | `three leafs` | `three leaves` |
| 168 | `$a' = f(a), b'= f(b)$ and $c' =f(c)$.` | `$a' = f(a)$, $b'=f(b)$, $c'=f(c)$, and $s'=f(s)$.` |
| 193 | `inscribing circle` | `circumscribed circle` |
| 208 | `nicely ↵ demonstrate` | `nicely ↵ demonstrates` |
| 233 | `the root $r$ of $\HST$` | `the least common ancestor $r$ of all image leaves in $\HST$` |
| 234, 235 | `n/2` | `\floor{n/2}` |
| 255 | `is NP-complete` | `is NP-hard` |
| 264 | `Is not too hard` | `It is not too hard` |
| 397 | `and $t$ a parameter $\leq ↵         \Delta/8$` | `and $t$ a parameter satisfying $0<t\leq\Delta/8$` |
| 430, 431 | `happen then` | `happens then` |
| 477 | `$(\FMS,\DistChar)$. we` | `$(\FMS,\DistChar)$, we` |
| 480 | `algorithm that embed` | `algorithm that embeds` |
| 515 | `in $t$` | `in $T$` |
| 530 | `first to happened` | `first to happen` |
| 558 | `clustering. Number, find` | `clustering. Namely, find` |
| 575 | `can be easily be verified` | `can easily be verified` |
| 597 | `&= %` | `&\leq %` |
| 653 | `closet points` | `closest points` |
| 699 | `c \log n` | `c \ln n` |
| 703 | `be the all the points` | `be all the points` |
| 750 | `&=%` | `&\geq%` |
| 761 | `happens, than` | `happens, then` |
| 767 | `probability that only $\beta/16$ of ↵     $\Event_1, \ldots, \Event_\beta$ happens, is ↵     $\Prob{Z < (1-1/2)\Ex{Z}}$. By the Chernoff inequality, we have ↵     \[ ↵     \Prob{Z < (1-1/2)\Ex{Z}} \leq \exp \pth{ - \mu 1/(2\cdot 2^2)} = ↵     \exp \pth{ -\beta/64} \leq 1/n^{10},` | `probability that fewer than $\beta/16$ of ↵     $\Event_1,\ldots,\Event_\beta$ occur is bounded by the Chernoff inequality: ↵     \[ ↵     \Prob{Z<\beta/16}\leq\Prob{Z<\mu/2} ↵     \leq \exp(-\mu/8)\leq\exp(-\beta/64)\leq 1/n^{10},` |
| 797 | `O( \sqrt{\ln \Phi} \ln n)` | `O(\sqrt{1+\ln\Phi}\ln n)` |
| 838 | `its connected components` | `its connected component` |
| 867 | `For a pair $x,y \in \FMS$, and let` | `For a pair $x,y \in \FMS$, let` |
| 875 | `r_i > \phi n^2` | `r_i \geq \phi n^2` |
| 883 | `\phi/n^2 < r_i < \phi` | `\phi/n^2 \leq r_i < \phi` |
| 887 | `&=% ↵     \beta \phi^2 \lg \pth{n^4} + ↵     \sum_{i, r_i < \phi/n^2} (2r_i)^2 \beta ↵     \\& ↵     \leq 4\beta \phi^2 \lg n + \frac{4\phi^2\beta}{n^4 }` | `&\leq% ↵     \beta \phi^2 \ceil{4\lg n} + ↵     \sum_{i, r_i < \phi/n^2} (2r_i)^2 \beta ↵     \\& ↵     \leq \beta\phi^2\ceil{4\lg n}+\frac{16\phi^2\beta}{3n^4}` |
| 904 | `every pair of distances` | `every pair of points` |
| 908 | `it is $n-1$ dimensional` | `it has dimension at most $n-1$` |
| 909 | `that projects a point to its ↵ closest point in $h$` | `that projects a point to its ↵ closest point in $h$, followed by a translation and an isometric ↵ identification of $h$ with a subspace of $\Re^{n-1}$` |
| 939 | `which showed` | `who showed` |
| 947 | `which achieve` | `who achieved` |
| 965 | `Truely` | `Truly` |
| 971 | `get similar result` | `get a similar result` |
| 972 | `then reduce` | `then reducing` |
| 973 | `finally, construct` | `finally, constructing` |
| 978 | `several result` | `several results` |
| 979 | `in Arora \cite{a-ptase-98} approximation algorithm for` | `in the approximation algorithm of Arora~\cite{a-ptase-98} for` |
| 1039 | `i \sep{ 2^i` | `i\in\mathbb{Z} \sep{ 2^i` |
| 1040 | `\text{ for } x,y \in \FMS` | `\text{ for some } x,y \in \FMS` |
| 1044 | `only $n$ different` | `only $O(n)$ different` |
| 1074 | `Given a set $P$ of $n$ in the plane, given ↵         a $O(n/\sqrt{\eps})$ time algorithm` | `Given a set $P$ of $n$ points in the plane, give ↵         an $O(n/\sqrt{\eps})$ time algorithm` |
| 364 | `permutation in distance $\leq R$ from $x$.` | `permutation in distance $<R$ from $x$.` |
| 370 | `P = \{C_y\}_{y \in \FMS}` | `P = \{C_y:y\in\FMS,\ C_y\ne\emptyset\}` |
| 486 | `$\max_{x,y}` | `$\max_{x\ne y}` |
| 141 | `it would useful` | `it is useful` |
| 222 | `A HST` | `an HST` |
| 494 | `Given $n$-point` | `Given an $n$-point` |
| 567 | `a $n$-point metric space` | `an $n$-point metric space` |
