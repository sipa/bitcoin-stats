set logscale y
set xdata time
set xlabel "Date"
set ylabel "hash"
set timefmt "%s"
set format x "%b '%y"
set key top left
set title "Bitcoin network: total hashes performed"
set terminal png large enhanced size 1280,800
set output "hashes.png"
set grid x y
plot "hashes.dat" using 1:3 with line title "Hashes"

set terminal png large enhanced size 2560,1440
set output "hashes-large.png"
replot

set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "hashes-small.png"
replot

unset logscale y
set format x "%b '%y"
set terminal png large enhanced size 1280,800
set output "hashes-lin.png"
replot

set terminal png large enhanced size 2560,1440
set output "hashes-large-lin.png"
replot


set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "hashes-small-lin.png"
replot
