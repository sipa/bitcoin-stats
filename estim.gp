set xdata time
set xlabel "Date"
set ylabel "Ghash/s"
set logscale y
set timefmt "%s"
set key top left
set title "Bitcoin network: computation speed"
set terminal png large enhanced size 1024,768
set output "estim.png"
plot "estim.csv" using 1:(($4)/1000000000) with line title "192-block estimate", \
     "estim.csv" using 1:(($5)/1000000000) with line title "768-block estimate", \
     "estim.csv" using 1:(($6)/1000000000) with line title "3072-block estimate", \
     "estim.csv" using 1:(($2)/1000000000) with line title "Corresponding to difficulty"
set terminal pdfcairo enhanced color solid linewidth 1 rounded font "sans,3"
set output "estim.pdf"
replot
