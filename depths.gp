set xlabel "Blocks deep"
set ylabel "# requested"
set grid x y
set log x
set title "Block download frequency vs depth"
set terminal png large enhanced size 1280,800
set output "depth.png"
plot "depth.txt" using 1:2 with line title "Blocks requested"

set terminal png small enhanced size 2560,1440
set output "depth-large.png"
replot

set terminal png small enhanced size 720,480
set output "depth-small.png"
replot
