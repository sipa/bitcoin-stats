set xdata time
set xlabel "Date"
set ylabel "Average block version"
set timefmt "%s"
# set format x "%b '%y"
set key bottom left
set xzeroaxis
set grid x y
set title "Block version evolution"
set terminal png large enhanced size 1280,800
set output "ver-50k.png"
plot "ver-50k.dat" using 1:2 with line title "Last 1001 blocks", \
     "ver-50k.dat" using 1:((3951.0/1001)) with line title "BIP65 enforcement", \
     "ver-50k.dat" using 1:((3751.0/1001)) with line title "BIP65 activation", \
     "ver-50k.dat" using 1:((2951.0/1001)) with line title "BIP66 enforcement", \
     "ver-50k.dat" using 1:((2751.0/1001)) with line title "BIP66 activation"

set terminal png small enhanced size 2560,1440
set output "ver-large-50k.png"
replot

# set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "ver-small-50k.png"
replot
