#!/usr/bin/env ruby
# frozen_string_literal: true

chap_dir = File.expand_path('..', __dir__)
orig_file = File.join(chap_dir, 'chebychev.tex')
dest_file = File.join(chap_dir, 'chebychev_reviewed.tex')

content = File.read(orig_file)

def replace_exact(content, old_str, new_str, label)
  unless content.include?(old_str)
    raise "Failed to find #{label}:\n#{old_str}"
  end
  content.sub(old_str) { new_str }
end

# 1. Subsection 1.1: Remove duplicate "each" in "each taking each value"
old_sub11 = "each taking each value in $\\brc{-1,+1}$ with equal probability $1/2$."
new_sub11 = "each \\chgY{taking each value}{taking value} in $\\brc{-1,+1}$ with equal probability $1/2$."
content = replace_exact(content, old_sub11, new_sub11, "sub11_each")

# 2. Remark 1.1 & Lemma 1.1: Highlight pairwise independence
old_rem11_head = '\begin{remark}[Maybe skip for now]'
new_rem11_head = '\begin{remark}[\chgY{Maybe skip for now}{Pairwise vs.~mutual independence}]'
content = replace_exact(content, old_rem11_head, new_rem11_head, "rem11_head")

old_rem11_end = "put differently, Chebyshev is NOT strictly dominated by\n    other tools.\n\\end{remark}"
new_rem11_end = <<~'LATEX'.chomp
put differently, Chebyshev is NOT strictly dominated by
    other tools.
    \remX{Pedagogical emphasis: Highlighting pairwise independence here is central. Chebyshev's inequality only requires pairwise cancellation of cross-terms $\Ex{X_i X_j} = \Ex{X_i}\Ex{X_j}$ for $i \neq j$. This provides significant algorithmic utility in scenarios where full mutual independence is impossible or computationally costly to construct, such as universal hashing and streaming algorithms.}
\end{remark}
LATEX
content = replace_exact(content, old_rem11_end, new_rem11_end, "rem11_end")

old_lem11_decl = "Let $X_1, \\ldots, X_n \\in \\brc{-1,+1}$ be independent random variables, each\n    taking each value in $\\brc{-1, +1}$ with probability $1/2$."
new_lem11_decl = "Let $X_1, \\ldots, X_n \\in \\brc{-1,+1}$ be \\chgY{independent}{pairwise independent} random variables, each\n    \\chgY{taking each value}{taking value} in $\\brc{-1, +1}$ with probability $1/2$."
content = replace_exact(content, old_lem11_decl, new_lem11_decl, "lem11_decl")

old_lem11_proof = "    by Markov's inequality.\n\\end{proof}"
new_lem11_proof = <<~'LATEX'.chomp
    by Markov's inequality.
    \remX{Pairwise independence in Lemma 1.1: Markov's inequality applies to the non-negative variable $Z = Y^2 \geq 0$ with threshold $a = t^2 \Ex{Z} = t^2 n > 0$, giving $\Prob{Z \geq a} \leq \Ex{Z}/a = 1/t^2$. Notice that only pairwise independence is used to establish $\Ex{Z} = \Ex{Y^2} = n$.}
\end{proof}
LATEX
content = replace_exact(content, old_lem11_proof, new_lem11_proof, "lem11_proof")

# 3. Exercise 1.3: Note zero variance case \sigma_X = 0 via \remX
old_ex13 = <<~'LATEX'.chomp
\begin{exercise}[Not too interesting]
    Consider the case that $\sigma_X = \Var{X} = 0$, what happens then
    with Chebyshev's inequality?
\end{exercise}
LATEX

new_ex13 = <<~'LATEX'.chomp
\begin{exercise}[\chgY{Not too interesting}{Zero variance case}]
    Consider the case that $\sigma_X = \Var{X} = 0$, what happens then
    with Chebyshev's inequality?
    \remX{Zero variance case ($\sigma_X = 0$): When $\Var{X} = 0$, $X = \mu_X$ almost surely. In the standardized tail form $\Prob{|X - \mu_X| \geq t \sigma_X} \leq 1/t^2$, the event becomes $\Prob{0 \geq 0} = 1$, which strictly exceeds $1/t^2$ for any $t > 1$. Hence, the standardized form implicitly assumes $\sigma_X > 0$. In contrast, the unstandardized Chebyshev bound $\Prob{|X - \mu_X| \geq \lambda} \leq \Var{X}/\lambda^2$ remains unconditionally valid for every $\lambda > 0$, correctly yielding $0 \leq 0$ when $\Var{X} = 0$.}
\end{exercise}
LATEX
content = replace_exact(content, old_ex13, new_ex13, "ex13_zero_var")

# 4. Example 2.2: Remove duplicate "that" in "that, we have that"
old_ex22 = "and by the \\lemrefY{above\n       lemma}{Chebyshev-1} that, we have that"
new_ex22 = "and by the \\lemrefY{above\n       lemma}{Chebyshev-1}\\chgY{ that, we have that}{, we have that}"
content = replace_exact(content, old_ex22, new_ex22, "ex22_duplicate_that")

# 5. Example 2.3: Add missing comma in "that is,"
old_ex23 = "property---that is $\\widehat{p} n = \\tfrac{n}{m} Y$."
new_ex23 = "property---\\chgY{that is}{that is,} $\\widehat{p} n = \\tfrac{n}{m} Y$."
content = replace_exact(content, old_ex23, new_ex23, "ex23_comma")

# 6. Lemma 3.1 & Subsection 3.1.1: Fix cross-reference from lemref{estimate:chebyshev} to lemref{Chebyshev-1}
# Lemma 3.1
old_lem31_ref = "Let $Y$ be the number of elements in the sample $\\Sample$ that are\n    $\\leq \\EBRY{U}{k}$.  By \\lemref{estimate:chebyshev}, we have"
new_lem31_ref = "Let $Y$ be the number of elements in the sample $\\Sample$ that are\n    $\\leq \\EBRY{U}{k}$.  By \\newX{\\lemref{Chebyshev-1}}\\remX{Cross-reference correction: Replaced reference to Lemma~2.3 with \\lemref{Chebyshev-1}, which establishes the concentration bound for the sample count $Y$.}, we have"
content = replace_exact(content, old_lem31_ref, new_lem31_ref, "lem31_cross_ref")

# Subsection 3.1.1
old_sub311_ref = "Furthermore, for any $t\\geq 1$, \\lemref{estimate:chebyshev} implies\nthat"
new_sub311_ref = "Furthermore, for any $t\\geq 1$, \\newX{\\lemref{Chebyshev-1}}\\remX{Cross-reference correction: Replaced reference to \\lemref{estimate:chebyshev} with \\lemref{Chebyshev-1} for the concentration of $Y$.} implies\nthat"
content = replace_exact(content, old_sub311_ref, new_sub311_ref, "sub311_cross_ref")

# 7. Subsection 3.2.1: Fix asymptotic bound from Theta(n^{3/4}) to O(n^{3/4})
old_sub321_bound = "\\item If $\\cardin{S_m} > 8 t {n}/ \\sqrt{m} = \\Theta( n^{3 / 4})$,\n    then the set $S_m$ is too large, and the algorithm fails."
new_sub321_bound = "\\item If $\\cardin{S_m} > 8 t {n}/ \\sqrt{m} = \\newX{O(n^{3/4})}$,\\remX{Asymptotic bound correction: Corrected $\\Theta(n^{3/4})$ to $O(n^{3/4})$. The cutoff threshold $8tn/\\sqrt{m} = 8\\ceil{n^{1/8}}n/\\sqrt{\\ceil{n^{3/4}}} = O(n^{3/4})$ is an asymptotic upper-bound test; using big-$O$ notation is mathematically accurate.}\n    then the set $S_m$ is too large, and the algorithm fails."
content = replace_exact(content, old_sub321_bound, new_sub321_bound, "sub321_bound")

# 8. Theorem 3.6 proof: Fix E[Y] = 1/p <= 1 + O(1/n^{1/4}) (original wrote 1/(1-p) = 1 + O(1/n^{3/4})), and 1/p <= 1 + 4/n^{1/4} (original wrote n^{3/4} in denominator)
old_thm36_ey = "As the\n    expectation of $Y$ is $\\Ex{Y} = \\frac{1}{1-p} = 1 + O(1/n^{3/4})$, it\n    follows the expected number of comparisons is $\\Ex{Y} \\xi$"
new_thm36_ey = "As the\n    expectation of $Y$ is \\newX{$\\Ex{Y} = 1/p \\leq 1 + O(1/n^{1/4})$}\\remX{Mathematical correction: For a geometric random variable with success probability $p \\geq 1 - 3/n^{1/4}$, the expected number of trials is $\\Ex{Y} = 1/p \\leq 1/(1 - 3/n^{1/4}) \\leq 1 + O(1/n^{1/4})$. The original text erroneously wrote $\\frac{1}{1-p} = 1 + O(1/n^{3/4})$.}, it\n    follows the expected number of comparisons is $\\Ex{Y} \\xi$"
content = replace_exact(content, old_thm36_ey, new_thm36_ey, "thm36_ey")

old_thm36_recurrence = "\\pth{ 1 + \\frac{6}{n^{3/4}}}"
new_thm36_recurrence = "\\newX{\\pth{ 1 + \\frac{4}{n^{1/4}}}}"
content = replace_exact(content, old_thm36_recurrence, new_thm36_recurrence, "thm36_recurrence")

# 9. Theorem 3.6 proof: Remove dangling sentence on Wald identity at the end of the recurrence
old_thm36_dangling = <<~'LATEX'.chomp
    using \Eqref{s-p-r-selection} Wald's identity yields
    $\Ex{C} \leq \Ex{Y}(1.5n + O(n^{3/4} \log n)) = 1.5n + 6n^{3/4} +
    O(n^{3/4} \log n) = 1.5n + O(n^{3/4} \log n) = 1.5n + o(n)$.
\end{proof}
LATEX

new_thm36_dangling = <<~'LATEX'.chomp
    \remX{Corrected denominator: By \Eqref{q-s-few-rounds}, $1/p \leq 1 + 4/n^{1/4}$ for sufficiently large $n$, correcting the typo that wrote $n^{3/4}$ in the denominator.}
    \newX{The recurrence above cleanly accounts for the expected $1.5n + O(n^{3/4})$ comparisons performed in partitioning across all rounds. In addition, sorting the sample $\Sample$ takes $O(m \log m) = O(n^{3/4} \log n)$ comparisons per round, and sorting $S_m$ in the final successful round takes $O(|S_m| \log |S_m|) = O(n^{3/4} \log n)$ comparisons. Since the expected number of rounds is $\Ex{Y} = 1 + O(1/n^{1/4}) = O(1)$, summing the partitioning and sorting costs yields the claimed total of $1.5n + O(n^{3/4} \log n)$ expected comparisons.}
    \remX{Pedagogical note on recurrence vs.~Wald's identity: The dangling sentence invoking Wald's identity has been removed. The memoryless recurrence already accounts for all partitioning comparisons directly and intuitively without requiring stopping times or formal martingales.}
\end{proof}
LATEX
content = replace_exact(content, old_thm36_dangling, new_thm36_dangling, "thm36_dangling")

# 10. Wald Equation theorem: Add \remX noting that while Wald is interesting, the memoryless recurrence is much simpler and preferred for class notes
old_wald_end = <<~'LATEX'.chomp
    \begin{math}
        \Ex{ \sum_{i=1}^{Y} X_i } = \Ex{Y} \,
        \Ex{X_1}.
    \end{math}
\end{theorem}
LATEX

new_wald_end = <<~'LATEX'.chomp
    \begin{math}
        \Ex{ \sum_{i=1}^{Y} X_i } = \Ex{Y} \,
        \Ex{X_1}.
    \end{math}
    \remX{Pedagogical note: While Wald's Equation is mathematically elegant and provides an alternative way to sum i.i.d.~rounds, introducing formal stopping times, filtrations, and measure-theoretic machinery adds unnecessary formalism for class notes. The memoryless recurrence for expected comparisons used in the proof of Theorem~3.6 is intuitive, elementary, self-contained, and pedagogically preferred for students.}
\end{theorem}
LATEX
content = replace_exact(content, old_wald_end, new_wald_end, "wald_remark")

File.write(dest_file, content)
puts "Successfully generated #{dest_file} (#{content.lines.count} lines)."
