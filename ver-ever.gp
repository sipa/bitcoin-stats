set xdata time
set xlabel "Date"
set ylabel "Average block version"
set timefmt "%s"
# set format x "%b '%y"
set key bottom right
set xzeroaxis
set grid x y
set title "Block version evolution"
set terminal png large enhanced size 1280,800
set output "ver-ever.png"
plot "ver-ever.dat" using 1:2 with line title "Last 1001 blocks", \
     "ver-ever.dat" using 1:((3951.0/1001)) with line title "BIP65 enforcement", \
     "ver-ever.dat" using 1:((3751.0/1001)) with line title "BIP65 activation", \
     "ver-ever.dat" using 1:((2951.0/1001)) with line title "BIP66 enforcement", \
     "ver-ever.dat" using 1:((2751.0/1001)) with line title "BIP66 activation", \
     "ver-ever.dat" using 1:((1951.0/1001)) with line title "BIP34 enforcement", \
     "ver-ever.dat" using 1:((1751.0/1001)) with line title "BIP34 activation"

set terminal png small enhanced size 2560,1440
set output "ver-large-ever.png"
replot

# set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "ver-small-ever.png"
replot
