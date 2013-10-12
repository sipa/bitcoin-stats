set xdata time
set xlabel "Date"
set ylabel "MiB"
set timefmt "%s"
set format x "%b '%y"
set key top left
set title "Bitcoin network: UTXO set pruning"
set terminal png large enhanced size 1280,800
set output "pruning.png"
set ytics nomirror tc lt -1
#set logscale y
set grid x y
plot "pruning.txt" using 2:(($6)/1048576) with line title "All coins", \
     "pruning.txt" using 2:(($5)/1048576) with line title "Unspent coins"

set terminal png large enhanced size 2560,1440
set output "pruning-large.png"
replot

set terminal png small enhanced size 720,480
set output "pruning-small.png"
replot
