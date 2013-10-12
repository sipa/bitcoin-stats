set xdata time
set xlabel "Date"
set ylabel "Ghash/s"
#set logscale y
set timefmt "%s"
set key top left
set title "Bitcoin Pooled Mining: computation speed"
set terminal png large enhanced size 1024,768
set output "graph-bpm.png"
plot "estim-14400.csv" using 1:(($2)/1000000000) with line title "4 hour estimate", \
     "estim-57600.csv" using 1:(($2)/1000000000) with line title "16 hour estimate", \
     "estim-230400.csv" using 1:(($2)/1000000000) with line title "64 hour estimate"
set terminal pdfcairo enhanced color solid linewidth 1 rounded font "sans,3"
set output "graph-bpm.pdf"
replot
