f(x)=-(x*log(x) + (1-x)*log(1-x))/log(2)

#set title "The entropy function"
#set xlabel "$p$ range"

set border lw 1
set xrange [-0.11:1.1]
#set yrange [:1.5]
set samples 1000


set xtics (0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0)
set xtics axis
set grid xtics  ytics 
set grid layerdefault front 

show xtics
set size 1.25,.75 

plot [-0.1:] [:1.1] [x=0.0001:0.9999] \
     f(x) with filledcurve above x1  lt rgb "gray" t "", \
     f(x) with lines lc rgb "red" t \
          "$\\mathbb{H}(p) = -p \\lg p - (1-p)\\lg(1-p)$"


#plot [x=-0.1:1.1] f(x) with filledcurve
#border

