fact = 139.696254564
min = 0.001
emin = 0.001
set xdata time
set xlabel "Date"
set ylabel "double-SHA256 hashes"
set timefmt "%s"
set format x "%b '%y"
set key top left
set title "Bitcoin network: total computations"
set terminal png large enhanced size 1280,800
set output "work.png"
set ytics nomirror tc lt -1
set logscale y
set mytics 10
set grid x y
plot "diff-50k.dat" using 1:(($3)*1000000000) with line title "work", \
     "diff-50k.dat" using 1:(($4)*1000000000) with line title "standard deviation"

set terminal png large enhanced size 2560,1440
set output "work-large.png"
replot

set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "work-small.png"
replot

unset logscale y
unset mytics
set format x "%b '%y"
set terminal png large enhanced size 1280,800
set output "work-lin.png"
replot

set terminal png large enhanced size 2560,1440
set output "work-large-lin.png"
replot


set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "work-small-lin.png"
replot
