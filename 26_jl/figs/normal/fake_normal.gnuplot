set terminal latex
#set term pdfcairo enhanced crop
set format '$$%g$$' 
set terminal epslatex standalone color  
set key spacing 5

set output "fake_normal.tex"


#set title "Some polynomials of degree two, passing through two fixed points"
#set xlabel "x"

set border lw 1
set yrange [0:0.42]

set style line 1 lt 1 lw 4 lc rgb "red"


set style data histogram
set style fill solid border -1
set xtics axis
set ytics border nomirror 0,0.1
set border 3

set size ratio 0.4
     
f(x)=0.398942*exp(-x*x/2)

#       t "$\\frac{1}{\\sqrt{2 \\pi}} \\exp(-x^2/2)$", \
#set label "$\\frac{1}{\\sqrt{2 \\pi}} \\exp(-x^2/2)$" at 0, 0.1

set label  "\\scalebox{1.5}{$\\frac{1}{\\sqrt{2 \\pi}} \\exp(-x^2/2)$}" at 1, 0.35 font "Symbol,48"

plot [x=-4:4] f(x) with filledcurve above x1 lw 1  lt rgb "gray" notitle, \
     [x=-0:1] f(x) with filledcurve above x1 lt rgb "#A4A4FF" notitle, \
     [x=2:3] f(x) with filledcurve above x1 lw 1  lt rgb "#A4A4FF" notitle, \
     [x=-2:-1] f(x) with filledcurve above x1 lw 1  lt rgb "#A4A4FF" notitle, \
     [x=-4:4] f(x) lt rgb "#AA0000" lw 2 notitle 

       

#plot [x=-0.1:1.1] f(x) with filledcurve
#border

