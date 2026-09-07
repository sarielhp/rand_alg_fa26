#!/usr/bin/env ruby
# frozen_string_literal: true

orig_file = File.expand_path('../chebychev.tex', __dir__)
dest_file = File.expand_path('../chebychev_reviewed.tex', __dir__)

content = File.read(orig_file)

def replace_exact(content, old_str, new_str, label)
  raise "Failed to find #{label}" unless content.include?(old_str)
  # Block form prevents Ruby from treating \&, \', \` as regex backreferences
  content.sub(old_str) { new_str }
end

# 1. Epigraph quote typography
old_quote = "“The natives are to be instructed\n   that on pain of harsh penalties, every rebellion must be announced,\n   in writing, six weeks before it breaks out.”"
new_quote = "\\chgY{“}{``}The natives are to be instructed\n   that on pain of harsh penalties, every rebellion must be announced,\n   in writing, six weeks before it breaks \\chgY{out.”}{out.''}"
content = replace_exact(content, old_quote, new_quote, "epigraph")

# 2. Section 1 Chebyshev spelling footnote and dates
old_s1 = "Here, we discuss Chebyshev's inequality, sometimes written as Chebychev's\ninequality using the Frechet spelling of Chebyshev\\footnote{\\emph{Pafnuty\n      Lvovich Chebyshev} (Russian: \\SpellIgnore{Пафну́тий Льво́вич\n         Чебышёв}), (16 May, 1821--8 December, 1894) was a Russian\n      mathematician and considered to be the founding father of Russian\n      mathematics (wikipedia).}.\n"

new_s1 = <<~'LATEX'
Here, we discuss Chebyshev's inequality, sometimes written as Chebychev's
inequality using the \chgY{Frechet}{Fr{\'e}chet} spelling of Chebyshev\footnote{\emph{Pafnuty
      Lvovich Chebyshev} (Russian: \SpellIgnore{Пафну́тий Льво́вич
         Чебышёв}), \chgY{(16 May, 1821--8 December, 1894)}{(May 16, 1821--December 8, 1894)} was a Russian
      mathematician and \newX{is} considered to be the founding father of Russian
      \chgY{mathematics (wikipedia).}{mathematics; see~\cite{b-pct-99}.}\remX{The Russian letter \emph{ё} in Чебышёв is pronounced ``yo'', making the native pronunciation ``Cheby-SHOV'', rhyming with ``shove''.}}
LATEX
content = replace_exact(content, old_s1, new_s1, "s1")

# 3. Subsection 1.1 phrasing
old_moments = <<~'LATEX'
Let $X_i \in \brc{-1,+1}$ each with probability $1/2$, for
$i=1,\ldots, n$ (mutually independent). Let $Y= \sum_i X_i$. We have that
LATEX

new_moments = <<~'LATEX'
\chgY{Let $X_i \in \brc{-1,+1}$ each with probability $1/2$, for
$i=1,\ldots, n$ (mutually independent).}{Let $X_1, \ldots, X_n \in \brc{-1,+1}$ be mutually independent random variables, each taking value $\pm 1$ with equal probability $1/2$.} Let $Y= \sum_i X_i$. We have that
LATEX
content = replace_exact(content, old_moments, new_moments, "moments")

# 3b. Mention pairwise independence in moments
old_moments_eq = <<~'LATEX'
  n + 2 \sum_{i < j} \Ex{ X_i} \Ex{ X_j}%
  \EQ%
  n.
\end{align*}
LATEX

new_moments_eq = <<~'LATEX'
  n + 2 \sum_{i < j} \Ex{ X_i} \Ex{ X_j}%
  \EQ%
  n.
\end{align*}
\remX{Note that this second-moment derivation requires only pairwise independence of $X_1, \ldots, X_n$, rather than full mutual independence. This property is a principal advantage of Chebyshev's inequality over higher-moment techniques.}
LATEX
content = replace_exact(content, old_moments_eq, new_moments_eq, "moments_eq")

# 4. Lemma 1.1 statement punctuation and phrasing
old_lem1 = <<~'LATEX'
\begin{lemma}
    Let $X_i \in \brc{-1,+1}$ each with probability $1/2$, for
    $i=1,\ldots, n$ (mutually independent). For any $t > 0$, we have that
    \begin{equation*}
        \Prob{ \cardin{\sum_i X_i} \geq t \sqrt{n}} \leq 1/t^2
    \end{equation*}
\end{lemma}
LATEX

new_lem1 = <<~'LATEX'
\begin{lemma}
    \chgY{Let $X_i \in \brc{-1,+1}$ each with probability $1/2$, for
    $i=1,\ldots, n$ (mutually independent).}{Let $X_1, \ldots, X_n \in \brc{-1,+1}$ be mutually independent random variables, each taking $\pm 1$ with probability $1/2$.} For any $t > 0$, we have that
    \begin{equation*}
        \Prob{ \cardin{\sum_i X_i} \geq t \sqrt{n}} \leq 1/t^2\newX{.}
    \end{equation*}
\end{lemma}
LATEX
content = replace_exact(content, old_lem1, new_lem1, "lem1")

# 5. Chebyshev inequality theorem remark (sigma=0 edge case)
old_cheb_thm = <<~'LATEX'
\begin{fragment}{\deflabel{Chebyshev}}
    \begin{theorem}[Chebyshev's inequality]
        \thmlab{Chebyshev:inequality}%
        %
        Let $X$ be a real random variable, with $\mu_X = \Ex{X}$, and
        $\sigma_X = \sqrt{\Var{X}}$. Then, for any $t > 0$, we have
        \begin{equation*}
            \Prob{\bigl. \cardin{X - \mu_X} \geq t \sigma_X} \leq
            \frac{1}{t^2}.
        \end{equation*}
        % where $\mu_X = \Ex{\bigl. X}$ and
        % $\sigma_X = \sqrt{\Var{ X}}$.
    \end{theorem}
\end{fragment}
LATEX

new_cheb_thm = <<~'LATEX'
\begin{fragment}{\deflabel{Chebyshev}}
    \begin{theorem}[Chebyshev's inequality]
        \thmlab{Chebyshev:inequality}%
        %
        Let $X$ be a real random variable, with $\mu_X = \Ex{X}$, and
        $\sigma_X = \sqrt{\Var{X}}$. Then, for any $t > 0$, we have
        \begin{equation*}
            \Prob{\bigl. \cardin{X - \mu_X} \geq t \sigma_X} \leq
            \frac{1}{t^2}.
        \end{equation*}
        % where $\mu_X = \Ex{\bigl. X}$ and
        % $\sigma_X = \sqrt{\Var{ X}}$.
    \end{theorem}
\end{fragment}
\remX{If $\sigma_X = 0$, $X = \mu_X$ almost surely, and for any $\lambda > 0$, $\Prob{|X - \mu_X| \geq \lambda} = 0 \leq \Var{X}/\lambda^2$. Stating Chebyshev's inequality in deviation form $\Prob{|X - \mu_X| \geq \lambda} \leq \Var{X}/\lambda^2$ for any $\lambda > 0$ avoids degeneracy when $\sigma_X = 0$.}
LATEX
content = replace_exact(content, old_cheb_thm, new_cheb_thm, "cheb_thm")

# 6. Example 1.3 formatting and notation
old_ex1 = <<~'LATEX'
\begin{example}[Variance of a binomial distribution]
    Let $Y = \sum_{i=1}^m Y_i$,\hfil\break where $Y_1, \ldots, Y_m$ are
    independent random $0/1$ variables that are each one with probability
    $p$. The random variable $Y$ has a binomial distribution with
    probability $p$, and $m$ trials.  That is, $Y \sim
    \DistBinom{m}{p}$. Thus, for all $i$, we have $\Ex{Y_i} = p$, and
    $\Var{Y_i} = \Ex{Y_i^2} - \Ex{Y_i}^2 = p - p^2 = p(1-p)$. Since the
    variance is additive for independent variables, we have
    \begin{equation*}
        \Var{Y} = \Var{\Bigl. \smash{\sum_i Y_i}} =
        \smash{\sum_{i=1}^m \Var{Y_i}} = m p (1-p).
    \end{equation*}
    This also implies that
    $\Ex{\smash{Y^2}} = \Var{Y} + \pth{\Ex{Y}}^2 = m p (1-p) + m^2 p^2$.
\end{example}
LATEX

new_ex1 = <<~'LATEX'
\begin{example}[Variance of a binomial distribution]
    Let $Y = \sum_{i=1}^m Y_i$\chgY{,\hfil\break where}{, where} $Y_1, \ldots, Y_m$ are
    independent \chgY{random $0/1$ variables that are each one with probability
    $p$}{Bernoulli random variables, each taking value $1$ with probability $p$ and $0$ with probability $1-p$}. The random variable $Y$ has a binomial distribution with
    probability $p$, and $m$ trials.  That is, $Y \sim
    \DistBinom{m}{p}$. Thus, for all $i$, we have $\Ex{Y_i} = p$, and
    $\Var{Y_i} = \chgY{\Ex{Y_i^2} - \Ex{Y_i}^2}{\Ex{Y_i^2} - \pth{\Ex{Y_i}}^2} = p - p^2 = p(1-p)$. Since the
    variance is additive for independent variables, we have
    \begin{equation*}
        \Var{Y} = \Var{\Bigl. \smash{\sum_i Y_i}} =
        \smash{\sum_{i=1}^m \Var{Y_i}} = m p (1-p).
    \end{equation*}
    This also implies that
    $\Ex{\smash{Y^2}} = \Var{Y} + \pth{\Ex{Y}}^2 = m p (1-p) + m^2 p^2$.
\end{example}
LATEX
content = replace_exact(content, old_ex1, new_ex1, "ex1")

# 7. Overfull hbox fix in Section 2
old_s2 = "A natural approach is to pick a random sample $\\Sample$ of $m$ objects,\n$r_1, \\ldots, r_m$ from $U$ (with replacement), and compute"
new_s2 = "A natural approach is to pick a random \\chgY{sample $\\Sample$ of $m$ objects,\n$r_1, \\ldots, r_m$ from $U$ (with replacement), and compute}{sample $\\Sample$ of $m$ objects $r_1, \\ldots, r_m \\in U$ (with replacement), and compute}"
content = replace_exact(content, old_s2, new_s2, "s2")

# 8. Lemma 2.1 proof remark (Chebyshev bound directly avoiding sigma_Y = 0)
old_lem2_end = <<~'LATEX'
      \Prob{\bigl. \cardin{Y - \Ex{Y} } \geq t \sigma_Y }%
      \leq
      \frac{1}{t^2}.
    \end{align*}
\end{proof}
LATEX

new_lem2_end = <<~'LATEX'
      \Prob{\bigl. \cardin{Y - \Ex{Y} } \geq t \sigma_Y }%
      \leq
      \frac{1}{t^2}.
    \end{align*}
    \remX{Alternatively, applying Chebyshev's bound directly with deviation $\lambda = t \sqrt{m}/2$ gives $\Prob{|Y - \Ex{Y}| \geq t\sqrt{m}/2} \leq \frac{\Var{Y}}{(t\sqrt{m}/2)^2} = \frac{4 m p (1-p)}{t^2 m} \leq \frac{1}{t^2}$, which holds unconditionally for all $p \in [0, 1]$, even when $\sigma_Y = 0$.}
\end{proof}
LATEX
content = replace_exact(content, old_lem2_end, new_lem2_end, "lem2_end")

# 9. Section 3 title overfull hbox fix
old_s3 = '\Section{Rand{.} selection---learning via sampling}'
new_s3 = '\Section{Randomized selection via sampling}'
content = replace_exact(content, old_s3, new_s3, "s3")

# 10. Lemma 3.1 precision on rank k
old_lem3 = "    Given a set $U$ of $n$ numbers, a number $k$, and parameters\n    $t \\geq 1$ and $m \\geq 1$, one can compute, in $O(m \\log m)$ time,"
new_lem3 = "    Given a set $U$ of $n$ numbers, \\chgY{a number $k$}{a rank $k \\in \\brc{1, \\dots, n}$}, and parameters\n    $t \\geq 1$ and $m \\geq 1$, one can compute, in $O(m \\log m)$ time,"
content = replace_exact(content, old_lem3, new_lem3, "lem3")

# 11. Lemma 3.1 proof g_Sample definition clarification
old_g_sample = "    \\textbf{(B)} Let $g= k - t \\frac{n}{\\sqrt{m}} -3\\frac{n}{m}$, and\n    let $g^{}_\\Sample$ be the number of elements in $\\Sample$ that are\n    smaller than $\\EBRY{U}{g}$. Arguing as above, we have that"
new_g_sample = "    \\textbf{(B)} Let $g= k - t \\frac{n}{\\sqrt{m}} -3\\frac{n}{m}$, and\n    let $g^{}_\\Sample$ be the number of elements in $\\Sample$ that are\n    \\chgY{smaller than $\\EBRY{U}{g}$}{at most $\\EBRY{U}{g}$ (i.e., $\\leq \\EBRY{U}{g}$)}. Arguing as above, we have that"
content = replace_exact(content, old_g_sample, new_g_sample, "g_sample")

# 11b. Remark on g_sample
old_g_sample_end = <<~'LATEX'
  In words, since ranks $1,\dots,g$ and $h+1,\dots,n$ are excluded, at
  most $h-g$ candidate elements remain in $\{g+1,\dots,h\}$.
\end{proof}
LATEX

new_g_sample_end = <<~'LATEX'
  In words, since ranks $1,\dots,g$ and $h+1,\dots,n$ are excluded, at
  most $h-g$ candidate elements remain in $\{g+1,\dots,h\}$.
  \remX{Defining $g^{}_\Sample$ using $\leq \EBRY{U}{g}$ ensures that $g^{}_\Sample < \ell_-$ strictly implies $\Sample[\ell_-] > \EBRY{U}{g}$, cleanly excluding all elements with ranks $1, \dots, g$ from $[r_-, r_+]$.}
\end{proof}
LATEX
content = replace_exact(content, old_g_sample_end, new_g_sample_end, "g_sample_end")

# 12. Intuition subsection em-dash
old_dash = 'as a \emph{confidence interval} -- we know that $s_k \in \Interval(k)$'
new_dash = 'as a \emph{confidence interval}\chgY{ --}{---}we know that $s_k \in \Interval(k)$'
content = replace_exact(content, old_dash, new_dash, "dash")

# 13. Algorithm description typos and tense
old_alg_cases = <<~'LATEX'
    \item If $\rankY{r_{-}}{ S} > k$ or $\rankY{r_{+}}{S} < k $ then the
    algorithm failed.

    \item $\cardin{S_m} > 8 t {n}/ \sqrt{m} = O( n^{3 / 4})$. This is bad
    as the set $S_m$ is too large.
\end{compactitem}
\medskip%
If any of these failures happen, then the algorithm restart from scratch.
\begin{compactitem}
    \smallskip%
    \item if $k = \cardin{S_<}$, the algorithm returns $r_-$ as the
    desired answer.

    \smallskip%
    \item If $k = \cardin{S_<} + \cardin{S_m} + 1$, then 
    $r_+$ is returned.
LATEX

new_alg_cases = <<~'LATEX'
    \item If $\rankY{r_{-}}{ S} > k$ or $\rankY{r_{+}}{S} < k $ then the
    algorithm \chgY{failed}{fails}.

    \item $\cardin{S_m} > 8 t {n}/ \sqrt{m} = O( n^{3 / 4})$. This is bad
    as the set $S_m$ is too large.
\end{compactitem}
\medskip%
If \chgY{any of these failures happen, then the algorithm restart}{either failure occurs, the algorithm restarts} from scratch.
\begin{compactitem}
    \smallskip%
    \item \chgY{if}{If} $k = \cardin{S_<}$, the algorithm returns $r_-$ as the
    desired answer.

    \smallskip%
    \item If $k = \cardin{S_<} + \cardin{S_m} + 1$, then 
    \chgY{$r_+$ is returned}{the algorithm returns $r_+$}.
LATEX
content = replace_exact(content, old_alg_cases, new_alg_cases, "alg_cases")

# 14. Analysis intro: "routs" typo and grammar
old_analysis = <<~'LATEX'
For the sake of simplicity of exposition we ignore any floors/ceilings in
the calculations here\footnote{It is easy to verify the floor function
   only introduce tedium and anxiety in carrying out (essentially) the
   same calculations.}.  The correctness is intuitively easy---the
algorithm clearly returns the desired element (the analysis below shows
that its probability of running an infinite number of routs is
zero. Implying the algorithm always terminates [so not so easy after
all]).
LATEX

new_analysis = <<~'LATEX'
For the sake of simplicity of exposition we ignore any floors/ceilings in
the calculations here\footnote{It is easy to verify the floor function
   only \chgY{introduce}{introduces} tedium and anxiety in carrying out (essentially) the
   same calculations.}.  The correctness is intuitively easy---the
algorithm clearly returns the desired element (the analysis below shows
that \chgY{its probability of running an infinite number of routs is
zero. Implying the algorithm always terminates [so not so easy after
all]}{the probability of running an infinite number of rounds is zero, which implies that the algorithm terminates almost surely}).
LATEX
content = replace_exact(content, old_analysis, new_analysis, "analysis")

# 15. Running time paragraph phrasing
old_run1 = 'By (previously mysterious, but now hopefully clear)'
new_run1 = 'By \delX{(previously mysterious, but now hopefully clear)}'
content = replace_exact(content, old_run1, new_run1, "run1")

# 16. CRITICAL FIX: Geometric variable success probability & typo "runing"
old_rounds = <<~'LATEX'
\subparagraph*{Not too many rounds.}

More generally, the probability that the algorithm fails in the first
$\alpha$ tries to get a good interval $[r_{-}, r_{+}]$ is at most
$(3/n^{1/4})^\alpha = O(3^\alpha /n^{\alpha /4})$. Let $Y$ be the expected number of
rounds the algorithm performs. The running time of the algorithm is
$ O(Yn)$.  The variable $Y$ is a geometric variable and has
\begin{equation}
    \mu = \Ex{Y} \leq  \frac{1}{  1- 3/n^{1/4}} \leq 1 + 4/n^{1/4},
    \eqlab{q-s-few-rounds}
\end{equation}
for $n$ sufficiently large, as $Y$ is a geometric variable with
probability $p \geq 3/n^{1/4}$.  Thus, the expected runing time of the
algorithm is $O(n)$.
LATEX

new_rounds = <<~'LATEX'
\subparagraph*{Not too many rounds.}

More generally, the probability that the algorithm fails in the first
$\alpha$ tries to get a good interval $[r_{-}, r_{+}]$ is at most
$(3/n^{1/4})^\alpha = O(3^\alpha /n^{\alpha /4})$. Let $Y$ be the \chgY{expected number of rounds}{number of rounds} the algorithm performs. The running time of the algorithm is
$ O(Yn)$.  The variable $Y$ is a geometric variable and has
\begin{equation}
    \mu = \Ex{Y} \leq  \frac{1}{  1- 3/n^{1/4}} \leq 1 + 4/n^{1/4},
    \eqlab{q-s-few-rounds}
\end{equation}
for $n$ sufficiently large, \chgY{as $Y$ is a geometric variable with
probability $p \geq 3/n^{1/4}$.  Thus, the expected runing time of the
algorithm is $O(n)$.}{since $Y$ is a geometric random variable with success probability $p \geq 1 - 3/n^{1/4}$. Thus, the expected running time of the algorithm is $O(n)$.}
\remX{Crucial mathematical correction: The original text stated ``$p \geq 3/n^{1/4}$'', which confused the failure probability $q \leq 3/n^{1/4}$ with the success probability $p = 1 - q \geq 1 - 3/n^{1/4}$. A geometric variable with success probability $p$ has mean $\Ex{Y} = 1/p \leq 1/(1 - 3/n^{1/4}) = 1 + O(n^{-1/4})$. Had the success probability been $3/n^{1/4}$, the expected number of rounds would have been $\Omega(n^{1/4})$, ruining the linear running time! Also fixed typo ``runing'' $\to$ ``running''.}
LATEX
content = replace_exact(content, old_rounds, new_rounds, "rounds")

# 17. Doing better tone
old_better = 'using in expectation (only!)'
new_better = 'using in expectation \delX{(only!)}'
content = replace_exact(content, old_better, new_better, "better")

# 18. Theorem 3.3 proof: expectation phrasing, typo, and recurrence remark
old_thm3 = <<~'LATEX'
\begin{proof}
    By \Eqref{q-s-few-rounds},  the expected number of rounds $Y$ performed by the algorithm is $1 + 4/n^{1/4}$. We have that the number of comparisons performed by the algorithm has the recurrence
    \begin{equation*}
        C(n) \leq 1.5Yn + O(n^{3/4} \log n^{3/4}) + C(n^{3/4}).
    \end{equation*}
    Setting $D(n) = \Ex{C(n)}$, and using linearity of expecation on the
    above expression, we have the recurrence
LATEX

new_thm3 = <<~'LATEX'
\begin{proof}
    By \Eqref{q-s-few-rounds},  \chgY{the expected number of rounds $Y$ performed by the algorithm is $1 + 4/n^{1/4}$}{the expected number of rounds is $\Ex{Y} \leq 1 + 4/n^{1/4}$}. We have that the number of comparisons performed by the algorithm has the recurrence
    \begin{equation*}
        C(n) \leq 1.5Yn + O(n^{3/4} \log n^{3/4}) + C(n^{3/4}).
    \end{equation*}
    Setting $D(n) = \Ex{C(n)}$, and using \chgY{linearity of expecation}{linearity of expectation} on the
    above expression, we have the recurrence
LATEX
content = replace_exact(content, old_thm3, new_thm3, "thm3")

# 18b. Clean parenthesis and remark on recurrence vs sorting
old_thm3_end = <<~'LATEX'
        \leq
        1.5n + O(n^{3/4} \log n) + D(n^{3/4} )
        \\&%
        \leq
        1.5n + O(n^{3/4}\log n )
        \tag{by easy but tedious induction}%
        \\&
        =%
        1.5n + o(n).
    \end{align*}
\end{proof}
LATEX

new_thm3_end = <<~'LATEX'
        \leq
        1.5n + O(n^{3/4} \log n) + D(n^{3/4})
        \\&%
        \leq
        1.5n + O(n^{3/4}\log n)
        \tag{by easy but tedious induction}%
        \\&
        =%
        1.5n + o(n).
    \end{align*}
    \remX{Algorithmic remark: In Section~3.2, the algorithm directly sorts $S_m$ in $O(|S_m| \log |S_m|) = O(n^{3/4} \log n)$ comparisons, terminating without recursion. Hence, $\Ex{C(n)} \leq 1.5 n \Ex{Y} + O(n^{3/4} \log n)$, which evaluates directly to $1.5 n + O(n^{3/4} \log n)$ without recurrence. The recurrence $D(n) \leq 1.5 n + O(n^{3/4} \log n) + D(n^{3/4})$ corresponds to the recursive selection formulation of Floyd and Rivest~\cite{fr-etbs-75}.}
\end{proof}
LATEX
content = replace_exact(content, old_thm3_end, new_thm3_end, "thm3_end")

# 19. Add Bibliographical Notes and Funny Stories Section before \ChapterEnd{}
old_chapend = '\ChapterEnd{}'

new_bib_notes = <<~'LATEX'
\section[\texorpdfstring{\newX{Bibliographical notes}}{Bibliographical notes}]{\newX{Bibliographical notes}}

\newX{Chebyshev's inequality has a rich and colorful history. Although universally named after Chebyshev, the inequality was first discovered and published in 1853 by the French statistician Ir{\'e}n{\'e}e-Jules Bienaym{\'e}}~\cite{b-cadld-1853}\newX{ in the context of Laplace's work on least squares. Fourteen years later, Pafnuty Lvovich Chebyshev}~\cite{c-dvm-1867}\newX{ independently rediscovered and published the inequality in 1867 in Liouville's \emph{Journal de Math{\'e}matiques Pures et Appliqu{\'e}es} under the title \emph{Des valeurs moyennes} (``On mean values''). Chebyshev recognized its foundational power and used it to establish the first fully rigorous proof of the Generalized Weak Law of Large Numbers for arbitrary independent random variables with bounded variance. Chebyshev's student Andrei Markov later explicitly acknowledged Bienaym{\'e}'s priority, which is why French literature and careful historical treatises refer to it as the \emph{Bienaym{\'e}-Chebyshev inequality}; see Butzer and Jongmans}~\cite{b-pct-99}\newX{ for a historical survey.}

\newX{The selection problem has equally celebrated roots in computer science. C.~A.~R. Hoare}~\cite{h-a6f-61}\newX{ introduced \textsf{QuickSelect} (published as Algorithm~65, \textsf{Find}) in 1961, which requires an expected $3.38 n$ comparisons to find the median. In 1973, Blum, Floyd, Pratt, Rivest, and Tarjan}~\cite{bfprt-tbs-73}\newX{ presented the first deterministic worst-case linear-time selection algorithm (the ``median-of-medians'' algorithm, taking at most $5.43 n$ comparisons). In 1975, Floyd and Rivest}~\cite{fr-a4s-75,fr-etbs-75}\newX{ introduced the randomized sampling approach analyzed here (Algorithm~489, \textsf{Select}). By drawing a sample of size $o(n)$ and bracketing the desired rank with two pivots derived from Chebyshev's inequality, their algorithm achieves an expected comparison bound of $n + \min(k, n-k) + o(n)$, which evaluates to $1.5 n + o(n)$ comparisons for the median. Comprehensive textbook treatments of selection and moment inequalities can be found in Motwani and Raghavan}~\cite{mr-ra-95}\newX{, Mitzenmacher and Upfal}~\cite{mu-pcrpt-17}\newX{, and Knuth}~\cite{k-acp3-98}\newX{.}

\subsection[\texorpdfstring{\newX{Anecdotes and eccentricities of Chebyshev}}{Anecdotes and eccentricities of Chebyshev}]{\newX{Anecdotes and eccentricities of Chebyshev}}

\newX{Beyond his profound mathematical achievements, Chebyshev was an eccentric, colorful, and beloved figure in 19th-century science. Several delightful stories surround his life and work:}

\begin{compactenumi}
    \medskip
    \item \textbf{\newX{Chebyshev and the Parisian dressmakers.}}
    \newX{In August 1878, Chebyshev gave an invited address in Paris before the \emph{Association Fran{\c c}aise pour l'Avancement des Sciences} entitled \emph{Sur la coupe des v{\^e}tements} (``On the cutting of clothes'')}~\cite{c-scv-1878}\newX{. Word of the title spread through the Parisian fashion district, and the lecture hall was promptly packed with elegant society ladies, tailors, dressmakers, and fashion designers eager to learn practical Parisian cutting tips from a renowned Russian savant. Chebyshev climbed to the rostrum, regarded his impeccably dressed audience, and began his lecture with serene mathematical composure:}
    \begin{quote}
        \itshape
        \newX{``Pour simplifier, mesdames et messieurs, supposons que le corps humain soit une sph{\`e}re\dots''}
        \par\medskip
        \upshape
        \newX{(``To simplify matters, ladies and gentlemen, let us assume that the human body is a sphere\dots'')}
    \end{quote}
    \newX{As the stunned tailors and ladies gasped in dismay, Chebyshev proceeded to compute the Gaussian curvature of surfaces and lay the foundations for what differential geometers today call \emph{Chebyshev nets}---the study of how inextensible fabrics drape and deform over curved surfaces; see Papadopoulos}~\cite{p-cc-14}\newX{.}

    \medskip
    \item \textbf{\newX{The Plantigrade walking machine.}}
    \newX{Chebyshev walked with a severe limp from childhood due to an asymmetrical leg condition. Rather than dampening his spirits, this physical limitation sparked a lifelong fascination with the kinematics of locomotion. He designed the famous \emph{Plantigrade Machine} (стопоходящая машина)---a four-legged walking linkage that transformed continuous circular motion into a rhythmic, animal-like stepping gait without using wheels. Chebyshev transported his wooden walking contraption to Paris for the 1878 Exposition Universelle (World's Fair), where he demonstrated it walking across the exhibition floor to the enormous delight, laughter, and cheers of the Parisian crowds. It is celebrated today as one of the world's earliest mechanical walking robots, and the original device is preserved in the Polytechnic Museum in Moscow.}

    \medskip
    \item \textbf{\newX{Bertrand's postulate and Erd\H{o}s's rhyme.}}
    \newX{In 1845, Joseph Bertrand}~\cite{b-mna-1845}\newX{ conjectured that there is always at least one prime number between $n$ and $2n-2$ for every integer $n > 3$. Chebyshev gave the very first proof of Bertrand's Postulate in 1850}~\cite{c-mdnpp-1852}\newX{, using his ingenious $\theta(x)$ and $\psi(x)$ functions. In 1932, a nineteen-year-old Paul Erd\H{o}s}~\cite{e-bbp-32}\newX{ published a dazzlingly elementary proof using middle binomial coefficients $\binom{2n}{n}$. Erd\H{o}s's proof popularized the famous mathematical doggerel:}
    \begin{quote}
        \itshape
        \newX{Chebyshev said it, and I say it again:}\\
        \newX{There is always a prime between $n$ and $2n$!}
    \end{quote}

    \medskip
    \item \textbf{\newX{The mystery of the missing dots.}}
    \newX{Bibliographers and librarians have long struggled with the myriad Western spellings of Chebyshev's surname: \emph{Chebyshev}, \emph{Chebychev}, \emph{Tchebycheff}, \emph{Tschebyscheff}, and \emph{\v{C}eby\v{s}\"{e}v}. The source of the confusion is typographic: in Russian (\SpellIgnore{Чебышёв}), the letter \emph{ё} is pronounced ``yo''. Because 19th-century Russian printers routinely omitted the diacritical dots, Western scholars mistook the letter for an ordinary \emph{e} (``ye''). In Russian, the stress falls squarely on the final syllable: \emph{Che-by-SHOV}, rhyming with ``shove''. A lighthearted mathematical limerick captures the resulting editorial despair:}
    \begin{quote}
        \itshape
        \newX{There once was a savant named Chebyshev,}\\
        \newX{Whose spelling caused catalogers grief.}\\
        \newX{Though Russians say -shov,}\\
        \newX{We all say -shev,}\\
        \newX{Much to everyone's lasting relief.}
    \end{quote}
\end{compactenumi}

\bigskip

\ChapterEnd{}
LATEX
content = replace_exact(content, old_chapend, new_bib_notes, "chapend")

File.write(dest_file, content)
puts "Successfully created #{dest_file} (#{content.lines.count} lines)"
