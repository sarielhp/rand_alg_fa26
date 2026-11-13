# Review of Entropy, Randomness, and Information

Locations below refer to the original [entropy.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex). The original is unchanged; this review did not edit shared sources or other chapters.

## What was done

- Created [entropy_review.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy_review.tex) and its [PDF](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy_review.pdf): **7 tracked edits**, **8 notes with matching anchors**, no legacy remarks. Minor corrections are applied without markup and logged below. An annotation is not necessarily an applied correction: statuses are explicit below and in the copy.
- Read the complete chapter, captions, relevant shared macros, and its bibliography entry. Checked the derivatives, entropy additivity, binomial sandwich, all four rounded bounds, the elementary fraction inequality, and both extraction theorems. Separate simplification, notation, and writing passes covered the whole chapter. No proof was merely skimmed.
- Verification: **independent-agent** for both substantive errors, the simplification, both notation repairs, both mathematical writing proposals, and the local mathematical corrections. A separate verifier tried to refute the findings and checked the repairs. No unresolved technical findings remain. A proposed small-instance witness for the pointwise upper-bound problem was strengthened to cover arbitrarily large inputs; see E2.
- Models: reviewers inherited the parent model; exact backend model identifiers were unavailable. Correctness, simplification/notation, writing, and independent verification were each explicitly requested at **high** reasoning effort. The coordinator's exact effort setting was unavailable.
- Computations: Ruby checked 24,120 rounded binomial inequalities for `n=1..60`, `q=j/200` (relative floating tolerance `1e-12`), and the stronger block-extraction bound exactly for `m=1..10000`. These supplement the algebraic proofs. Numerical entropies agree with the text. Reproduction: `ruby /tmp/entropy-review-check/check.rb`; the [scratch script](/tmp/entropy-review-check/check.rb) passes syntax and Ruby audit. Scratch paths are session-local.
- Build: the prescribed `/home/sariel/bin/l -no-env -s entropy.tex` failed in its bibliography stage with `Cannot find './book.bib'`, despite the chapter's valid bibliography symlink. A fallback build of the original and review copy in an isolated temporary tree used **XeLaTeX, Biber, XeLaTeX, XeLaTeX**, with TeX/Bib environment overrides cleared. Both finished with **0 errors, no unresolved references/citations, and the same single warning**: float option `h` changed to `ht`. Review-introduced overfull boxes were fixed. Representative definition and theorem annotation pages were visually inspected.
- Cleanup: ran the repository's `./tools/clean --skip-compile` in the isolated build tree after preserving the review PDF. It removed temporary files and scratch chapter PDFs. This avoided a repository-wide cleanup of unrelated work. Final status includes concurrent changes outside this chapter; none were changed by the review. The original's SHA-256 remains `937f31cbd37496de67e59dd5044989999cf3f93243f65f3f55b00b8b2d93a91b`.

## Summary of findings

**2 errors, 0 gaps, 0 unclear findings, 1 simplification, 2 notation findings, and 3 writing findings.** The central distinction is between a random output length and a guaranteed bit count. The intended expected-length theorem is valid after the definition and statement repairs and the local calculation corrections.

### Errors

- **E1**, [definition `extract`, lines 283–292](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:283): condition on the random output length and require positive conditioning probability (confidence: high). Formal replacement proposed in the note; explanatory bullet corrected with tracking.
- **E2**, [final theorem, lines 431–442](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:431): both bit-count bounds must concern **expectation**, and the flips must be independent (confidence: high). Statement corrections tracked in the copy.

### Simplifications

- **S1**, [proof of `extract`, lines 361–428](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:361): a direct weighted sum removes the induction and all three cases, and strengthens the bound. Added as a separate alternative proof after the existing proof for comparison, including an induction hint for the finite-sum identity. Choosing it in place of the original would also make the Tedium at lines 323–339 unnecessary.

### Notation

- Counts: **0 clashes, 0 splits, 0 convention violations, 2 definition findings** (N1/N2). E1 is an additional technical conditioning-definition issue, counted under Errors, not counted twice.
- **N1**, [lines 40–41](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:40): define the probability mass function before evaluating it at a random outcome. Proposed, not applied.
- **N2**, [final proof, lines 445–518](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:445): explicitly bind `X` to the input sequence. Tracked insertion applied.

Proposed notation rules: retain uppercase random variables and lowercase outcomes; explicitly introduce locally reused symbols; retain `\lg` for bits and `\ln` for natural logarithms. These are existing conventions. Newly proposed: name a mass function before evaluating it at a random variable. The intentional overload of `\Entropy{X}` and `\Entropy{p}` needs no rename. Equivalent delimiter/conditional-probability macros do not warrant unification.

### Writing

- **W1**, [lines 224–233](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:224): distinguish the full sequence's exact entropy from entropy conditional on a fixed head count. Full replacement proposed in the note; the local equality-to-approximation slip is corrected separately.
- **W2**, [lines 278–279](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:278): replace the unqualified identification of entropy with extracted bits by an expected-length upper bound and a signpost to asymptotic attainability. Tracked replacement applied.
- **W3**, [line 530](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:530): name Mitzenmacher and Upfal explicitly. Tracked insertion applied; authors verified in [shared/book.bib](/home/sariel/papers/teach/26/fa26_rand_alg/notes/shared/book.bib:1250), with citation key and locator preserved.

## Details

### E1. Condition on the length of the random output

Old condition: `\ProbCond{\ExtractFunc(X)=y}{|y|=k}=2^{-k}`, whenever `\Prob{|y|=k}\geq0`. For fixed `y`, its length is deterministic. Moreover, a nonnegative probability condition does not exclude null conditioning events.

Proposed replacement definition:

```latex
An extraction function is a deterministic function $\ExtractFunc$ whose
output is a finite binary string. Set $L=\cardin{\ExtractFunc(X)}$.
For every integer $k\geq0$ with $\Prob{L=k}>0$, and every
$y\in\brc{0,1}^k$, require
\[
  \ProbCond{\ExtractFunc(X)=y}{L=k}=2^{-k}.
\]
```

Consequently the unconditional probability is `Pr(L=k)/2^k`, not necessarily `2^{-k}`. In the chapter's `m=12` example, each two-bit output has unconditional probability `1/12` and conditional probability `1/4`. The formal definition remains annotated for replacement; the first explanatory bullet now explicitly states the conditional probability. Fixed-width example corrections are logged below.

### E2. A positive deterministic output length can be impossible

Take `p=3/4`. For any fixed positive `n`, a particular input with `j` heads has probability `3^j/4^n`. A subset of inputs therefore has a probability numerator congruent to either `0` or `1` modulo `3`: only the all-tails input contributes a numerator not divisible by `3`. Probability `1/2`, however, requires numerator `4^n/2`, congruent to `2` modulo `3`. No deterministic function can always output even one fair bit. Thus rounding the claimed bit count does not fix the theorem.

Conversely, an individual output can exceed input entropy. For fixed `p=0.9`, the balanced type class has size

\[
m=\binom n{\lfloor n/2\rfloor}\geq\frac{2^n}{n+1}.
\]

The chapter's block extractor outputs `floor(lg m)` bits on its largest block, hence at least `n-lg(n+1)-1` bits. For all sufficiently large `n`, this exceeds `n H(0.9)`, and those inputs have positive probability. The entropy bound applies to the **average**.

The tracked statement now specifies independent flips and expected lengths. The repaired lower-bound calculation retains

\[
A=nH(p+\varepsilon)-\lg(n+1)-2
\]

and sums over `ceil(n(p-epsilon))` through `floor(n(p+epsilon))`. For fixed `1/2<p<1` and `0<delta<1`, choose `0<epsilon<min(p-1/2,1-p)` sufficiently small that `H(p+epsilon)>(1-delta/4)H(p)`. For large enough `n`, absorb `lg(n+1)+2` into `(delta/10)nH(p)` and bound the tail probability by `delta/10`. The resulting coefficient is

\[
(1-\delta/4-\delta/10)(1-\delta/10)
=1-0.45\delta+0.035\delta^2\geq1-\delta.
\]

The trivial lower-bound cases `p=1` and `delta>=1` are now discharged separately. The converse still applies in those cases: sum over positive-probability inputs and use `H(X)=nH(p)`.

One implicit construction step is valid: conditional on both a head count and an output length, the output is uniform; mixing over head counts preserves uniformity at that length. This is not reported as a gap.

### S1. Replace the induction by one finite sum

Keep the block construction. Let `k=floor(lg m)`, write `m=sum a_i 2^i` with `a_k=1`, and let `L` be the output length. A block of size `2^i` contributes probability `a_i 2^i/m`, so, for `k>=1`,

\[
\begin{aligned}
m(\mathbb E[L]-(k-1))
&=\sum_{i=0}^{k}a_i2^i(i-k+1)\\
&=2^k-\sum_{i=0}^{k-2}a_i(k-1-i)2^i\\
&\geq2^k-\sum_{i=0}^{k-2}(k-1-i)2^i=k+1.
\end{aligned}
\]

The finite-sum identity follows by subtracting the standard geometric and weighted geometric sums; it also follows immediately by induction on `k`. The sum is empty when `k=1`; `m=1` is immediate separately. This proves the stronger bound `E[L]>=k-1+(k+1)/m`. A separate alternative proof now follows the existing proof in the review copy and includes the induction hint. Both proofs and the Tedium are retained for comparison.

### N1–N2. Exact notation changes

**N1:** replace the single occurrence `\Prob{X}` at line 41 by `p_X(X)`, introducing `p_X(x)=\Prob{X=x}` immediately before the expectation. The complete replacement is:

```latex
where $\lg x$ is the logarithm base $2$ of $x$.
Writing $p_X(x)=\Prob{X=x}$, we equivalently have
$\Entropy{X}=\Ex{\lg(1/p_X(X))}$.
```

Use `0\lg0=0` in the entropy sum, or explicitly sum only over the support. `p_X` is free in this scope. The expectation samples only positive-mass outcomes. This remains a proposal.

**N2:** insert `Let $X$ denote the random input sequence.` at the start of the final proof. This binds the five formerly implicit occurrences at lines 509, 514, 516 (twice), and 518. Counts exclude comments and prior locally defined random variables. The insertion is tracked; no global rename was performed.

### W1. Separate exact entropy from the counting heuristic

The proposed paragraph says: for `n` independent flips with head probability `q`, the full sequence has entropy exactly `nH(q)`. Conditional on any head count `j` of positive probability, it is uniform on `binom(n,j)` strings and has entropy `lg binom(n,j)`, between `nH(j/n)-lg(n+1)` and `nH(j/n)`. This also avoids using a binomial coefficient with a noninteger lower argument. The proposal appears in full beside the original paragraph.

## Minor corrections applied

These corrections are applied only to the review copy, without inline markup, and are excluded from finding counts. Mathematical repairs were independently checked. Newlines below are shown as `↵`; spacing-only changes used to separate tracked old/new text are omitted.

| Original line(s) | Old | New |
|---|---|---|
| [58](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:58) | `is a concave symmetric` | `is concave and symmetric` |
| [61](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:61) | `a coin that has $3/4$ probably to be heads ↵ have higher amount` | `a coin that has probability $3/4$ of coming up heads ↵ has a higher amount` |
| [77](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:77) | `compute derivative of simple` | `compute derivatives of simple` |
| [86](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:86) | `and the $\Entropy{\cdot}$ is concave` | `and $\Entropy{\cdot}$ is concave` |
| [99](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:99) | `Note, that the entropy` | `Note that the entropy` |
| [101](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:101) | `a random variables that accepts $-1,+1$` | `a random variable that takes the values $-1,+1$` |
| [113](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:113) | `summation are` | `summations are` |
| [139](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:139) | `$nq$ is integer` | `$nq$ is an integer` |
| [182](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:182) | `it is larger than the average` | `it is at least the average` |
| [191](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:191) | `non-integer values of ↵ $q$` | `non-integer values of ↵ $nq$` |
| [231](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:231) | `\lg \binom{n}{nq} = n \Entropy{q}` | `\lg \binom{n}{nq} \approx n \Entropy{q}` |
| [242](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:242) | `Our purpose is built an` | `Our purpose is to build an` |
| [243](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:243) | `algorithm that given $X$ output a binary string` | `algorithm that, given $X$, outputs a binary string` |
| [250](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:250) | `We break the $\IRY{0}{m-1}$ into consecutive blocks that are powers of` | `We break $\IRY{0}{m-1}$ into consecutive blocks whose sizes are powers of` |
| [253](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:253) | `if a block is length` | `if a block has length` |
| [297](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:297) | `to do in this case, is just to compute the binary representation of ↵ $x$.` | `to do in this case is compute the three-bit binary representation of ↵ $x$, including leading zeros.` |
| [312](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:312) | `can output the binary ↵ representation for $x$` | `can output the three-bit binary ↵ representation of $x$` |
| [315](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:315) | `a two bit number` | `a two-bit number` |
| [321](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:321) | `can be of course extended` | `can of course be extended` |
| [352](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:352) | `we ↵     decomposed` | `we ↵     decompose` |
| [356](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:356) | `using binary representation` | `using a binary representation` |
| [363](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:363) | `Thus, if $m$ is not a power of $2$, then in the decomposition if ↵     there is a block of size $2^k$, and the $X$ falls inside this ↵     block, then the entropy is $k$.` | `If $X$ falls inside a block of size $2^k$, then the scheme outputs ↵     $k$ bits.` |
| [376](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:376) | `$\IRY{0}{m - K}$` | `$\IRY{0}{m - K - 1}$` |
| [411](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:411) | `k - \frac{2U}{2U + K}\pth{ u -k-1}` | `k + \frac{2U}{2U + K}\pth{ u -k-1}` |
| [415](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:415) | `$\Entropy{X} \geq k - \frac{1}{2}` | `$\Ex{Y} \geq k - \frac{1}{2}` |
| [416](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:416) | `$\Entropy{X} \geq k - \frac{1}{3}` | `$\Ex{Y} \geq k - \frac{1}{3}` |
| [445](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:445) | `(insertion at proof start)` | `For the lower bound, the cases $p=1$ and $\delta\geq1$ are immediate by outputting the empty string. Otherwise, assume $1/2<p<1$ and $0<\delta<1$.` |
| [447](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:447) | `We map this sequence ↵     to the corresponding number in the set` | `Fix an ordering of these sequences and map each ↵     to its index in the set` |
| [449](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:449) | `Note, that this, conditional distribution on ↵     $j$, is uniform on this set` | `Note that the conditional distribution, given ↵     $j$, is uniform on this set` |
| [451](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:451) | `Let $Z$ be the random variables` | `Let $Z$ be the random variable` |
| [458](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:458) | `Let $\eps < p-1/2$ be a` | `Let $0<\eps < \min\{p-1/2,1-p\}$ be a` |
| [465](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:465) | `    by \corref{q:integer:values} (iii). We have` | `    by \corref{q:integer:values} (iii). For $n$ sufficiently large, ↵     $n\Entropy{p+\eps}-\lg(n+1)-2$ is nonnegative. We have` |
| [468](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:468), [471](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:471), [474](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:474) | `\sum_{k=\floor{n(p-\eps)}}^{\ceil{n(p-\eps)}}` | `\sum_{k=\ceil{n(p-\eps)}}^{\floor{n(p+\eps)}}` |
| [478](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:478) | `\pth{ n  \Entropy{p+\eps} - \lg(n+1) }` | `\pth{ n  \Entropy{p+\eps} - \lg(n+1) -2 }` |
| [481](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:481) | `\pth{ n  \Entropy{p+\eps} - \lg (n+1) }` | `\pth{ n  \Entropy{p+\eps} - \lg (n+1) -2 }` |
| [491](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:491) | `- \lg\pth{n+1}\geq -` | `- \lg\pth{n+1}-2\geq -` |
| [503](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:503) | `if an input sequence $x$ has ↵     probability $q$,` | `if an input sequence $x$ in the support has ↵     probability $q>0$,` |
| [511](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:511) | `\begin{equation*} ... \end{equation*}` | `\begin{align*} ... \end{align*}; the final expectation calculation uses separate rows for =, <=, = to fit the page.` |
| [514](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:514) | `\sum_{x} \Prob{X = x} \cardin{\ExtractFunc(x)}` | `\sum_{x:\,\Prob{X=x}>0} \Prob{X = x} \cardin{\ExtractFunc(x)}` |
| [516](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:516) | `\sum_{x} \Prob{X = x} \lg \frac{1}{\Prob{X=x}}` | `\sum_{x:\,\Prob{X=x}>0} \Prob{X = x} \lg \frac{1}{\Prob{X=x}}` |
| [518](/home/sariel/papers/teach/26/fa26_rand_alg/notes/43_entropy/entropy.tex:518) | `\Entropy{X}.` | `\Entropy{X}=n\Entropy{p}, followed by: by independence and \lemref{entropy:independent}.` |
