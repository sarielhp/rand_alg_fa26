#!/usr/bin/env ruby
# frozen_string_literal: true

orig_file = File.expand_path('../chebychev.tex', __dir__)
dest_file = File.expand_path('../chebychev_reviewed.tex', __dir__)

content = File.read(orig_file)

def replace_exact(content, old_str, new_str, label)
  unless content.include?(old_str)
    raise "Failed to find #{label}:\n#{old_str}"
  end
  # Block form prevents Ruby from treating \&, \', \` as regex backreferences
  content.sub(old_str) { new_str }
end

# 1. Footnote 1 punctuation and priority remark
old_fn_clause = "(Russian: \\SpellIgnore{Пафну́тий Льво́вич\n      Чебышёв}), (May 16, 1821--December 8, 1894)"
new_fn_clause = "\\chgY{(Russian: \\SpellIgnore{Пафну́тий Льво́вич\n      Чебышёв}), (May 16, 1821--December 8, 1894)}{(Russian: \\SpellIgnore{Пафну́тий Льво́вич\n      Чебышёв}; May 16, 1821--December 8, 1894)}"
content = replace_exact(content, old_fn_clause, new_fn_clause, "fn_clause")

old_fn_quote = "``\\SpellIgnore{Cheby-SHOV}''{},{} rhyming with\n   ``shove''.}"
new_fn_quote = "``\\SpellIgnore{Cheby-SHOV}\\chgY{''{},{}}{'',} rhyming with\n   ``shove''.} \\remX{Historical priority: The inequality was first discovered and published in 1853 by the French mathematician Ir{\\'e}n{\\'e}e-Jules Bienaym{\\'e}~\\cite{b-cadld-1853}, fourteen years before Chebyshev published it independently in 1867~\\cite{c-dvm-1867}. Andrei Markov later acknowledged Bienaym{\\'e}'s priority, which is why it is often called the Bienaym{\\'e}--Chebyshev inequality; see Butzer and Jongmans~\\cite{b-pct-99}.}"
content = replace_exact(content, old_fn_quote, new_fn_quote, "fn_quote")

# 2. Subsection 1.1 phrasing and indexing
old_s11_vars = "each taking value $\\pm 1$ with equal probability $1/2$. Let\n$Y= \\sum_i X_i$."
new_s11_vars = "each \\chgY{taking value $\\pm 1$}{taking each value in $\\brc{-1,+1}$} with equal probability $1/2$. Let\n\\chgY{$Y= \\sum_i X_i$}{$Y= \\sum_{i=1}^n X_i$}."
content = replace_exact(content, old_s11_vars, new_s11_vars, "s11_vars")

# 3. Remark 1.1 phrasing
old_rem1_title = '\begin{remark}[Maybe skip for now]'
new_rem1_title = '\begin{remark}[\chgY{Maybe skip for now}{Pairwise vs.~mutual independence}]'
content = replace_exact(content, old_rem1_title, new_rem1_title, "rem1_title")

old_rem1_body = "put differently, Chebyshev is NOT strictly dominated by\n    tools we would see later on."
new_rem1_body = "put differently, \\chgY{Chebyshev is NOT strictly dominated by\n    tools we would see}{Chebyshev's inequality is not strictly dominated by\n    tools we will see} later on."
content = replace_exact(content, old_rem1_body, new_rem1_body, "rem1_body")

# 4. Lemma 1.1 pairwise independence and proof remark
old_lem1_decl = "Let $X_1, \\ldots, X_n \\in \\brc{-1,+1}$ be mutually independent random\n    variables, each taking $\\pm 1$ with probability $1/2$."
new_lem1_decl = "Let $X_1, \\ldots, X_n \\in \\brc{-1,+1}$ be \\chgY{mutually independent}{pairwise independent} random\n    variables, each \\chgY{taking $\\pm 1$}{taking each value in $\\brc{-1, +1}$} with probability $1/2$."
content = replace_exact(content, old_lem1_decl, new_lem1_decl, "lem1_decl")

old_lem1_end = "by Markov's inequality.\n\\end{proof}"
new_lem1_end = "by Markov's inequality.\n    \\remX{Markov's inequality applies to the non-negative variable $Z = Y^2 \\geq 0$ with threshold $a = t^2 \\Ex{Z} = t^2 n > 0$, giving $\\Prob{Z \\geq a} \\leq \\Ex{Z}/a = 1/t^2$. Note that only pairwise independence is needed to establish $\\Ex{Z} = n$.}\n\\end{proof}"
content = replace_exact(content, old_lem1_end, new_lem1_end, "lem1_end")

# 5. Theorem 1.2: Remark on sigma_X = 0 edge case and Exercise title
old_thm12_end = "\\end{theorem}\n\\end{fragment}"
new_thm12_end = "\\end{theorem}\n\\end{fragment}\n\\remX{Degeneracy when $\\sigma_X = 0$: If $\\Var{X} = 0$, then $X = \\mu_X$ almost surely, and $\\Prob{|X - \\mu_X| \\geq t \\sigma_X} = \\Prob{0 \\geq 0} = 1$, which strictly exceeds $1/t^2$ for any $t > 1$. The standardized tail form requires $\\sigma_X > 0$. Alternatively, expressing the deviation in absolute form $\\lambda > 0$ as $\\Prob{|X - \\mu_X| \\geq \\lambda} \\leq \\frac{\\Var{X}}{\\lambda^2}$ holds unconditionally for all random variables, yielding $0 \\leq 0$ when $\\Var{X} = 0$.}"
content = replace_exact(content, old_thm12_end, new_thm12_end, "thm12_end")

old_ex13 = '\begin{exercise}[Not too interesting]'
new_ex13 = '\begin{exercise}[\chgY{Not too interesting}{Degenerate variance}]'
content = replace_exact(content, old_ex13, new_ex13, "ex13")

# 6. Example 1.4 binomial phrasing
old_ex14_dist = 'binomial distribution with probability $p$, and $m$ trials.'
new_ex14_dist = 'binomial distribution with \chgY{probability $p$, and $m$ trials}{parameters $m$ and $p$}.'
content = replace_exact(content, old_ex14_dist, new_ex14_dist, "ex14_dist")

old_ex14_add = "Since\n    the variance is additive for independent variables, we have"
new_ex14_add = "\\chgY{Since\n    the variance is additive for independent variables}{Since\n    variance is additive for pairwise independent random variables}, we have"
content = replace_exact(content, old_ex14_add, new_ex14_add, "ex14_add")

# 7. Section 2 phrasing and CRITICAL MATHEMATICAL PROOF FIX for Lemma 2.1
old_lem21_decl = "Let $U$ be a set of elements, with $p$ fraction of them having a\n    certain property $\\propertyC$."
new_lem21_decl = "Let $U$ be a set of elements, \\chgY{with $p$ fraction of them having a\n    certain property $\\propertyC$}{where a fraction $p$ of the elements have a\n    certain property $\\propertyC$}."
content = replace_exact(content, old_lem21_decl, new_lem21_decl, "lem21_decl")

old_thus_by = "\\sigma_Y = \\sqrt{\\Var{Y}} \\leq \\sqrt{m}/2$. Thus, by\n    \\thmrefY{Chebyshev's inequality}{Chebyshev:inequality}"
new_thus_by = "\\sigma_Y = \\sqrt{\\Var{Y}} \\leq \\sqrt{m}/2$. \\newX{Since $t \\sigma_Y \\leq t \\sqrt{m}/2$, by}\n    \\thmrefY{Chebyshev's inequality}{Chebyshev:inequality}"
content = replace_exact(content, old_thus_by, new_thus_by, "thus_by")

old_lem21_ineq = "\\LEQ\n        1- \\frac{1}{t^2}.\n    \\end{equation*}\n\\end{proof}"
new_lem21_ineq = <<~'LATEX'.chomp
        \LEQ
        \chgY{1- \frac{1}{t^2}}{\frac{1}{t^2}}.
    \end{equation*}
    \newX{Taking the complement yields}
    \begin{equation*}
        \newX{\Prob{ \cardin{Y - \Ex{Y}} \leq t \sqrt{m}/2 } \geq 1 - \frac{1}{t^2},}
    \end{equation*}
    \newX{which is equivalent to the stated bound.}
    \remX{Critical mathematical correction: Chebyshev's inequality bounds the deviation tail probability by $1/t^2$, not $1 - 1/t^2$. The probability that $Y$ stays within $t \sqrt{m}/2$ of its mean is the complement $1 - \Prob{|Y - \Ex{Y}| > t\sqrt{m}/2} \geq 1 - 1/t^2$. Also, applying Chebyshev's bound directly with absolute deviation $\lambda = t\sqrt{m}/2$ gives $\Prob{|Y - \Ex{Y}| \geq t\sqrt{m}/2} \leq \frac{\Var{Y}}{(t\sqrt{m}/2)^2} = \frac{4mp(1-p)}{t^2 m} \leq \frac{1}{t^2}$, which holds unconditionally even if $\sigma_Y = 0$.}
\end{proof}
LATEX
content = replace_exact(content, old_lem21_ineq, new_lem21_ineq, "lem21_ineq")

# 8. Example 2.2 and 2.3 grammar and precision
old_ex22_ref = "and by the\n    \\lemrefY{above lemma}{Chebyshev-1} that"
new_ex22_ref = "\\chgY{and by the\n    \\lemrefY{above lemma}{Chebyshev-1} that}{and by \\lemref{Chebyshev-1}, we have that}"
content = replace_exact(content, old_ex22_ref, new_ex22_ref, "ex22_ref")

old_ex22_prob = 'with probability of $99\%$. That is pretty crazy'
new_ex22_prob = '\\chgY{with probability of $99\%$}{with probability at least $99\%$}. That is pretty crazy'
content = replace_exact(content, old_ex22_prob, new_ex22_prob, "ex22_prob")

old_ex23_text = "That is $\\widehat{p} = Y/m$ is an estimate of $p$ (i.e., it\n    is the fraction of the sample that has the desired property)."
new_ex23_text = "\\chgY{That is $\\widehat{p} = Y/m$ is an estimate}{That is, $\\widehat{p} = Y/m$ is an estimate} of $p$ (i.e.,\n    \\chgY{it is the fraction}{the fraction} of the sample that has the desired property)."
content = replace_exact(content, old_ex23_text, new_ex23_text, "ex23_text")

# 9. Lemma 2.3 CRITICAL TYPO FIX (p = C/n not m/n) and proof complement
old_lem23_head = "In the settings of \\lemref{Chebyshev-1}, let $n= \\cardin{U}$ and\n    assume that $\\numC$ of them have the property (i.e.,\n    $p=\\tfrac{m}{n}$)."
new_lem23_head = "\\chgY{In the settings of}{In the setting of} \\lemref{Chebyshev-1}, let $n= \\cardin{U}$ and\n    assume that $\\numC$ of them have the property (i.e.,\n    \\chgY{$p=\\tfrac{m}{n}$}{$p=\\tfrac{\\numC}{n}$})."
content = replace_exact(content, old_lem23_head, new_lem23_head, "lem23_head")

old_lem23_end = "        \\Prob{\\bigl. \\cardin{Y - \\Ex{Y} } \\geq t \\sigma_Y }%\n        \\leq\n        \\frac{1}{t^2}.\n    \\end{align*}\n\\end{proof}"
new_lem23_end = "        \\Prob{\\bigl. \\cardin{Y - \\Ex{Y} } \\geq t \\sigma_Y }%\n        \\leq\n        \\frac{1}{t^2}.\n    \\end{align*}\n    \\newX{Taking the complement completes the proof.}\n    \\remX{Mathematical typo fix: $p = \\numC / n$ is the proportion of elements with the property; $m$ is the sample size. The final line of the proof bounds the failure tail $\\Prob{|Z - \\numC| \\geq t \\frac{n}{2\\sqrt{m}}} \\leq 1/t^2$, whose complement establishes the concentration interval in the lemma statement.}\n\\end{proof}"
content = replace_exact(content, old_lem23_end, new_lem23_end, "lem23_end")

# 10. Subsection 3.1: terminology "element of rank" & boundary condition remark
old_rank = "$\\EBRY{U}{i}$ is the number of \\emphi{rank} $i$ in $U$."
new_rank = "$\\EBRY{U}{i}$ is \\chgY{the number of \\emphi{rank} $i$}{the element of \\emphi{rank} $i$} in $U$."
content = replace_exact(content, old_rank, new_rank, "rank")

old_lem31_item = '\item The number of rank $k$ in $U$ is in the interval'
new_lem31_item = '\item \chgY{The number of rank $k$}{The element of rank $k$} in $U$ is in the interval'
content = replace_exact(content, old_lem31_item, new_lem31_item, "lem31_item")

old_lem31_end = "  most $h-g$ candidate elements remain in $\\{g+1,\\dots,h\\}$.\n\\end{proof}"
new_lem31_end = "  most $h-g$ candidate elements remain in $\\{g+1,\\dots,h\\}$.\n  \\remX{Boundary edge cases: If $g \\leq 0$, no elements in $U$ have rank $\\leq g$, so trivially zero elements are excluded from below; similarly if $h > n$, all elements have rank $\\leq h$. In either extreme, the number of candidate elements in $\\Interval \\cap U$ remains bounded by $h - g \\leq 8t n/\\sqrt{m}$.}\n\\end{proof}"
content = replace_exact(content, old_lem31_end, new_lem31_end, "lem31_end")

# 11. Subsection 3.1.1 (Intuition): Deterministic vs random intervals and algebraic refinement
old_intuition_1 = "We have that $\\IntervalA(g, t)$, $\\IntervalA(k, t)$ and\n$\\IntervalA(h, t)$ are all disjoint, with probability $\\geq 1 - 3/t^2$."
new_intuition_1 = "\\chgY{We have that $\\IntervalA(g, t)$, $\\IntervalA(k, t)$ and\n$\\IntervalA(h, t)$ are all disjoint, with probability $\\geq 1 - 3/t^2$.}{By construction, the sample rank intervals $\\IntervalA(g, t)$, $\\IntervalA(k, t)$, and $\\IntervalA(h, t)$ are deterministically pairwise disjoint.}"
content = replace_exact(content, old_intuition_1, new_intuition_1, "intuition_1")

old_intuition_2 = "  \\cardin{\\big.\\ts \\Interval(k) \\cap U\\ts}%\n  \\leq%\n  h-g%\n  \\leq%\n  4\\pth[]{t \\frac{n}{2\\sqrt{m}}}.\n\\end{math}"
new_intuition_2 = "  \\cardin{\\big.\\ts \\Interval(k) \\cap U\\ts}%\n  \\leq%\n  h-g%\n  \\leq%\n  \\chgY{4\\pth[]{t \\frac{n}{2\\sqrt{m}}}}{2 t \\frac{n}{\\sqrt{m}} + 4 \\frac{n}{m} \\leq 6 t \\frac{n}{\\sqrt{m}}}.\n\\end{math}\n\\remX{Disjointness of the rank intervals $\\IntervalA(\\cdot, t)$ in the sample is deterministic by algebraic choice of $g$ and $h$; the random confidence intervals $\\Interval(\\cdot)$ in $U$ are disjoint with probability $\\geq 1 - 3/t^2$. Also refined the size calculation: $h - g = 2(t \\frac{n}{\\sqrt{m}} + 2\\frac{n}{m}) = 2t \\frac{n}{\\sqrt{m}} + 4\\frac{n}{m} \\leq 6t \\frac{n}{\\sqrt{m}}$.}"
content = replace_exact(content, old_intuition_2, new_intuition_2, "intuition_2")

# 12. Subsection 3.2: failure case grammatical consistency & Remark 3.4 attribution
old_case2 = '\item $\cardin{S_m} > 8 t {n}/ \sqrt{m} = O( n^{3 / 4})$. This is bad'
new_case2 = '\item \chgY{$\cardin{S_m} > 8 t {n}/ \sqrt{m} = O( n^{3 / 4})$. This is bad}{If $\cardin{S_m} > 8 t {n}/ \sqrt{m} = O( n^{3 / 4})$, then the algorithm fails (as}'
content = replace_exact(content, old_case2, new_case2, "case2")

old_rem34_body = "Crucially for our analysis this algorithm is not recursive---it\n    performs some rounds of sampling followed by partition, and then a\n    single sorting of the interval of interest and extracting the desired\n    element from this sorted subset. It is thus fundamentally different\n    than \\AlgorithmI{QuickSelect}."
new_rem34_body = "Crucially for our \\chgY{analysis this algorithm}{analysis, this algorithm} is not recursive---it\n    performs some rounds of sampling followed by partition, and then a\n    single sorting of the interval of interest and extracting the desired\n    element from this sorted subset. It is thus \\chgY{fundamentally different\n    than}{fundamentally different from} \\AlgorithmI{QuickSelect}."
content = replace_exact(content, old_rem34_body, new_rem34_body, "rem34_body")

old_rem34_end = "\\end{remark}"
new_rem34_end = "\\end{remark}\n\\remX{Historical attribution: This randomized selection algorithm is the landmark Floyd--Rivest algorithm~\\cite{fr-a4s-75,fr-etbs-75} (Algorithm~489, \\textsf{Select}), published in 1975. While Hoare's \\textsf{QuickSelect}~\\cite{h-a6f-61} uses $O(n)$ expected comparisons (approximately $3.38 n$ for the median) and the deterministic BFPRT algorithm~\\cite{bfprt-tbs-73} requires $\\leq 5.43 n$ comparisons, Floyd and Rivest achieved $n + \\min(k, n-k) + o(n)$ expected comparisons (which is $1.5 n + o(n)$ for the median) using two sample pivots derived from Chebyshev's inequality.}"
content = replace_exact(content, old_rem34_end, new_rem34_end, "rem34_end")

# 13. Subsection 3.2.2: punctuation and grammar
old_an1 = 'For the sake of simplicity of exposition we ignore any floors/ceilings in'
new_an1 = 'For the sake of simplicity of \chgY{exposition we ignore}{exposition, we ignore} any floors/ceilings in'
content = replace_exact(content, old_an1, new_an1, "an1")

old_an2 = 'It is probability way'
new_an2 = '\chgY{It is probability way}{It is probability\'s way of}'
content = replace_exact(content, old_an2, new_an2, "an2")

old_an3 = "it\nsucceeded in the first try."
new_an3 = "\\chgY{it\nsucceeded in the first try}{the algorithm succeeds on the first try}."
content = replace_exact(content, old_an3, new_an3, "an3")

# 14. Subsection 3.2.3: Lemma 3.5 precision, pronoun agreement, and Theorem 3.6 rigor
old_lem35 = "Given the numbers $r_{-}, r_{+}$, one can compute the sets $S_<$,\n    $S_m$, and $S_>$ using in expectation (strikingly only)\n    $1.5n + O(n^{3/4})$ comparisons."
new_lem35 = "Given the numbers $r_{-}, r_{+}$ \\newX{computed by \\lemref{good:interval}}, one can compute the sets $S_<$,\n    $S_m$, and $S_>$ using in expectation (strikingly only)\n    $1.5n + O(n^{3/4})$ comparisons."
content = replace_exact(content, old_lem35, new_lem35, "lem35")

old_pronoun = 'require only one comparison to put them into the right'
new_pronoun = 'require only one comparison to \chgY{put them into the right}{put it into the right}'
content = replace_exact(content, old_pronoun, new_pronoun, "pronoun")

old_thm36_end = "\\end{align*}\n\\end{proof}"
new_thm36_end = "\\end{align*}\n    \\remX{Probabilistic rigor: Each round $i$ uses an expected $\\Ex{C_i} \\leq 1.5n + O(n^{3/4})$ comparisons for partitioning and $O(m \\log m) = O(n^{3/4} \\log n)$ comparisons to sort $\\Sample$. Sorting $S_m$ occurs only in the final round, taking $O(|S_m| \\log |S_m|) = O(n^{3/4} \\log n)$ comparisons. Since $Y$ is a geometric stopping time with $\\Ex{Y} \\leq 1 + 4/n^{1/4}$, Wald's identity yields $\\Ex{C} \\leq \\Ex{Y}(1.5n + O(n^{3/4} \\log n)) = 1.5n + 6n^{3/4} + O(n^{3/4} \\log n) = 1.5n + O(n^{3/4} \\log n) = 1.5n + o(n)$.}\n\\end{proof}"
content = replace_exact(content, old_thm36_end, new_thm36_end, "thm36_end")

File.write(dest_file, content)
puts "Successfully written #{dest_file} with #{content.lines.count} lines."
