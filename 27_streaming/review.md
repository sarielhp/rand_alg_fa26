# Second review of “Streaming and the Multipass Model”

Locations refer to the revised [streaming.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex). The manuscript was not changed. This is a quick second pass for class notes: routine floor/ceiling conventions and formalization of standard sampling conventions are intentionally not reported.

## What improved

The secretary random-order assumption and integral evaluation are corrected. The reservoir tails transition is explicit. The randomized heavy-hitter analysis now includes the all-hitters union bound and the correct exponential endpoint. The deterministic guarantee now refers to the correct state, and its update is presented as a choice of cases. The general multipass space statement now allows a polynomial logarithmic factor.

The detailed median-selection implementation was deleted. Its former pivot-index, output-index, and comparison-accounting errors therefore no longer occur in the text; this does not by itself supply the justification for the remaining space claim.

Layout improved substantially: the revised baseline has one 8.45-point overfull box, compared with five overfull boxes recorded in the first review.

## What was done

- Read the complete chapter, the included Chernoff statement, relevant shared macro definitions, and the earlier report. Checked all arguments, with separate simplification, notation, and writing readings.
- Created [streaming_review2.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming_review2.tex), with **6 review notes**, no tracked prose rewrites, and a few silent grammatical fixes. Mathematical corrections remain proposals. The suffix preserves the existing first-pass PDF.
- **Verification: independent-agent.** Fresh-context correctness and notation reviewers and a separate adversarial verifier used the inherited session model with **high reasoning effort**. The exact runtime model identifier and coordinator effort are not exposed. All retained technical findings, notation replacements, and the simplification were independently checked.
- Dropped the old counter-reset accusation: “one of the following” already indicates a single update. Also rejected any claim that the two-pass space theorem itself has been disproved. Routine rounding comments were removed at the author's request.
- Ruby 3.3.8 recomputation confirmed both reservoir induction identities in 190 cases, the exact heavy-hitter miss probability, and finite and asymptotic thinning counterexamples. Scratch checks are in [checks.rb](/tmp/streaming-second-pass-20261014/checks.rb); syntax and Ruby audit passed.

## Findings

**2 errors, 1 gap, 1 simplification, 2 notation findings, and 1 writing finding.** The most consequential remaining error is the thinning rank estimate: the accumulated error can be a logarithmic factor larger than stated, so the proposed narrow bracket can exclude the median.

- **E1 — Error, high confidence**, [lines 380–390](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:380): repeated thinning has worst-case rank error of order `h·2^h`, not `2^h`. Widening the bracket preserves the final stated space bound; see below.
- **E2 — Error, high confidence**, [lines 439–455](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:439): the reservoir miss probability is bounded by `(1−ε)^m`, rather than equal to it. Also write the sample-size denominator explicitly to match the subsequent calculation.
- **G1 — Gap, high confidence**, [lines 341–359](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:341): the claimed `O(n^(2/3))` space bound still needs an explanation. The straightforward reservoir implementation of the displayed Chernoff bound uses an extra logarithmic factor. This is a problem with the asserted derivation, not a disproof of the theorem.
- **S1 — Simplification**, [lines 513–522](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:513): the cancellation proof can end immediately with `u−t/(k+1) ≥ εt−t/(k+1) > 0`, since `k+1>1/ε`. The existing longer calculation is correct.
- **N1 — Split**, [lines 286, 290, 333](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:286): replace the three remaining `\delta` occurrences by `\BadProb`, the failure parameter declared in the statements. In the heavy-hitter paragraph, explicitly give this parameter its usual domain `(0,1)`.
- **N2 — Split**, [lines 510, 524–525](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:510): replace `counter for $u$` with `counter for $e$`, `counter of $u$` with `counter of $e$`, and `$u$ appears in $S_{t}$` with `$e$ appears in $S_{t}$`. Keep `u` in the inequalities: it is the frequency, not the element.
- **W1 — Writing**, [line 359](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming.tex:359): an inherited first-pass review note is still embedded in the manuscript. Remove it after resolving G1; its `G4/G5` references belong to the earlier report.

Notation counts: **0 clashes, 2 splits, 0 convention findings, 0 standalone definition findings**. Proposed rules: use the declared `\BadProb` consistently for failure probability; use `e` for a tracked element and `u` for its frequency. No global symbol renaming is needed.

## Details

### E1. Thinning error accumulates

For `n=256`, buffer size `s=16`, and `h=4`, construct sixteen blocks of sixteen distinct keys. Give them respectively

```text
6,7,7,8,7,8,8,9,7,8,8,9,8,9,9,10
```

low keys, allocating keys `1,…,128` in block order; fill their remaining positions with keys `129,…,256`, also in block order. Repeated merge-then-thin produces

```text
17,36,53,77,96,113,129,145,160,173,188,197,213,228,241,256
```

The seventh retained key has true rank 129 but weighted rank `7·16=112`. More seriously, predecessor/successor keys around the nominal median summary index eight are 129 and 160, excluding median 128. Thus this is an algorithmic issue, not a request for more precise wording.

“Roughly” cannot absorb the missing factor. For even `h`, set `s=2^h`, `n=s²`, and give block `j` exactly `s/2−h/2+popcount(j)` low keys. Half the original keys are low, but repeated thinning retains only `s/2−h/2` low keys. The first retained high key consequently has rank error at least `(h/2−1)2^h+1`, whose ratio to `2^h` is unbounded.

A valid invariant is

\[
0\le F_h(x)-2^h C_h(x)\le h2^{h-1},
\]

where `F_h` counts represented original keys at most `x` and `C_h` counts retained keys at most `x`. The recurrence is `E_h≤2E_(h−1)+2^(h−1)`, with `E_0=0`.

Use this error bound to widen the median bracket across `O(h)` summary positions. For `s≈√n`, the collected interval then has `O(√n log n)` keys. Linear-time selection in that interval preserves the final `O(√n log n)` space and extraction-time conclusions. Sorting that larger interval would introduce another logarithmic factor. The complete algorithm still scans the input twice.

### E2. Randomized heavy hitters

For a fixed hitter with frequency `f≥εt` in a fixed prefix of length `t≥m`, the correct start of the chain is

\[
\Pr[\text{miss}]=\frac{\binom{t-f}{m}}{\binom tm}
\le (1-f/t)^m\le(1-\varepsilon)^m.
\]

For `t=10,f=5,m=2`, this is `2/9`, whereas the printed expression is `1/4`. The rest of the corrected exponential/union-bound calculation works.

At line 439, replace `\ln( 1/\eps\BadProb)` by `\ln\frac{1}{\eps\BadProb}`. This is a consequential denominator clarification: the subsequent display needs `ln(1/(εφ))`, not `ln(φ/ε)`. Keep the entire prefix when `t<m`. The resulting list contains every heavy hitter with the stated probability at a fixed prefix, but may also contain other values.

### G1. Two-pass space accounting

Substituting `ε=n^(−1/3)` and polynomially small failure probability into the stated sampling lemma requires `k=Θ(n^(2/3) log n)` samples. A reservoir storing them already exceeds the advertised space. Deleting the implementation does not explain how to avoid that storage.

Either give the additional idea achieving `O(n^(2/3))` space, or state the elementary implementation's `O(n^(2/3) log n)` bound. For the latter, select the two sample pivots in linear time rather than sorting the sample, which would cost `O(n^(2/3) log² n)` comparisons. A brief implementation sketch should also explain the reservoir concentration argument and how a too-large candidate interval causes detected failure within the two passes. This is enough detail to support the stronger resource claim without restoring the long deleted proof.

## Build and preservation

The unchanged revised chapter and final review copy both compiled with `/home/sariel/bin/l -no-env`, using XeLaTeX and the tool's normal bibliography/reference passes: **0 errors, 0 alerts, 1 warning**, with no unresolved citations or references. Both warnings are the same **8.45-point overfull box** in the reservoir proof; review annotations introduced no additional warnings.

Builds ran in `/tmp/streaming-second-pass-20261014` with copies of the shared styles/fragments. The baseline used a scratch bibliography containing the two existing cited entries; the review uses [streaming_review2.bib](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming_review2.bib), copied from the existing first-pass bibliography. No shared sources or original bibliography files were changed. The [annotated PDF](/home/sariel/papers/teach/26/fa26_rand_alg/notes/27_streaming/streaming_review2.pdf) is the final review build.

Original manuscript SHA-256 remains `df836b91d42131e256935c6c34b452edb983dace77d95ae28ec0dfb2189bca6b`. The relative styles symlink and existing first-pass artifacts are preserved. Build auxiliaries stayed under `/tmp`; the repository-wide cleaner was unnecessary and would have triggered a full-book build because `book.fls` is absent. Nothing was committed.
