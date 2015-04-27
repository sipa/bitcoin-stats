set xdata time
set xlabel "Date"
set ylabel "Average block version"
set timefmt "%s"
# set format x "%b '%y"
set key top left
set xzeroaxis
set grid x y
set title "Block version evolution"
set terminal png large enhanced size 1280,800
set output "ver-10k.png"
plot "ver-10k.dat" using 1:2 with line title "Last 1001 blocks", \
     "ver-10k.dat" using 1:3 with line title "Last 288 blocks"

set terminal png small enhanced size 2560,1440
set output "ver-large-10k.png"
replot

# set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "ver-small-10k.png"
replot
