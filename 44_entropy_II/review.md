# Review of Entropy II

Locations below refer to the original [entropy_II.tex](/home/sariel/papers/teach/26/fa26_rand_alg/notes/44_entropy_II/entropy_II.tex). The saved manuscript and editor autosave were left unchanged.

## What was done

- [Annotated source](/home/sariel/papers/teach/26/fa26_rand_alg/notes/44_entropy_II/entropy_II_review.tex): 3 tracked writing replacements (`\chgY`), 10 explanatory notes (`\noteX`), 9 exact-span anchors (`\markX`), and 40 minor-correction groups logged below. S2 is a located alternative proof without an existing span. No legacy review notes were retained.
- Checked every proof and calculation, the decoding example, all four recalled binomial bounds, the shared mathematical macros, and the bibliography attribution. Correctness, simplification, notation, and writing received separate passes.
- Verification: **independent-agent** for the five substantive technical findings, their proposed repairs, both simplifications, and mathematical writing edits. A separate reviewer tried to refute the candidates. Three additional suspicions were excluded: the eventual `n/2` counting factor is valid; the contracted-tree depth display telescopes correctly; the recalled rounded binomial bounds are valid. Local mathematical slips were also independently checked.
- Models: reviewers inherited the session model with **high** reasoning effort requested for correctness, notation, verification, and writing. Exact underlying model identifiers were not exposed. The coordinating pass used inherited settings.
- Computations: Ruby enumerated all four-leaf full binary tree profiles and weight permutations; tested 240,240 rounded-binomial inequalities (zero failures, log-space tolerance `1e-10`); and recomputed the entropy-sign example. These checks supplement the analytic arguments.
- Build: the [11-page review PDF](/home/sariel/papers/teach/26/fa26_rand_alg/notes/44_entropy_II/entropy_II_review.pdf) compiled with **0 errors, 0 warnings, and no unresolved references or citations**. XeLaTeX, Biber, and two further XeLaTeX passes ran in isolated copies under `/tmp/entropy-ii-review-20261106`, using the repository's 35-variable TeX environment sanitization. The baseline has three existing macro-redefinition errors (`costX`, `codeX`, `lengthX`); removing those duplicate declarations only in the review copy resolves them. The required `/home/sariel/bin/l -no-env -s` wrapper was tried first, but Biber could not locate `./book.bib` from its separate build directory. Direct execution of the same engines from the isolated source directory succeeded without changing the shared preamble or bibliography paths. Reproduction: [build script](/tmp/build_entropy_review.rb). Rendered pages containing tracked prose, math anchors, notes, and the bibliography were visually checked. No repository-wide test suite or cleanup was run; compilation produced no auxiliary files in the manuscript directory.

## Summary of findings

**3 errors, 2 gaps, 2 simplifications, 0 substantive notation findings, 3 writing findings.** The main proof strategies work after the repairs below. The most consequential proof error is the Huffman exchange argument's inference that equal cost forces equal frequencies; equal-depth swaps disprove it. The compression lower bound also needs a strict-event repair and an entropy-sign correction; the latter is already applied as a local slip.

### Errors

- **E1**, lines 40–53 — The prefix-code definition and Morse example claim decoding that the undelimited stream does not permit (confidence: high); annotated, replacement proposed.
- **E2**, lines 182–199 — Equal cost does not imply equal frequencies when the exchanged leaves have equal depth (confidence: high); annotated, repair proposed.
- **E3**, lines 88–101, 151–166, 302–315 — Zero-frequency symbols invalidate the universal full-tree claim and cause `\lg 0` in the entropy proof; the singleton sibling claim also needs qualification (confidence: high); support convention proposed.

### Gaps

- **G1**, lines 392–435 — The compression proof omits `p=1` and the upper restriction on `\eps` needed for `p+\eps<1` (confidence: high); endpoint and parameter repair proposed.
- **G2**, lines 461–467 — Length is bounded for `X<\tau`, but the expectation uses `X\leq\tau` (confidence: high); matching strict-event estimate proposed.

### Simplifications

- **S1**, lines 220–236 — Replace the expanded contraction calculation by one depth-change identity; proposal only.
- **S2**, lines 409–435 — Block Huffman coding gives the entire compression upper bound directly; proposal only.

### Notation

Substantive counts: **clash 0; split 0; convention 0; definition 0**. The full chapter and macro expansions were checked. The two obvious wrong-name occurrences (`b` for `\beta`, and `\Tree` for `\Tree_H`) are logged as minor corrections. Local reuse of `n,X,\Delta,\tau` is legitimate; `\Entropy` and `\EntropyX` render the same entropy operator. Binary entropy is defined in the preceding chapter.

Proposed rule sheet:

- Established: use roman operators for cost, code, length, and depth.
- Established: introduce counts and random variables in each new local scope.
- Preserve the appropriate subscript when referring to a particular code tree.
- Distinguish input strings from their encoded output strings when comparing lengths.

### Writing

- **W1**, lines 126–129 — Specify initialization and the summed weight of a merged tree; tracked in the copy.
- **W2**, lines 135–139 — Replace the broad asymptotic compression claim with exact optimality among symbol-by-symbol prefix-free binary codes; tracked in the copy.
- **W3**, line 500 — Name Mitzenmacher and Upfal explicitly; verified against the bibliography and tracked, preserving the citation key and section locator.

## Details

### E1. Prefix codes and the Morse example

The manuscript says Morse is “a binary code (and also a prefix code)” and proposes choosing between `S` and `EEE` using likelihood. Their dot/dash streams are identical: `code(S)=...=code(E)code(E)code(E)`. A likelihood preference does not give lossless decoding.

Proposed replacement for lines 40–53, preserving the ASCII/UTF-8 example:

> A prefix code assigns distinct codewords to the symbols, with no codeword a prefix of another; such a code is also called prefix-free. This permits decoding one character at a time, without separators between codewords. ASCII and UTF-8 are prefix-free binary codes. The dot/dash strings of Morse code are not prefix-free: the code for E is a prefix of the code for S. Morse transmissions use pauses to mark letter boundaries; without these separators, S and EEE produce the same dot/dash stream.

The substantive rewrite is **not applied**. The original passage is marked. Verification: independent-agent, high confidence, using the explicit ambiguity.

### E2. Exchange proof: zero depth change

At lines 195–197 the proof infers `f[\alpha]=f[x]` from equal total costs. The equation proves only
\[
(f[\alpha]-f[x])\Delta=0.
\]
Take weights `(x,y,\alpha,\beta)=(1,2,2,2)` and codewords `00,01,10,11`. The balanced tree is optimal with cost `14`, yet swapping `x` and `\alpha` preserves cost because `\Delta=0`, while their frequencies differ.

Reproduction: `ruby /tmp/huffman_review_checks.rb` returned:

> weights=[1, 2, 2, 2]; minimum full-tree cost=14; balanced cost=14  
> swap x(weight 1) with alpha(weight 2), Delta=0: cost change=0; equal weights? false

For four leaves, the only full-tree depth profiles up to permutation are `(2,2,2,2)` and `(1,2,3,3)`. Both have minimum weighted cost `14`, so the counterexample does not rely on a heuristic optimizer.

Repair: delete “(and incidentally, `f[\alpha]` actually equals `f[x]`)”. At lines 182–184, use:

> Choose a pair of deepest sibling leaves. Leave any of x and y already in this pair fixed, and swap each missing character with a label outside {x,y} occupying a remaining position.

Then every needed swap has nonnegative frequency difference and nonnegative depth increase. Optimality forces no cost change, which suffices. The false parenthetical remains marked as a proposed deletion; the obvious `>` to `\geq` tie correction and `b` to `\beta` typo are already applied and logged. Verification: independent-agent, high confidence.

### E3. Positive support and singleton conventions

The input frequency array is not restricted to positive entries. With frequencies `(1,0)` and codewords `0,10`, cost is `1`, optimal for two distinct codewords, but the node at prefix `1` has one child. Contracting it does not improve cost. Thus “Let T be an optimal code tree. Then T is a full binary tree” is false at zero weights.

The theorem at lines 302–310 explicitly allows an alphabet character absent from the message. Its `p_i=0` makes `q_i=2^{\floor{\lg p_i}}` undefined. A one-symbol tree also has no sibling pair.

One coherent proposed convention is:

> In this section, retain only symbols occurring in a nonempty message, so all frequencies are positive. The message length is known to the decoder; a one-symbol alphabet may therefore use the empty codeword.

Corresponding exact changes:

- At lines 302–305, replace “of `m` characters” by “of `m\geq1` characters”, and “an alphabet set `\Sigma` of size `n`” by “the set `\Sigma` of its `n` occurring characters”.
- At lines 153–154, replace “In particular, if the height of `\Tree` is `d`” by “If `n\geq2` and the height of `\Tree` is `d`”.
- Keep the positive-frequency assumption available to the full-tree lemma and all later Huffman arguments.

These are **proposed domain changes**, not silently applied edits. They restrict the discussion to the support of the message. Retaining the theorem for an arbitrary ambient alphabet instead requires an explicit zero-weight extension, not merely evaluating `\lg 0` or silently dropping symbols while still claiming to analyze Huffman on the original alphabet. The singleton base case in the dyadic lemma has been added separately as a minor correction. Verification: independent-agent, high confidence.

### G1. Endpoint and epsilon range

At `p=1` the target upper bound is zero, while the proof's flag bit always costs at least one bit. Under the definition of an injective compression function, the theorem itself remains true.

Replace the opening sentence of the proof with:

> If p=1, encode the all-heads input by the empty string and every other input by a distinct nonempty string. The expected length is zero. Hence assume 1/2<p<1, and choose 0<epsilon<min{p−1/2,1−p}.

The new range makes both entropy arguments lie in `(1/2,1)`. With fixed interior `p`, continuity of binary entropy and then sufficiently large `n` justify both limiting bounds. This repair is proposed in the note, not applied. Verification: independent-agent, high confidence.

### G2. Match the event used in the expectation

Monotonicity transfers the long-codeword bound from one string with `\tau` heads to every string with **fewer** than `\tau` heads. It does not transfer it to every equally likely string with exactly `\tau` heads.

Replace the sentence at lines 463–465 with:

> For `n\eps\geq2`, we have `\tau=\floor{(p+\eps)n}\geq(p+\eps/2)n`. Hence the Chernoff inequality gives `\Prob{X<\tau}\geq1-\exp(-n\eps^2/(12p))`.

Indeed, the multiplicative upper-tail parameter is `\eps/(2p)<1`, giving exponent `np(\eps/(2p))^2/3=n\eps^2/(12p)`. Choose `n` large enough that the corrected `\mu=n\Entropy{p+\eps}-\lg(n+1)-1` is nonnegative before multiplying by the probability lower bound. The expectation argument then works. Proposed, not applied; verification: independent-agent, high confidence.

The entropy sign at line 442 **is already corrected without markup**. For `p=.75,\eps=.05,n=10000`, `ruby /tmp/compression_review_checks.rb` gives corrected `\mu=7204.993092232`, versus printed `8798.621135665`. This is an unambiguous local sign slip and is excluded from substantive finding counts.

### S1. Contracting a pair changes cost by its total weight

For any tree whose leaves 1 and 2 are siblings, let T' replace the pair by a leaf of weight `f[1]+f[2]`. If their parent has depth d, their old contribution is `(f[1]+f[2])(d+1)` and the new contribution is `(f[1]+f[2])d`. All other contributions agree. Therefore
\[
\operatorname{cost}(T)=\operatorname{cost}(T')+f[1]+f[2].
\]
Conversely, expanding the merged leaf adds the same constant to **every** reduced tree. This proves the optimization correspondence directly and replaces the multi-line display. Verification: independent-agent; proposal only.

### S2. Use block Huffman coding for the upper bound

First state that the preceding Huffman argument applies to any finite positive probability law, not only empirical frequencies. The optimality exchange/induction works for positive real weights; the rounded dyadic masses have a finite common power-of-two denominator, so the padding argument still works.

For `1/2<p<1`, regard each `s\in\{H,T\}^n` as one symbol, with probability `P(s)=p^{k(s)}(1-p)^{n-k(s)}`. Independence gives
\[
\mathbb H(S)
=\mathbb E[-\lg P(S)]
=n[-p\lg p-(1-p)\lg(1-p)]
=n\mathbb H(p).
\]
The Huffman bound gives `\mathbb E L\leq n\mathbb H(p)+1`, which is at most `(1+\delta)n\mathbb H(p)` for `n\geq1/(\delta\mathbb H(p))`. This is an existence argument over the block alphabet, so exponential alphabet size does not obstruct the theorem. Handle `p=1` as in G1.

This removes the upper-tail estimate, counting bound, flag bit, and integer-length bookkeeping while establishing a prefix-free upper bound for interior p. Verification: independent-agent; proposal only.

## Minor corrections applied

Applied only in the review copy, without inline markup; excluded from finding counts. Original line numbers are used. Multi-line source snippets are flattened only for this table. The three removed macro definitions already exist in the current shared preamble; the editor autosave independently contains the same removal.

| Original lines | Old | New |
|---|---|---|

| 11–13 | `\newcommand{\costX}[1]{\mathrm{cost}\pth{#1}} \newcommand{\codeX}[1]{\mathrm{code}\pth{#1}} \newcommand{\lengthX}[1]{\mathrm{l{}e{}n}\pth{#1}} ` | (deleted; use shared definitions) |
| 37 | `were you can send only` | `where you can send only` |
| 53 | `\texttt{E{}E{}E}, but rather \texttt{S}.` | `\texttt{E{}E{}E}, but rather \texttt{S}.)` |
| 72 | `prefix odes` | `prefix codes` |
| 76 | `left if get a '0'` | `left if we get a '0'` |
| 77 | `the character output in the leaf` | `the character stored at the leaf` |
| 83 | `which the algorithm output.` | `which the algorithm outputs.` |
| 90 | `an array frequency counts` | `an array of frequency counts` |
| 124 | `Hoffman's code` | `Huffman's code` |
| 154 | `leafs nodes of height $d$ that are sibling` | `leaf nodes at depth $d$ that are siblings` |
| 164 | `consider it parent` | `consider its parent` |
| 165 | `both leafs` | `both leaves` |
| 192 | `$f[\alpha] > f[x]$` | `$f[\alpha] \geq f[x]$` |
| 197 | `swapping $y$ and $b$` | `swapping $y$ and $\beta$` |
| 198 | `$x$ and $y$ as` | `$x$ and $y$ are` |
| 214–215 | `optimal code for $f[1 .. n]$ has characters $1$ and $2$ as     siblings.` | `optimal code for $f[1 .. n]$ has characters $1$ and $2$ as     siblings at maximum depth.` |
| 216–217 | `tree formed by it by removing $1$ and $2$ as it leaves. We remain     with a tree $\TreeOptA$ that has as leafs the characters` | `tree obtained by removing the leaves $1$ and $2$. We obtain     a tree $\TreeOptA$ that has as leaves the characters` |
| 240 | `removing the leafs of` | `removing the leaves of` |
| 241 | `$2$ from $\Tree$.` | `$2$ from $\Tree_H$.` |
| 256 | `our input is made out of $n$ characters` | `our input uses an alphabet of $n$ characters` |
| 257 | `character is $p_i$ fraction of the input` | `character occupies a fraction $p_i$ of the input` |
| 266 | `probabilities are power of $2$` | `probabilities are powers of $2$` |
| 277–279 | `The proof is by easy induction of the Huffman algorithm. Indeed,     for $n=2$` | `The proof is by induction on the number of symbols.     For $n=1$, we have $p_1=1$ and the empty codeword has length $0$.     For $n=2$` |
| 282 | `Huffman's merges this two letters, into a single` | `Huffman's algorithm merges these two characters into a single` |
| 283 | `that have probability` | `with probability` |
| 339 | `leafs/symbols` | `leaves/symbols` |
| 342 | `since process only` | `since the process only` |
| 348 | `is a better encoder for the input string than` | `encodes the input string at least as well as` |
| 367 | `underling distribution` | `underlying distribution` |
| 381–382 | `assigns a bit sequence to $S_2$ which is at least as long as     $S_1$.` | `assigns to $S_2$ a bit sequence at least as long as the sequence     assigned to $S_1$.` |
| 413 | `denoted by $X$ is larger than` | `denoted by $X$, is at least` |
| 417 | `If there are more than $(p-\eps)n$ ones` | `If there are at least $(p-\eps)n$ ones` |
| 427 | `random bits.` | `bits.` |
| 434–435 | `by carefully setting $\eps$ and $n$ being sufficiently     large. Establishing the upper bound.` | `by choosing $\eps$ sufficiently small and then $n$ sufficiently     large. This establishes the upper bound.` |
| 442 | `- 1 = n\Entropy{p-\eps}` | `- 1 = n\Entropy{p+\eps}` |
| 447 | `for a     specific strings` | `for     specific strings` |
| 463,465 | `compresser` | `compressor` |
| 463 | `Chenroff` | `Chernoff` |
| 465 | `Implying that an optimal` | `This implies that an optimal` |
| 486 | `$q \in [1/2,1]$ $\binom` | `$q \in [1/2,1]$ $\Rightarrow$ $\binom` |
