set terminal latex

set format '$$%g$$' 
set terminal epslatex standalone color  


set output "cut_func.tex"

f(x)=-(x*log(x) + (1-x)*log(1-x))/log(2)

g(x)=(2/3.14159265358979) * x / (1-cos(x))

#set title "The cut rounding function"
set xlabel "$\\psi$"

set border lw 1
set xrange [0:3.14159265]
set yrange [-1.1:11.1]
set samples 1000
set key spacing 2

plot   [-0.1:] [:11.1] [x=0.0001:3.14159265] 0.87856 with lines lc rgb "blue", \
       g(x) with lines lc rgb "red" t "$\\Bigl.\\frac{2}{\\pi} \\frac{\\psi}{1-\\cos(\\psi)}$"


