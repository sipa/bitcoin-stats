set xdata time
set xlabel "Date"
set ylabel "Average block version"
set y2label "Days left"
set y2tics
set autoscale y2
set timefmt "%s"
# set format x "%b '%y"
set key top left
set xzeroaxis
set grid x y
set title "Block version evolution"
set terminal png large enhanced size 1280,800
set output "ver-2k.png"
plot "ver-2k.dat" using 1:2 with line title "Last 1001 blocks", \
     "ver-2k.dat" using 1:3 with line title "Last 288 blocks", \
     "ver-2k.dat" using 1:(($5)/86400) axes x1y2 with line title "First possible 95% v3"

set terminal png small enhanced size 2560,1440
set output "ver-large-2k.png"
replot

# set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "ver-small-2k.png"
replot
