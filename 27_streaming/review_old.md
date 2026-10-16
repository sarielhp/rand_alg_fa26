# Review of “Streaming and the Multipass Model”

All locations below refer to the original [streaming.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex). The original manuscript and shared styles were not changed.

## What was done

- Created [streaming_review.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming_review.tex): **2 tracked prose edits and 23 review notes**, plus silent mechanical corrections. Mathematical repairs are proposals in notes and this report; the annotated chapter is not a corrected edition.
- Read the entire chapter, the included Chernoff statement, and the shared preamble/macros. Checked all arguments, including the unproved stronger sampling lemma and the two-pass theorem's dependencies. Performed separate simplification, notation, and writing passes.
- Correctness, notation/simplification, and adversarial verification used fresh-context agents with **high reasoning effort**; the writing reviewer also used high effort. Agents inherited the session model; the exact runtime model identifier and coordinator effort are not exposed. No lower-effort override was requested.
- **Verification: independent-agent.** All 17 reported errors/gaps, both simplifications, four notation proposals, and mathematical wording changes were independently checked. Two overly strong diagnoses were rejected: the heavy-hitter paragraph does not literally promise all hitters, and the chapter's final general-pass space bound has not been disproved. These are reported as gaps. The longer deterministic counter calculation is valid; its shortening is only S2.
- Ruby 3.3.8 computations checked the integral, reservoir miss probability, off-by-one selection, thinning counterexample, and heavy-hitter failures. Exhaustive checks covered 9,840 short streams for the repaired counter algorithm and all 40,320 permutations of eight items for the repaired thinning invariant. These finite checks supplement the proofs below.
- Build results are recorded at the end. A small [review bibliography](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming_review.bib) supplies the two existing citations without modifying the original bibliography setup.

## Summary

**10 errors, 7 gaps, 2 simplifications, 4 notation findings, and 4 writing findings.** The main repairs are in median selection: invalid pivot ranks, an off-by-one output rank, inconsistent comparison/space accounting, and a false thinning invariant. The reservoir induction and the deterministic cancellation argument are sound once the sampling units and update cases are stated correctly.

### Errors

- **E1**, [line 38](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:38): independent qualities do not imply the random rank order used by the secretary calculation. **High confidence.**
- **E2**, [line 84](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:84): the integral evaluates to `ln(n−1)−ln(r−2)`; the asymptotic conclusion also needs a lower bound. **High confidence.**
- **E3**, [line 324](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:324): both sample pivot ranks omit division by two; the upper rank exceeds the sample size. **High confidence.**
- **E4**, [line 336](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:336): selection from the inclusive interval is off by one, and the failure check misses invalid ranks. **High confidence.**
- **E5**, [line 361](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:361): sorting the stated sample contributes `n^(2/3) log² n`, invalidating the displayed accounting. **High confidence.**
- **E6**, [line 348](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:348): `1−1/δ` should be `1−δ`. **High confidence.**
- **E7**, [line 418](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:418): repeated thinning does not satisfy the asserted rank interval; the proposed narrow bracket is unjustified. **High confidence.**
- **E8**, [lines 478 and 488](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:478): the reservoir miss probability is hypergeometric, and `exp(φ)=φ` is false. **High confidence.**
- **E9**, [line 508](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:508): the sequential update conditions can reset a tracked counter; they must be mutually exclusive. **High confidence.**
- **E10**, [line 519](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:519): the guarantee after `t` inputs concerns `S_t`; the proof also confuses the element `e` with its frequency `u`. **High confidence.**

### Gaps

- **G1**, [line 100](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:100): specify sampling of positions, short prefixes, and the tails transition. **High confidence.**
- **G2**, [line 200](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:200): noninteger/zero order-statistic indices and an unspecified sampling law leave the median lemmas incomplete. **High confidence.**
- **G3**, [line 375](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:375): an expectation calculation does not prove the claimed high-probability comparison bound; S1 removes the issue. **High confidence.**
- **G4**, [line 383](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:383): the two-pass implementation needs more space than stated, a without-replacement tail argument, and an explicit pass/failure policy. **High confidence.**
- **G5**, [line 350](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:350): repeated values defeat the retained-interval size bound; use consistent tie-breaking. **High confidence.**
- **G6**, [line 475](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:475): the single-hitter probability does not establish the section's all-hitters objective. **High confidence.**
- **G7**, [line 431](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:431): the asserted general-pass logarithmic factor is stronger than the cited theorem and lacks a proof. **High confidence that justification is missing; no impossibility claim.**

### Simplifications

- **S1**, [line 375](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:375): always compare to the lower pivot first; the good sampling event already gives the `1.5n` scan bound.
- **S2**, [line 540](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:540): replace the ceiling expansion by `u−t/(k+1) ≥ εt−t/(k+1) > 0`.

### Notation

- **N1 — clash:** reserve `P(r)` for success probability; use `\ProbCond` for the conditional event at line 66.
- **N2 — split:** replace the two upper-pivot `R` occurrences at lines 324 and 326 by `H`, matching five later uses.
- **N3 — convention:** replace the two `k^+` occurrences at lines 293 and 296 by `k_+`, matching `k_-`.
- **N4 — definition:** introduce `δ` and `\BadProb` (rendered `φ`) as failure probabilities before use.
- Counts among N findings: clash **1**, split **1**, convention **1**, definition **1**. G2 adds **1 technical definition finding**, counted only once in the overall totals. Occurrence counts exclude comments and unrelated meanings.
- Highest payoff: unify the upper pivot, declare probability parameters, and separate `P(r)` from the event-probability operator. The shared `\rankY` renders an indexed order statistic; the local `\providecommand` is inactive, which is not a rendered notation error.

### Proposed notation rules

- **Established:** use `\Prob` and `\ProbCond` for event probabilities, and `P(r)` for the secretary strategy's success function.
- **Proposed:** use `L,H` for the filtering pivots and `k_-,k_+` for their sample ranks.
- **Proposed:** state each local failure parameter's domain and define all order-statistic indices as integers.
- **Proposed:** distinguish a sampled stream occurrence from its value; use an array/multiset when sampling with replacement.

### Writing

- **W1**, lines 36 and 444: move the streaming-model introduction before the algorithms and add an overview connecting online selection, sampling, multipass selection, and heavy hitters; annotated as a suggestion.

- **W2**, lines 273–276: explain why the next lemma needs two
  bracketing order statistics; tracked in the review copy.

- **W3**, lines 228 and 245: the guarantee is an interval event, not an exact rank distance; a sufficient bad event is not itself necessarily failure. The second correction is tracked; the first is a mathematical wording note.
- **W4**, original displays ending at lines 77, 158, 179, 260, and 549: split the long equations across lines. The original also lacks the bibliography files needed for an isolated build; details below.

## Details and proposed repairs

### E1–E2. Secretary assumptions and asymptotics

Replace “the quality of each one of them is an independent random event” by “the applicants have distinct qualities and arrive in a uniformly random order.” Independent identically distributed continuous qualities are another sufficient assumption. Independence alone is insufficient: independent qualities uniform on `(3,4)`, `(1,2)`, and `(0,1)` make the best applicant always first. Then `P(2)=0`, but the displayed formula gives `1/2`.

For integer `3 ≤ r ≤ n`, the correct sandwich is

\[
\ln\frac{n}{r-1}\le \sum_{i=r}^{n}\frac1{i-1}
\le \ln\frac{n-1}{r-2}.
\]

For `n=10,r=4`, the sum is `1.328968254`, the integral is `1.504077397`, and the printed logarithmic expression is `1.386294361`. Choose `r=1+⌊n/e⌋` and explicitly take `n→∞`; both bounds tend to 1 and `(r−1)/n→1/e`. Treat `r=1,2` separately if those strategies are discussed.

### G1. Reservoir sampling is uniform over occurrences

The usual interpretation is valid, but the proof should say that `s_i` denotes an indexed occurrence. Sample `min(k,t)` distinct indices from the first `t` positions and return their values, retaining repetitions. Otherwise the set `{s_1,…,s_t}` need not have size `t`: on `a,a,b`, a two-position reservoir returns values `a,a` with probability `1/3` and `a,b` with probability `2/3`.

At lines 119–123, also specify `S_0=∅` and `S_i=S_{i−1}` on tails. Once occurrences are distinct, both displayed induction cases are correct. A length-`k` array implements uniform replacement in constant time per arrival in the usual word model.

### G2. State the rank and sampling conventions

The definition at line 200 only covers integer ranks, while the lemmas use real indices. The stronger lemma uses “a set of k samples” without saying whether they are independent or sampled without replacement. With replacement the sample must be an array/multiset even if the input keys are distinct.

There is also a genuine boundary problem: for any fixed proposed constant `c`, choose `δ<1` sufficiently close to 1 that `⌈c ε^−2 ln(1/δ)⌉=1`. Then permitted `k=1` gives `k_-=0` at line 296, so the stated order statistic does not exist.

A repair should define the chosen integer median rank, round lower population bounds downward and upper bounds upward, handle indices outside `[1,n]`, and use valid sample pivot indices (for example floor/ceiling of `(1∓ε)k/2`). Restricting the stronger lemma to `0<δ≤1/2` and a sufficiently large absolute constant supplies a useful lower bound on `k`; small input sizes can be handled directly.

Do not just add floor symbols and leave the proof unchanged: its equality `Pr[X_i=1]=(1−ε)/2` and lower bound `μ≥k/4` may then fail. Bound the bad-event count by a binomial with success probability `(1−ε)/2`, or redo the tail estimate. For the lower failure event, count values strictly below the rounded lower endpoint; for the upper failure event, count values strictly above the rounded upper endpoint. This preserves the needed probability upper bounds. G4 supplies the without-replacement justification needed later.

### E3–E6, G3–G5, S1. A coherent median-selection repair

1. Use integer pivot ranks near `(1−ε)k/2` and `(1+ε)k/2`. At `k=100,ε=0.1`, the manuscript requests ranks 90 and 110; the intended unrounded ranks are 45 and 55.
2. Keep the definition `α=rank_B(L)` and inclusive `T`. Select rank `q=m−α+1` within `T`, where `m` is the chosen integer median rank. Fail unless `1≤q≤|T|`. For `B=1,…,8,L=2,H=6`, the original returns 3; the corrected rank returns 4. Equivalently redefine `α` as the number of keys strictly below `L` and keep `q=m−α`.
3. Make the sample size a sufficiently large explicit multiple: `k=Θ(n^(2/3) log n)` for fixed polynomial failure exponent. The current `O(…)` specification alone supplies no lower bound. Select the two sample pivots in linear time instead of sorting the sample. Two linear-time order-statistic calls cost `O(k)`; sorting the retained `O(n^(2/3))` keys then fits the advertised comparison remainder. If sorting the sample is retained, change the comparison remainder to `O(n^(2/3) log² n)` instead.
4. Correct `1−1/δ` to `1−δ`. The former is negative for every allowed `δ<1` and conveys no useful guarantee.
5. **S1:** compare every key to `L` first, and compare to `H` only when the key is at least `L`. Writing `ℓ=rank_B(L)`, the scan uses `n+(n−ℓ+1)` comparisons. The stronger sampling event gives `ℓ≥n/2−εn−O(1)`, so this is at most `1.5n+εn+O(1)`. For `ε=n^−1/3`, the extra term is `O(n^(2/3))`. This removes the extra random coins and concentration argument.
6. If random comparison order is retained instead, conditional on the pivots and `a=|T|`, the scan cost has distribution `n+a+Bin(n−a,1/2)`. Its expectation is `1.5n+a/2`; a tail bound contributes `O(√(n log n))` with high probability. This closes G3, but is longer than S1.
7. For the straightforward two-pass implementation, state **`O(n^(2/3) log n)` space**. The reservoir alone has that size. This is a defect in the offered proof of the smaller space theorem, not a disproof of every possible algorithm achieving it.
8. Use keys `(value, original stream position)` consistently in both passes and return the numeric component. An all-equal input otherwise makes `L=H` and retains all `n` occurrences, contradicting the claimed small interval.
9. To enforce a space bound on every execution, cap the candidate buffer and report failure on overflow. Under the good sampling event this does not occur. State that `n` is known for choosing the sample capacity, or supply a resizing scheme. A strict two-pass algorithm should report failure after its second pass; retrying requires additional passes. Handle bounded small `n` directly.

**Without-replacement concentration (G4).** If a uniform `k`-subset is drawn from `n` positions, with `k≤n`, and `M` positions are marked, let `X` count marked samples and `p=M/n`. For every integer `0≤j≤k`,

\[
\mathbb E\binom Xj=\binom kj\frac{(M)_j}{(n)_j}
\le\binom kj p^j.
\]

Consequently, for `λ≥0`, expanding `(1+(e^λ−1))^X` gives
`E[e^(λX)] ≤ (1−p+p e^λ)^k`. The usual binomial Chernoff upper-tail proof therefore applies; count unmarked positions for the opposite tail. This supplies the missing bridge from the independent-trials lemma to reservoir sampling. When the prescribed capacity exceeds `n`, retain the whole input and handle it directly.

### E7. Thinning accumulates rank error

Take `n=8,s=2` and stream `[1,2,3,8,4,5,6,7]`. The two level-one summaries are `[2,8]` and `[5,7]`; the final summary is `[5,8]`. At level `h=2`, its first item has actual rank 5, greater than the claimed `2^h r=4`.

A replacement invariant for the stated merge-then-thin procedure is

\[
0\le F_h(x)-2^h C_h(x)\le h2^{h-1},
\]

where `F_h(x)` counts original keys at most `x` in the represented block and `C_h(x)` counts retained keys at most `x`. If the child summaries contain `a,b` keys at most `x`, the parent retains `⌊(a+b)/2⌋`. Thus the error satisfies `E_h≤2E_(h−1)+2^(h−1)`, with `E_0=0`, proving the formula.

For distinct keys, retained rank `r` therefore corresponds to an original rank in `[2^h r, 2^h r+h2^(h−1)]`. Write `w=2^h`, `E=hw/2`, and let `m` be the target rank. A valid bracket uses sample indices `⌊(m−E)/w⌋` and `⌈m/w⌉`, with a lower sentinel when necessary. These are `O(h+1)` indices apart and enclose `O((h+1)n/s)` original keys. With `s≈√n`, retain **`O(√n log n)`**, not the claimed `O(√n)`, candidates. Linear-time selection on them preserves the stated final selection-time bound; sorting them would add another logarithm.

The final two-pass `O(√n log n)` space conclusion can therefore survive. The assumption that `n` is a power of two does not alone ensure that `n/s` is a power of two; add compatible buffer/divisibility assumptions or explain padding. The first-pass processing time is separate from the stated final extraction time.

### G7. The general-pass claim needs a different logarithmic factor or proof

Munro and Paterson's Theorem 2 states `O(n^(1/p)(log n)^(2−2/p))` storage. This matches the chapter for two passes, but has a larger logarithmic exponent for `p>2`. Their procedure also thins the children before merging, so its detailed invariant should not be silently substituted for the chapter's variant. Either cite that theorem with its actual bound or prove the stronger `O(n^(1/p) log n)` assertion. The review has not established that the stronger bound is impossible. [Original paper, Theorem 2 and Section 3](https://sites.cs.ucsb.edu/~suri/cs290/MunroPat.pdf).

### E8 and G6. Fixed-hitter versus all-hitters probabilities

At a fixed prefix of length `t`, a value occurring `f≥εt` times is missed by a reservoir of size `m≤t` with probability

\[
\frac{\binom{t-f}{m}}{\binom tm}\le (1-\varepsilon)^m\le e^{-\varepsilon m}.
\]

For `t=10,f=5,m=2`, the exact value is `2/9`, not `1/4`. Also `exp(−ln(1/φ))=φ`; delete the intervening `exp(φ)` at line 488.

The wording “a heavy hitter” does not itself assert simultaneous coverage, but the section asks for all values meeting the threshold. There are at most `1/ε` such values. A valid capacity for all of them at one fixed prefix is

\[
M=\left\lceil\frac1\varepsilon\ln\frac1{\varepsilon\varphi}\right\rceil.
\]

For `t≥M`, union-bound the individual miss probabilities; for `t<M`, retain every position and failure is zero. The original capacity can fail substantially: ten values each occurring ten times, `ε=φ=0.1`, give `m=24` and probability `0.4650888677` of missing at least one heavy hitter. This was computed exactly by inclusion–exclusion before converting to decimal.

The output is a **candidate list** that may contain non-heavy values. Say whether false positives are allowed; exact identification needs frequency verification. The analysis is for a fixed prefix, not simultaneous success over every time.

### E9–E10 and S2. Deterministic counters

Replace the update paragraph by three exclusive cases: if the arriving value is tracked, increment its counter; **otherwise**, if there is room, insert it with counter 1; **otherwise**, decrement all tracked counters and delete zeros. Say “at most k elements.” Following the two current `if` statements literally on `[a,a,b,c]` with `ε=1/2,k=2` resets the second `a` count and eventually loses `a`, although it is heavy. The corrected algorithm retains it.

The guarantee after `t` inputs must refer to `S_t`. This is not just a harmless future-state convention: after `[a,b]`, both values meet the threshold for `ε=1/2`, but the next input `c` empties `S_3`. Replace the conclusion's `S_{t+1}` at lines 519 and 551 by `S_t`. Keep the actual transition's `S_{t+1}` at line 511. Replace “counter for u” (537), “counter of u” (550), and “u appears” (551) by the corresponding phrases with `e`; keep `u` as its frequency everywhere in the inequalities.

**S2:** each decrement cancels `k+1` distinct occurrences, so the number `D` of decrements satisfies `D≤t/(k+1)`. For a heavy value with frequency `u`,

\[
c(e)\ge u-D\ge\varepsilon t-\frac{t}{k+1}>0,
\]

because `k+1=⌈1/ε⌉+1>1/ε` and `t≥1`. This replaces the ceiling expansion without changing the proof's substance.

### Exact notation proposals

- **N1**, lines 66–72: replace the plain `P\left(…\mid…\right)` conditional term by

  ```latex
  \ProbCond{\begin{array}{c}
      \text{the best of the first $i-1$ applicants}\\
      \text{is in the first $r-1$ applicants}
  \end{array}}{\text{applicant $i$ is the best}}
  ```

  Retain the surrounding sum and multiplication by `1/n`. This changes one event-probability occurrence; the three `P(r)` occurrences at lines 47, 52, and 89 remain.
- **N2**, line 324: `elements $L$ and $R$ of ranks` → `elements $L$ and $H$ of ranks`; line 326: `$R$, and keep only` → `$H$, and keep only`. The five existing upper-pivot `H` uses at lines 332, 349, 363, 376, 377 remain. No other local `H` meaning conflicts.
- **N3**, line 293: `\rankY{S}{k^+}` → `\rankY{S}{k_+}`; line 296: `and $k^+ =` → `and $k_+ =`. There is no pre-existing conflicting `k_+`; this is independent of G2's mathematical rounding repair.
- **N4**, line 211: replace `Let $\eps \in (0,1/2)$ be a fixed parameter, and let $B$ be a set` by `Let $\eps \in (0,1/2)$ and $\delta \in (0,1)$ be fixed parameters, and let $B$ be a set`. At line 281, replace `Let $\eps \in (0,1/2)$, $B$ an array of $n$ elements, and let` by `Let $\eps \in (0,1/2)$ and $\delta \in (0,1)$ be parameters, let $B$ be an array of $n$ elements, and let`; apply G2's stronger restrictions when repairing that statement. Before line 475 insert `Fix a failure parameter $\BadProb \in (0,1)$.`

These changes were independently checked as a batch. Mathematical notation is left intact in the review source and annotated with notes, avoiding fragile strikethrough inside formulas.

## Reproducible checks

Scratch commands used:

```text
rtk proxy ruby /tmp/refute_streaming_other.rb
rtk proxy ruby /tmp/streaming_median_counterexamples.rb
```

The following short Ruby program reproduces the main counterexamples independently of those scratch files:

```ruby
# frozen_string_literal: true
def choose(n, k)
  return 0 if k.negative? || k > n
  (1..k).reduce(1) { |v, i| v * (n - i + 1) / i }
end
def thin(values)
  values.sort.each_slice(2).map(&:last)
end
stream = [1, 2, 3, 8, 4, 5, 6, 7]
puts thin(stream.each_slice(4).flat_map { |block| thin(block) }).inspect
# [5, 8], violating the claimed first-rank upper bound 4.
t = (2..6).to_a
puts [t.fetch(4 - 2 - 1), t.fetch(4 - 2)].inspect
# [3, 4]: old and repaired selection results.
puts Rational(choose(5, 2), choose(10, 2))
# 2/9, rather than 1/4.
miss = (1..10).sum do |j|
  (-1)**(j + 1) * choose(10, j) *
    Rational(choose(100 - 10 * j, 24), choose(100, 24))
end
puts miss.to_f
# 0.4650888677216979
```

## Build and preservation

- **Review build:** `/home/sariel/bin/l -no-env streaming_review.tex`, using leeni 1.0.53 and XeLaTeX, succeeded. The [annotated PDF](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming_review.pdf) has 11 pages. Final diagnostics: **0 errors, 4 overfull-box alerts, 1 overfull-box warning**, and one suppressed minor diagnostic. No unresolved references or citations were reported.
- **Baseline:** an unchanged copy of the original was built in `/tmp/streaming-review-20261013/27_streaming`. Its first isolated build failed because `shortcuts.bib` was missing; `geometry.bib` was also absent from the chapter setup. Supplying the author's existing bibliography files in that temporary directory produced **0 errors, the same 4 alerts and 1 warning**, and the same suppressed minor-diagnostic count.
- The five overfull boxes have identical widths in both final builds: **129.45, 123.79, 163.32, 157.04, and 10.55 points**. An overfull review note introduced during editing was shortened and rebuilt successfully. The remaining layout defects belong to the original displays; W4 records them.
- The review-only bibliography copies the two cited entries from the author's existing bibliography. The original citation keys and textual Munro–Paterson attribution were preserved.
- Ran the compiler's local `--clean-only` operation and removed its retained review `.bbl`. The repository-wide `tools/clean --skip-compile` was not used: there is no root `book.fls`, and inspection shows that this command would instead compile and clean the entire book outside the chapter. The source directory contains only the original files and the four review deliverables; temporary computations and the baseline build remain under `/tmp`.
- Verified the original source SHA-256 stayed `c6169f041fbd03d92d049a4eacea02d784fb652c19a6ea9ca0e15274f2023503`; the relative `styles -> ../styles` symlink is unchanged. Final Git inspection preserves the pre-existing modification to `../.bws/config.jsonc`. Nothing was committed.
