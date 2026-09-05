set terminal pdf
set xrange [0:1]
set output "stupid_function.pdf"
f(x)=x-x*x/4
set border lw 1
plot [0:] [:1.1] [x=0.00001:0.99999] \
      f(x) with lines lc rgb "red" t "f(x)=x - x^2/4"

