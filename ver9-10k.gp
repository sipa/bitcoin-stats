set xdata time
set xlabel "Date"
set ylabel "Block percentage"
set timefmt "%s"
# set format x "%b '%y"
set format y "%g %%"
set key bottom left
set xzeroaxis
set grid x y
set title "Block version evolution"
set terminal png large enhanced size 1280,800
set output "ver9-10k.png"
plot "ver9-10k.dat" using 1:($4*100) with line title "SegWit (average over 2016 blocks)", \
     "ver9-10k.dat" using 1:($3*100) with line title "CSV (average over 2016 blocks)", \
     "ver9-10k.dat" using 1:($8*100) with line title "BIP91 (average over 336 blocks)", \
     "ver9-10k.dat" using 1:($7*100) with line title "SegWit (average over 144 blocks)", \
     "ver9-10k.dat" using 1:($6*100) with line title "CSV (average over 144 blocks)", \
     "ver9-10k.dat" using 1:($9*100) with line title "BIP91 (average over 144 blocks)", \

set terminal png small enhanced size 2560,1440
set output "ver9-large-10k.png"
replot

# set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "ver9-small-10k.png"
replot
