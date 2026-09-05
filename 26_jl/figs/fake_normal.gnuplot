set terminal latex

set format '$$%g$$' 
set terminal epslatex standalone color  
set key spacing 5

set output "fake_normal.tex"


#set title "Some polynomials of degree two, passing through two fixed points"
set xlabel "x"

set border lw 1
set yrange [-0:0.44]

set style line 1 lt 1 lw 4 lc rgb "red"


set style data histogram
set style fill solid border -1

f(x)=0.39894*exp(-x*x/2)


plot [x=-3.1:3.1] f(x)

#above x1 lw 1  lt rgb "gray" \
#       t "$\\frac{1}{\\sqrt{2 \\pi}}  \\exp(-x^2/2)$"

plot [x=-3.1:0] f(x) with filledcurve above x1 lw 1  lt rgb "gray" \
       t "$\\frac{1}{\\sqrt{2 \\pi}}  \\exp(-x^2/2)$"

plot [x=-0:1] f(x) with filledcurve above x1 lw 1  lt rgb "blue" \
  t "$\\frac{1}{\\sqrt{2 \\pi}}  \\exp(-x^2/2)$"

#plot [x=-0.1:1.1] f(x) with filledcurve
#border

